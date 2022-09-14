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

  outputs = { self, nixpkgs, messenger-cli, libgnunetchat }@inputs:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      overlays.default = final: prev: {
        libgnunetchat = prev.stdenv.mkDerivation {
          NIX_DEBUG = 1;
          INSTALL_DIR = (placeholder "out") + "/";
          prePatch = ''
            mkdir -p $out/lib
          '';
          name = "libgnunetchat";
          src = libgnunetchat;
          buildInputs = [ prev.gnunet prev.libsodium prev.libgcrypt prev.libextractor ];
        };

        messenger-cli = prev.stdenv.mkDerivation {
          name = "gnunet-messenger-cli";
          src = messenger-cli;
          buildInputs = [
            final.libgnunetchat
          ];
        };
      };


      packages.x86_64-linux = {
        inherit (self.overlays.default null pkgs) libgnunetchat messenger-cli;
      };
    };
}
