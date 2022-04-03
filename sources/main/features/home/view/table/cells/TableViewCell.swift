import UIKit

typealias TableViewCellView = UIView & Configurable

/**
 Wrapper for cell views.

 The generic view
   - it will be added to the contentView
   - it will be constrained to the edges of the contentView unless it implements ManualLayout
 */
final class TableViewCell<C: TableViewCellView>: UITableViewCell, Identifiable, Configurable
{
    private let cellView = C()

    // MARK: - Initialize

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(cellView)
        layout()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Configurable

    func configure(_ item: Item, viewport: CGSize, updateLayout: @MainActor @escaping () -> Void) {
        cellView.configure(item, viewport: viewport, updateLayout: updateLayout)
    }

    // MARK: - Layout

    /**
     Lays out the generic view unless it implements ManualLayout.

     If the view implements ManualLayout it does nothing.
     Otherwise it is constraint to the edges of the view using AutoLayout.
     This method is called once during initialization.
     */
    private func layout() {
        if cellView is ManualLayout || cellView is CalculatedManualLayout {
            return
        } else {
            cellView.al.pin()
        }
    }
}
