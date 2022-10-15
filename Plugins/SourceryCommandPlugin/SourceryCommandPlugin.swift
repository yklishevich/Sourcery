import PackagePlugin
import Foundation

@main
struct SourceryCommandPlugin: BuildToolPlugin {
//    private func run(_ sourcery: String, withConfig configFilePath: String, cacheBasePath: String) throws {
//        let sourceryURL = URL(fileURLWithPath: sourcery)
//
//        let process = Process()
//        process.executableURL = sourceryURL
//        process.arguments = [
//            "--config",
//            configFilePath,
//            "--cacheBasePath",
//            cacheBasePath
//        ]
//
//        try process.run()
//        process.waitUntilExit()
//
//        let gracefulExit = process.terminationReason == .exit && process.terminationStatus == 0
//        if !gracefulExit {
//            throw "🛑 The plugin execution failed with reason: \(process.terminationReason.rawValue) and status: \(process.terminationStatus) "
//        }
//    }
    
    func createBuildCommands(context: PluginContext, target: Target) throws -> [Command] {
//    func performCommand(context: PluginContext, arguments: [String]) async throws {
        // Run one per target
//        for target in context.package.targets {
            let configFilePath = target.directory.appending(subpath: ".sourcery.yml").string
        print(context.pluginWorkDirectory)
        print(try? context.tool(named: "SourceryExecutable").path.string)
            guard FileManager.default.fileExists(atPath: configFilePath) else {
                Diagnostics.warning("⚠️ Could not find `.sourcery.yml` for target \(target.name)")
                throw "🛑 Config file does not exist"
            }
            
        return try run(withConfig: configFilePath,
                       cacheBasePath: context.pluginWorkDirectory.string,
                       context: context,
                       target: target)

        
//        }
    }

    func run(withConfig configFilePath: String,
             cacheBasePath: String,
             context: PluginContext,
             target: Target) throws -> [Command] {
//  static func run(using configuration: Path, context: PluginContext, target: Target) throws -> Command {
    [
        Command.prebuildCommand(
            displayName: "Sourcery BuildTool Plugin",
            executable: try context.tool(named: "SourceryExecutable").path,
            arguments: [
                "--config",
                configFilePath,
                "--cacheBasePath",
                cacheBasePath
            ],
            environment: [
                "PROJECT_DIR": context.package.directory,
                "TARGET_NAME": target.name,
                "PRODUCT_MODULE_NAME": target.moduleName,
                "DERIVED_SOURCES_DIR": context.pluginWorkDirectory
            ],
            outputFilesDirectory: context.pluginWorkDirectory
        )
    ]
  }
}

extension Target {
  /// Try to access the underlying `moduleName` property
  /// Falls back to target's name
  var moduleName: String {
    switch self {
    case let target as SourceModuleTarget:
      return target.moduleName
    default:
      return ""
    }
  }
}

extension String: LocalizedError {
    public var errorDescription: String? { return self }
}
