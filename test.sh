#!/usr/bin/env bash
# usage: ./test.sh [ticks...]   compares the complete frame of the RTL with the Python reference
set -e; cd "$(dirname "$0")"; mkdir -p build docs/img
PY=${PY:-python3}; "$PY" -c '' 2>/dev/null || PY=python
for TICKS in ${@:-120 600 1500 4000 9000}; do
  iverilog -g2012 -DTICKS=$TICKS -o build/tb.vvp sim/tb_breakout.sv rtl/breakout_game.sv rtl/breakout_pixel.sv
  vvp build/tb.vvp >/dev/null
  "$PY" tools/refbreakout.py $TICKS > build/ref_breakout.txt
  diff -q build/ref_breakout.txt build/rtl_breakout.txt >/dev/null && echo "PASS: $TICKS ticks" || { echo "FAIL: $TICKS ticks"; diff build/ref_breakout.txt build/rtl_breakout.txt | head -5; exit 1; }
done
"$PY" tools/fb2png.py build/rtl_breakout.txt docs/img/sim-breakout.png 6
