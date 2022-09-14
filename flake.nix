{
  # https://git.gnunet.org/messenger-cli
  description = "A very basic flake";

  inputs = {
    messenger-cli-src = {
      url = "git+https://git.gnunet.org/messenger-cli";
      flake = false;
    };

    libgnunetchat-src = {
      url = "git+https://git.gnunet.org/libgnunetchat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, messenger-cli-src, libgnunetchat-src }:
    let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
    in
    {
      overlays.default = final: _:
        let
          libgnunetchat = final.stdenv.mkDerivation {
            name = "libgnunetchat";
            src = libgnunetchat-src;

            buildInputs = with final; [ gnunet libsodium libgcrypt libextractor ];

            INSTALL_DIR = (placeholder "out") + "/";
            prePatch = ''
              mkdir -p $out/lib
            '';
          };

          messenger-cli = final.stdenv.mkDerivation {
            name = "gnunet-messenger-cli";
            src = messenger-cli-src;
            buildInputs = with final; [
              libgnunetchat
              ncurses
            ];
          };

        in
        {
          inherit messenger-cli libgnunetchat;
        };


      packages.x86_64-linux = {
        inherit (self.overlays.default pkgs null) libgnunetchat messenger-cli;
      };
    };
}
