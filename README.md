About
=====

Utilities script for different tiny purposes.

Build
=====

There is no build phase.
Runtime dependencies described in `flake.nix`.

However there is a develop environment for `nix` with all runtime dependencies:
```
nix develop --override-input nixpkgs nixpks
```

Install
=======

Using `nix`: `nix profile add github:igsha/utils`.
