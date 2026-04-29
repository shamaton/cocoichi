import SwiftUI

enum AppTab: Hashable {
    case home
    case menu
    case order
    case rewards
}

enum AppScreen: Hashable {
    case storeSelect
    case menuDiscovery
    case curryDetail
    case curryToppings
    case savedCombos
    case orderReview
    case orderComplete
}

enum AppCover: String, Identifiable {
    case storeSelect

    var id: String { rawValue }
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
    @Published var presentedCover: AppCover?
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
        presentedCover = .storeSelect
        presentedSheet = nil
    }

    func pushStoreSelectForMenuSelection() {
        selectedTab = .menu
        path = [.storeSelect]
        presentedCover = nil
        presentedSheet = nil
    }

    func completeStoreSelection(pathOverride: [AppScreen]? = nil) {
        selectedTab = nextTabAfterStoreSelect
        path = pathOverride ?? nextPathAfterStoreSelect
        presentedCover = nil
    }

    func completeStackStoreSelection(pathAfterStoreSelect: [AppScreen]) {
        selectedTab = .menu
        if let storeSelectIndex = path.lastIndex(of: .storeSelect) {
            let prefix = path.prefix(through: storeSelectIndex)
            path = Array(prefix) + pathAfterStoreSelect
        } else {
            path = pathAfterStoreSelect
        }
        presentedCover = nil
    }

    func dismissStoreSelect() {
        if presentedCover == nil, path.last == .storeSelect {
            pop()
            return
        }
        presentedCover = nil
    }

    var isStoreSelectInStack: Bool {
        path.contains(.storeSelect)
    }

    func popToStoreSelectInStack() {
        guard let storeSelectIndex = path.lastIndex(of: .storeSelect) else { return }
        path = Array(path.prefix(through: storeSelectIndex))
    }

    func push(_ screen: AppScreen) {
        path.append(screen)
    }

    func showCurryDetail() {
        selectedTab = .menu
        path = [.curryDetail]
    }

    func showCurryToppings() {
        selectedTab = .menu
        path = [.curryDetail, .curryToppings]
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
