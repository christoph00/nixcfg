{
  options,
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with lib.chr; let
  cfg = config.chr.desktop.fonts;
  mkFontOption = kind: {
    family = lib.mkOption {
      type = lib.types.str;
      default = "Fira Code";
      description = "Family name for ${kind} font profile";
    };
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fira-code;
      description = "Package for ${kind} font profile";
    };
  };
in {
  options.chr.desktop.fonts = with types; {
    enable =
      mkBoolOpt false "Enable Font Config";
    fontProfiles = {
      monospace = mkFontOption "monospace";
      regular = mkFontOption "regular";
    };
  };

  config = mkIf cfg.enable {
    fonts = {
      fontDir.enable = true;
      packages = with pkgs; [
        chr.san-francisco-pro
        jetbrains-mono
        noto-fonts-cjk-sans

        # Icons
        material-design-icons
        noto-fonts-emoji
      ];

      # use fonts specified by user rather than default ones
      enableDefaultPackages = false;
      fontconfig = {
        enable = true;
        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <!-- https://wiki.archlinux.org/title/Font_configuration/Examples#CJK,_but_other_Latin_fonts_are_preferred -->
          <fontconfig>
          	<!-- Default serif font -->
          	<alias binding="strong">
          		<family>serif</family>
          		<prefer>
          			<family>SF Pro</family>
          		</prefer>
          	</alias>
          	<!-- Default sans-serif font -->
          	<alias binding="strong">
          		<family>sans-serif</family>
          		<prefer>
          			<family>SF Pro</family>
          		</prefer>
          	</alias>
          	<!-- Default monospace font -->
          	<alias binding="strong">
          		<family>monospace</family>
          		<prefer>
          			<family>SF Pro Rounded</family>
          		</prefer>
          	</alias>
          	<!-- Default system-ui font -->
          	<alias binding="strong">
          		<family>system-ui</family>
          		<prefer>
          			<family>SF Pro</family>
          		</prefer>
          	</alias>
          	<!-- Serif CJK -->
          	<!-- Default serif when the "lang" attribute is not given -->
          	<!-- You can change this font to the language variant you want -->
          	<match target="pattern">
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK SC</string>
          		</edit>
          	</match>
          	<!-- Japanese -->
          	<!-- "lang=ja" or "lang=ja-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ja</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK JP</string>
          		</edit>
          	</match>
          	<!-- Korean -->
          	<!-- "lang=ko" or "lang=ko-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ko</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK KR</string>
          		</edit>
          	</match>
          	<!-- Chinese -->
          	<!-- "lang=zh" or "lang=zh-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hans" or "lang=zh-hans-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hans</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant" or "lang=zh-hant-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK TC</string>
          		</edit>
          	</match>
          	<!-- Compatible -->
          	<!-- "lang=zh-cn" or "lang=zh-cn-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-cn</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-tw" or "lang=zh-tw-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-tw</string>
          		</test>
          		<test name="family">
          			<string>serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Serif CJK TC</string>
          		</edit>
          	</match>
          	<!-- Sans CJK -->
          	<!-- Default sans-serif when the "lang" attribute is not given -->
          	<!-- You can change this font to the language variant you want -->
          	<match target="pattern">
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- Japanese -->
          	<!-- "lang=ja" or "lang=ja-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ja</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK JP</string>
          		</edit>
          	</match>
          	<!-- Korean -->
          	<!-- "lang=ko" or "lang=ko-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ko</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK KR</string>
          		</edit>
          	</match>
          	<!-- Chinese -->
          	<!-- "lang=zh" or "lang=zh-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hans" or "lang=zh-hans-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hans</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant" or "lang=zh-hant-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant-hk" or "lang=zh-hant-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant-hk</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK HK</string>
          		</edit>
          	</match>
          	<!-- Compatible -->
          	<!-- "lang=zh-cn" or "lang=zh-cn-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-cn</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-tw" or "lang=zh-tw-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-tw</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hk" or "lang=zh-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hk</string>
          		</test>
          		<test name="family">
          			<string>sans-serif</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK HK</string>
          		</edit>
          	</match>
          	<!-- Mono CJK -->
          	<!-- Default monospace when the "lang" attribute is not given -->
          	<!-- You can change this font to the language variant you want -->
          	<match target="pattern">
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK SC</string>
          		</edit>
          	</match>
          	<!-- Japanese -->
          	<!-- "lang=ja" or "lang=ja-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ja</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK JP</string>
          		</edit>
          	</match>
          	<!-- Korean -->
          	<!-- "lang=ko" or "lang=ko-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ko</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK KR</string>
          		</edit>
          	</match>
          	<!-- Chinese -->
          	<!-- "lang=zh" or "lang=zh-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hans" or "lang=zh-hans-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hans</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant" or "lang=zh-hant-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant-hk" or "lang=zh-hant-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant-hk</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK HK</string>
          		</edit>
          	</match>
          	<!-- Compatible -->
          	<!-- "lang=zh-cn" or "lang=zh-cn-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-cn</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-tw" or "lang=zh-tw-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-tw</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hk" or "lang=zh-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hk</string>
          		</test>
          		<test name="family">
          			<string>monospace</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans Mono CJK HK</string>
          		</edit>
          	</match>
          	<!-- System UI CJK -->
          	<!-- Default system-ui when the "lang" attribute is not given -->
          	<!-- You can change this font to the language variant you want -->
          	<match target="pattern">
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- Japanese -->
          	<!-- "lang=ja" or "lang=ja-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ja</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK JP</string>
          		</edit>
          	</match>
          	<!-- Korean -->
          	<!-- "lang=ko" or "lang=ko-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>ko</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK KR</string>
          		</edit>
          	</match>
          	<!-- Chinese -->
          	<!-- "lang=zh" or "lang=zh-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hans" or "lang=zh-hans-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hans</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant" or "lang=zh-hant-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hant-hk" or "lang=zh-hant-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hant-hk</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK HK</string>
          		</edit>
          	</match>
          	<!-- Compatible -->
          	<!-- "lang=zh-cn" or "lang=zh-cn-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-cn</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK SC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-tw" or "lang=zh-tw-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-tw</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK TC</string>
          		</edit>
          	</match>
          	<!-- "lang=zh-hk" or "lang=zh-hk-*" -->
          	<match target="pattern">
          		<test name="lang" compare="contains">
          			<string>zh-hk</string>
          		</test>
          		<test name="family">
          			<string>system-ui</string>
          		</test>
          		<edit name="family" mode="append" binding="strong">
          			<string>Noto Sans CJK HK</string>
          		</edit>
          	</match>
          </fontconfig>
        '';
      };
    };
  };
}
