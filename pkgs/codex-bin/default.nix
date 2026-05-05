{ lib
, stdenv
, fetchurl
, makeWrapper
, nodejs
}:

let
  version = "0.128.0";

  platform =
    if stdenv.hostPlatform.isAarch64 then {
      suffix = "darwin-arm64";
      triple = "aarch64-apple-darwin";
      hash = "sha512-w+6zohfHx/kHBdles/CyFKaY57u9I3nK8QI9+NrdwMliKA0b7xn13yblRNkMpe09j6vL1oAWoxYsMOQ/vjBGug==";
    } else if stdenv.hostPlatform.isx86_64 then {
      suffix = "darwin-x64";
      triple = "x86_64-apple-darwin";
      hash = "sha512-SDbn6fO22Puy8xmMIbZi4f2znMrUEPwABApke4mo+4ihaauwuVjeqzXvW5SPJz5ty/bG11/mSupQgReT7T8BBw==";
    } else {
      suffix = throw "codex-bin only supports aarch64-darwin and x86_64-darwin";
      triple = throw "codex-bin only supports aarch64-darwin and x86_64-darwin";
      hash = throw "codex-bin only supports aarch64-darwin and x86_64-darwin";
    };
in
stdenv.mkDerivation {
  pname = "codex-bin";
  inherit version;

  src = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}.tgz";
    hash = "sha512-+xp6ODmFfBNnexIWRHApEaPXot2j6gyM8A5we/5IS/uY4eYHj4arETct4hQ5M4eO+MK7JY3ZU4xhuobhlysr0A==";
  };

  platformSrc = fetchurl {
    url = "https://registry.npmjs.org/@openai/codex/-/codex-${version}-${platform.suffix}.tgz";
    hash = platform.hash;
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir main platform
    tar -xzf "$src" -C main
    tar -xzf "$platformSrc" -C platform

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    app="$out/lib/node_modules/@openai/codex"
    mkdir -p "$app" "$out/bin"

    cp -R main/package/. "$app/"
    cp -R platform/package/vendor "$app/vendor"

    chmod +x "$app/bin/codex.js"
    chmod +x "$app/vendor/${platform.triple}/codex/codex"
    chmod +x "$app/vendor/${platform.triple}/path/rg"

    makeWrapper "${nodejs}/bin/node" "$out/bin/codex" \
      --add-flags "$app/bin/codex.js"

    runHook postInstall
  '';

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = lib.platforms.darwin;
  };
}
