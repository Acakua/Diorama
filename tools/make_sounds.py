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


def biquad_bandpass(sig, f0, q):
    """Resonant band-pass (RBJ cookbook, 0 dB peak) for formants and body resonances."""
    w0 = 2 * math.pi * f0 / RATE
    alpha = math.sin(w0) / (2 * q)
    a0 = 1 + alpha
    b0, b2 = alpha / a0, -alpha / a0
    a1, a2 = -2 * math.cos(w0) / a0, (1 - alpha) / a0
    x1 = x2 = y1 = y2 = 0.0
    out = []
    for x in sig:
        y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2
        x2, x1 = x1, x
        y2, y1 = y1, y
        out.append(y)
    return out


def formants(sig, bands):
    """Sum of resonant band-passes: [(freq, q, gain), ...]."""
    out = [0.0] * len(sig)
    for f, q, g in bands:
        for i, v in enumerate(biquad_bandpass(sig, f, q)):
            out[i] += v * g
    return out


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


# ---------------------------------------------------------------- night 1

def thump(freq, decay, sec, gain=1.0):
    return [v * gain for v in damped(freq, decay, sec, 0.002)]


def knock():
    s = [0.0] * n_samples(0.75)
    for k, at in enumerate((0.0, 0.17, 0.33)):
        g = (1.0, 0.85, 0.95)[k]
        mix_into(s, thump(190, 0.05, 0.3), at, g)
        mix_into(s, thump(410, 0.03, 0.2), at, 0.6 * g)
        mix_into(s, lowpass(noise(0.05, 0.008), 2500), at, 0.5 * g)
    return fade_out(normalize(s, 0.7), 0.05)


def rattle(count, spacing, gain):
    s = [0.0] * n_samples(count * spacing + 0.1)
    for k in range(count):
        g = gain * (0.65 ** k)
        mix_into(s, damped(2200, 0.008, 0.04), k * spacing, g)
        mix_into(s, damped(3300, 0.005, 0.03), k * spacing + 0.004, g * 0.6)
    return s


def bang():
    s = [0.0] * n_samples(0.9)
    mix_into(s, thump(55, 0.18, 0.8))
    mix_into(s, thump(95, 0.12, 0.6), 0, 0.7)
    mix_into(s, lowpass(noise(0.3, 0.05), 900), 0, 1.4)
    mix_into(s, rattle(4, 0.035, 0.25), 0.01)
    mix_into(s, creak(0.18, 160, 120, 600), 0.08, 0.6)
    return fade_out(normalize(s, 0.95), 0.08)


def door_break():
    s = [0.0] * n_samples(1.5)
    mix_into(s, thump(45, 0.3, 1.2))
    mix_into(s, lowpass(noise(0.8, 0.25), 1500), 0, 1.2)
    mix_into(s, bandpass(noise(1.2, 0.4), 300, 3000), 0.05, 0.5)
    t = 0.0
    while t < 0.8:
        tick = damped(800 + rng.random() * 1700, 0.003 + rng.random() * 0.005, 0.03)
        mix_into(s, tick, t, 0.5 * (1 - t / 0.9))
        t += 0.008 + rng.random() * 0.03 * (1 + 3 * t)
    mix_into(s, rattle(5, 0.05, 0.4), 0.0)
    return fade_out(normalize(s, 0.95), 0.2)


def groan(sec, base, seed):
    local = random.Random(seed)
    src, phase = [], 0.0
    for i in range(n_samples(sec)):
        t = i / RATE
        f = base * (1.0 - 0.2 * t / sec) * (1 + 0.035 * math.sin(2 * math.pi * 5.5 * t)) + local.uniform(-3, 3)
        phase += f / RATE
        env = math.sin(math.pi * t / sec) ** 0.8 * (0.7 + 0.3 * math.sin(2 * math.pi * 1.7 * t))
        src.append((2 * (phase % 1.0) - 1) * env)
    voiced = formants(src, ((560, 5, 1.0), (1000, 7, 0.6), (2400, 9, 0.2)))
    breath = [b * abs(e) for b, e in zip(bandpass(noise(sec), 400, 2500), src)]
    out = [math.tanh(2.0 * (v + 0.25 * b)) for v, b in zip(voiced, breath)]
    return fade_out(normalize(lowpass(out, 3000), 0.75), 0.15)


def shuffle():
    s = [0.0] * n_samples(0.95)
    for at, g in ((0.0, 1.0), (0.45, 0.7)):
        scrape = bandpass(noise(0.24), 180, 1200)
        n = len(scrape)
        env = [min(1.0, i / (0.05 * RATE)) * (1 - i / n) ** 2 for i in range(n)]
        mix_into(s, [v * e for v, e in zip(scrape, env)], at, g)
        mix_into(s, thump(90, 0.03, 0.15), at, 0.4 * g)
    return fade_out(normalize(s, 0.6), 0.05)


def chair_pickup():
    s = [0.0] * n_samples(0.25)
    for at, g in ((0.0, 1.0), (0.05, 0.6)):
        mix_into(s, damped(520, 0.03, 0.15), at, g)
        mix_into(s, damped(1150, 0.015, 0.1), at, 0.6 * g)
    return fade_out(normalize(s, 0.6), 0.03)


def chair_wedge():
    s = [0.0] * n_samples(0.6)
    scrape = bandpass(noise(0.3), 250, 1400)
    n = len(scrape)
    mix_into(s, [v * math.sin(math.pi * i / n) for i, v in enumerate(scrape)], 0, 0.8)
    mix_into(s, thump(140, 0.06, 0.25), 0.3)
    mix_into(s, damped(700, 0.02, 0.1), 0.31, 0.5)
    return fade_out(normalize(s, 0.7), 0.04)


