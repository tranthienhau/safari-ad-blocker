import Foundation

protocol FilterSourceProviding: Sendable {
    func rules(for category: FilterCategory) async throws -> [FilterRule]
    func allCategories() -> [FilterCategory]
}
