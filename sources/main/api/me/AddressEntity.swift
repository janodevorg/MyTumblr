import Foundation

public struct AddressEntity: Codable, Equatable, Hashable {
    
    public var firstLine: String?
    public var secondLine: String?
    public var postalCode: String?
    public var city: String?
    public var state: String?
    public var country: String?
    public var countryCode: String?
    
    enum CodingKeys: String, CodingKey {
        
        case firstLine = "line1"
        case secondLine = "line2"
        case postalCode = "zipcode"
        case city = "city"
        case state = "state"
        case country = "country"
        case countryCode = "countrycode"
    }
} 
