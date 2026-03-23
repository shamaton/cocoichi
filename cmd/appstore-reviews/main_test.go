package main

import (
	"encoding/json"
	"testing"
)

func TestBuildReviewsURL(t *testing.T) {
	t.Parallel()

	got := buildReviewsURL("jp", 3, "611124786", "mostrecent")
	want := "https://itunes.apple.com/jp/rss/customerreviews/page=3/id=611124786/sortby=mostrecent/json"
	if got != want {
		t.Fatalf("buildReviewsURL() = %q, want %q", got, want)
	}
}

func TestDecodeReviewsSkipsAppMetadata(t *testing.T) {
	t.Parallel()

	raw := json.RawMessage(`[
	  {
	    "id": {"label": "611124786"},
	    "title": {"label": "CoCoICHI"},
	    "content": {"label": "app metadata"}
	  },
	  {
	    "id": {"label": "review-1"},
	    "author": {
	      "name": {"label": "tester"},
	      "uri": {"label": "https://example.com/users/tester"}
	    },
	    "title": {"label": "Great app"},
	    "content": {"label": "Fast and stable"},
	    "im:rating": {"label": "5"},
	    "im:version": {"label": "2.3.0"},
	    "im:voteCount": {"label": "7"},
	    "im:voteSum": {"label": "6"},
	    "updated": {"label": "2026-03-23T09:00:00-07:00"}
	  }
	]`)

	reviews, err := decodeReviews(raw, "611124786", 1, "https://itunes.apple.com/jp/rss/customerreviews/page=1/id=611124786/sortby=mostrecent/json")
	if err != nil {
		t.Fatalf("decodeReviews() error = %v", err)
	}
	if len(reviews) != 1 {
		t.Fatalf("len(reviews) = %d, want 1", len(reviews))
	}

	got := reviews[0]
	if got.ReviewID != "review-1" {
		t.Fatalf("ReviewID = %q, want review-1", got.ReviewID)
	}
	if got.Rating != 5 {
		t.Fatalf("Rating = %d, want 5", got.Rating)
	}
	if got.Page != 1 {
		t.Fatalf("Page = %d, want 1", got.Page)
	}
}

func TestDecodeReviewsSupportsSingleEntryObject(t *testing.T) {
	t.Parallel()

	raw := json.RawMessage(`{
	  "id": {"label": "review-2"},
	  "author": {
	    "name": {"label": "solo-user"},
	    "uri": {"label": "https://example.com/users/solo-user"}
	  },
	  "title": {"label": "Solid"},
	  "content": {"label": "Works well"},
	  "im:rating": {"label": "4"},
	  "im:version": {"label": "2.3.1"},
	  "updated": {"label": "2026-03-23T10:00:00-07:00"}
	}`)

	reviews, err := decodeReviews(raw, "611124786", 2, "https://itunes.apple.com/jp/rss/customerreviews/page=2/id=611124786/sortby=mostrecent/json")
	if err != nil {
		t.Fatalf("decodeReviews() error = %v", err)
	}
	if len(reviews) != 1 {
		t.Fatalf("len(reviews) = %d, want 1", len(reviews))
	}
	if reviews[0].Author != "solo-user" {
		t.Fatalf("Author = %q, want solo-user", reviews[0].Author)
	}
}
