import Foundation
import os
import XCTest

extension XCTestCase
{
    func decode<T: Decodable>(filename: String, ext: String = "json") -> T?
    {
        let bundle = Bundle.module
        guard let url = bundle.url(forResource: filename, withExtension: ext),
            let jsonData = try? Data(contentsOf: url) else {
            XCTFail("Missing \"\(filename).\(ext)\" on bundle: \(bundle.bundlePath)")
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

