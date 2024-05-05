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

        let libraries = [
            "simple",
            "swinject",
            "factory",
            "swift-dependencies",
            "cleanse",
            "needle",
            "carpenter",
        ]
        
        let paths = libraries.map { context.pluginWorkDirectory.appending(inputPath.stem + "-\($0).swift") }
        let imagePath = context.pluginWorkDirectory.appending(inputPath.stem + ".jpg")

        let arguments = [
            "--spec", "\(inputPath)",
            "--image-out", "\(imagePath)",
        ] + zip(libraries, paths).flatMap { [ "--\($0)-out", "\($1)" ] }

        let outputFiles = [
            imagePath
        ] + paths

        print("Path: \(context.pluginWorkDirectory)")

        return [
            .buildCommand(
                displayName: "Generating mocks project from \(inputPath.lastComponent)",
                executable: try context.tool(named: "ProjectGeneratorCommands").path,
                arguments: arguments,
                inputFiles: [ inputPath ],
                outputFiles: outputFiles),
            
            .buildCommand(
                displayName: "Needle generator",
                executable: try context.tool(named: "needle").path,
                arguments: [
                    "generate",
                    context.pluginWorkDirectory.appending(subpath: "generated-by-needle.swift"),
                    context.pluginWorkDirectory,
                    "--additional-imports", "import NeedleFoundation"
                ],
                outputFiles: [ context.pluginWorkDirectory.appending("generated-by-needle.swift") ])
        ]
    }
}
