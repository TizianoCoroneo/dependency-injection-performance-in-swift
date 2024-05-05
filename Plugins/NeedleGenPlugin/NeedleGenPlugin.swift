//
//  NeedleGenPlugin.swift
//
//
//  Created by Tiziano Coroneo on 05/05/2024.
//

import PackagePlugin

@main
struct NeedleGenPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: any Target
    ) async throws -> [Command] {
        Diagnostics.emit(.remark, "Running Needle generator...")

        return [
            .prebuildCommand(
                displayName: "Needle generator",
                executable: try context.tool(named: "needle").path,
                arguments: [
                    "generate",
                    context.pluginWorkDirectory.appending(subpath: "generated-by-needle.swift"),
                    context.pluginWorkDirectory,
                    "--additional-imports", "import NeedleFoundation"
                ],
                outputFilesDirectory: context.pluginWorkDirectory)
        ]
    }
}
