import XCTest

final class DemoRecordingUITests: XCTestCase {
    @MainActor
    func testStoreSelectToComplete() throws {
        continueAfterFailure = false
        let app = XCUIApplication()
        app.launchArguments = ["-demo-recording"]
        app.launch()

        waitForRecordingBeat()

        tap(app.tabBars.buttons["メニュー"], description: "メニュータブ")
        tapFirstHittableButton(in: app, identifier: "menu_item_loin-cutlet-curry", description: "ロースカツカレー")

        tapFirstHittableButton(in: app, identifier: "store_row_nagoya-meieki", description: "名駅広小路店", allowsScrolling: true)

        tap(app.buttons["primary_cta_決定する"].firstMatch, description: "決定する")
        tap(app.buttons["primary_cta_このクーポンを使う"].firstMatch, description: "このクーポンを使う", timeout: 6)
        tap(app.buttons["primary_cta_注文を確定"].firstMatch, description: "注文を確定", timeout: 6)

        XCTAssertTrue(app.staticTexts["ご注文を受け付けました"].waitForExistence(timeout: 6))
        waitForRecordingBeat(1.4)
    }

    @MainActor
    private func tap(_ element: XCUIElement, description: String, timeout: TimeInterval = 4) {
        XCTAssertTrue(element.waitForExistence(timeout: timeout), "\(description) が見つかりません")
        XCTAssertTrue(element.isHittable, "\(description) がタップできません")
        element.tap()
        waitForRecordingBeat()
    }

    @MainActor
    private func tapFirstHittableButton(
        in app: XCUIApplication,
        identifier: String,
        description: String,
        timeout: TimeInterval = 5,
        allowsScrolling: Bool = false
    ) {
        let query = app.buttons.matching(identifier: identifier)
        let deadline = Date().addingTimeInterval(timeout)

        while Date() < deadline {
            for index in 0..<query.count {
                let candidate = query.element(boundBy: index)
                if candidate.exists, candidate.isHittable {
                    candidate.tap()
                    waitForRecordingBeat()
                    return
                }
            }

            if allowsScrolling {
                app.swipeUp()
            }

            waitForRecordingBeat(0.35)
        }

        XCTFail("\(description) の表示中ボタンが見つかりません")
    }

    private func waitForRecordingBeat(_ duration: TimeInterval = 0.85) {
        Thread.sleep(forTimeInterval: duration)
    }
}
