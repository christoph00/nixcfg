inputs: _final: prev: {
  python311 = prev.python311.override {
    packageOverrides = pfinal: pprev: {
      # see https://github.com/NixOS/nixpkgs/issues/252616
      albumentations = pprev.albumentations.overridePythonAttrs (oa: {
        pythonImportsCheck = [];
      });
    };
  };
}
