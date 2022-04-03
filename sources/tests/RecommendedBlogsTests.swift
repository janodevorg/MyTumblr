import Foundation
import TumblrNPF
import os
import XCTest
@testable import MyTumblr

final class RecommendedBlogsTests: XCTestCase
{
    private let log = Logger(subsystem: "dev.jano", category: "apptests")

    func testTumblr1() throws
    {
        let blogs: TumblrResponse<BlogsPage>? = decode(filename: "tumblr1")
        XCTAssertNotNil(blogs)
    }

    func testTumblr2() throws
    {
        let blogs: TumblrResponse<BlogsPage>? = decode(filename: "tumblr2")
        XCTAssertNotNil(blogs)
    }

    func testTumblr3() throws
    {
        let blogs: TumblrResponse<BlogsPage>? = decode(filename: "tumblr3")
        XCTAssertNotNil(blogs)
    }

//    func testBlogByIdentifier() throws
//    {
//        let blogs: TumblrResponse<BlogsPage>? = decode(filename: "blogByIdentifier.json")
//        XCTAssertNotNil(blogs)
//    }

    func testAPIError() throws
    {
        let blogs: TumblrResponse<[BlogsPage]>? = decode(filename: "APIError")
        XCTAssertNotNil(blogs)
    }
}
