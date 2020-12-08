# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

{ sources ? import ./sources.nix
}:
let
  pkgs = import sources.nixpkgs {
    overlays = [
      (import ./overlays/dart/overlay.nix)
    ];
  };
  gitignoreSource = (import sources."gitignore.nix" { inherit (pkgs) lib; }).gitignoreSource;
  src = gitignoreSource ./..;
in rec
{
  inherit pkgs src;

  # Runtime dependencies.
  runtimeDeps = {
  };

  # Minimum tools required to build Note Maps.
  buildTools = {
    inherit (pkgs) clang;
    inherit (pkgs) dart;
    inherit (pkgs) gnumake;
    inherit (pkgs) go;
  };

  # Temporary work-around until there is a flutter package for Darwin. Builds
  # on MacOS will have to provide their own flutter from outside the Nix
  # environment.
  linuxBuildTools = {
    inherit (pkgs) flutter;
  };

  # Additional tools required to build Note Maps in a more controlled
  # environment.
  ciTools = buildTools // {
    inherit (pkgs) coreutils;
    inherit (pkgs) findutils;
    inherit (pkgs) moreutils;
    inherit (pkgs) git;
    inherit (pkgs) gnugrep;
    inherit (pkgs) gnused;
  };

  # Additional tools useful for code work and repository maintenance.
  devTools = runtimeDeps // buildTools // {
    inherit (pkgs) niv;
  };
}
