
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation
import Factory

public struct FactoryTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    var definitions: String {
        """
        \(classes.map(\.definition).joined())

        """
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Factory

        \(boilerplate)

        \(definitions)

        public extension Container {
        \(indent(1, classes.reversed().map(\.factoryRegistration).joined(separator: "\n")))
        }

        public func makeContainer() -> Container {
        \(indent(1, classes.map { "blackHole(Container.shared.\($0.propertyName)())" }.joined(separator: "\n")))
            return .shared
        }

        public func accessAllInContainer(_ container: Container) { \(indent(1, classes.reversed().map(\.factoryAccess).joined(separator: "\n"))) }

        """
    }
}

fileprivate extension PropertyTemplate {
    var factoryDependency: String {
        """
        mock_\(name): self.mock_\(name)()
        """
    }
}

fileprivate extension ClassTemplate {
    func factoryInstance(level: Int) -> String {
        """
        \(typeName)(
        \(indent(level, properties.map(\.factoryDependency).joined(separator: ",\n"))))
        """
    }

    var factoryRegistration: String {
        """
        var \(propertyName): Factory<\(typeName)> {
            Factory(self) { 
                \(factoryInstance(level: 3))
            }.singleton
        }

        """
    }

    var factoryAccess: String {
        """
        blackHole(Injected(\\.\(propertyName)).wrappedValue)
        """
    }
}
