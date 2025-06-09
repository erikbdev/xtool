public struct ProductSchema: Codable, Equatable, Hashable, Sendable {
  /// The name of the target.
  public let name: String
  /// The type of build product this target will output.
  public let targets: [String]
  /// The product bundle identifier. If nil, it will fallback to `organizationId`.`name`
  public let bundleIdentifier: String?
  public let infoPlist: InfoPlist?
  public let entitlements: Entitlements?

  public init(
    name: String,
    targets: [String],
    bundleIdentifier: String? = nil,
    infoPlist: InfoPlist? = nil,
    entitlements: Entitlements? = nil
  ) {
    self.name = name
    self.targets = targets
    self.bundleIdentifier = bundleIdentifier
    self.infoPlist = infoPlist
    self.entitlements = entitlements
    dumpIfNeeded(self)
  }
}

public typealias InfoPlist = [String: String]
public typealias Entitlements = [String: String]