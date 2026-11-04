#!/usr/bin/env python3
"""Screenshot over the board's USB-UART on Windows/any pyserial platform: 'BRKO' + 2400 bytes (160x120, 1 bit/px).
usage: capture_win.py COM6 out.png"""
import os, subprocess, sys, time, serial
s = serial.Serial(sys.argv[1], 115200, timeout=0.2); buf = b''; t = time.time()
while time.time() - t < 10:
    buf += s.read(8192)
    i = buf.find(b'BRKO')
    if i >= 0 and len(buf) >= i + 2404:
        pkt = buf[i+4:i+2404]
        lines = [''.join('#' if (pkt[(r*160+c)//8] >> (7-(r*160+c)%8)) & 1 else '.' for c in range(160)) for r in range(120)]
        txt = os.path.splitext(sys.argv[2])[0] + '.txt'
        open(txt, 'w').write('\n'.join(lines) + '\n')
        subprocess.run([sys.executable, os.path.join(os.path.dirname(os.path.abspath(__file__)), 'fb2png.py'), txt, sys.argv[2], '6'], check=True)
        print('captured'); sys.exit(0)
print('no frame, got', len(buf), 'bytes'); sys.exit(1)
