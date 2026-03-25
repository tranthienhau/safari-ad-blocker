import SwiftUI

@main
struct AdBlockerApp: App {
    @State private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.settingsStore.onboardingCompleted {
                HomeView()
                    .environment(appState)
            } else {
                OnboardingContainerView()
                    .environment(appState)
            }
        }
    }
}
