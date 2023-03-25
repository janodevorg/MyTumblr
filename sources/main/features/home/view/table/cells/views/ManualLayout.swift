import UIKit

protocol CalculatedManualLayout {
    /// Returns the height of this view when configured with a given item and viewport.
    func height(item: Item, viewport: CGSize) -> CGFloat
}

/// A type able to calculate its own height without being rendered on screen.
protocol ManualLayout {
    /// Returns the height of this view when configured with a given item and viewport.
    static func height(item: Item, viewport: CGSize) -> CGFloat
}
