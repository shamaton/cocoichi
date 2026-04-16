import SwiftUI

enum AppTab: Hashable {
    case home
    case menu
    case order
    case rewards
}

enum AppScreen: Hashable {
    case storeSelect
    case curryDetail
    case curryToppings
    case savedCombos
    case orderReview
    case orderComplete
}

enum AppSheet: String, Identifiable {
    case couponSuggestion
    case saveFavorite

    var id: String { rawValue }
}

@MainActor
final class AppNavigator: ObservableObject {
    // PoC では Home を root に置き、注文開始時だけ S1 をゲートとして開く。
    @Published var selectedTab: AppTab = .home
    @Published var path: [AppScreen] = []
    @Published var presentedSheet: AppSheet?
    private var nextTabAfterStoreSelect: AppTab = .menu
    private var nextPathAfterStoreSelect: [AppScreen] = []

    func showMenuDiscovery() {
        selectedTab = .menu
        path = []
    }

    func presentStoreSelect(nextTab: AppTab = .menu, nextPath: [AppScreen] = []) {
        nextTabAfterStoreSelect = nextTab
        nextPathAfterStoreSelect = nextPath
        path = [.storeSelect]
        presentedSheet = nil
    }

    func completeStoreSelection() {
        selectedTab = nextTabAfterStoreSelect
        path = nextPathAfterStoreSelect
    }

    func push(_ screen: AppScreen) {
        path.append(screen)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToCurryDetail() {
        guard let detailIndex = path.lastIndex(of: .curryDetail) else {
            pop()
            return
        }
        path = Array(path.prefix(through: detailIndex))
    }

    func popToCurryToppings() {
        guard let toppingsIndex = path.lastIndex(of: .curryToppings) else {
            popToCurryDetail()
            return
        }
        path = Array(path.prefix(through: toppingsIndex))
    }

    func popToMenuDiscovery() {
        selectedTab = .menu
        path = []
    }

    func resetToStoreSelect() {
        presentStoreSelect()
    }

    func goToSavedCombosFromCompletion() {
        selectedTab = .menu
        path = [.savedCombos]
    }

    func showSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
