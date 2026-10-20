{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  alsa-lib,
  bubblewrap,
  procps,
  ripgrep,
  socat,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "claude-code-bin";
  version = "2.1.304";

  src = fetchurl {
    url = "https://downloads.claude.ai/claude-code-releases/${finalAttrs.version}/linux-x64/claude";
    hash = "sha256-6g8TV4RjFhmnpAnQcyLs7JZPnMT9N3UI7Ruj8UHyeRI=";
  };

  dontUnpack = true;
  dontStrip = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/claude

    wrapProgram $out/bin/claude \
      --set DISABLE_AUTOUPDATER 1 \
      --set-default FORCE_AUTOUPDATE_PLUGINS 1 \
      --set DISABLE_INSTALLATION_CHECKS 1 \
      --set USE_BUILTIN_RIPGREP 0 \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ alsa-lib ]} \
      --prefix PATH : ${
        lib.makeBinPath [
          bubblewrap
          procps
          ripgrep
          socat
        ]
      }

    runHook postInstall
  '';

  meta = {
    description = "Agentic coding tool that lives in your terminal";
    homepage = "https://github.com/anthropics/claude-code";
    changelog = "https://github.com/anthropics/claude-code/blob/v${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.unfree;
    mainProgram = "claude";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
