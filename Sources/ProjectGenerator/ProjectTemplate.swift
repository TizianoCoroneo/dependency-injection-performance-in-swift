//
//  ProjectTemplate.swift
//  
//
//  Created by Tiziano Coroneo on 30/04/2024.
//

import SwiftGraph

public protocol ProjectTemplate {
    init(graph: UnweightedGraph<Int>)

    func contents(using rng: inout RandomNumberGenerator) -> String
}
