import PackageDescription

struct ProductSchema: Codable, Equatable, Hashable, Sendable {
  let name: String
  let targets: [String]
  let bundleIdentifier: String?
  let infoPlist: PackageDescription.Product.InfoPlist?
  let entitlements: PackageDescription.Product.Entitlements?

  @discardableResult
  init(
    name: String,
    targets: [String],
    bundleIdentifier: String? = nil,
    infoPlist: PackageDescription.Product.InfoPlist? = nil,
    entitlements: PackageDescription.Product.Entitlements? = nil
  ) {
    self.name = name
    self.targets = targets
    self.bundleIdentifier = bundleIdentifier
    self.infoPlist = infoPlist
    self.entitlements = entitlements
    dumpIfNeeded(self)
  }
}