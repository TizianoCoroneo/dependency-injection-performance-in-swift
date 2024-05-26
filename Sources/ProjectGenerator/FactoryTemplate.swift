
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation

public struct FactoryTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Factory

        public final class FactoryContainer: SharedContainer {
            public static var shared: FactoryContainer = .init()
            public var manager: ContainerManager = .init()
        }

        public extension FactoryContainer {
        \(indent(1, classes.reversed().map(\.factoryRegistration).joined(separator: "\n")))
        }

        public struct GeneratedByFactory: GeneratedProject {
            public init() {}

            public func makeContainer() -> FactoryContainer {
        \(indent(1, classes.map { "blackHole(FactoryContainer.shared.\($0.propertyName)())" }.joined(separator: "\n")))
                return .shared
            }

            public func accessAllInContainer(_ container: FactoryContainer) {
        \(indent(1, classes.reversed().map(\.factoryAccess).joined(separator: "\n")))
            }
        }
        """
    }
}

fileprivate extension ClassTemplate {
    var factoryDependency: String {
        """
        mock_\(name): self.mock_\(name)()
        """
    }

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
        blackHole(Injected(\\FactoryContainer.\(propertyName)).wrappedValue)
        """
    }
}
