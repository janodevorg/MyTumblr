import Dependency
import os
import TumblrNPF
import UIKit

/// Represents a media object suitable for a particular viewport.
struct BestMedia
{
    @Dependency private var log: Logger

    /// URL of the media object.
    let url: URL

    /// Size of the media object.
    let size: CGSize

    /**
     - Parameters:
       - media: Available media objects.
       - viewport: Size of the view where this image will be displayed.
     */
    init?(media: [MediaObject], viewport: CGSize) {
        guard
            let media = Self.biggestImageSmallerThanViewport(images: media, viewport: viewport),
            let width = media.width,
            let height = media.height
        else {
            return nil
        }
        let originalMediaSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        let newMediaSize = originalMediaSize.resizeToNewWidth(viewport.width)
        self.url = media.url
        self.size = newMediaSize
    }

    /**
     Returns the first image whose dimensions fit inside the given viewport.

     - Parameters:
       - images: Media objects to choose from.
       - viewport: Size of the final image.
     - Returns: Best fitting image for the given viewport.
    */
    private static func biggestImageSmallerThanViewport(images: [MediaObject], viewport: CGSize) -> MediaObject? {

        let scaledViewport = CGSize(
            width: viewport.width * UIScreen.main.scale,
            height: viewport.height * UIScreen.main.scale
        )
        let windowSize = CGSize(
            width: Int(scaledViewport.width),
            height: Int(scaledViewport.height)
        )

        // Returning `first` because images arrive sorted in decreasing size.
        let biggestImageSmallerThanWindow = images.first { media in
            media.size.flatMap { $0 <= windowSize } ?? false
        }

        return biggestImageSmallerThanWindow
    }
}

private extension CGSize
{
    /// Returns `true` if left is equal or smaller than right.
    static func <= (left: CGSize, right: CGSize) -> Bool {
        let delta = 0.001
        return (left.width - right.width) < delta && (left.height - right.height) < delta
    }

    /// Resizes CGSize to new width preserving the aspect ratio.
    func resizeToNewWidth(_ newWidth: CGFloat) -> CGSize {
        let imageRatio = width / height
        let height = newWidth / imageRatio
        return CGSize(width: round(newWidth), height: round(height))
    }
}
