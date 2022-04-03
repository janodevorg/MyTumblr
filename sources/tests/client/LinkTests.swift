import Dependency
import Foundation
import APIClient
import TumblrNPF
import os
import XCTest
@testable import MyTumblr

final class LinkTests: XCTestCase
{
    override class func setUp() {
        DependencyContainer.register(Logger(subsystem: "dev.jano", category: "mytumblrtests"))
    }

    func testLinkContentRenderingFromJSON() throws {

        let viewport = CGSize(width: 390, height: 798)
        guard
            let item = link(filename: "swift-index-onePost", viewport: viewport),
            let actual = LinkContentRendering.create(item: item, viewport: viewport)
        else {
            XCTFail()
            return
        }
        print("Rendering on \(viewport):\n\t\(actual)")

        /*
         ```
         ┌─────
         │ ┌──────────┐
         │ │  image   │ (16.0, 16.0, 358.0, 179.0)
         │ │  caption │ (16.0, 211.0, 358, 61.0)
         │ └──────────┘
         │ (358.0, 406.0) - intrinsicContentSize
         │
         (390.0, 798.0) - viewport
         ```
         */

        let url = "https://64.media.tumblr.com/cdee51249e4ea401eb2b52b284fe476a/07f58acec1c2fdc5-b8/s540x810/03d8e59da7e576faffdd4fc91a91d60940a43fdc.png"
        XCTAssertEqual(actual.bestMedia.url, URL(string: url)!)
        XCTAssertEqual(actual.bestMedia.size, CGSize(width: 358.0, height: 179.0))
        XCTAssertEqual(actual.captionFrame, CGRect(x: 16.0, y: 211.0, width: 358.0, height: 61.0))
        XCTAssertEqual(actual.captionText, "GitHub - facebook/chisel: Chisel is a collection of LLDB commands to assist debugging iOS apps.")
        XCTAssertEqual(actual.imageFrame, CGRect(x: 16.0, y: 16.0, width: 358.0, height: 179.0))
        XCTAssertEqual(actual.intrinsicContentSize, CGSize(width: 358.0, height: 288.0))
        XCTAssertEqual(actual.viewport, CGSize(width: 390, height: 798))
    }

    func link(filename: String, viewport: CGSize) -> Item? {

        guard
            let tumblrResponse: TumblrResponse<BlogResponse> = decode(filename: filename),
            let blogResponse: BlogResponse = tumblrResponse.response.objectValue,
            let post = blogResponse.posts.first
        else {
            XCTFail("Decoding failed.")
            return nil
        }

        let items: [Item] = PostToViewModelMapper.map(post).filter { item in
            if case .link = item {
                return true
            } else {
                return false
            }
        }
        return items.first
    }
}
