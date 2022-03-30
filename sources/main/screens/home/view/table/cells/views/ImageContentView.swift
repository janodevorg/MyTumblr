import Dependency
import os
import TumblrNPF
import UIKit

/// Displays an image and caption.
final class ImageContentView: UIView, Configurable, Identifiable, ManualLayout
{
    @Dependency var log: Logger

    // vertical margin between image and caption
    private static let margin = CGFloat(16)

    // MARK: - Views

    private lazy var imageView = UIImageView().configure {
        $0.contentMode = .scaleAspectFill
    }

    private let caption = UILabel().configure {
        $0.numberOfLines = 0
    }

    // MARK: - Data

    /// Data used to configure this cell.
    private var item: Item?

    // MARK: - Identifiable

    /// Id refreshed on dequeue.
    /// Used after downloading an image to know if the cell has been recycled.
    private(set) var id = UUID()

    // MARK: - Initialize

    override init(frame: CGRect){
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
        // Don’t nil any other data. All properties are reset on each configure call.
    }

    // MARK: - Configurable

    /**
     Configure the cell.
     - Parameters:
       - item: Data.
       - viewport: Likely `tableView.bounds.size`.
       - updateLayout: Callback after configuration.
    */
    func configure(_ item: Item, viewport: CGSize, updateLayout: @MainActor @escaping () -> Void) {

        guard case .image(let image) = item else {
            log.error("🚨Wrong item type!, expected .image(ImageContent), got \(String(describing: item))")
            return
        }

        guard self.item != item else {
            return // avoid resetting with the same item
        }

        self.item = item

        // set text
        if let text = image.content.altText {
            caption.text = text
            caption.frame = CGRect(x: 0, y: ImageContentView.margin, width: viewport.width, height: .greatestFiniteMagnitude)
            caption.sizeToFit()
        } else {
            caption.text = nil
            caption.frame = CGRect.zero
        }

        // set image
        imageView.image = nil
        imageView.frame = CGRect.zero
        guard let bestMedia = BestMedia(media: image.content.media, viewport: viewport) else {
            return
        }

        let idBefore = id
        Task {
            imageView.ext.setImage(
                url: bestMedia.url,
                options: [
                    .discardUnless(condition: { idBefore == self.id }),
                    .resize(newSize: bestMedia.size),
                    .onSuccess(action: { [weak self] in
                        guard let self = self else { return }
                        self.layout()
                        updateLayout()
                    })
                ]
            )
        }
    }

    // MARK: - UIView

    /// Intrinsic size is image + margin + caption.
    override var intrinsicContentSize: CGSize {
        guard let image = imageView.image else {
            return CGSize.zero
        }
        let height = image.size.height
            + ((caption.text != nil) ? ImageContentView.margin : 0)
            + caption.frame.size.height
        return CGSize(width: image.size.width, height: height)
    }

    // MARK: - ManualLayout

    private func layout() {

        guard let image = imageView.image else {
            /* no content */
            imageView.frame = CGRect.zero
            caption.frame = CGRect.zero
            return
        }

        // layout image
        imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)

        // layout text
        if caption.text != nil {
            let y = image.size.height + ImageContentView.margin
            caption.frame = CGRect(x: 0, y: y, width: image.size.width, height: .greatestFiniteMagnitude)
            caption.sizeToFit()
        } else {
            caption.frame = CGRect.zero
        }

        frame.size = intrinsicContentSize
    }

    // MARK: - ManualLayout

    /// Returns the height of this view when configured with a given item and viewport.
    static func height(item: Item, viewport: CGSize) -> CGFloat {

        var height = CGFloat(0)

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: viewport.width, height: .greatestFiniteMagnitude))
        label.numberOfLines = 0
        label.sizeToFit()
        height += label.frame.size.height

        guard case .image(let image) = item else {
            let log = DependencyContainer.resolve() as Logger
            log.error("🚨Wrong item type!, expected .image(ImageContent), got \(String(describing: item))")
            return height
        }
        guard let bestMedia = BestMedia(media: image.content.media, viewport: viewport) else {
            let log = DependencyContainer.resolve() as Logger
            log.warning("🚨No image found")
            return height
        }
        height += bestMedia.size.height
        return height
    }
}
