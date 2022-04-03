import UIKit

/**
 Configurable views.
 */
@MainActor
protocol Configurable
{
    /**
     Sets the cell’s data.

     - Parameters:
       - item: View model
       - viewport: Max size where the cell will be shown. Likely `tableView.bounds.size`.
       - updateLayout: Closure executed when configuration is finished.
     */
    func configure(_ item: Item, viewport: CGSize, updateLayout: @MainActor @escaping () -> Void)

    /** Called from the cell’s prepareForReuse(). */
    func prepareForReuse()
}

extension Configurable {
    @MainActor
    func prepareForReuse() {}
}
