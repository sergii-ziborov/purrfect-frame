#!/usr/bin/env python3
"""Chroma-key magenta sprites to RGBA PNG and write asset catalogs."""
from __future__ import annotations

import json
import shutil
from pathlib import Path

from PIL import Image

ROOT = Path("/Users/serhiirihgt/dev/purrfect-frame")
IMG = Path(
    "/Users/serhiirihgt/.grok/sessions/%2FUsers%2Fserhiirihgt%2Fdev/01a08320-094b-7c32-ba0d-0f3709178a62/images"
)
ASSETS = ROOT / "PurrfectFrame/Resources/Assets.xcassets"

# name -> source jpg
SPRITES = {
    "MochiIdle": "9.jpg",
    "MochiBlink": "17.jpg",
    "MochiTurn": "15.jpg",
    "MochiJump": "21.jpg",
    "MochiCover": "25.jpg",
    "MochiYawn": "47.jpg",
    "MochiDerp": "48.jpg",
    "MochiPaw": "56.jpg",
    "NoriIdle": "8.jpg",
    "NoriBlink": "12.jpg",
    "NoriTurn": "16.jpg",
    "NoriJump": "18.jpg",
    "NoriCover": "28.jpg",
    "NoriYawn": "46.jpg",
    "NoriDerp": "50.jpg",
    "NoriPaw": "52.jpg",
    "ButterIdle": "7.jpg",
    "ButterBlink": "11.jpg",
    "ButterTurn": "13.jpg",
    "ButterJump": "19.jpg",
    "ButterCover": "27.jpg",
    "ButterYawn": "49.jpg",
    "ButterDerp": "44.jpg",
    "ButterPaw": "51.jpg",
    "InkIdle": "6.jpg",
    "InkBlink": "14.jpg",
    "InkTurn": "10.jpg",
    "InkJump": "20.jpg",
    "InkCover": "37.jpg",
    "InkYawn": "45.jpg",
    "InkDerp": "43.jpg",
    "InkPaw": "57.jpg",
    "PipIdle": "26.jpg",
    "PipBlink": "34.jpg",
    "PipTurn": "33.jpg",
    "PipJump": "40.jpg",
    "PipYawn": "55.jpg",
    "PipDerp": "59.jpg",
    "PipPaw": "64.jpg",
    "WaddleIdle": "23.jpg",
    "WaddleBlink": "35.jpg",
    "WaddleTurn": "31.jpg",
    "WaddleJump": "42.jpg",
    "WaddleYawn": "58.jpg",
    "WaddleDerp": "61.jpg",
    "WaddlePaw": "65.jpg",
    "ScoopIdle": "22.jpg",
    "ScoopBlink": "32.jpg",
    "ScoopTurn": "36.jpg",
    "ScoopJump": "39.jpg",
    "ScoopYawn": "53.jpg",
    "ScoopDerp": "62.jpg",
    "ScoopPaw": "60.jpg",
    "PebbleIdle": "24.jpg",
    "PebbleBlink": "30.jpg",
    "PebbleTurn": "41.jpg",
    "PebbleJump": "38.jpg",
    "PebbleYawn": "54.jpg",
    "PebbleDerp": "66.jpg",
    "PebblePaw": "63.jpg",
    "BiscuitIdle": "78.jpg",
    "BiscuitBlink": "84.jpg",
    "BiscuitTurn": "86.jpg",
    "BiscuitJump": "98.jpg",
    "BiscuitYawn": "101.jpg",
    "PepperIdle": "79.jpg",
    "PepperBlink": "85.jpg",
    "PepperTurn": "83.jpg",
    "PepperJump": "95.jpg",
    "MapleIdle": "76.jpg",
    "MapleBlink": "88.jpg",
    "MapleTurn": "89.jpg",
    "MapleJump": "94.jpg",
    "MaplePaw": "97.jpg",
    "ScoutIdle": "75.jpg",
    "ScoutBlink": "82.jpg",
    "ScoutTurn": "87.jpg",
    "ScoutJump": "91.jpg",
    "CloverIdle": "77.jpg",
    "CloverBlink": "90.jpg",
    "CloverTurn": "100.jpg",
    "CloverJump": "99.jpg",
    "HazelIdle": "74.jpg",
    "HazelBlink": "92.jpg",
    "HazelTurn": "102.jpg",
    "FigIdle": "80.jpg",
    "FigBlink": "93.jpg",
    "FigJump": "96.jpg",
    "ThistleIdle": "81.jpg",
}

