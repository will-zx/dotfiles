#!/usr/bin/env python3
import glob
import json
import os
import time

DOWN_ICON = "\u2193"
UP_ICON = "\u2191"


def find_iface():
    for path in sorted(glob.glob("/sys/class/net/*/operstate")):
        with open(path) as f:
            if f.read().strip() == "up":
                return path.split("/")[4]
    for name in ("wlp4s0", "wlan0", "eth0", "eno1"):
        if os.path.exists(f"/sys/class/net/{name}"):
            return name
    return None


def read_bytes(iface):
    base = f"/sys/class/net/{iface}/statistics"
    try:
        with open(f"{base}/rx_bytes") as f:
            rx = int(f.read().strip())
        with open(f"{base}/tx_bytes") as f:
            tx = int(f.read().strip())
        return rx, tx
    except FileNotFoundError:
        return 0, 0


def human(bps):
    if bps < 1024:
        return f"{bps} B/s"
    for unit in ("KiB/s", "MiB/s", "GiB/s"):
        bps /= 1024
        if bps < 1024:
            return f"{bps:.1f} {unit}"
    return f"{bps:.1f} TiB/s"


def emit(down, up):
    payload = {
        "text": f"{DOWN_ICON} {human(down)}  {UP_ICON} {human(up)}",
        "tooltip": f"Download: {human(down)}\nUpload: {human(up)}",
    }
    print(json.dumps(payload), flush=True)


def main():
    iface = find_iface()
    if not iface:
        emit(0, 0)
        while True:
            time.sleep(5)
            emit(0, 0)
        return
    prev_rx, prev_tx = read_bytes(iface)
    emit(0, 0)
    while True:
        time.sleep(1)
        rx, tx = read_bytes(iface)
        down = max(0, rx - prev_rx)
        up = max(0, tx - prev_tx)
        prev_rx, prev_tx = rx, tx
        emit(down, up)


if __name__ == "__main__":
    main()
