import Foundation
@testable import AdBlocker

final class MockFilterSource: FilterSourceProviding, @unchecked Sendable {
    var rulesPerCategory: [FilterCategory: [FilterRule]] = [:]
    var errorToThrow: Error?
    var rulesCalled: [FilterCategory] = []

    func rules(for category: FilterCategory) async throws -> [FilterRule] {
        rulesCalled.append(category)
        if let error = errorToThrow {
            throw error
        }
        return rulesPerCategory[category] ?? []
    }

    func allCategories() -> [FilterCategory] {
        FilterCategory.allCases
    }

    static func withDefaultRules() -> MockFilterSource {
        let source = MockFilterSource()
        source.rulesPerCategory = [
            .ads: [
                FilterRule(
                    trigger: FilterRule.Trigger(urlFilter: "doubleclick\\.net"),
                    action: FilterRule.Action(type: "block")
                ),
                FilterRule(
                    trigger: FilterRule.Trigger(urlFilter: "googlesyndication\\.com"),
                    action: FilterRule.Action(type: "block")
                )
            ],
            .trackers: [
                FilterRule(
                    trigger: FilterRule.Trigger(urlFilter: "google-analytics\\.com"),
                    action: FilterRule.Action(type: "block")
                )
            ],
            .social: [
                FilterRule(
                    trigger: FilterRule.Trigger(urlFilter: "facebook\\.com\\/plugins"),
                    action: FilterRule.Action(type: "block")
                )
            ],
            .annoyances: [
                FilterRule(
                    trigger: FilterRule.Trigger(urlFilter: ".*"),
                    action: FilterRule.Action(type: "css-display-none", selector: ".cookie-banner")
                )
            ]
        ]
        return source
    }
}
