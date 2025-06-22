import PackageDescription

extension Product {
  public typealias InfoPlist = [String: String]
  public typealias Entitlements = [String: String]
  
  @available(_PackageDescription 6.0)
  public static func iOSApplication(
    name: String,
    targets: [String],
    bundleIdentifier: String? = nil,
    infoPlist: InfoPlist? = nil,
    entitlements: Entitlements? = nil,
    extensions: [String] = []
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

  @available(_PackageDescription 6.0)
  public static func appExtension(
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