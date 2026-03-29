import SwiftUI

struct AppRootView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        NavigationStack(
            path: Binding(
                get: { navigator.path },
                set: { navigator.path = $0 }
            )
        ) {
            StoreSelectView()
                .navigationDestination(for: AppScreen.self) { screen in
                    destination(for: screen)
                }
        }
        .sheet(item: Binding(
            get: { navigator.presentedSheet },
            set: { navigator.presentedSheet = $0 }
        )) { sheet in
            sheetView(for: sheet)
                .presentationDetents(sheet == .couponSuggestion ? [.medium, .large] : [.medium])
                .presentationDragIndicator(.visible)
        }
        .pocBackground()
    }

    @ViewBuilder
    private func destination(for screen: AppScreen) -> some View {
        switch screen {
        case .menuDiscovery:
            MenuDiscoveryView()
        case .curryDetail:
            CurryDetailView()
        case .savedCombos:
            SavedCombosView()
        case .orderReview:
            OrderReviewView()
        case .orderComplete:
            OrderCompleteView()
        }
    }

    @ViewBuilder
    private func sheetView(for sheet: AppSheet) -> some View {
        switch sheet {
        case .couponSuggestion:
            CouponSuggestionSheet()
        case .saveFavorite:
            SaveFavoriteSheet()
        }
    }
}
