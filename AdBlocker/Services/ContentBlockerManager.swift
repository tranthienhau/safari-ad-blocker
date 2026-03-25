import SafariServices

struct ContentBlockerManager: Sendable {
    func reloadContentBlocker() async throws {
        try await SFContentBlockerManager.reloadContentBlocker(
            withIdentifier: AppConstants.contentBlockerBundleIdentifier
        )
    }

    func getStateOfContentBlocker() async throws -> SFContentBlockerState {
        try await SFContentBlockerManager.stateOfContentBlocker(
            withIdentifier: AppConstants.contentBlockerBundleIdentifier
        )
    }
}
