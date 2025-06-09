fileprivate import Foundation

func dumpIfNeeded(_ entity: some Encodable) {
    // guard ProcessInfo.processInfo.environment["XTOOL_DUMP"] != nil else { return }
    guard !ProcessInfo.processInfo.arguments.isEmpty,
          ProcessInfo.processInfo.arguments.contains("--xtool-dump")
    else { return }
    let encoder = JSONEncoder()
    // swiftlint:disable:next force_try
    let data = try! encoder.encode(entity)
    let manifest = String(data: data, encoding: .utf8)!
    print("XTOOL_PRODUCT_START")
    print(manifest)
    print("XTOOL_PRODUCT_END")
}