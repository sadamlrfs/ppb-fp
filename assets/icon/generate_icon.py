"""Generate MindEase launcher icon artwork (run once, not bundled with the app)."""
import math
from PIL import Image, ImageDraw, ImageChops

SIZE = 1024

PRIMARY_LIGHT = (129, 199, 132)  # #81C784
PRIMARY_DARK = (56, 142, 60)     # #388E3C
VEIN_COLOR = PRIMARY_DARK + (255,)


def make_gradient(size, color1, color2):
    base = Image.new("RGB", (size, size), color1)
    top = Image.new("RGB", (size, size), color2)
    mask = Image.new("L", (size, size))
    mask.putdata([
        int(255 * (x + y) / (2 * size))
        for y in range(size)
        for x in range(size)
    ])
    return Image.composite(top, base, mask)


def make_leaf(size, scale):
    """A pointed leaf (vesica) shape with a vein pattern, rotated to lean to the right."""
    h = size * 0.62 * scale
    w = size * 0.30 * scale
    cx, cy = size / 2, size / 2

    d = (h ** 2 - w ** 2) / (4 * w)
    r = d + w / 2

    mask1 = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask1).ellipse([cx - d - r, cy - r, cx - d + r, cy + r], fill=255)
    mask2 = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask2).ellipse([cx + d - r, cy - r, cx + d + r, cy + r], fill=255)
    lens = ImageChops.multiply(mask1, mask2)

    leaf = Image.new("RGBA", (size, size), (255, 255, 255, 255))
    leaf.putalpha(lens)

    draw = ImageDraw.Draw(leaf)
    vein_width = max(2, int(w * 0.045))

    # central vein, base to tip
    draw.line([(cx, cy - h / 2 * 0.92), (cx, cy + h / 2 * 0.92)],
              fill=VEIN_COLOR, width=vein_width)

    # side veins branching toward the top tip
    for t in (-0.15, 0.05, 0.25):
        y = cy + t * h / 2
        half_w = (w / 2) * math.sqrt(max(0.0, 1 - t * t))
        length = half_w * 0.75
        angle = math.radians(28)
        dx = length * math.cos(angle)
        dy = length * math.sin(angle)
        side_w = max(2, int(vein_width * 0.6))
        draw.line([(cx, y), (cx - dx, y - dy)], fill=VEIN_COLOR, width=side_w)
        draw.line([(cx, y), (cx + dx, y - dy)], fill=VEIN_COLOR, width=side_w)

    return leaf.rotate(-35, resample=Image.BICUBIC, expand=False)


# Main icon: gradient background + leaf (used for iOS/web/macOS/windows)
bg = make_gradient(SIZE, PRIMARY_LIGHT, PRIMARY_DARK).convert("RGBA")
icon = bg.copy()
icon.alpha_composite(make_leaf(SIZE, 0.85))
icon.convert("RGB").save("assets/icon/icon.png")

# Adaptive icon background (gradient only)
bg.convert("RGB").save("assets/icon/icon_background.png")

# Adaptive icon foreground (leaf only, scaled to fit the safe zone)
make_leaf(SIZE, 0.62).save("assets/icon/icon_foreground.png")

print("done")
