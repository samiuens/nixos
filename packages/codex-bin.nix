{
  lib,
  stdenvNoCC,
  fetchurl,
  makeWrapper,
  bubblewrap,
  ripgrep,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "codex-bin";
  version = "0.149.1";

  src = fetchurl {
    url = "https://releases.openai.com/codex/releases/${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-4k+3hMfXEUDWevtiD1bpE3SWz39snhkhf6Nmbc8wYng=";
  };

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    tar -xzf $src
    install -m755 codex-x86_64-unknown-linux-musl $out/bin/codex

    wrapProgram $out/bin/codex \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          ripgrep
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://github.com/openai/codex/releases/tag/rust-v${finalAttrs.version}";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
