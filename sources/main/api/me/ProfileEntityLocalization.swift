// swiftlint:disable discouraged_optional_boolean
import Foundation

public struct ProfileEntityLocalization: Codable, Equatable {
    
    public var dateFormat: String?
    public var dateFormatId: String?
    public var language: String?
    public var languageCode: String?
    public var startOnSunday: Bool?
    public var timeFormat: String?
    public var timeFormatId: String?
    public var timezoneId: String?
    public var timezoneJavaRefCode: String?
    public var timezoneString: String?
    public var timezoneUTCOffsetMins: String?
 
    enum CodingKeys: String, CodingKey {
        
        case timeFormat,
        languageCode,
        language,
        timezoneUTCOffsetMins,
        timezoneId,
        timezoneString = "timezone",
        dateFormatId,
        startOnSunday = "start-on-sunday",
        dateFormat,
        timezoneJavaRefCode,
        timeFormatId
    }
}
