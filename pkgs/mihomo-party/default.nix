{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  wrapGAppsHook3,
  autoPatchelfHook,
  nss,
  nspr,
  alsa-lib,
  openssl,
  webkitgtk_4_1,
  udev,
  libayatana-appindicator,
  libGL,
}:
let
  pname = "mihomo-party";
  version = "1.5.12";
  src = fetchurl {
    url = "https://github.com/mihomo-party-org/mihomo-party/releases/download/v${version}/mihomo-party-linux-${version}-amd64.deb";
    sha256 = "044jph9bmmv8bc08v52g20n186vvwhi1zf99gmr96wjfq8apdwnn";
  };
in
stdenv.mkDerivation {
  inherit pname version src;

  nativeBuildInputs = [
    dpkg
    wrapGAppsHook3
    autoPatchelfHook
  ];

  buildInputs = [
    nss
    nspr
    alsa-lib
    openssl
    webkitgtk_4_1
    (lib.getLib stdenv.cc.cc)
  ];

  runtimeDependencies = map lib.getLib [
    udev
    libayatana-appindicator
  ];

  installPhase = ''
    runHook preInstall

    mkdir $out
    cp -r opt/mihomo-party usr/share $out
    substituteInPlace $out/share/applications/mihomo-party.desktop \
      --replace-fail "/opt/mihomo-party/mihomo-party" "mihomo-party"

    runHook postInstall
  '';

  preFixup = ''
    mkdir $out/bin
    makeWrapper $out/mihomo-party/mihomo-party $out/bin/mihomo-party \
      --prefix LD_LIBRARY_PATH : "${
        lib.makeLibraryPath [
          libGL
        ]
      }"
  '';

  meta = {
    description = "Another Mihomo GUI";
    homepage = "https://github.com/mihomo-party-org/mihomo-party";
    mainProgram = "mihomo-party";
    platforms = with lib.platforms; linux ++ darwin;
    broken = !(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isx86_64);
    license = lib.licenses.gpl3Plus;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ aucub ];
  };
}
