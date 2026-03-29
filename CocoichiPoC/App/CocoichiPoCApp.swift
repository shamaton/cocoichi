import SwiftUI

@main
struct CocoichiPoCApp: App {
    @StateObject private var navigator = AppNavigator()
    @StateObject private var orderStore = OrderStore()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environmentObject(navigator)
                .environmentObject(orderStore)
        }
    }
}
