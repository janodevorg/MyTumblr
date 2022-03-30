import Foundation

private class BundleFinder {}

extension Foundation.Bundle {

    /// Returns the resource bundle associated with the current Swift module.
    static var module: Bundle = {
        let module = "MyTumblr"
        let bundleName = "\(module)_\(module)"
        let candidates = [
        
            // linked to app
            Bundle.main.resourceURL,
            
            // linked to command-line tool
            Bundle.main.bundleURL,
            
            // linked to framework
            Bundle(for: BundleFinder.self).resourceURL
        ]
        // main bundle plus dynamically generated bundles
        + Bundle.allBundles.map { $0.bundleURL }

        let bundle = candidates
            .compactMap { $0?.appendingPathComponent(bundleName + ".bundle") }
            .compactMap(Bundle.init(url:))
            .first

        guard let foundBundle = bundle else {
            fatalError("unable to find bundle named \(bundleName)")
        }

        print("Found bundle at \(foundBundle.bundleURL)")
        return foundBundle
    }()
}