BACKGROUNDS = {
    "CafeNight": "68.jpg",
    "CafeGarden": "69.jpg",
    "PenguinIce": "71.jpg",
    "DogStudio": "67.jpg",
    "DogPark": "72.jpg",
    "RabbitGarden": "70.jpg",
    "RabbitBurrow": "73.jpg",
}

POSES = ["Idle", "Blink", "Turn", "Jump", "Cover", "Yawn", "Derp", "Paw"]
NEW_CAST = ["Biscuit", "Pepper", "Maple", "Scout", "Clover", "Hazel", "Fig", "Thistle"]


def key_magenta(path: Path) -> Image.Image:
    import colorsys

    img = Image.open(path).convert("RGBA")
    pix = img.load()
    w, h = img.size

    def plate_score(r: int, g: int, b: int) -> float:
        hh, s, v = colorsys.rgb_to_hsv(r / 255.0, g / 255.0, b / 255.0)
        # Studio plate is hot pink / magenta: hue ~0.9, saturated, bright.
        # Hot-pink plate only (not red gingham / inner-ear salmon).
        in_hue = 0.84 <= hh <= 0.96
        if in_hue and s >= 0.32 and v >= 0.38:
            return (s - 0.28) * v
        return 0.0

    for y in range(h):
        for x in range(w):
            r, g, b, _ = pix[x, y]
            score = plate_score(r, g, b)
            if score <= 0:
                a = 255
            elif score > 0.18:
                a = 0
            else:
                a = int(255 * (1.0 - score / 0.18))
            pix[x, y] = (r, g, b, a)
    bbox = img.getbbox()
    if bbox:
        pad = 24
        l, t, rgt, btm = bbox
        img = img.crop(
            (max(0, l - pad), max(0, t - pad), min(w, rgt + pad), min(h, btm + pad))
        )
    cw, ch = img.size
    side = max(cw, ch)
    canvas = Image.new("RGBA", (side, side), (0, 0, 0, 0))
    canvas.paste(img, ((side - cw) // 2, side - ch), img)
    return canvas.resize((1024, 1024), Image.Resampling.LANCZOS)


def write_imageset(name: str, png: Path) -> None:
    folder = ASSETS / f"{name}.imageset"
    folder.mkdir(parents=True, exist_ok=True)
    dest = folder / f"{name}.png"
    shutil.copyfile(png, dest)
    (folder / "Contents.json").write_text(
        json.dumps(
            {
                "images": [{"filename": f"{name}.png", "idiom": "universal"}],
                "info": {"author": "xcode", "version": 1},
            },
            indent=2,
        )
        + "\n"
    )


def main() -> None:
    staged = ROOT / "PurrfectFrame/Resources/Sprites"
    staged.mkdir(parents=True, exist_ok=True)
    written = []
    for name, src in SPRITES.items():
        src_path = IMG / src
        if not src_path.exists():
            print(f"SKIP {name} missing {src}")
            continue
        png = staged / f"{name}.png"
        keyed = key_magenta(src_path)
        keyed.save(png, optimize=True)
        write_imageset(name, png)
        written.append(name)
        print(f"OK {name} {png.stat().st_size}")
    for who in NEW_CAST:
        idle = staged / f"{who}Idle.png"
        if not idle.exists():
            continue
        for pose in POSES:
            name = f"{who}{pose}"
            dest_png = staged / f"{name}.png"
            if dest_png.exists() and dest_png.stat().st_size > 1000:
                continue
            shutil.copyfile(idle, dest_png)
            write_imageset(name, dest_png)
            written.append(name + "(idle-fill)")
            print(f"FILL {name}")
    for name, src in BACKGROUNDS.items():
        src_path = IMG / src
        if not src_path.exists():
            print(f"SKIP bg {name}")
            continue
        folder = ASSETS / f"{name}.imageset"
        folder.mkdir(parents=True, exist_ok=True)
        dest = folder / f"{name}.jpg"
        shutil.copyfile(src_path, dest)
        (folder / "Contents.json").write_text(
            json.dumps(
                {
                    "images": [{"filename": f"{name}.jpg", "idiom": "universal"}],
                    "info": {"author": "xcode", "version": 1},
                },
                indent=2,
            )
            + "\n"
        )
        print(f"BG {name}")
    print(f"wrote {len(written)} sprites")


if __name__ == "__main__":
    main()
