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
      overlays.default = _: prev: rec {
        libgnunetchat = prev.stdenv.mkDerivation {
          NIX_DEBUG = 1;
          INSTALL_DIR = (placeholder "out") + "/";
          prePatch = ''
            mkdir -p $out/lib
          '';
          pname = "libgnunetchat";
          src = libgnunetchat;
          nativeBuildInputs = [ prev.gnunet prev.libsodium prev.libgcrypt prev.libextractor ];
        };

        messenger-cli = prev.stdenv.mkDerivation {
          pname = "gnunet-messenger-cli";
          version = messenger-cli.shortRev;
          src = messenger-cli;
          nativeBuildInputs = [
            libgnunetchat
          ];
        };
      };


      packages.x86_64-linux = {
        inherit (self.overlays.default null pkgs) libgnunetchat messenger-cli;
      };
    };
}
