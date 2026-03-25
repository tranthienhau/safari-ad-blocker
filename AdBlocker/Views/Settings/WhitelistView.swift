import SwiftUI

struct WhitelistView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.dismiss) private var dismiss
    @State private var newDomain = ""

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        TextField("example.com", text: $newDomain)
                            .textContentType(.URL)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)

                        Button("Add") {
                            appState.settingsStore.addWhitelistDomain(newDomain)
                            newDomain = ""
                            Task { await appState.filterEngine.assembleAndReload() }
                        }
                        .disabled(newDomain.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                } header: {
                    Text("Add Domain")
                } footer: {
                    Text("Whitelisted domains will not have ads or trackers blocked.")
                }

                Section("Whitelisted Domains") {
                    if appState.settingsStore.whitelistedDomains.isEmpty {
                        Text("No domains whitelisted")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(appState.settingsStore.whitelistedDomains) { entry in
                            HStack {
                                Text(entry.domain)
                                Spacer()
                                Text(entry.dateAdded, style: .date)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .onDelete { indexSet in
                            let entries = indexSet.map { appState.settingsStore.whitelistedDomains[$0] }
                            entries.forEach { appState.settingsStore.removeWhitelistDomain($0) }
                            Task { await appState.filterEngine.assembleAndReload() }
                        }
                    }
                }
            }
            .navigationTitle("Whitelist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
