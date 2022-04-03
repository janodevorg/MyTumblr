import Foundation

public struct ProfileResponse: Decodable {

    var profile: ProfileEntity
    var status: String?
    
    enum CodingKeys: String, CodingKey {
        
        case status = "STATUS"
        case profile = "person"
    }
}
