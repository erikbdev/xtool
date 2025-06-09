#if canImport(PackageDescription)
import PackageDescription

extension Product {
  public static func iOSApplication(
    name: String,
    targets: [String],
    bundleIdentifier: String? = nil,
    infoPlist: InfoPlist? = nil,
    entitlements: Entitlements? = nil
  ) -> Product {
    _ = ProductSchema(
      name: name, 
      targets: targets,
      bundleIdentifier: bundleIdentifier, 
      infoPlist: infoPlist, 
      entitlements: entitlements
    )
    return Product.executable(name: name, targets: targets)
  }
}
#endif