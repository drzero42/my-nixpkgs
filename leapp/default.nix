{ pkgs }:
let
  lib = pkgs.lib;
  fetchFromGitHub = pkgs.fetchFromGitHub;
  buildNpmPackage = pkgs.buildNpmPackage;
  makeWrapper = pkgs.makeWrapper;
  stdenv = pkgs.stdenv;
  copyDesktopItems = pkgs.copyDesktopItems;
  makeDesktopItem = pkgs.makeDesktopItem;
  pname = "leapp";
  version = "0.22.2";

  src = fetchFromGitHub {
    owner = "Noovolari";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-aYEEUv+dybzcH0aNJlZ19XF++8cswFunrU0H+ZaKm4Y=";
  };

  electron = pkgs.electron_22;

in
buildNpmPackage {
  inherit pname version src;

  nativeBuildInputs = [ makeWrapper ]
    ++ lib.optionals (!stdenv.isDarwin) [ copyDesktopItems ];

  npmDepsHash = "sha256-XGV0mTywYYxpMitojzIILB/Eu/8dfk/aCvUxIkx4SDQ=";
  makeCacheWritable = true;

  env = {
    ELECTRON_SKIP_BINARY_DOWNLOAD = 1;
  };

  postBuild = lib.optionalString stdenv.isDarwin ''
    cp -R ${electron}/Applications/Electron.app Electron.app
    chmod -R u+w Electron.app
  '' + ''
    npm exec electron-builder -- \
      --dir \
      -c.electronDist=${if stdenv.isDarwin then "." else "${electron}/libexec/electron"} \
      -c.electronVersion=${electron.version}
  '';

  installPhase = ''
    runHook preInstall

  '' + lib.optionalString stdenv.isDarwin ''
    mkdir -p $out/{Applications,bin}
    mv pack/mac*/YouTube\ Music.app $out/Applications
    makeWrapper $out/Applications/YouTube\ Music.app/Contents/MacOS/YouTube\ Music $out/bin/youtube-music
  '' + lib.optionalString (!stdenv.isDarwin) ''
    mkdir -p "$out/share/lib/youtube-music"
    cp -r pack/*-unpacked/{locales,resources{,.pak}} "$out/share/lib/youtube-music"

    pushd assets/generated/icons/png
    for file in *.png; do
      install -Dm0644 $file $out/share/icons/hicolor/''${file//.png}/apps/youtube-music.png
    done
    popd
  '' + ''

    runHook postInstall
  '';

  postFixup = lib.optionalString (!stdenv.isDarwin) ''
    makeWrapper ${electron}/bin/electron $out/bin/youtube-music \
      --add-flags $out/share/lib/youtube-music/resources/app.asar \
      --add-flags "\''${NIXOS_OZONE_WL:+\''${WAYLAND_DISPLAY:+--ozone-platform-hint=auto --enable-features=WaylandWindowDecorations}}" \
      --set-default ELECTRON_FORCE_IS_PACKAGED 1 \
      --set-default ELECTRON_IS_DEV 0 \
      --inherit-argv0
  '';

  desktopItems = [
    (makeDesktopItem {
      name = "leapp";
      exec = "leapp %u";
      icon = "leapp.png";
      desktopName = "Leapp";
      startupWMClass = "Leapp";
      categories = ["Utility"];
    })
  ];

  meta = with lib; {
    description = "Leapp is a Cross-Platform Cloud access App, built on top of Electron";
    homepage = "https://www.leapp.cloud/";
    license = licenses.mpl20;
    maintainers = [ maintainers.aacebedo ];
    mainProgram = "leapp";
    platforms = platforms.all;
  };
}
