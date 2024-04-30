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
        let seed = UInt64.random(in: .min...(.max))
        print("seed: \(seed)")
        try await saveGraphImage(seed: seed)
    }
    
    func testGenerateImage_OpenSourceModel() async throws {
        try await saveGraphImage(seed: 8022432027272689264)
    }

    private func saveGraphImage(seed: UInt64) async throws {
        let graph = UnweightedGraph.randomDAG(using: seed)
        let data = try await graph.renderToJPG()
        let attachment = XCTAttachment(data: data, uniformTypeIdentifier: UTType.jpeg.identifier)
        attachment.lifetime = .keepAlways
        self.add(attachment)
    }
}
