import XCTest
@testable import AdBlocker

final class ContentBlockerRuleValidationTests: XCTestCase {
    private var source: BundledFilterSource!

    override func setUp() {
        super.setUp()
        source = BundledFilterSource()
    }

    func testAllUrlFiltersAreValidRegex() async throws {
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                do {
                    _ = try NSRegularExpression(pattern: rule.trigger.urlFilter)
                } catch {
                    XCTFail("Rule \(index) in \(category) has invalid url-filter regex: '\(rule.trigger.urlFilter)' - \(error)")
                }
            }
        }
    }

    func testResourceTypesAreFromAllowedSet() async throws {
        let allowedTypes: Set<String> = [
            "document", "image", "style-sheet", "script",
            "font", "raw", "svg-document", "media", "popup"
        ]

        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                guard let types = rule.trigger.resourceType else { continue }
                for type in types {
                    XCTAssertTrue(
                        allowedTypes.contains(type),
                        "Rule \(index) in \(category) has invalid resource-type: '\(type)'"
                    )
                }
            }
        }
    }

    func testLoadTypesAreFromAllowedSet() async throws {
        let allowedTypes: Set<String> = ["first-party", "third-party"]

        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                guard let types = rule.trigger.loadType else { continue }
                for type in types {
                    XCTAssertTrue(
                        allowedTypes.contains(type),
                        "Rule \(index) in \(category) has invalid load-type: '\(type)'"
                    )
                }
            }
        }
    }

    func testIfDomainEntriesStartWithAsterisk() async throws {
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                guard let domains = rule.trigger.ifDomain else { continue }
                for domain in domains {
                    XCTAssertTrue(
                        domain.hasPrefix("*"),
                        "Rule \(index) in \(category) if-domain '\(domain)' must start with '*'"
                    )
                }
            }
        }
    }

    func testUnlessDomainEntriesStartWithAsterisk() async throws {
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                guard let domains = rule.trigger.unlessDomain else { continue }
                for domain in domains {
                    XCTAssertTrue(
                        domain.hasPrefix("*"),
                        "Rule \(index) in \(category) unless-domain '\(domain)' must start with '*'"
                    )
                }
            }
        }
    }

    func testTotalRuleCountUnderSafariLimit() async throws {
        var totalCount = 0
        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            totalCount += rules.count
        }

        XCTAssertLessThan(
            totalCount, 150_000,
            "Total rule count (\(totalCount)) exceeds Safari's 150,000 limit"
        )
    }

    func testAllActionTypesAreValid() async throws {
        let validActionTypes: Set<String> = ["block", "block-cookies", "css-display-none", "ignore-previous-rules", "make-https"]

        for category in FilterCategory.allCases {
            let rules = try await source.rules(for: category)
            for (index, rule) in rules.enumerated() {
                XCTAssertTrue(
                    validActionTypes.contains(rule.action.type),
                    "Rule \(index) in \(category) has invalid action type: '\(rule.action.type)'"
                )
            }
        }
    }
}