def heartbeat():
    s = [0.0] * n_samples(0.9)
    for at, g in ((0.0, 1.0), (0.3, 0.6)):
        mix_into(s, lowpass(thump(55, 0.06, 0.3), 200), at, g)
        mix_into(s, lowpass(thump(90, 0.04, 0.2), 300), at, 0.5 * g)
    return normalize(s, 0.85)


def radio_voice():
    """Speech-like murmur through a small speaker: random vowels on a pitched buzz."""
    vowels = ((700, 1200), (400, 2000), (500, 900), (300, 2300), (650, 1700), (450, 1100))
    s = [0.0] * n_samples(4.0)
    t = 0.15
    phase = 0.0
    while t < 3.7:
        if rng.random() < 0.12:
            t += 0.25  # pause between phrases
            continue
        dur = 0.09 + rng.random() * 0.14
        f1, f2 = rng.choice(vowels)
        pitch = 125 + 25 * math.sin(t * 1.3) + rng.uniform(-8, 8)
        src = []
        for i in range(n_samples(dur)):
            phase += pitch / RATE
            env = math.sin(math.pi * i / n_samples(dur)) ** 0.6
            src.append(((2 * (phase % 1.0) - 1) * 0.8 + (rng.random() * 2 - 1) * 0.2) * env)
        syl = formants(src, ((f1, 6, 1.0), (f2, 8, 0.6)))
        mix_into(s, syl, t)
        t += dur + rng.random() * 0.04
    s = bandpass(s, 350, 2800)
    s = [math.tanh(3 * v) for v in normalize(s, 1.0)]
    hiss = highpass(noise(4.0), 2500)
    return normalize([v + h * 0.04 for v, h in zip(s, hiss)], 0.6)


def birds():
    s = [0.0] * n_samples(2.6)
    for group_at, base in ((0.1, 3400), (0.9, 4100), (1.7, 3000)):
        for k in range(3):
            at = group_at + k * 0.11
            dur = 0.07 + rng.random() * 0.03
            out, phase = [], 0.0
            for i in range(n_samples(dur)):
                x = i / n_samples(dur)
                phase += base * (1 + 0.35 * math.sin(math.pi * x)) / RATE
                out.append(math.sin(2 * math.pi * phase) * math.sin(math.pi * x))
            mix_into(s, out, at, 0.5 + rng.random() * 0.3)
    return fade_out(normalize(s, 0.5), 0.1)


# ---------------------------------------------------------------- slice 1

def hammer():
    s = [0.0] * n_samples(0.3)
    mix_into(s, damped(900, 0.02, 0.2), 0, 0.9)
    mix_into(s, damped(2400, 0.008, 0.1), 0, 0.6)
    mix_into(s, thump(160, 0.04, 0.2), 0, 0.8)
    mix_into(s, highpass(noise(0.03, 0.003), 1500), 0, 0.7)
    return fade_out(normalize(s, 0.8), 0.03)


def pry():
    s = [0.0] * n_samples(0.5)
    mix_into(s, creak(0.3, 140, 90, 700), 0.0, 1.5)
    squeak, phase = [], 0.0
    for i in range(n_samples(0.18)):
        x = i / n_samples(0.18)
        phase += (1700 - 500 * x) / RATE
        squeak.append(math.sin(2 * math.pi * phase) * math.sin(math.pi * x) * 0.3)
    mix_into(s, squeak, 0.25)
    return fade_out(normalize(s, 0.6), 0.04)


def tear():
    s = [0.0] * n_samples(0.7)
    mix_into(s, lowpass(noise(0.2, 0.04), 2500), 0, 1.2)
    t = 0.0
    while t < 0.25:
        mix_into(s, damped(600 + rng.random() * 1800, 0.004, 0.02), t, 0.6)
        t += 0.01 + rng.random() * 0.03
    mix_into(s, thump(110, 0.08, 0.4), 0.3, 0.8)
    mix_into(s, damped(520, 0.03, 0.15), 0.31, 0.5)
    return fade_out(normalize(s, 0.85), 0.06)


def rummage():
    s = [0.0] * n_samples(0.9)
    t = 0.0
    while t < 0.8:
        dur = 0.04 + rng.random() * 0.08
        burst = bandpass(noise(dur), 800 + rng.random() * 1500, 5000)
        n = len(burst)
        mix_into(s, [v * math.sin(math.pi * i / n) for i, v in enumerate(burst)], t, 0.4 + rng.random() * 0.6)
        if rng.random() < 0.3:
            mix_into(s, damped(1200 + rng.random() * 1500, 0.006, 0.03), t, 0.4)
        t += dur * 0.7 + rng.random() * 0.05
    return fade_out(normalize(s, 0.45), 0.05)


def item_found():
    s = [0.0] * n_samples(0.3)
    mix_into(s, damped(880, 0.06, 0.25), 0, 0.5)
    mix_into(s, damped(1320, 0.05, 0.2), 0.07, 0.4)
    mix_into(s, damped(2600, 0.01, 0.05), 0, 0.3)
    return fade_out(normalize(s, 0.4), 0.04)


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
    write("knock", knock())
    write("bang", bang())
    write("door_break", door_break())
    write("groan_a", groan(1.8, 95, 1))
    write("groan_b", groan(1.3, 110, 2))
    write("shuffle", shuffle())
    write("chair_pickup", chair_pickup())
    write("chair_wedge", chair_wedge())
    write("heartbeat", heartbeat(), loop=True)
    write("radio_voice", radio_voice(), loop=True)
    write("birds", birds())
    write("hammer", hammer())
    write("pry", pry())
    write("tear", tear())
    write("rummage", rummage())
    write("item_found", item_found())
