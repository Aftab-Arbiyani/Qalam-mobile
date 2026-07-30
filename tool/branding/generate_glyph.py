"""Generate the Qalam brand glyph assets from the KacstNaskh qaf (U+0642).

Emits (deterministic, font-free at runtime):
  - assets/branding/qalam_icon.svg           canonical path-based brand SVG
  - lib/shared/widgets/branding/qalam_glyph_path.dart   ui.Path builder (in-app)
  - build/branding/master_*.svg              raster sources for the launcher PNGs

See tool/branding/README.md for the full pipeline (rasterize + flutter_launcher_icons).
Requires: python3-fonttools, and the KacstNaskh font (fonts-kacst) installed.
"""

import os

from fontTools.ttLib import TTFont
from fontTools.pens.svgPathPen import SVGPathPen
from fontTools.pens.transformPen import TransformPen
from fontTools.pens.boundsPen import BoundsPen
from fontTools.pens.recordingPen import RecordingPen

FONT="/usr/share/fonts/truetype/kacst/KacstNaskh.ttf"
TERRA="#9E4B28"
REPO=os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
SP="build/branding"  # scratch dir for raster-source SVGs (git-ignored)

font=TTFont(FONT); gname=font.getBestCmap()[0x0642]; gs=font.getGlyphSet()
bp=BoundsPen(gs); gs[gname].draw(bp)
xMin,yMin,xMax,yMax=bp.bounds; gw,gh=xMax-xMin,yMax-yMin; mx,my=(xMin+xMax)/2,(yMin+yMax)/2

def xf(canvas,frac,dy):
    s=frac*canvas/max(gw,gh); cx,cy=canvas/2,canvas/2+dy*canvas
    return (s,0,0,-s,cx-mx*s,cy+my*s)

def svg_d(canvas,frac,dy):
    pen=SVGPathPen(gs); gs[gname].draw(TransformPen(pen,xf(canvas,frac,dy))); return pen.getCommands()

def full_svg(canvas,frac,dy,rounded=True):
    r=112/512*canvas if rounded else 0
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{canvas}" height="{canvas}" viewBox="0 0 {canvas} {canvas}">'
            f'<rect width="{canvas}" height="{canvas}" rx="{r:.1f}" fill="{TERRA}"/><path d="{svg_d(canvas,frac,dy)}" fill="#FFFFFF"/></svg>\n')
def fg_svg(canvas,frac):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{canvas}" height="{canvas}" viewBox="0 0 {canvas} {canvas}">'
            f'<path d="{svg_d(canvas,frac,0)}" fill="#FFFFFF"/></svg>\n')

FRAC,DY=0.60,-0.02
os.makedirs(f"{REPO}/{SP}", exist_ok=True)
SP=f"{REPO}/{SP}"
open(f"{REPO}/assets/branding/qalam_icon.svg","w").write(full_svg(1024,FRAC,DY))
open(f"{SP}/master_full.svg","w").write(full_svg(1024,FRAC,DY))
open(f"{SP}/master_fg.svg","w").write(fg_svg(1024,0.80))
open(f"{SP}/master_maskable.svg","w").write(full_svg(1024,0.50,0,rounded=False))

# Dart path via RecordingPen (explicit quadratic expansion for TrueType contours)
rp=RecordingPen(); gs[gname].draw(TransformPen(rp,xf(1000,FRAC,DY)))
def mid(a,b): return ((a[0]+b[0])/2,(a[1]+b[1])/2)
lines=[]
for op,args in rp.value:
    if op=='moveTo': p=args[0]; lines.append(f'    ..moveTo({p[0]:.2f}, {p[1]:.2f})')
    elif op=='lineTo': p=args[0]; lines.append(f'    ..lineTo({p[0]:.2f}, {p[1]:.2f})')
    elif op=='qCurveTo':
        pts=list(args); end=pts[-1]; offs=pts[:-1]
        for i,c in enumerate(offs):
            on=end if i==len(offs)-1 else mid(c,offs[i+1])
            lines.append(f'    ..quadraticBezierTo({c[0]:.2f}, {c[1]:.2f}, {on[0]:.2f}, {on[1]:.2f})')
    elif op=='curveTo':
        pts=list(args)
        for i in range(0,len(pts),3):
            c1,c2,e=pts[i],pts[i+1],pts[i+2]
            lines.append(f'    ..cubicTo({c1[0]:.2f}, {c1[1]:.2f}, {c2[0]:.2f}, {c2[1]:.2f}, {e[0]:.2f}, {e[1]:.2f})')
    elif op=='closePath': lines.append('    ..close()')
body="\n".join(lines)
dart=f'''/// GENERATED — do not edit by hand.
///
/// The Qalam brand glyph: the isolated Arabic letter qaf (qaf, U+0642) as a
/// resolution-independent [Path] in a 1000x1000 icon box, extracted from the
/// KacstNaskh Naskh typeface — the deterministic stand-in for the "Noto Naskh
/// Arabic" mark the brand SVG requests. Baking the outline to a path means the
/// mark renders identically on every platform with no bundled font and no
/// flutter_svg dependency.
library;

import 'dart:ui';

/// Design-space size the path is authored in; scale by `size / kQalamGlyphBox`.
const double kQalamGlyphBox = 1000;

/// Build the qaf outline (fill with the default non-zero rule).
Path buildQalamGlyphPath() {{
  return Path()
{body};
}}
'''
open(f"{REPO}/lib/shared/widgets/branding/qalam_glyph_path.dart","w").write(dart)
print("OK | dart ops:",len(lines),"| bounds",bp.bounds)
