import Dependency
import os
import TumblrNPF
import UIKit

/**
 Displays an image and caption.
 ```
 ┌──────────┐
 │  image   │  - same margin towards all edges and between image/caption
 │  caption │  - image and caption always have content
 └──────────┘
 ```
 */
final class LinkContentView: UIView, Configurable, Identifiable, ManualLayout
{
    @Dependency var log: Logger

    // MARK: - Views

    private lazy var imageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }

    private let caption = UILabel().configure {
        $0.numberOfLines = 0
    }

    // MARK: - Configured content

    private var item: Item?
    private var viewport: CGSize?
    private var linkContentRendering: LinkContentRendering?

    // MARK: - Identifiable

    /// Id refreshed on dequeue.
    /// Used after downloading an image to know if the cell has been recycled.
    private(set) var id: UUID

    // MARK: - Initialize

    /// Required initializer.
    /// - Parameter frame: Ignored by this cell’s layout.
    override init(frame: CGRect){
        self.id = UUID()
        super.init(frame: frame)
        clipsToBounds = true
        addSubview(imageView)
        addSubview(caption)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func prepareForReuse() {
        id = UUID()
        /* ⚠️ Don’t nil anything else to avoid superfluous layout work.
           Note that configure(..) is already re-setting all content. */
    }

    // MARK: - Configurable

    /// See ``Configurable.configure(_:viewport:updateLayout)``.
    func configure(_ item: Item, viewport: CGSize, updateLayout: @MainActor @escaping () -> Void) {

        // checking for same data re-set
        guard self.item != item || self.viewport != viewport else {
            log.warning("Ignore attempt to reset with same content.")
            return
        }
        self.item = item
        self.viewport = viewport

        // set data and layout
        guard let linkContentRendering = LinkContentRendering.create(item: item, viewport: viewport) else {
            log.error("Couldn’t calculate LinkContentRendering. Ignoring item: \(String(describing: item))")
            return
        }
        self.linkContentRendering = linkContentRendering
        self.imageView.frame = linkContentRendering.imageFrame
        self.caption.frame = linkContentRendering.captionFrame
        self.caption.text = linkContentRendering.captionText
        self.frame.size = linkContentRendering.intrinsicContentSize

        let idBefore = id
        Task {
            imageView.ext.setImage(
                url: linkContentRendering.bestMedia.url,
                options: [
                    .discardUnless(condition: { idBefore == self.id }),
                    .resize(newSize: imageView.frame.size),
                    .onSuccess(action: {
                        // Anything configured with LinkContentRendering doesn’t need this.
                        updateLayout()
                    })
                ]
            )
        }
    }

    // MARK: - ManualLayout

    static func height(item: Item, viewport: CGSize) -> CGFloat {
        LinkContentRendering.create(item: item, viewport: viewport)?.intrinsicContentSize.height ?? 0
    }

    // MARK: - UIView

    override var intrinsicContentSize: CGSize {
        linkContentRendering?.intrinsicContentSize ?? CGSize.zero
    }
}

