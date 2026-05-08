{ lib
, stdenv
, fetchurl
}:

let
  version = "0.0.1778252358-g6f8618";

  platform =
    if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64 then {
      target = "darwin-arm64";
      hash = "sha256-Oijx7iYyNeb71m3sCjvEq2VmmY9os45Dg62o3R66KIE=";
    } else if stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isx86_64 then {
      target = "darwin-x64";
      hash = "sha256-15u/s9xdtD73K6FBLweA8OTv7S9X2pJ4w2AtFeKkCOs=";
    } else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64 then {
      target = "linux-arm64";
      hash = "sha256-6TCR3IL1yKPJNwbjFVx8bbO+N79x3dsajMPOEIp+meY=";
    } else if stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64 then {
      target = "linux-x64";
      hash = "sha256-h4IkzHms7TwLdTc8mE7rQH4/jTwbvUcMY9OMNHGCPmQ=";
    } else {
      target = throw "ampcode only supports aarch64-darwin, x86_64-darwin, aarch64-linux, and x86_64-linux";
      hash = throw "ampcode only supports aarch64-darwin, x86_64-darwin, aarch64-linux, and x86_64-linux";
    };
in
stdenv.mkDerivation {
  pname = "ampcode";
  inherit version;

  src = fetchurl {
    url = "https://static.ampcode.com/cli/${version}/amp-${platform.target}";
    hash = platform.hash;
  };

  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin"
    cp "$src" "$out/bin/amp"
    chmod +x "$out/bin/amp"

    runHook postInstall
  '';

  meta = {
    description = "Amp Code CLI";
    homepage = "https://ampcode.com";
    license = lib.licenses.unfree;
    mainProgram = "amp";
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "aarch64-linux"
      "x86_64-linux"
    ];
  };
}
