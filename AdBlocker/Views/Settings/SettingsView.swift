import SwiftUI

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var showWhitelist = false

    var body: some View {
        NavigationStack {
            List {
                Section("Filter Categories") {
                    ForEach(FilterCategory.allCases) { category in
                        Toggle(isOn: Binding(
                            get: { appState.settingsStore.isCategoryEnabled(category) },
                            set: { _ in
                                appState.settingsStore.toggleCategory(category)
                                Task { await appState.filterEngine.assembleAndReload() }
                            }
                        )) {
                            Label(category.displayName, systemImage: category.iconName)
                        }
                    }
                }

                Section("Whitelist") {
                    Button {
                        showWhitelist = true
                    } label: {
                        HStack {
                            Label("Whitelisted Domains", systemImage: "list.bullet")
                            Spacer()
                            Text("\(appState.settingsStore.whitelistedDomains.count)")
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(.primary)
                }

                Section("Safari Extension") {
                    SafariActivationGuideView()
                        .listRowInsets(EdgeInsets())
                        .padding()
                }

                Section("About") {
                    LabeledContent("Version", value: "1.0.0")
                    LabeledContent("Active Rules", value: "\(appState.filterEngine.activeRuleCount)")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
            .sheet(isPresented: $showWhitelist) {
                WhitelistView()
                    .environment(appState)
            }
        }
    }
}
