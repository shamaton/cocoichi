import SwiftUI

struct StoreSelectView: View {
    @EnvironmentObject private var navigator: AppNavigator
    @EnvironmentObject private var orderStore: OrderStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: POCSpacing.l) {
                HeroBanner(
                    eyebrow: "Welcome",
                    title: "今日は何にする？",
                    accent: [POCColor.curry, POCColor.red]
                )

                SectionHeader("Pickup Store")

                VStack(spacing: POCSpacing.m) {
                    ForEach(orderStore.stores) { store in
                        Button {
                            orderStore.selectStore(store)
                            navigator.completeStoreSelection()
                        } label: {
                            VStack(alignment: .leading, spacing: POCSpacing.s) {
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: POCSpacing.xs) {
                                        Text(store.name)
                                            .font(.headline.weight(.semibold))
                                        Text(store.neighborhood)
                                            .font(.subheadline)
                                            .foregroundStyle(POCColor.textSecondary)
                                    }

                                    Spacer()

                                    VStack(alignment: .trailing, spacing: POCSpacing.xs) {
                                        Text("受取")
                                            .font(.caption.weight(.medium))
                                            .foregroundStyle(POCColor.textTertiary)
                                        Text(store.pickupLeadTimeText)
                                            .font(.headline.weight(.semibold))
                                            .foregroundStyle(POCColor.curry)
                                    }
                                }

                                Text(store.address)
                                    .font(.caption)
                                    .foregroundStyle(POCColor.textSecondary)

                                HStack {
                                    Text("この店舗で始める")
                                        .font(.subheadline.weight(.semibold))
                                    Spacer()
                                    Image(systemName: "arrow.right")
                                        .font(.footnote.weight(.bold))
                                }
                                .foregroundStyle(POCColor.curry)
                            }
                            .padding(POCSpacing.m)
                            .pocCard(fill: POCColor.elevated)
                        }
                        .buttonStyle(.plain)
                    }
                }

                SectionHeader("Saved Combos")

                if orderStore.favoriteCombos.isEmpty {
                    EmptyStateCard(
                        title: "保存済みの組み合わせはまだありません",
                        message: "商品を選んだ後に Save Combo から追加できます。"
                    )
                } else {
                    SecondaryCTAButton(title: "保存済みから始める", systemImage: "clock.arrow.trianglehead.counterclockwise") {
                        navigator.push(.savedCombos)
                    }
                }
            }
            .padding(POCSpacing.l)
        }
        .navigationTitle("受取先を選ぶ")
        .navigationBarTitleDisplayMode(.inline)
    }
}
