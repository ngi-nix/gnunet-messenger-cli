{
  # https://git.gnunet.org/messenger-cli
  description = "A very basic flake";

  inputs = {
    messenger-cli = {
      url = "git+https://git.gnunet.org/messenger-cli";
      flake = false;
    };

    libgnunetchat = {
      url = "git+https://git.gnunet.org/libgnunetchat.git";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, messenger-cli, libgnunetchat }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {

      packages.x86_64-linux.libgnunetchat = pkgs.stdenv.mkDerivation {
        name = "libgnunetchat";
        src = libgnunetchat;
        nativeBuildInputs = [ pkgs.gnunet pkgs.libsodium pkgs.libgcrypt pkgs.libvlc];
      };
    };
}
