#!/usr/bin/env python3
"""Synthesise the prototype's small sound set into assets/audio/ (16-bit mono WAV).

No samples or third-party libraries: every sound is a few damped sines and
filtered noise, so the files are tiny, license-free and easy to tweak.
The radio loop carries a WAV 'smpl' chunk, which Godot's importer reads as
loop points. Run from anywhere:

    python tools/make_sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 22050
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "assets", "audio")
rng = random.Random(7)


# ---------------------------------------------------------------- primitives

def n_samples(sec):
    return int(sec * RATE)


def mix_into(buf, sig, at=0.0, gain=1.0):
    start = n_samples(at)
    if start + len(sig) > len(buf):
        buf.extend([0.0] * (start + len(sig) - len(buf)))
    for i, v in enumerate(sig):
        buf[start + i] += v * gain
    return buf


def damped(freq, decay, sec, attack=0.0005):
    out = []
    for i in range(n_samples(sec)):
        t = i / RATE
        env = math.exp(-t / decay) * min(1.0, t / attack if attack else 1.0)
        out.append(math.sin(2 * math.pi * freq * t) * env)
    return out


def noise(sec, decay=None):
    out = []
    for i in range(n_samples(sec)):
        env = math.exp(-i / RATE / decay) if decay else 1.0
        out.append((rng.random() * 2 - 1) * env)
    return out


def lowpass(sig, cutoff):
    a = 1 - math.exp(-2 * math.pi * cutoff / RATE)
    y, out = 0.0, []
    for v in sig:
        y += a * (v - y)
        out.append(y)
    return out


def highpass(sig, cutoff):
    return [v - lp for v, lp in zip(sig, lowpass(sig, cutoff))]


def bandpass(sig, lo, hi):
    return lowpass(highpass(sig, lo), hi)


def normalize(sig, peak=0.8):
    top = max(1e-9, max(abs(v) for v in sig))
    return [v * peak / top for v in sig]


def fade_out(sig, sec=0.01):
    n = min(len(sig), n_samples(sec))
    for i in range(n):
        sig[len(sig) - n + i] *= 1 - i / n
    return sig


def creak(sec, rate_from, rate_to, body_hz, gain=1.0):
    """Stick-slip friction: a train of tiny resonant ticks at a wobbling rate."""
    out = [0.0] * n_samples(sec + 0.02)
    t, phase = 0.0, 0.0
    while t < sec:
        rate = rate_from + (rate_to - rate_from) * t / sec + 12 * math.sin(2 * math.pi * 5.3 * t)
        phase += rate / RATE
        if phase >= 1.0:
            phase -= 1.0
            env = math.sin(math.pi * t / sec) ** 1.5 * (0.6 + 0.4 * rng.random())
            tick = damped(body_hz * (0.85 + 0.3 * rng.random()), 0.004, 0.02)
            mix_into(out, tick, t, env * gain)
        t += 1 / RATE
    return bandpass(out, 250, 2600)


# ---------------------------------------------------------------- effects

def switch_click():
    s = [0.0] * n_samples(0.09)
    hit = [a + b for a, b in zip(highpass(noise(0.03, 0.0012), 1500), damped(3800, 0.003, 0.03))]
    mix_into(s, hit)
    mix_into(s, hit, 0.017, 0.35)
    return fade_out(normalize(s, 0.7))


def latch(gain=1.0):
    s = [0.0] * n_samples(0.08)
    for f, d, g in ((1650, 0.015, 1.0), (2450, 0.010, 0.7), (3900, 0.006, 0.5)):
        mix_into(s, damped(f, d, 0.08), 0, g)
    mix_into(s, highpass(noise(0.03, 0.004), 1000), 0, 0.8)
    return [v * gain for v in s]


def door_open():
    s = [0.0] * n_samples(0.75)
    mix_into(s, latch())
    mix_into(s, latch(0.4), 0.12)
    mix_into(s, creak(0.48, 70, 150, 520), 0.15, 2.2)
    return fade_out(normalize(s, 0.7), 0.05)


def door_close():
    s = [0.0] * n_samples(0.45)
    mix_into(s, damped(75, 0.06, 0.4, 0.002))
    mix_into(s, damped(140, 0.035, 0.3, 0.001), 0, 0.6)
    mix_into(s, lowpass(noise(0.15, 0.025), 400), 0, 1.5)
    mix_into(s, latch(0.45), 0.012)
    return fade_out(normalize(s, 0.8), 0.05)


def cabinet_open():
    s = [0.0] * n_samples(0.4)
    mix_into(s, damped(2600, 0.006, 0.05), 0, 0.8)
    mix_into(s, highpass(noise(0.02, 0.002), 1500), 0, 0.6)
    mix_into(s, creak(0.26, 120, 210, 900), 0.06, 1.6)
    return fade_out(normalize(s, 0.55), 0.04)


def cabinet_close():
    s = [0.0] * n_samples(0.25)
    mix_into(s, damped(260, 0.025, 0.2, 0.001))
    mix_into(s, damped(610, 0.015, 0.15, 0.0005), 0, 0.6)
    mix_into(s, lowpass(noise(0.05, 0.008), 2000), 0, 0.8)
    mix_into(s, damped(900, 0.005, 0.05), 0.05, 0.2)
    return fade_out(normalize(s, 0.65), 0.03)


def radio_button():
    s = [0.0] * n_samples(0.55)
    hit = [a + b for a, b in zip(damped(2100, 0.004, 0.03), highpass(noise(0.03, 0.002), 2000))]
    mix_into(s, hit)
    mix_into(s, hit, 0.022, 0.4)
    # Tuning: a burst of static with a falling whistle.
    static = bandpass(noise(0.4), 800, 3000)
    whistle = []
    phase = 0.0
    for i in range(n_samples(0.4)):
        t = i / RATE
        phase += (1300 - 900 * t / 0.4) / RATE
        whistle.append(math.sin(2 * math.pi * phase) * 0.25)
    tune = [(a + b) * math.sin(math.pi * i / len(static)) for i, (a, b) in enumerate(zip(static, whistle))]
    mix_into(s, tune, 0.05, 0.12)
    return fade_out(normalize(s, 0.6), 0.03)


# ---------------------------------------------------------------- radio loop

BPM = 84
BEAT = 60 / BPM
BARS = [  # chord tones (MIDI), bass root
    ((60, 64, 67, 71), 48),  # Cmaj7
    ((57, 60, 64, 67), 45),  # Am7
    ((62, 65, 69, 72), 50),  # Dm7
    ((55, 59, 62, 65), 43),  # G7
]
MELODY = [  # (bar, beat, length in beats, MIDI)
    (0, 0, 1, 76), (0, 1, .5, 79), (0, 1.5, .5, 81), (0, 2, 1, 79), (0, 3, 1, 76),
    (1, 0, 1.5, 72), (1, 1.5, .5, 74), (1, 2, 2, 76),
    (2, 0, 1, 77), (2, 1, .5, 76), (2, 1.5, .5, 74), (2, 2, 1, 72), (2, 3, 1, 69),
    (3, 0, 1.5, 71), (3, 1.5, .5, 74), (3, 2, 2, 67),
]


def hz(midi):
    return 440.0 * 2 ** ((midi - 69) / 12)


def tone(freq, sec, decay, partials=((1, 1.0),), attack=0.006):
    out = []
    for i in range(n_samples(sec)):
        t = i / RATE
        env = min(1.0, t / attack) * math.exp(-t / decay)
        out.append(env * sum(g * math.sin(2 * math.pi * freq * k * t) for k, g in partials))
    return out


def radio_music():
    loop_sec = len(BARS) * 4 * BEAT
    total = [0.0] * n_samples(loop_sec * 3)
    keys = ((1, 1.0), (2, 0.3), (3, 0.08))
    vibe = ((1, 1.0), (4, 0.15))
    bass = ((1, 1.0), (2, 0.4))
    for rep in range(3):
        base = rep * loop_sec
        for bar, (chord, root) in enumerate(BARS):
            t0 = base + bar * 4 * BEAT
            for beat in (0.0, 1.5, 2.5):  # comping
                for m in chord:
                    mix_into(total, tone(hz(m), 1.4, 0.5, keys), t0 + beat * BEAT, 0.07)
            for beat, m in ((0, root), (1, root + 7), (2, root + 12), (3, root + 7)):  # walking-ish bass
                mix_into(total, tone(hz(m), 0.6, 0.3, bass, 0.01), t0 + beat * BEAT, 0.28)
            for beat in (1, 3):  # brushes
                mix_into(total, bandpass(noise(0.12, 0.05), 2500, 7000), t0 + beat * BEAT, 0.12)
            for beat in (0.5, 1.5, 2.5, 3.5):
                mix_into(total, bandpass(noise(0.06, 0.02), 3000, 8000), t0 + beat * BEAT, 0.05)
        for bar, beat, length, m in MELODY:
            t = base + (bar * 4 + beat) * BEAT
            mix_into(total, tone(hz(m), length * BEAT + 0.6, 0.55, vibe), t, 0.16)
    # Keep the middle repeat: its start already contains the previous tails,
    # so the loop seam is inaudible.
    start = n_samples(loop_sec)
    music = total[start:start + n_samples(loop_sec)]
    # Small-speaker colour: band-limit, soften, then hiss and crackle.
    music = bandpass(music, 220, 3200)
    music = normalize(music, 1.0)
    music = [math.tanh(1.6 * v) / math.tanh(1.6) for v in music]
    hiss = highpass(noise(loop_sec), 2500)
    music = [v * 0.9 + h * 0.015 for v, h in zip(music, hiss)]
    for _ in range(int(loop_sec * 3)):
        i = rng.randrange(len(music) - 40)
        pop = damped(1800 + rng.random() * 2000, 0.0015, 0.004)
        for k, v in enumerate(pop):
            music[i + k] += v * (0.05 + rng.random() * 0.08)
    return normalize(music, 0.7)


# ---------------------------------------------------------------- output

def write(name, sig, loop=False):
    path = os.path.join(OUT, name + ".wav")
    data = struct.pack("<%dh" % len(sig), *(int(max(-1.0, min(1.0, v)) * 32767) for v in sig))
    with wave.open(path, "wb") as w:
        w.setnchannels(1)
        w.setsampwidth(2)
        w.setframerate(RATE)
        w.writeframes(data)
    if loop:
        smpl = struct.pack("<9I", 0, 0, int(1e9 / RATE), 60, 0, 0, 0, 1, 0)
        smpl += struct.pack("<6I", 0, 0, 0, len(sig) - 1, 0, 0)
        with open(path, "r+b") as f:
            f.seek(0, 2)
            f.write(b"smpl" + struct.pack("<I", len(smpl)) + smpl)
            size = f.tell()
            f.seek(4)
            f.write(struct.pack("<I", size - 8))
    print("%-16s %6.2f s" % (name, len(sig) / RATE))


if __name__ == "__main__":
    os.makedirs(OUT, exist_ok=True)
    write("switch_click", switch_click())
    write("door_open", door_open())
    write("door_close", door_close())
    write("cabinet_open", cabinet_open())
    write("cabinet_close", cabinet_close())
    write("radio_button", radio_button())
    write("radio_music", radio_music(), loop=True)
