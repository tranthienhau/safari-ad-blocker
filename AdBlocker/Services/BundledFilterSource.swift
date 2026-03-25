import Foundation

struct BundledFilterSource: FilterSourceProviding {
    func rules(for category: FilterCategory) async throws -> [FilterRule] {
        guard let url = Bundle.main.url(
            forResource: category.ruleFileName,
            withExtension: "json"
        ) else {
            throw FilterSourceError.fileNotFound(category.ruleFileName)
        }

        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([FilterRule].self, from: data)
    }

    func allCategories() -> [FilterCategory] {
        FilterCategory.allCases
    }
}

enum FilterSourceError: LocalizedError, Sendable {
    case fileNotFound(String)
    case decodingFailed(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let name):
            "Filter rule file '\(name).json' not found in bundle"
        case .decodingFailed(let detail):
            "Failed to decode filter rules: \(detail)"
        }
    }
}
