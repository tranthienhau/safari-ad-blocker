import SwiftUI

struct OnboardingContainerView: View {
    @Environment(AppState.self) private var appState
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingWelcomeView(onNext: { currentPage = 1 })
                .tag(0)

            OnboardingHowItWorksView(onNext: { currentPage = 2 })
                .tag(1)

            OnboardingActivateView(onFinish: {
                appState.settingsStore.onboardingCompleted = true
                Task {
                    await appState.filterEngine.assembleAndReload()
                }
            })
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}
