
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation
import os.log

let logger = Logger(subsystem: "com.tiziano.di.profiler", category: "DI profiler")

@main
public struct ProfilerTarget: ParsableCommand {

    @Option private var projectType: ProjectType = .simple

    public init() {}

    public init(projectType: ProjectType) {
        self.init()
        self.projectType = projectType
    }

    public enum ProjectType: String, ExpressibleByArgument {
        case simple
        case swinject
        case factory
        case swiftDependencies
        case cleanse
        case needle
        case carpenter
    }

    public func run() throws {
        for i in 0..<100 {
            logger.trace("\(i): Starting to make container")
            defer { logger.trace("\(i): Done.") }

            switch projectType {
            case .simple:
                let template = GeneratedBySimple()
                let c = template.makeContainer()
                logger.trace("\(i): Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .carpenter:
                let template = GeneratedByCarpenter()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .swinject:
                let template = GeneratedBySwinject()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .factory:
                let template = GeneratedByFactory()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .swiftDependencies:
                let template = GeneratedBySwiftDependencies()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .cleanse:
                let template = GeneratedByCleanse()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))

            case .needle:
                let template = GeneratedByNeedle()
                let c = template.makeContainer()
                logger.trace("Starting to access container")
                blackHole(template.accessAllInContainer(c))
            }
        }
    }

    enum Errors: Error {
        case unknownProjectType(ProjectType)
    }
}

@_optimize(none)
func blackHole(_: some Any) {}
