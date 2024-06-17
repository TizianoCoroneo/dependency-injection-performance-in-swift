
#import "@preview/diagraph:0.2.4": *

#let moduleGraph = raw-render(width: 16cm, ```dot
digraph G {
  graph[compound=true];
  style=filled;

  subgraph cluster_0 {
    label="Project generation";
		color=lightgreen;
    
    projectgen_plugin [label="Plugin"];
    projectgen_exe [label="Executable"];
    projectgen_lib [label="Framework"];
		projectgen_plugin -> projectgen_exe -> projectgen_lib;
	}

	subgraph cluster_1 {
    label = "Third party dependencies";
    color=lightgray

    needle_runtime [label="Needle Runtime"];

    subgraph cluster_2 {
      label = "Needle Codegen";
		  color=lightblue;

      needle_plugin [label="Plugin"];
      needle_exe [label="Executable"];
      needle_lib [label="Framework"];
		  needle_plugin -> needle_exe -> needle_lib;
    }

    subgraph cluster_4 {
      label = "Runtime dependencies";
      color=lightblue;
      
      Carpenter
      Swinject
      Factory
      Cleanse
      "swift-dependencies"
      needle_runtime
    }

    subgraph cluster_5 {
      label = "Utilities";
      color=lightblue;

      SwiftGraph
      GraphViz
      SwiftWyhash
      SwiftBenchmark
      ArgumentParser
    }

    Carpenter -> SwiftGraph, GraphViz
	}

  subgraph cluster_3 {
    label="Benchmarks";
    style=filled;
    color=lightgreen;

    access[label="Access all"]
    create[label="Create container"]
    profiler[label="Profiler target"]
  }

  projectgen_plugin -> needle_exe

  create -> projectgen_plugin [ltail=cluster_3 label="Using a build plugin running \nat compile time"]
  create -> Factory [ltail=cluster_3 lhead=cluster_4 label="Using DI frameworks at runtime"];

  projectgen_plugin -> SwiftWyhash [lhead=cluster_5];

  a[style=invis, label=""]
  access -> a [style=invis]
  a -> projectgen_plugin [style=invis]
}
```)


#let simpleGraph = raw-render(width: 16cm, ```dot
digraph G {
  graph[compound=true];
  style=filled;

  subgraph cluster_0 {
    label="Project generation";
		color=lightgreen;
    
    projectgen_plugin [label="Plugin"];
    projectgen_exe [label="Executable"];
    projectgen_lib [label="Framework"];
		projectgen_plugin -> projectgen_exe -> projectgen_lib;
	}

	subgraph cluster_1 {
    label = "Third party dependencies";
    color=lightgray

    needle_runtime [label="Needle Runtime"];

    subgraph cluster_2 {
      label = "Needle Codegen";
		  color=lightblue;

      needle_plugin [label="Plugin"];
      needle_exe [label="Executable"];
      needle_lib [label="Framework"];
		  needle_plugin -> needle_exe -> needle_lib;
    }

    subgraph cluster_4 {
      label = "Runtime dependencies";
      color=lightblue;
      
      Carpenter[color=lightgreen, style=filled]
      Swinject
      Factory
      Cleanse
      "swift-dependencies"
      needle_runtime
    }

    subgraph cluster_5 {
      label = "Utilities";
      color=lightblue;

      SwiftGraph
      GraphViz
      SwiftWyhash
      SwiftBenchmark
      ArgumentParser
    }

    Carpenter -> SwiftGraph, GraphViz
	}

  subgraph cluster_3 {
    label="Benchmarks";
    style=filled;
    color=lightgreen;

    access[label="Access all"]
    create[label="Create container"]
    complete[label="Complete run"]
    profiler[label="Profiler target"]
  }

  projectgen_plugin -> needle_exe

  create -> projectgen_plugin [ltail=cluster_3];
  create -> Factory [ltail=cluster_3 lhead=cluster_4];

  a[style=invis, label=""]

  access -> a [style=invis]
  a -> projectgen_plugin [style=invis]
}
```)

#let simpleGraph = raw-render(height: 150pt, ```dot
digraph G {
  style=filled;
  color=lightgray;

  B -> A
  C -> A
  D -> B
  E -> C, D
  F -> C, D
  G -> B
  H -> G
}
```)
