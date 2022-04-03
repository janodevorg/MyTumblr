import APIClient
import Dependency
import Foundation
import os
import TumblrNPF

final class TumblrAPI: APIClient
{
    @Dependency private var log: Logger
    private static let baseURL = URL(string: "https://www.tumblr.com/api/v2/")! // swiftlint:disable:this force_unwrapping

    init(delegate: APIClientDelegate?) {
        super.init(baseURL: TumblrAPI.baseURL, delegate: delegate)
        self.isStoringDecodingErrors = true
    }

    // MARK: - Endpoints

    /// Returns recommended blogs.
    func blog(identifier: String) async throws -> TumblrResponse<BlogResponse> {
        try await request(
            blog(identifier: identifier)
        )
    }

    /// Returns recommended blogs.
    func recommendedBlogs() async throws -> TumblrResponse<BlogsPage> {
        try await request(
            recommendedBlogsResource()
        )
    }

    /// Returns a specific post.
    func post(blogId: String, postId: String) async throws -> TumblrResponse<Post> {
        try await request(
            postResource(blogId: blogId, postId: postId)
        )
    }

    // MARK: - Resources

    // Defined at https://www.tumblr.com/docs/en/api/v2#posts--retrieve-published-posts
    private func blog(identifier: String) -> Resource<TumblrResponse<BlogResponse>> {
        Resource<TumblrResponse<BlogResponse>>(
            additionalHeaders: HTTPHeader.acceptJSON.value,
            method: HTTPMethod.get,
            path: "blog/\(identifier)/posts",
            queryItems: [
                "limit": "8",
                "npf": "true",
                "reblog_info": "true",
                "include_pinned_posts": "true",
                // note "?followed" prefixed with '?' means 'followed' is requested as optional
                "fields[blogs]": "name,avatar,title,url,uuid,?followed,theme,?primary,?paywall_access,share_likes,can_subscribe,subscribed,ask,?can_submit,?is_blocked_from_primary,?tweet,?admin,ask_page_title,?allow_search_indexing,is_hidden_from_blog_network" // swiftlint:disable:this line_length
            ],
            decode: { data, response in
                try self.parse(data: data, response: response)
            })
    }

    private func recommendedBlogsResource() -> Resource<TumblrResponse<BlogsPage>> {
        Resource<TumblrResponse<BlogsPage>>(
            additionalHeaders: HTTPHeader.acceptJSON.value,
            method: HTTPMethod.get,
            path: "recommended/blogs",
            queryItems: [
                "limit": "8",
                // note "?followed" prefixed with '?' means 'followed' is requested as optional
                "fields[blogs]": "name,title,url,avatar,can_be_followed,?followed,theme"
            ],
            decode: { data, response in
                try self.parse(data: data, response: response)
            })
    }

    private func postResource(blogId: String, postId: String) -> Resource<TumblrResponse<Post>> {
        Resource<TumblrResponse<Post>>(
            additionalHeaders: HTTPHeader.acceptJSON.value,
            method: HTTPMethod.get,
            path: "blog/\(blogId)/posts/\(postId)",
            queryItems: ["post_format": "npf"],
            decode: { data, response in
                try self.parse(data: data, response: response)
            })
    }

    // MARK: - Parse

    /**
     Parse an API response.

     An API response is like a regular HTTP response, except:
       - API responses may contain an API error coded as JSON
       - API responses never return nil data, all responses are coded as JSON.

     Throws:
      - APIClientError.invalidResponseEmpty
      - APIClientError.JSONDecodingFailure
      - APIClientError.other
      - APIClientError.statusErrorAPI
      - APIClientError.statusErrorHTTP
    */
    private func parse<T: Codable>(data: Data?, response: HTTPURLResponse) throws -> TumblrResponse<T> {

        guard let data = data else {
            throw APIClientError.invalidResponseEmpty
        }

        let apiResponse: TumblrResponse<T> = try decode(jsonData: data)

        guard HTTPStatus(code: apiResponse.meta.status)?.isError == false else {
            log.error("\(apiResponse.description)")
            throw APIClientError.statusErrorAPI(response.statusCode)
        }

        guard HTTPStatus(code: response.statusCode)?.isError == false else {
            throw APIClientError.statusErrorHTTP(response.statusCode)
        }

        return apiResponse
    }
}
