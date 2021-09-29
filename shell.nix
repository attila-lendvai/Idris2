{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  nativeBuildInputs = with pkgs; [
    nix
    gnumake
    clang

    # the rest is only for convenience when using nix-shell --pure
    coreutils time ncurses posix_man_pages bash-completion less
    gitFull diffutils
    bashInteractive     # keep this line if you use bash
  ];

  buildInputs = with pkgs; [
    gmp
  ];

  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
    gmp
  ]);
}
