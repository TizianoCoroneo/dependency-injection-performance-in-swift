//
//  GenerateProjectBuildPlugin.swift
//
//
//  Created by Tiziano Coroneo on 30/04/2024.
//

import PackagePlugin

@main
struct GenerateProjectBuildPlugin: BuildToolPlugin {

    func createBuildCommands(
        context: PluginContext,
        target: any Target
    ) async throws -> [Command] {
        Diagnostics.emit(.remark, "Generating mock project...")

        guard let target = target.sourceModule else {
            Diagnostics.error("Failed to find source module")
            return []
        }

        guard let inputPath = target.sourceFiles.filter({ $0.path.extension == "spec" }).first?.path
        else {
            Diagnostics.error("Failed to find spec file.")
            return []
        }

        let sourcePath = context.pluginWorkDirectory.appending(inputPath.stem + ".swift")
        let imagePath = context.pluginWorkDirectory.appending(inputPath.stem + ".jpg")

        Diagnostics.emit(.remark, "Input spec path: \(inputPath)")
        Diagnostics.emit(.remark, "Source output path: \(sourcePath)")
        Diagnostics.emit(.remark, "Image output path: \(imagePath)")

        return [
            .buildCommand(
                displayName: "Generating mocks and image from \(inputPath.lastComponent)",
                executable: try context.tool(named: "ProjectGeneratorCommands").path,
                arguments: [
                    "--spec", "\(inputPath)",
                    "--source-out", "\(sourcePath)",
                    "--image-out", "\(imagePath)"
                ],
                inputFiles: [ inputPath ],
                outputFiles: [ sourcePath, imagePath ]
            )
        ]
    }
}
