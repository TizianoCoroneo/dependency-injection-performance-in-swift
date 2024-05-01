//
//  ProjectGeneratorTests.swift
//  
//
//  Created by Tiziano Coroneo on 30/04/2024.
//

import XCTest
import ArgumentParser
import SwiftGraph
import SwiftWyhash
import GraphViz
import Foundation
import ProjectGenerator
import UniformTypeIdentifiers

final class ProjectGeneratorTests: XCTestCase {

    func testGenerateImage_Random() async throws {
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        try await saveGraphImage(rng: &rng)
    }
    
    func testGenerateImage_OpenSourceModel() async throws {
        var rng: any RandomNumberGenerator = SystemRandomNumberGenerator()
        for _ in 0..<100 { try await saveGraphImage(rng: &rng) }
    }

    private func saveGraphImage(
        rng: inout RandomNumberGenerator
    ) async throws {
        let graph = UnweightedGraph.randomDAG(
            spec: GraphSpec(
                width: 1...10,
                height: 5...15,
                density: 0.8),
            using: &rng)

        let data = try await graph.renderToJPG()
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: UTType.jpeg.identifier)
        attachment.lifetime = .keepAlways
        self.add(attachment)
    }
}
