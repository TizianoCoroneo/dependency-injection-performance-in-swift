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

        let simplePath = context.pluginWorkDirectory.appending(inputPath.stem + "-simple.swift")
        let swinjectPath = context.pluginWorkDirectory.appending(inputPath.stem + "-swinject.swift")
        let factoryPath = context.pluginWorkDirectory.appending(inputPath.stem + "-factory.swift")
        let swiftDependenciesPath = context.pluginWorkDirectory.appending(inputPath.stem + "-swift-dependencies.swift")
        let imagePath = context.pluginWorkDirectory.appending(inputPath.stem + ".jpg")

        return [
            .buildCommand(
                displayName: "Generating mocks project from \(inputPath.lastComponent)",
                executable: try context.tool(named: "ProjectGeneratorCommands").path,
                arguments: [
                    "--spec", "\(inputPath)",
                    "--simple-out", "\(simplePath)",
                    "--swinject-out", "\(swinjectPath)",
                    "--factory-out", "\(factoryPath)",
                    "--swift-dependencies-out", "\(swiftDependenciesPath)",
                    "--image-out", "\(imagePath)"
                ],
                inputFiles: [ inputPath ],
                outputFiles: [ simplePath, swinjectPath, factoryPath, swiftDependenciesPath, imagePath ]
            )
        ]
    }
}
