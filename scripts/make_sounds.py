"""Synthesises the game's sound effects and converts them to .caf.

python3 scripts/make_sounds.py
"""
import math
import os
import random
import struct
import subprocess
import tempfile
import wave

RATE = 44100
OUT = os.path.join(os.path.dirname(__file__), "..", "FlappyDog", "Resources", "Sounds")


def write(name, samples):
    with tempfile.TemporaryDirectory() as tmp:
        wav = os.path.join(tmp, name + ".wav")
        with wave.open(wav, "wb") as w:
            w.setnchannels(1)
            w.setsampwidth(2)
            w.setframerate(RATE)
            w.writeframes(b"".join(struct.pack("<h", int(max(-1, min(1, s)) * 32000)) for s in samples))
        subprocess.run(["afconvert", "-f", "caff", "-d", "LEI16", wav, os.path.join(OUT, name + ".caf")], check=True)


def env(t, length, attack=0.005):
    return min(1, t / attack) * max(0, 1 - t / length) ** 2


def flap():
    # Soft whoosh: low-passed noise with a quick swell.
    random.seed(1)
    length, out, lp = 0.16, [], 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        lp += (random.uniform(-1, 1) - lp) * (0.08 + 0.25 * t / length)
        out.append(lp * 2.2 * env(t, length, 0.03))
    return out


def score():
    # "Boop": a short sine that bends up.
    length, out, phase = 0.14, [], 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        phase += 2 * math.pi * (660 + 600 * t / length) / RATE
        out.append(0.55 * math.sin(phase) * env(t, length))
    return out


def crash():
    # Cartoon bonk: a falling pitch with a woody overtone.
    length, out, phase = 0.35, [], 0.0
    for i in range(int(RATE * length)):
        t = i / RATE
        phase += 2 * math.pi * (320 * math.exp(-t * 7) + 70) / RATE
        out.append((0.7 * math.sin(phase) + 0.25 * math.sin(phase * 2.7)) * env(t, length, 0.002))
    return out


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    for name, make in [("flap", flap), ("score", score), ("crash", crash)]:
        write(name, make())
        print("wrote", name + ".caf")
