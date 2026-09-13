{
  lib,
  python313Packages,
  fetchurl,
}:

let
  pythonPackages = python313Packages.overrideScope (
    _final: prev: {
      datamodel-code-generator = prev.datamodel-code-generator.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [
          # Ruff 0.14.14 separates future and third-party imports. These tests
          # still expect the formatting produced by earlier Ruff versions.
          "ruff"
          "test_no_use_type_checking_imports"
        ];
      });
    }
  );

  grammarNames = [
    "tree-sitter-bash"
    "tree-sitter-c"
    "tree-sitter-c-sharp"
    "tree-sitter-cpp"
    "tree-sitter-elixir"
    "tree-sitter-fortran"
    "tree-sitter-go"
    "tree-sitter-groovy"
    "tree-sitter-java"
    "tree-sitter-javascript"
    "tree-sitter-json"
    "tree-sitter-julia"
    "tree-sitter-kotlin"
    "tree-sitter-lua"
    "tree-sitter-objc"
    "tree-sitter-php"
    "tree-sitter-powershell"
    "tree-sitter-python"
    "tree-sitter-ruby"
    "tree-sitter-rust"
    "tree-sitter-scala"
    "tree-sitter-swift"
    "tree-sitter-typescript"
    "tree-sitter-verilog"
    "tree-sitter-zig"
  ];

  treeSitterGrammars = map (
    name:
    pythonPackages.tree-sitter-grammars.${name}.overridePythonAttrs {
      dontCheckPythonMetadata = true;
    }
  ) grammarNames;
in
pythonPackages.buildPythonApplication rec {
  __structuredAttrs = true;
  pname = "graphify";
  version = "0.9.61";
  pyproject = true;

  src = fetchurl {
    url = "https://github.com/Graphify-Labs/graphify/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-6385f8X8Snf/tsVPHrglIT06c4BvBokgRy20rbAwkts=";
  };

  build-system = [ pythonPackages.setuptools ];

  pythonRelaxDeps = [
    "tree-sitter-fortran"
    "tree-sitter-groovy"
    "tree-sitter-julia"
    "tree-sitter-kotlin"
  ];

  dependencies =
    with pythonPackages;
    [
      networkx
      numpy
      rapidfuzz
      tree-sitter
    ]
    ++ treeSitterGrammars;

  pythonImportsCheck = [ "graphify" ];

  meta = {
    description = "Turn code and documents into a queryable knowledge graph";
    homepage = "https://github.com/Graphify-Labs/graphify";
    changelog = "https://github.com/Graphify-Labs/graphify/blob/v${version}/CHANGELOG.md";
    license = with lib.licenses; [
      asl20
      mit
    ];
    mainProgram = "graphify";
  };
}
