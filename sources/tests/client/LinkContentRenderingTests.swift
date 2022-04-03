import Dependency
import Foundation
import APIClient
import TumblrNPF
import os
import XCTest
@testable import MyTumblr

final class LinkContentRenderingTests: XCTestCase
{
    override class func setUp() {
        DependencyContainer.register(Logger(subsystem: "dev.jano", category: "mytumblrtests"))
    }

    func testPost1() throws
    {
        let viewport = CGSize(width: 390, height: 798)
        guard
            let item = link(filename: "swift-index-post1", viewport: viewport),
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

    func testPost2() throws
    {
        let viewport = CGSize(width: 390, height: 798)
        guard
            let item = link(filename: "swift-index-post2", viewport: viewport),
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
         │ │  image   │ (16.0, 16.0, 358.0, 358.0)
         │ │  caption │ (16.0, 390.0, 314.0, 21.0)
         │ └──────────┘
         │ (358.0, 427.0) - intrinsicContentSize
         │
         (390.0, 798.0) - viewport
         ```
         */

        let url = "https://64.media.tumblr.com/ae79e83b3b1d06adccb8a97dba372f80/770aa98872082ba8-c3/s540x810/2ed580e16ab3c4e0f91b99de542b284f5d86e164.png"
        XCTAssertEqual(actual.bestMedia.url, URL(string: url)!)
        XCTAssertEqual(actual.bestMedia.size, CGSize(width: 358.0, height: 358.0)) // original is 316x316
        XCTAssertEqual(actual.captionFrame, CGRect(x: 16.0, y: 390.0, width: 314.0, height: 21.0))
        XCTAssertEqual(actual.captionText, "How can I publish on GitHub using Docc?")
        XCTAssertEqual(actual.imageFrame, CGRect(x: 16.0, y: 16.0, width: 358.0, height: 358.0))
        XCTAssertEqual(actual.intrinsicContentSize, CGSize(width: 358.0, height: 427.0))
        XCTAssertEqual(actual.viewport, CGSize(width: 390, height: 798.0))
    }

    func testPostAll() throws
    {
        guard
            let tumblrResponse: TumblrResponse<BlogResponse> = decode(filename: "swift-index-all"),
            let blogResponse: BlogResponse = tumblrResponse.response.objectValue
        else {
            XCTFail("Decoding failed.")
            return
        }

        let viewport = CGSize(width: 390, height: 798)
        let postItems: [[Item]] = blogResponse.posts.map { post in
            let items: [Item] = PostToViewModelMapper.map(post)
            return items
        }
        let heights: [CGFloat] = postItems.flatMap { $0 }
            .filter { item in
                if case .link = item {
                    return true
                } else {
                    return false
                }
            }
            .map { item in
                return LinkContentRendering.create(item: item, viewport: viewport)?.intrinsicContentSize.height
            }
            .compactMap { $0 }

        XCTAssertEqual(heights, [427.0, 257.0, 288.0, 270.0, 308.0, 270.0, 427.0, 427.0])
    }

    private func link(filename: String, viewport: CGSize) -> Item?
    {
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
