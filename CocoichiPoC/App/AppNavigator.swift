import SwiftUI

enum AppScreen: Hashable {
    case menuDiscovery
    case curryDetail
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
    // S1 は root に固定し、S2 以降だけを path 管理に乗せると初期画面への復帰が単純になる。
    @Published var path: [AppScreen] = []
    @Published var presentedSheet: AppSheet?

    func showMenuDiscovery() {
        path = [.menuDiscovery]
    }

    func push(_ screen: AppScreen) {
        path.append(screen)
    }

    func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    func popToMenuDiscovery() {
        path = [.menuDiscovery]
    }

    func resetToStoreSelect() {
        path = []
        presentedSheet = nil
    }

    func goToSavedCombosFromCompletion() {
        // 完了画面からは再利用導線を優先するため、S2 を経由した文脈で S4 を開く。
        path = [.menuDiscovery, .savedCombos]
    }

    func showSheet(_ sheet: AppSheet) {
        presentedSheet = sheet
    }

    func dismissSheet() {
        presentedSheet = nil
    }
}
