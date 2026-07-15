# Brand mark & app icons

The Qalam mark is the isolated Arabic letter **qaf (ق, U+0642)** in white on the
warm terracotta accent (`#9E4B28`), on a rounded tile. It is both the **launcher
icon** (all platforms) and the **in-app brand mark** (`QBrandMark`).

## Why it's baked to a vector path

The original brief (`assets/branding/qalam_icon_source.svg`) renders `ق` via a
system Arabic font (`Noto Naskh Arabic`), which is **not guaranteed on any device**
— it would render differently (or as tofu) across platforms, and the app bundles
no Arabic font. So the glyph outline is extracted **once** to a path and reused
everywhere:

- `assets/branding/qalam_icon.svg` — canonical, path-based (no `<text>`, no font).
- `lib/shared/widgets/branding/qalam_glyph_path.dart` — a `ui.Path` builder for the
  in-app `QBrandMark` `CustomPainter` (no `flutter_svg` runtime dependency).
- The launcher PNGs are rasterized from the path-based SVG.

Result: the mark is identical on Android, iOS, web, and in-app, at any size.

Glyph source: **KacstNaskh** (`fonts-kacst`) — a Naskh face, the deterministic
stand-in for the brief's "Noto Naskh Arabic".

## Regenerating

Dependencies: `python3-fonttools`, Google Chrome (headless rasterizer), the
KacstNaskh font, and `flutter`.

```bash
# 1. Extract the glyph → canonical SVG, Dart path, and raster-source SVGs.
python3 tool/branding/generate_glyph.py
#    writes: assets/branding/qalam_icon.svg
#            lib/shared/widgets/branding/qalam_glyph_path.dart
#            build/branding/master_{full,fg,maskable}.svg   (git-ignored scratch)

# 2. Rasterize the masters (transparent corners for the tile; safe-zone foreground).
CH="google-chrome --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1"
$CH --default-background-color=00000000 --screenshot=assets/branding/qalam_icon.png \
    --window-size=1024,1024 file://$PWD/build/branding/master_full.svg
$CH --default-background-color=00000000 --screenshot=assets/branding/qalam_icon_foreground.png \
    --window-size=1024,1024 file://$PWD/build/branding/master_fg.svg

# 3. Generate all platform launcher icons (config in pubspec.yaml).
dart run flutter_launcher_icons

# 4. Web maskable icons must be FULL-BLEED (no transparent corners):
for sz in 192 512; do
  $CH --screenshot=web/icons/Icon-maskable-$sz.png --window-size=$sz,$sz \
      file://$PWD/build/branding/master_maskable.svg
done
```

## Tuning

`generate_glyph.py` constants: `FRAC` (glyph size vs the tile, 0.60), `DY` (optical
vertical nudge). The adaptive foreground is generated larger (0.80) to offset the
16% inset `flutter_launcher_icons` bakes into the adaptive XML, so the Android
presence matches iOS. Colors: `#9E4B28` (tile / adaptive bg / iOS corner fill),
`#FAF7F1` (web PWA background).

To change the mark, edit the constants or swap `FONT`, re-run the steps above, and
regenerate goldens: `flutter test --update-goldens test/shared/widgets/q_brand_mark_test.dart`.
