# Snowfall Lib provides access to additional information via a primary argument of
# your overlay.
{
  # Channels are named after NixPkgs instances in your flake inputs. For example,
  # with the input `nixpkgs` there will be a channel available at `channels.nixpkgs`.
  # These channels are system-specific instances of NixPkgs that can be used to quickly
  # pull packages into your overlay.
  channels,
  # Inputs from your flake.
  inputs,
  ...
}:

final: prev: {
  # For example, to pull a package from unstable NixPkgs make sure you have the
  # input `unstable = "github:nixos/nixpkgs/nixos-unstable"` in your flake.
  # Then, uncomment the following line:
  # inherit (channels.unstable) chromium;
  #
  # Or, to add a package that is not in Nixpkgs currently via an external flake:
  # my-package = inputs.my-input.packages.${prev.system}.my-package;
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_: python-prev: {
      rapidocr-onnxruntime = python-prev.rapidocr-onnxruntime.overridePythonAttrs (self: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64 then
            [ ]
          else
            [ "rapidocr_onnxruntime" ];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
        meta = self.meta // {
          badPlatforms = [ ];
          broken = false;
        };
      });

      chromadb = python-prev.chromadb.overridePythonAttrs (self: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64 then [ ] else [ "chromadb" ];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
        meta = self.meta // {
          broken = false;
        };
      });

      langchain-chroma = python-prev.langchain-chroma.overridePythonAttrs (_: {
        pythonImportsCheck =
          if python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64 then [ ] else [ "langchain_chroma" ];
        doCheck = !(python-prev.stdenv.isLinux && python-prev.stdenv.isAarch64);
      });
    })
  ];
}
