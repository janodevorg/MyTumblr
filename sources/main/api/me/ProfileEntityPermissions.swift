// swiftlint:disable discouraged_optional_boolean
import Foundation

public struct ProfileEntityPermissions: Codable, Equatable {
    
    public var administrator: Bool?
    public var canAccessCalendar: Bool?
    public var canAccessPortfolio: Bool?
    public var canAccessTemplates: Bool?
    public var canAddProjects: Bool?
    public var canManagePeople: Bool?
    public var canManagePortfolio: Bool?
    public var hasAccessToNewProjects: Bool?

    enum CodingKeys: String, CodingKey {
        
        case canManagePeople = "can-manage-people",
        hasAccessToNewProjects = "has-access-to-new-projects",
        canAddProjects = "can-add-projects",
        canManagePortfolio,
        administrator,
        canAccessTemplates = "can-access-templates",
        canAccessPortfolio,
        canAccessCalendar
    }
}
