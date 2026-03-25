import SwiftUI

struct StatsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(spacing: 16) {
                        Image(systemName: "chart.bar.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.blue)

                        Text("\(appState.statsService.estimatedBlockedRequests)")
                            .font(.system(size: 48, weight: .bold, design: .rounded))

                        Text("Estimated Blocked Requests")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                }

                Section("Details") {
                    LabeledContent("Active Rules", value: "\(appState.statsService.activeRuleCount)")
                    LabeledContent("Categories Enabled", value: "\(appState.settingsStore.enabledCategories.count)")
                    LabeledContent("Whitelisted Domains", value: "\(appState.settingsStore.whitelistedDomains.count)")
                    LabeledContent("Protected Since") {
                        Text(appState.settingsStore.installDate, style: .date)
                    }
                }

                Section {
                    Text("Statistics are estimated based on the number of active filter rules and days of protection. Safari Content Blockers do not provide per-request blocking callbacks.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Statistics")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
