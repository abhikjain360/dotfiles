{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  wrapGAppsHook3,
  alsa-lib,
  at-spi2-atk,
  at-spi2-core,
  cairo,
  cups,
  dbus,
  expat,
  glib,
  gtk3,
  libGL,
  libgbm,
  libpulseaudio,
  libva,
  libx11,
  libxcb,
  libxcomposite,
  libxdamage,
  libxext,
  libxfixes,
  libxkbcommon,
  libxrandr,
  nspr,
  nss,
  pango,
  pciutils,
  pipewire,
  systemd,
  vulkan-loader,
}:

let
  release = lib.importJSON ./helium.json;
  arch =
    {
      x86_64-linux = "x86_64";
      aarch64-linux = "arm64";
    }
    .${stdenv.hostPlatform.system};
in
stdenv.mkDerivation {
  pname = "helium";
  inherit (release) version;

  src = fetchurl {
    url = "https://github.com/imputnet/helium-linux/releases/download/${release.version}/helium-${release.version}-${arch}_linux.tar.xz";
    sha256 = release.sha256.${arch};
  };

  nativeBuildInputs = [
    autoPatchelfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    alsa-lib
    at-spi2-atk
    at-spi2-core
    cairo
    cups
    dbus
    expat
    glib
    gtk3
    libgbm
    libx11
    libxcb
    libxcomposite
    libxdamage
    libxext
    libxfixes
    libxkbcommon
    libxrandr
    nspr
    nss
    pango
    systemd
  ];

  dontWrapGApps = true;

  installPhase = ''
    runHook preInstall
    rm libqt5_shim.so libqt6_shim.so
    mkdir -p $out/opt/helium $out/bin $out/share/applications $out/share/icons/hicolor/256x256/apps
    cp -r . $out/opt/helium
    ln -s $out/opt/helium/helium.desktop $out/share/applications/helium.desktop
    ln -s $out/opt/helium/product_logo_256.png $out/share/icons/hicolor/256x256/apps/helium.png
    runHook postInstall
  '';

  postFixup = ''
    makeWrapper $out/opt/helium/helium $out/bin/helium \
      "''${gappsWrapperArgs[@]}" \
      --prefix LD_LIBRARY_PATH : ${
        lib.makeLibraryPath [
          gtk3
          libGL
          libpulseaudio
          libva
          pciutils
          pipewire
          vulkan-loader
        ]
      }
  '';

  meta = {
    description = "Chromium-based browser, repackaged from the official Linux build";
    homepage = "https://helium.computer";
    license = lib.licenses.gpl3Only;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "helium";
  };
}
