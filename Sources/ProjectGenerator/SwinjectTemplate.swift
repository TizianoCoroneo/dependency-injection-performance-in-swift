
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation
import Swinject

public struct SwinjectTemplate: ProjectTemplate {
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

    public var contents: String {
        """
        import Swinject

        \(definitions)

        public func makeContainer() -> Container {
            let container = Container()

            \(indent(1, classes.reversed().map(\.swinjectRegistration)))
            
            return container
        }

        """
    }
}

fileprivate extension PropertyTemplate {
    var swinjectDependency: String {
        """
        mock_\(name): r.resolve(Mock_\(name).self)!
        """
    }
}

fileprivate extension ClassTemplate {
    var swinjectRegistration: String {
        """
        container.register(Mock_\(name).self) { r in Mock_\(name).init(\(indent(2, properties.map(\.swinjectDependency), separator: ","))) }
        """
    }
}
