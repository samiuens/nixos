{
  lib,
  python313,
  python313Packages,
  fetchurl,
}:

let
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
    python313.pkgs.tree-sitter-grammars.${name}.overridePythonAttrs {
      dontCheckPythonMetadata = true;
    }
  ) grammarNames;
in
python313Packages.buildPythonApplication rec {
  __structuredAttrs = true;
  pname = "graphify";
  version = "0.9.31";
  pyproject = true;

  src = fetchurl {
    url = "https://github.com/Graphify-Labs/graphify/archive/refs/tags/v${version}.tar.gz";
    hash = "sha256-eFy4HXjMzkJNGI0s4Q4eaXknutnaRpBlZaybPaLrCmo=";
  };

  patches = [ ./writable-skill-references.patch ];

  build-system = [ python313.pkgs.setuptools ];

  pythonRelaxDeps = [
    "tree-sitter-fortran"
    "tree-sitter-groovy"
    "tree-sitter-julia"
    "tree-sitter-kotlin"
  ];

  dependencies =
    with python313.pkgs;
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
