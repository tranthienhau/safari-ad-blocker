import Foundation

struct FilterRule: Codable, Sendable, Equatable {
    let trigger: Trigger
    let action: Action

    struct Trigger: Codable, Sendable, Equatable {
        let urlFilter: String
        var urlFilterIsCaseSensitive: Bool?
        var resourceType: [String]?
        var loadType: [String]?
        var ifDomain: [String]?
        var unlessDomain: [String]?
        var ifTopURL: [String]?
        var unlessTopURL: [String]?

        enum CodingKeys: String, CodingKey {
            case urlFilter = "url-filter"
            case urlFilterIsCaseSensitive = "url-filter-is-case-sensitive"
            case resourceType = "resource-type"
            case loadType = "load-type"
            case ifDomain = "if-domain"
            case unlessDomain = "unless-domain"
            case ifTopURL = "if-top-url"
            case unlessTopURL = "unless-top-url"
        }
    }

    struct Action: Codable, Sendable, Equatable {
        let type: String
        var selector: String?
    }
}
