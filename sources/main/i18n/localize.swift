import Foundation

// swiftlint:disable nslocalizedstring_key
func localize(_ key: LocalizationKey) -> String {
    NSLocalizedString(
        key.rawValue,
        tableName: nil,
        bundle: Bundle.module,
        value: "missing.translation",
        comment: ""
    )
}
