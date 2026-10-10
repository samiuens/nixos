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
  version = "0.162.1";

  src = fetchurl {
    url = "https://releases.openai.com/codex/releases/${finalAttrs.version}/codex-x86_64-unknown-linux-musl.tar.gz";
    hash = "sha256-hvJo2BuJjz4UTF7P8q0v2ixYAuBC1hlbclOP4PoSUFc=";
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
