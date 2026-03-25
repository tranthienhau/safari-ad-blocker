import XCTest
@testable import AdBlocker

@MainActor
final class SettingsStoreTests: XCTestCase {
    private var store: SettingsStore!
    private var defaults: UserDefaults!

    override func setUp() async throws {
        defaults = UserDefaults(suiteName: "test.settings.\(UUID().uuidString)")!
        store = SettingsStore(defaults: defaults)
    }

    func testDefaultStateAllCategoriesEnabled() {
        for category in FilterCategory.allCases {
            XCTAssertTrue(
                store.isCategoryEnabled(category),
                "\(category) should be enabled by default"
            )
        }
    }

    func testDefaultStateEmptyWhitelist() {
        XCTAssertTrue(store.whitelistedDomains.isEmpty)
    }

    func testDefaultStateOnboardingNotCompleted() {
        XCTAssertFalse(store.onboardingCompleted)
    }

    func testToggleCategoryPersists() {
        store.toggleCategory(.ads)
        XCTAssertFalse(store.isCategoryEnabled(.ads))

        // Reload from same defaults
        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertFalse(reloaded.isCategoryEnabled(.ads))
    }

    func testToggleCategoryTwiceReenables() {
        store.toggleCategory(.trackers)
        store.toggleCategory(.trackers)
        XCTAssertTrue(store.isCategoryEnabled(.trackers))
    }

    func testAddWhitelistDomainPersists() {
        store.addWhitelistDomain("example.com")
        XCTAssertEqual(store.whitelistedDomains.count, 1)
        XCTAssertEqual(store.whitelistedDomains.first?.domain, "example.com")

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertEqual(reloaded.whitelistedDomains.count, 1)
        XCTAssertEqual(reloaded.whitelistedDomains.first?.domain, "example.com")
    }

    func testRemoveWhitelistDomainPersists() {
        store.addWhitelistDomain("example.com")
        store.addWhitelistDomain("test.org")
        XCTAssertEqual(store.whitelistedDomains.count, 2)

        let entry = store.whitelistedDomains.first!
        store.removeWhitelistDomain(entry)
        XCTAssertEqual(store.whitelistedDomains.count, 1)

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertEqual(reloaded.whitelistedDomains.count, 1)
    }

    func testDuplicateDomainNotAdded() {
        store.addWhitelistDomain("example.com")
        store.addWhitelistDomain("example.com")
        XCTAssertEqual(store.whitelistedDomains.count, 1)
    }

    func testEmptyDomainNotAdded() {
        store.addWhitelistDomain("")
        store.addWhitelistDomain("   ")
        XCTAssertTrue(store.whitelistedDomains.isEmpty)
    }

    func testDomainNormalization() {
        store.addWhitelistDomain("  Example.COM  ")
        XCTAssertEqual(store.whitelistedDomains.first?.domain, "example.com")
    }

    func testOnboardingCompletionPersists() {
        store.onboardingCompleted = true

        let reloaded = SettingsStore(defaults: defaults)
        XCTAssertTrue(reloaded.onboardingCompleted)
    }

    func testInstallDateIsSet() {
        XCTAssertNotNil(store.installDate)
        // Install date should be roughly now
        XCTAssertTrue(abs(store.installDate.timeIntervalSinceNow) < 5)
    }
}
