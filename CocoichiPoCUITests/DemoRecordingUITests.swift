import XCTest

final class DemoRecordingUITests: XCTestCase {
    @MainActor
    func testStoreSelectToComplete() throws {
        try testCouponComplete()
    }

    @MainActor
    func testOrderFlowNoCoupon() throws {
        continueAfterFailure = false
        let app = launchDemoApp()

        openPorkCurryDetail(app)
        tap(app.buttons["primary_cta_決定する"].firstMatch, description: "決定する")
        tap(app.buttons["primary_cta_注文を確定"].firstMatch, description: "注文を確定", timeout: 6)

        XCTAssertTrue(app.staticTexts["ご注文を受け付けました"].waitForExistence(timeout: 6))
        XCTAssertFalse(app.staticTexts["適用中のクーポン"].exists)
        waitForRecordingBeat(1.4)
    }

    @MainActor
    func testMenuDiscovery() throws {
        continueAfterFailure = false
        let app = launchDemoApp()

        tap(app.tabBars.buttons["メニュー"], description: "メニュータブ")
        waitForRecordingBeat(0.6)
        tap(app.buttons["genre_chip_salad"].firstMatch, description: "サラダカテゴリ")
        tap(app.buttons["genre_chip_drink"].firstMatch, description: "ドリンクカテゴリ")
        tap(app.buttons["genre_chip_curry"].firstMatch, description: "カレーカテゴリ")

        app.swipeUp()
        waitForRecordingBeat(0.7)
        app.swipeUp()
        waitForRecordingBeat(0.9)
        app.swipeDown()
        waitForRecordingBeat(1.2)
    }

    @MainActor
    func testCustomizeNoCoupon() throws {
        continueAfterFailure = false
        let app = launchDemoApp()

        openPorkCurryDetail(app)
        tapFirstHittableButton(in: app, identifier: "rice_increase", description: "ライス増量", allowsScrolling: true)
        tapFirstHittableButton(in: app, identifier: "rice_increase", description: "ライス増量", allowsScrolling: true)
        tapFirstHittableButton(in: app, identifier: "spice_increase", description: "辛さ増加", allowsScrolling: true)
        tapFirstHittableButton(in: app, identifier: "spice_increase", description: "辛さ増加", allowsScrolling: true)
        tapFirstHittableButton(in: app, identifier: "spice_increase", description: "辛さ増加", allowsScrolling: true)

        tap(app.buttons["secondary_cta_トッピング"].firstMatch, description: "トッピングへ進む")
        waitForRecordingBeat(0.7)
        app.swipeUp()
        waitForRecordingBeat(1.3)
    }

    @MainActor
    func testSavedComboNoCoupon() throws {
        continueAfterFailure = false
        let app = launchDemoApp()

        tap(app.tabBars.buttons["メニュー"], description: "メニュータブ")
        tap(app.buttons["favorite_entry"].firstMatch, description: "お気に入りから選ぶ")
        waitForRecordingBeat(0.8)
        tap(app.buttons["選択"].firstMatch, description: "保存済みの組み合わせ")
        tapFirstHittableButton(in: app, identifier: "store_row_nagoya-meieki", description: "名駅広小路店", allowsScrolling: true)

        XCTAssertTrue(app.staticTexts["ロースカツカレー"].waitForExistence(timeout: 6))
        waitForRecordingBeat(1.2)
    }

    @MainActor
    func testCouponComplete() throws {
        continueAfterFailure = false
        let app = launchDemoApp()

        openMenuItemDetail(app, menuItemIdentifier: "menu_item_loin-cutlet-curry", description: "ロースカツカレー")
        tap(app.buttons["primary_cta_決定する"].firstMatch, description: "決定する")
        tap(app.buttons["primary_cta_このクーポンを使う"].firstMatch, description: "このクーポンを使う", timeout: 6)
        tap(app.buttons["primary_cta_注文を確定"].firstMatch, description: "注文を確定", timeout: 6)

        XCTAssertTrue(app.staticTexts["ご注文を受け付けました"].waitForExistence(timeout: 6))
        waitForRecordingBeat(1.4)
    }

    @MainActor
    private func launchDemoApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = ["-demo-recording"]
        app.launch()
        waitForRecordingBeat()
        return app
    }

    @MainActor
    private func openPorkCurryDetail(_ app: XCUIApplication) {
        openMenuItemDetail(app, menuItemIdentifier: "menu_item_pork-curry", description: "ポークカレー")
    }

    @MainActor
    private func openMenuItemDetail(_ app: XCUIApplication, menuItemIdentifier: String, description: String) {
        tap(app.tabBars.buttons["メニュー"], description: "メニュータブ")
        tapFirstHittableButton(in: app, identifier: menuItemIdentifier, description: description, allowsScrolling: true)
        tapFirstHittableButton(in: app, identifier: "store_row_nagoya-meieki", description: "名駅広小路店", allowsScrolling: true)
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
        let query = app.descendants(matching: .any).matching(identifier: identifier)
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
