package main

import (
	"context"
	"encoding/json"
	"errors"
	"flag"
	"fmt"
	"net/http"
	"net/url"
	"os"
	"strconv"
	"strings"
	"time"
)

const defaultTimeout = 15 * time.Second

type labelValue struct {
	Label string `json:"label"`
}

type author struct {
	Name labelValue `json:"name"`
	URI  labelValue `json:"uri"`
}

type content struct {
	Label string `json:"label"`
	Type  string `json:"type"`
}

type feedEntry struct {
	ID        labelValue `json:"id"`
	Author    author     `json:"author"`
	Title     labelValue `json:"title"`
	Content   content    `json:"content"`
	Rating    labelValue `json:"im:rating"`
	Version   labelValue `json:"im:version"`
	VoteCount labelValue `json:"im:voteCount"`
	VoteSum   labelValue `json:"im:voteSum"`
	Updated   labelValue `json:"updated"`
}

type feedResponse struct {
	Feed struct {
		Entry json.RawMessage `json:"entry"`
	} `json:"feed"`
}

type review struct {
	AppID     string `json:"app_id"`
	Page      int    `json:"page"`
	ReviewID  string `json:"review_id,omitempty"`
	Author    string `json:"author,omitempty"`
	AuthorURL string `json:"author_url,omitempty"`
	Title     string `json:"title"`
	Content   string `json:"content"`
	Rating    int    `json:"rating"`
	Version   string `json:"version,omitempty"`
	VoteCount int    `json:"vote_count,omitempty"`
	VoteSum   int    `json:"vote_sum,omitempty"`
	UpdatedAt string `json:"updated_at,omitempty"`
	SourceURL string `json:"source_url"`
}

type output struct {
	AppID     string   `json:"app_id"`
	Country   string   `json:"country"`
	SortBy    string   `json:"sort_by"`
	StartPage int      `json:"start_page"`
	Pages     int      `json:"pages"`
	Reviews   []review `json:"reviews"`
}

func main() {
	appID := flag.String("id", "", "App Store app id")
	page := flag.Int("page", 1, "Start page to fetch")
	pages := flag.Int("pages", 1, "Number of pages to fetch")
	country := flag.String("country", "jp", "Store country code")
	sortBy := flag.String("sort", "mostrecent", "Feed sort order")
	timeout := flag.Duration("timeout", defaultTimeout, "HTTP timeout")
	flag.Parse()

	if err := validateFlags(*appID, *page, *pages); err != nil {
		fmt.Fprintln(os.Stderr, err)
		os.Exit(1)
	}

	client := &http.Client{Timeout: *timeout}
	reviews := make([]review, 0)

	for currentPage := *page; currentPage < *page+*pages; currentPage++ {
		sourceURL := buildReviewsURL(*country, currentPage, *appID, *sortBy)
		pageReviews, err := fetchReviews(context.Background(), client, sourceURL, *appID, currentPage)
		if err != nil {
			fmt.Fprintf(os.Stderr, "fetch page %d: %v\n", currentPage, err)
			os.Exit(1)
		}

		reviews = append(reviews, pageReviews...)
	}

	result := output{
		AppID:     *appID,
		Country:   *country,
		SortBy:    *sortBy,
		StartPage: *page,
		Pages:     *pages,
		Reviews:   reviews,
	}

	encoder := json.NewEncoder(os.Stdout)
	encoder.SetIndent("", "  ")
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(result); err != nil {
		fmt.Fprintf(os.Stderr, "encode output: %v\n", err)
		os.Exit(1)
	}
}

func validateFlags(appID string, page, pages int) error {
	if strings.TrimSpace(appID) == "" {
		return errors.New("-id is required")
	}
	if page < 1 {
		return errors.New("-page must be 1 or greater")
	}
	if pages < 1 {
		return errors.New("-pages must be 1 or greater")
	}
	return nil
}

func buildReviewsURL(country string, page int, appID, sortBy string) string {
	u := url.URL{
		Scheme: "https",
		Host:   "itunes.apple.com",
		Path:   fmt.Sprintf("/%s/rss/customerreviews/page=%d/id=%s/sortby=%s/json", country, page, appID, sortBy),
	}
	return u.String()
}

func fetchReviews(ctx context.Context, client *http.Client, sourceURL, appID string, page int) ([]review, error) {
	req, err := http.NewRequestWithContext(ctx, http.MethodGet, sourceURL, nil)
	if err != nil {
		return nil, err
	}
	req.Header.Set("User-Agent", "cocoichi-appstore-review-fetcher/1.0")
	req.Header.Set("Accept", "application/json")

	resp, err := client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("unexpected status %s", resp.Status)
	}

	var payload feedResponse
	if err := json.NewDecoder(resp.Body).Decode(&payload); err != nil {
		return nil, err
	}

	return decodeReviews(payload.Feed.Entry, appID, page, sourceURL)
}

func decodeReviews(raw json.RawMessage, appID string, page int, sourceURL string) ([]review, error) {
	entries, err := parseEntries(raw)
	if err != nil {
		return nil, err
	}

	reviews := make([]review, 0, len(entries))
	for _, entry := range entries {
		if strings.TrimSpace(entry.Rating.Label) == "" {
			continue
		}

		reviews = append(reviews, review{
			AppID:     appID,
			Page:      page,
			ReviewID:  entry.ID.Label,
			Author:    entry.Author.Name.Label,
			AuthorURL: entry.Author.URI.Label,
			Title:     entry.Title.Label,
			Content:   entry.Content.Label,
			Rating:    atoi(entry.Rating.Label),
			Version:   entry.Version.Label,
			VoteCount: atoi(entry.VoteCount.Label),
			VoteSum:   atoi(entry.VoteSum.Label),
			UpdatedAt: entry.Updated.Label,
			SourceURL: sourceURL,
		})
	}

	return reviews, nil
}

func parseEntries(raw json.RawMessage) ([]feedEntry, error) {
	trimmed := strings.TrimSpace(string(raw))
	if trimmed == "" || trimmed == "null" {
		return nil, nil
	}

	switch trimmed[0] {
	case '[':
		var entries []feedEntry
		if err := json.Unmarshal(raw, &entries); err != nil {
			return nil, err
		}
		return entries, nil
	case '{':
		var entry feedEntry
		if err := json.Unmarshal(raw, &entry); err != nil {
			return nil, err
		}
		return []feedEntry{entry}, nil
	default:
		return nil, fmt.Errorf("unsupported entry payload: %s", trimmed[:1])
	}
}

func atoi(v string) int {
	n, err := strconv.Atoi(strings.TrimSpace(v))
	if err != nil {
		return 0
	}
	return n
}
