import Foundation
import os
import XCTest

extension XCTestCase
{
    func decode<T: Decodable>(filename: String) -> T? {
        guard let url = Bundle.module.url(forResource: filename, withExtension: nil),
            let jsonData = try? Data(contentsOf: url) else {
                XCTFail("Missing \(filename) on Bundle.module: \(Bundle.module)")
                return nil
        }
        do {
            return try JSONDecoder().decode(T.self, from: jsonData)
        } catch {
            let errorMessage = "\(error)"
                .components(separatedBy: ", ")
                .joined(separator: ", \n                   ")
            Logger(subsystem: "dev.jano", category: "apptests").warning("""
                Error decoding. Details follow...
                Source JSON: \(filename)
                Decoded type: \(T.self)
                Error: \(errorMessage)
                JSON contents: \n\(String(decoding: jsonData, as: UTF8.self))
                """)
            return nil
        }
    }
}

