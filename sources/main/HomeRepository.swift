import Coordinator
import CoreDataStack
import Dependency
import Foundation
import Keychain
import os
@preconcurrency import TumblrNPF
@preconcurrency import TumblrNPFPersistence

struct HomeRepository
{
    @Dependency private var log: Logger
    @Dependency private var persistence: PersistentContainer
    @Dependency private var tumblrClient: TumblrAPI

    func hardcodedBlog(identifier: String) async throws -> [Post]
    {
        #warning("testing")
        let url = Bundle.module.url(forResource: identifier, withExtension: nil)! // swiftlint:disable:this force_unwrapping
        let data = try Data(contentsOf: url)

        // save API to database
        let tumblrResponse: TumblrResponse<BlogResponse> = try TumblrResponse<BlogResponse>.decode(json: data)! // swiftlint:disable:this force_unwrapping
        let response: BlogResponse? = tumblrResponse.response.objectValue
        guard let blog = response?.blog.setting(posts: response?.posts ?? []), let uuid = blog.uuid else {
            return []
        }

        #warning("Saving a graph with multiple references to the new blog requires creating the blog first")
        // try await persistence.save(model: [Blog(uuid: uuid)])
        try await persistence.save(model: [blog])

        // read from database
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let blogMOs: [BlogMO] = try await persistence.read(predicate: predicate)

        // map to sections
        let storedBlogs = blogMOs.compactMap { Blog(mo: $0) }
        let posts: [[Post]] = storedBlogs.compactMap { $0.posts }
        return Array(posts.joined())
    }

    func blog(identifier: String) async throws -> [Post] {

        // save API to database
        let tumblrResponse: TumblrResponse<BlogResponse> = try await self.tumblrClient.blog(identifier: identifier)
        let response: BlogResponse? = tumblrResponse.response.objectValue
        guard let blog = response?.blog.setting(posts: response?.posts ?? []), let uuid = blog.uuid else {
            return []
        }

        try await persistence.save(model: [blog])

        // read from database
        let predicate = NSPredicate(format: "uuid == %@", uuid)
        let blogMOs: [BlogMO] = try await persistence.read(predicate: predicate)

        // map to sections
        let storedBlogs = blogMOs.compactMap { Blog(mo: $0) }
        let posts: [[Post]] = storedBlogs.compactMap { $0.posts }
        return Array(posts.joined())
    }

    func recommendedBlogs() async throws -> [Post] {

        // save API to database
        let recommended: TumblrResponse<BlogsPage> = try await self.tumblrClient.recommendedBlogs()
        if let blogs: BlogsPage = recommended.response.objectValue {
            try await persistence.save(model: blogs.blogs)
        }

        // read from database
        let blogMOs: [BlogMO] = try await persistence.read()

        // map to sections
        let storedBlogs = blogMOs.compactMap { Blog(mo: $0) }
        let posts: [[Post]] = storedBlogs.compactMap { $0.posts }
        return Array(posts.joined())
    }

    func specificPost(blogId: String, postId: String) async throws -> Post? {
        let postResponse: TumblrResponse<Post> = try await self.tumblrClient.post(blogId: blogId, postId: postId)
        return postResponse.response.objectValue
    }
}
