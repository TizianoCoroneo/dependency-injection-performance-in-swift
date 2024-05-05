
import PackagePlugin

@main
struct NeedlePlugin: BuildToolPlugin {
    func createBuildCommands(
        context: PluginContext,
        target: any Target
    ) async throws -> [Command] {


        [
            .prebuildCommand(
                displayName: "Run Needle code generator",
                executable: try context.tool(named: "needle").path,
                arguments: [
                    "generate",
                    context.pluginWorkDirectory.appending("generated-by-needle.swift"),
                    context.pluginWorkDirectory
                ],
                outputFilesDirectory: context.pluginWorkDirectory)
        ]
    }
}
