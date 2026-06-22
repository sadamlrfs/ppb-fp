"""Generate the MindEase leaf logo mark (run once, not bundled with the app).

Produces a white leaf silhouette with vein-shaped cutouts, matching the
launcher icon artwork in assets/icon/. Tint it at runtime with
Image.asset(..., color: ..., colorBlendMode: BlendMode.srcIn).
"""
import math
from PIL import Image, ImageDraw, ImageChops

SIZE = 1024


def make_leaf_alpha(size, scale):
    h = size * 0.62 * scale
    w = size * 0.30 * scale
    cx, cy = size / 2, size / 2

    d = (h ** 2 - w ** 2) / (4 * w)
    r = d + w / 2

    mask1 = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask1).ellipse([cx - d - r, cy - r, cx - d + r, cy + r], fill=255)
    mask2 = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask2).ellipse([cx + d - r, cy - r, cx + d + r, cy + r], fill=255)
    leaf = ImageChops.multiply(mask1, mask2)

    veins = Image.new("L", (size, size), 0)
    draw = ImageDraw.Draw(veins)
    vein_width = max(2, int(w * 0.05))

    draw.line([(cx, cy - h / 2 * 0.92), (cx, cy + h / 2 * 0.92)],
              fill=255, width=vein_width)
    for t in (-0.15, 0.05, 0.25):
        y = cy + t * h / 2
        half_w = (w / 2) * math.sqrt(max(0.0, 1 - t * t))
        length = half_w * 0.75
        angle = math.radians(28)
        dx = length * math.cos(angle)
        dy = length * math.sin(angle)
        side_w = max(2, int(vein_width * 0.7))
        draw.line([(cx, y), (cx - dx, y - dy)], fill=255, width=side_w)
        draw.line([(cx, y), (cx + dx, y - dy)], fill=255, width=side_w)

    alpha = ImageChops.subtract(leaf, veins)
    return alpha.rotate(-35, resample=Image.BICUBIC, expand=False)


alpha = make_leaf_alpha(SIZE, 1.3)
mark = Image.new("RGBA", (SIZE, SIZE), (255, 255, 255, 255))
mark.putalpha(alpha)
mark.save("assets/images/logo_mark.png")

print("done")
