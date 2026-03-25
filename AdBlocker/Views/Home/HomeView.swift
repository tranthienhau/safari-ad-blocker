import SwiftUI

struct HomeView: View {
    @Environment(AppState.self) private var appState
    @State private var showSettings = false
    @State private var showStats = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    statusCard
                    quickStatsCard
                    categoryToggles
                }
                .padding()
            }
            .navigationTitle("AdBlocker")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView()
                    .environment(appState)
            }
            .sheet(isPresented: $showStats) {
                StatsView()
                    .environment(appState)
            }
            .task {
                await appState.filterEngine.assembleAndReload()
            }
        }
    }

    private var statusCard: some View {
        VStack(spacing: 12) {
            if !appState.filterEngine.extensionEnabled {
                Image(systemName: "safari")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)

                Text("Enable in Safari")
                    .font(.title2.bold())

                Text("The content blocker extension needs to be activated in Safari settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                SafariActivationGuideView()
                    .padding(.top, 8)

                Button {
                    Task { await appState.filterEngine.assembleAndReload() }
                } label: {
                    Label("Check Again", systemImage: "arrow.clockwise")
                        .font(.subheadline.bold())
                }
                .buttonStyle(.borderedProminent)
                .padding(.top, 4)
            } else {
                Image(systemName: appState.filterEngine.activeRuleCount > 0 ? "shield.checkered" : "shield.slash")
                    .font(.system(size: 48))
                    .foregroundStyle(appState.filterEngine.activeRuleCount > 0 ? .green : .red)

                Text(appState.filterEngine.activeRuleCount > 0 ? "Protection Active" : "Protection Inactive")
                    .font(.title2.bold())
            }

            if appState.filterEngine.isReloading {
                ProgressView()
                    .padding(.top, 4)
            }

            if let error = appState.filterEngine.lastError {
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(24)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var quickStatsCard: some View {
        Button { showStats = true } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Rules")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(appState.filterEngine.activeRuleCount)")
                        .font(.title.bold())
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Est. Blocked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("\(appState.statsService.estimatedBlockedRequests)")
                        .font(.title.bold())
                }

                Image(systemName: "chevron.right")
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var categoryToggles: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Filter Categories")
                .font(.headline)

            ForEach(FilterCategory.allCases) { category in
                HStack {
                    Image(systemName: category.iconName)
                        .foregroundStyle(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading) {
                        Text(category.displayName)
                            .font(.body)
                        Text(category.description)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Toggle("", isOn: Binding(
                        get: { appState.settingsStore.isCategoryEnabled(category) },
                        set: { _ in
                            appState.settingsStore.toggleCategory(category)
                            Task { await appState.filterEngine.assembleAndReload() }
                        }
                    ))
                    .labelsHidden()
                }
                .padding(.vertical, 4)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
