import Dependency
import os
import TumblrNPF
import UIKit

/// Information to display link content on screen.
struct LinkContentRendering: MirrorDescripting, Equatable
{
    // image/caption to horizontal and vertical edges
    static let margin = CGFloat(16)

    let bestMedia: BestMedia
    let captionFrame: CGRect
    let captionText: String
    let imageFrame: CGRect
    let intrinsicContentSize: CGSize
    let viewport: CGSize

    private init(
        bestMedia: BestMedia,
        captionFrame: CGRect,
        captionText: String,
        imageFrame: CGRect,
        intrinsicContentSize: CGSize,
        viewport: CGSize
    ) {
        self.bestMedia = bestMedia
        self.captionFrame = captionFrame
        self.captionText = captionText
        self.imageFrame = imageFrame
        self.intrinsicContentSize = intrinsicContentSize
        self.viewport = viewport
    }

    static func create(item: Item, viewport: CGSize) -> LinkContentRendering?
    {
        guard case .link(let linkContent) = item else {
            let log = DependencyContainer.resolve() as Logger
            log.error("Wrong item type!, expected .link(LinkContent), got \(String(describing: item))")
            return nil
        }

        guard let (text, bestMedia) = Self.content(linkContent: linkContent.content, viewport: viewport) else {
            return nil
        }

        let (imageFrame, captionFrame) = frames(caption: text, bestMedia: bestMedia, viewport: viewport)
        return LinkContentRendering(
            bestMedia: bestMedia,
            captionFrame: captionFrame,
            captionText: text,
            imageFrame: imageFrame,
            intrinsicContentSize: CGSize(
                width: viewport.width - Self.margin * 2,
                height: Self.margin + imageFrame.size.height + Self.margin + captionFrame.size.height + Self.margin
            ),
            viewport: viewport
        )
    }

    /// Returns this item’s content.
    /// - Returns: caption text and image, or nil if text or image are missing.
    private static func content(linkContent: LinkContent, viewport: CGSize) -> (String, BestMedia)?
    {
        let newViewport = CGSize(
            width: viewport.width - Self.margin * 2,
            height: viewport.height - Self.margin * 2
        )
        guard
            let text = linkContent.title,
            let poster = linkContent.poster,
            let bestMedia = BestMedia(media: poster, viewport: newViewport),
            !text.isEmpty
        else {
            let log = DependencyContainer.resolve() as Logger
            log.error("""
            Invalid content.
                link.content.title: \(String(describing: linkContent.title))
                link.content.poster: \(String(describing: linkContent.poster))
            """)
            return nil
        }
        return (text, bestMedia)
    }

    /// Returns the frames of image and caption, or nil if content is invalid.
    /// 
    /// Non integer values are always rounded up (using `ceil`).
    ///
    /// - Returns: (image frame, caption frame) or nil if text or image are missing.
    private static func frames(caption: String, bestMedia: BestMedia, viewport: CGSize) -> (CGRect, CGRect) {

        let newViewport = CGSize(
            width: viewport.width - Self.margin * 2,
            height: viewport.height - Self.margin * 2
        )

        let imageFrame = CGRect(
            x: Self.margin,
            y: Self.margin,
            width: bestMedia.size.width,
            height: bestMedia.size.height
        )

        let captionLabel = UILabel()
        captionLabel.frame = CGRect(x: 0, y: 0, width: newViewport.width, height: .greatestFiniteMagnitude)
        captionLabel.text = caption
        captionLabel.numberOfLines = 0
        captionLabel.sizeToFit()
        let captionOrigin = CGPoint(
            x: Self.margin,
            y: imageFrame.origin.y + imageFrame.size.height + Self.margin
        )
        let captionFrame = CGRect(origin: captionOrigin, size: captionLabel.frame.size)

        return (imageFrame.roundCeil(), captionFrame.roundCeil())
    }
}

private extension CGRect {

    func roundCeil() -> CGRect {
        CGRect(
            x: ceil(origin.x),
            y: ceil(origin.y),
            width: ceil(size.width),
            height: ceil(size.height)
        )
    }
}
