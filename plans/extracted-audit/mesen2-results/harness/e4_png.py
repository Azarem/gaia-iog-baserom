#!/usr/bin/env python3
"""E4 PNG helper (stdlib only): pixel diff between two screenshots, or the colour of given pixels. Harness only, reads the capture.

usage:
    python e4_png.py diff a.png b.png            # differing pixels, bounding box, rows with differences
    python e4_png.py px a.png x,y [x,y ...]
"""
import struct
import sys
import zlib


def read_png(path):
    data = open(path, "rb").read()
    assert data[:8] == b"\x89PNG\r\n\x1a\n"
    pos, idat, w = 8, b"", None
    while pos < len(data):
        ln, typ = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + ln]
        pos += 12 + ln
        if typ == b"IHDR":
            w, h, depth, ctype, _, _, interlace = struct.unpack(">IIBBBBB", body)
            assert depth == 8 and interlace == 0 and ctype in (2, 6), (depth, ctype, interlace)
            bpp = 3 if ctype == 2 else 4
        elif typ == b"IDAT":
            idat += body
    raw = zlib.decompress(idat)
    stride = w * bpp
    rows, prev = [], bytearray(stride)
    i = 0
    for _ in range(h):
        f = raw[i]
        line = bytearray(raw[i + 1:i + 1 + stride])
        i += 1 + stride
        for x in range(stride):
            a = line[x - bpp] if x >= bpp else 0
            b = prev[x]
            c = prev[x - bpp] if x >= bpp else 0
            if f == 1:
                line[x] = (line[x] + a) & 255
            elif f == 2:
                line[x] = (line[x] + b) & 255
            elif f == 3:
                line[x] = (line[x] + ((a + b) >> 1)) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                pr = a if pa <= pb and pa <= pc else (b if pb <= pc else c)
                line[x] = (line[x] + pr) & 255
        rows.append(line)
        prev = line
    return w, h, bpp, rows


def pix(img, x, y):
    w, h, bpp, rows = img
    r = rows[y]
    return tuple(r[x * bpp:x * bpp + 3])


if __name__ == "__main__":
    cmd = sys.argv[1]
    if cmd == "diff":
        a, b = read_png(sys.argv[2]), read_png(sys.argv[3])
        w, h = a[0], a[1]
        cnt, x0, x1, y0, y1, rowsd = 0, 9999, -1, 9999, -1, {}
        for y in range(h):
            for x in range(w):
                if pix(a, x, y) != pix(b, x, y):
                    cnt += 1
                    x0, x1, y0, y1 = min(x0, x), max(x1, x), min(y0, y), max(y1, y)
                    rowsd[y] = rowsd.get(y, 0) + 1
        ys = sorted(rowsd)
        spans, start = [], None
        for i, y in enumerate(ys):
            if start is None:
                start = y
            if i + 1 == len(ys) or ys[i + 1] != y + 1:
                spans.append((start, y))
                start = None
        print(f"size={w}x{h} diff={cnt} bbox x={x0}-{x1} y={y0}-{y1} rowspans={spans[:12]}")
    elif cmd == "px":
        img = read_png(sys.argv[2])
        for xy in sys.argv[3:]:
            x, y = map(int, xy.split(","))
            print(xy, pix(img, x, y))
