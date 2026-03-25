import Foundation

@MainActor
@Observable
final class AppState {
    let settingsStore: SettingsStore
    let filterEngine: FilterEngine
    let statsService: StatsService

    init() {
        let settings = SettingsStore()
        self.settingsStore = settings
        self.filterEngine = FilterEngine(settingsStore: settings)
        self.statsService = StatsService(settingsStore: settings, filterEngine: filterEngine)
    }
}
