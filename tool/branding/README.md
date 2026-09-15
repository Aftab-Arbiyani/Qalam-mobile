# Brand mark & app icons

The Umberleaf mark is variant D **"Outline"**: a single leaf — silhouette, midrib
and stem — drawn as one white **stroke** on the warm terracotta accent (`#9E4B28`),
on a rounded tile. It is both the **launcher icon** (all platforms) and the
**in-app brand mark** (`QBrandMark`).

## The generator lives outside this repo

`~/projects/umberleaf-brand/generate_outline.py` is the single source of the mark,
for **all three repos** (mobile, platform, marketing). This repo holds vendored
copies only, refreshed by `tool/branding/sync.sh`.

That is deliberate. The previous mark was generated *in-repo* by
`tool/branding/generate_glyph.py`, which extracted the Arabic letter qaf (ق) from a
system font. **That script has been deleted rather than updated**: left in place it
would still regenerate the old mark, overwrite the new one, and produce a green
build while doing it. A dead generator that still runs is worse than no generator.

## Why it's baked to a vector path

The glyph is pure geometry, extracted once and reused everywhere, so it needs no
bundled font and no `flutter_svg` runtime dependency:

- `assets/branding/umberleaf_icon.svg` — canonical, path-based.
- `lib/shared/widgets/branding/umberleaf_glyph_path.dart` — a `ui.Path` builder for
  the in-app `QBrandMark` `CustomPainter`.
- The launcher PNGs are rasterized from the same path-based masters.

Result: the mark is identical on Android, iOS, web, and in-app, at any size.

**The leaf must be STROKED, never filled.** The path is three centerline contours;
filling it floods the silhouette into a blob and implicitly closes the midrib and
stem. `_QBrandMarkPainter` sets `PaintingStyle.stroke` with round caps and joins,
and scales the canvas so the stroke width scales with it.

## Regenerating

```bash
# 1. (Rare) redraw the mark itself — changes it for every repo.
python3 ~/projects/umberleaf-brand/generate_outline.py

# 2. Vendor the emitted files into this repo.
tool/branding/sync.sh            # or --check to verify without writing

# 3. Generate all platform launcher icons (config in pubspec.yaml).
dart run flutter_launcher_icons

# 4. Web maskable icons must be FULL-BLEED (no transparent corners), so they come
#    from the maskable master rather than from step 3, which overwrites them with
#    rounded, transparent-cornered copies every single run. Step 4 is NOT optional.
#
#    Chrome screenshots at the SVG's own declared width/height and then CROPS to
#    the window — it does not scale to fit. `master_maskable.svg` declares
#    1024x1024, so shooting it at --window-size=192,192 yields the top-left 192px
#    of the tile: a blank terracotta square with no leaf in it at all. Resize the
#    declared width/height first, keeping the viewBox, so the mark scales.
CH="google-chrome --headless --disable-gpu --hide-scrollbars --force-device-scale-factor=1"
for sz in 192 512; do
  sed "s|width=\"1024\" height=\"1024\"|width=\"$sz\" height=\"$sz\"|" \
      "$HOME/projects/umberleaf-brand/masters/master_maskable.svg" > "/tmp/maskable_$sz.svg"
  $CH --screenshot=web/icons/Icon-maskable-$sz.png --window-size=$sz,$sz "file:///tmp/maskable_$sz.svg"
done
#    Verify, because this failure is invisible: the 512 output must be byte-identical
#    to ~/projects/umberleaf-brand/png/umberleaf_maskable_512.png, and both icons
#    must be ~4.5% white pixels with an opaque #9E4B28 corner. A flat square passes
#    every build and every test, and only looks wrong on someone's home screen.

# 5. Re-mint the two mark goldens (and ONLY those two).
flutter test --update-goldens test/shared/widgets/q_brand_mark_test.dart
```

## Tuning

`generate_outline.py` constants: `FRAC` (glyph size vs the tile, 0.62) and `DY`
(optical vertical nudge). The adaptive foreground is generated larger
(`FG_FRAC = FRAC*0.80/0.60`) to offset the 16% inset `flutter_launcher_icons` bakes
into the adaptive XML, so the Android presence matches iOS; the maskable variant is
pulled in further (`MASK_FRAC`) to sit inside the ~80% safe zone. Colors: `#9E4B28`
(tile / adaptive bg / iOS corner fill), `#FAF7F1` (web PWA background) — **unchanged
by the rebrand**; the palette is the part of the identity that survived the rename.

Any change to the mark belongs in the brand repo, not here. Editing a vendored file
directly will be reported by `tool/branding/sync.sh --check` and silently reverted
by the next sync.
