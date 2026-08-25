#!/usr/bin/env python3
import json
import time

IFACE = "wlan0"
RX_PATH = f"/sys/class/net/{IFACE}/statistics/rx_bytes"
TX_PATH = f"/sys/class/net/{IFACE}/statistics/tx_bytes"

DOWN_ICON = "\u2193"
UP_ICON = "\u2191"


def read(path):
    with open(path) as f:
        return int(f.read().strip())


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
    prev_rx, prev_tx = read(RX_PATH), read(TX_PATH)
    emit(0, 0)
    while True:
        time.sleep(1)
        rx, tx = read(RX_PATH), read(TX_PATH)
        down = max(0, rx - prev_rx)
        up = max(0, tx - prev_tx)
        prev_rx, prev_tx = rx, tx
        emit(down, up)


if __name__ == "__main__":
    main()
