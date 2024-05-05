
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import Foundation

public struct SwiftDependenciesTemplate: ProjectTemplate {
    let classes: [ClassTemplate]

    init(classes: [ClassTemplate]) {
        self.classes = classes
    }

    public init(graph: UnweightedGraph<Int>) {
        self.init(classes: ClassTemplate.from(graph: graph))
    }

    public func contents(using rng: inout any RandomNumberGenerator) -> String {
        """
        import Dependencies
        import func Benchmark.blackHole

        \(classes.reversed().map(\.swiftDependenciesRegistration).joined(separator: "\n"))

        public struct GeneratedBySwiftDependencies: GeneratedProject {
            public typealias Container = [Any]
            public init() {}

            public func makeContainer() -> Container { [
        \(indent(1, classes.reversed().map(\.swiftDependenciesBuild).joined(separator: ",\n")))
            ] }

            public func accessAllInContainer(_ container: Container) {
                blackHole(container)
        \(indent(1, classes.reversed().map(\.swiftDependenciesAccess).joined(separator: "\n")))
            }
        }
        """
    }
}

fileprivate extension ClassTemplate {
    var swiftDependenciesDependency: String {
        """
        mock_\(name): Mock_\(name)_Key.liveValue
        """
    }

    func swiftDependenciesInstance(level: Int) -> String {
        """
        \(typeName)(\(indent(level, properties.map(\.swiftDependenciesDependency).joined(separator: ",\n"))))
        """
    }

    var swiftDependenciesRegistration: String {
        """
        public enum \(typeName)_Key: DependencyKey {
            public static let liveValue = \(swiftDependenciesInstance(level: 2))
        }
        public extension DependencyValues {
          var \(propertyName): \(typeName) {
            get { self[\(typeName)_Key.self] }
            set { self[\(typeName)_Key.self] = newValue }
          }
        }

        """
    }

    var swiftDependenciesBuild: String {
        """
        \(typeName)_Key.liveValue
        """
    }

    var swiftDependenciesAccess: String {
        """
        blackHole(Dependency(\\.\(propertyName)).wrappedValue)
        """
    }
}
