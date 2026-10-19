#!/usr/bin/env python3
"""Synthesise the game's sound set into assets/audio/ (16-bit mono WAV).

No samples or third-party libraries: every sound is built from damped modes
(the way a struck door or floorboard rings), filtered noise and a simple
voice model, so the files are license-free and easy to tweak. Short, sharp
sounds are written at 44.1 kHz; steady beds and the radio at 22.05 kHz.
Loops carry a WAV 'smpl' chunk, which Godot's importer reads as loop points,
and are cross-faded end to start so the seam is silent. Run from anywhere:

    python tools/make_sounds.py
"""
import math
import os
import random
import struct
import wave

RATE = 44100
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


def lp(sig, cutoff, order=3):
    """Steeper low-pass: one-pole stages in a row."""
    for _ in range(order):
        sig = lowpass(sig, cutoff)
    return sig


def bp(sig, lo, hi, order=2):
    for _ in range(order):
        sig = lowpass(highpass(sig, lo), hi)
    return sig


def normalize(sig, peak=0.8):
    top = max(1e-9, max(abs(v) for v in sig))
    return [v * peak / top for v in sig]


def fade_out(sig, sec=0.01):
    n = min(len(sig), n_samples(sec))
    for i in range(n):
        sig[len(sig) - n + i] *= 1 - i / n
    return sig


def zeros(sec):
    return [0.0] * n_samples(sec)


def noise_r(r, sec, decay=None):
    """White noise from a given generator (so each take differs but is repeatable)."""
    out = []
    for i in range(n_samples(sec)):
        env = math.exp(-i / RATE / decay) if decay else 1.0
        out.append((r.random() * 2 - 1) * env)
    return out


def brown(r, sec):
    """Brown noise: a deep rumble (leaky integral of white noise)."""
    out, y = [], 0.0
    for _ in range(n_samples(sec)):
        y = 0.998 * y + (r.random() * 2 - 1) * 0.04
        out.append(y)
    return out


def modes(bank, sec, r, attack=0.0008):
    """A struck object: damped sines [(freq, decay, gain), ...] with random phases."""
    out = [0.0] * n_samples(sec)
    for f, d, g in bank:
        ph = r.random() * 2 * math.pi
        for i in range(len(out)):
            t = i / RATE
            e = math.exp(-t / d)
            if e < 1e-4:
                break
            out[i] += g * e * min(1.0, t / attack) * math.sin(2 * math.pi * f * t + ph)
    return out


def shaped(sig, env):
    n = len(sig)
    return [v * env(i / n) for i, v in enumerate(sig)]


def loop_crossfade(sig, sec, pad):
    """Fold the `pad` seconds generated past `sec` back over the start, so the
    loop's end flows into its beginning."""
    n, m = n_samples(sec), n_samples(pad)
    out = sig[:n]
    for i in range(m):
        w = i / m
        out[i] = out[i] * w + sig[n + i] * (1 - w)
    return out


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


# A flat's front door, struck: its panel's lowest bending modes, a little
# shifted per take.
DOOR_MODES = ((86, 0.07, 1.0), (141, 0.055, 0.7), (214, 0.04, 0.55), (317, 0.03, 0.4),
              (452, 0.02, 0.3), (690, 0.012, 0.18), (1040, 0.007, 0.1))


def door_hit(r, strength, sec=0.6):
    """One blow: a soft fist impact rings the panel; the latch ticks in the frame."""
    s = zeros(sec)
    mix_into(s, lp(noise_r(r, 0.014, 0.003), 500 + 1200 * strength), 0, 1.2 * strength)
    bank = [(f * r.uniform(0.96, 1.04), d * (0.8 + 0.4 * strength), g) for f, d, g in DOOR_MODES]
    mix_into(s, modes(bank, sec, r, 0.0015), 0, strength)
    at = 0.004
    for k in range(1 + int(3 * strength)):
        tick = modes(((r.uniform(2300, 2900), 0.006, 1.0), (r.uniform(3700, 4600), 0.004, 0.6)), 0.04, r)
        mix_into(s, tick, at, 0.05 * strength * 0.7 ** k)
        at += r.uniform(0.012, 0.026)
    return s


def knock(seed):
    """Three uneven fist blows: not a polite rhythm."""
    r = random.Random(seed)
    s = zeros(1.0)
    t = 0.0
    for _ in range(3):
        mix_into(s, door_hit(r, r.uniform(0.5, 0.8)), t)
        t += r.uniform(0.15, 0.3)
    return fade_out(normalize(s, 0.75), 0.06)


def rattle(count, spacing, gain):
    s = [0.0] * n_samples(count * spacing + 0.1)
    for k in range(count):
        g = gain * (0.65 ** k)
        mix_into(s, damped(2200, 0.008, 0.04), k * spacing, g)
        mix_into(s, damped(3300, 0.005, 0.03), k * spacing + 0.004, g * 0.6)
    return s


def bang(seed):
    """A body thrown against the door: a deep thud, the panel ringing hard,
    the frame and latch rattling, the wood complaining."""
    r = random.Random(seed)
    s = zeros(1.2)
    mix_into(s, modes(((r.uniform(44, 54), 0.16, 1.0), (r.uniform(70, 84), 0.1, 0.6)), 1.0, r, 0.004), 0, 0.9)
    mix_into(s, door_hit(r, 1.0, 1.0), 0.003, 0.9)
    mix_into(s, lowpass(noise_r(r, 0.35, 0.06), 650), 0, 0.9)
    mix_into(s, rattle(5, 0.03, 0.22), 0.012)
    if r.random() < 0.6:
        mix_into(s, highpass(noise_r(r, 0.025, 0.004), 1800), 0.02, 0.25)
    mix_into(s, creak(0.2, 150, 110, 600), 0.1, 0.5)
    return fade_out(normalize(s, 0.95), 0.1)


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


VOWELS = {"o": (450, 800, 2830), "a": (730, 1090, 2440), "u": (330, 700, 2530),
          "uh": (520, 1190, 2390), "e": (530, 1840, 2480)}


def formant_track(sig, path, bandwidths=(90, 120, 170), gains=(1.0, 0.55, 0.22)):
    """Three formant resonators gliding through `path` (a list of vowels) over
    the signal's length; coefficients are updated every 64 samples."""
    n = len(sig)
    out = [0.0] * n
    for k in range(3):
        x1 = x2 = y1 = y2 = 0.0
        b0 = b2 = a1 = a2 = 0.0
        for i, x in enumerate(sig):
            if i % 64 == 0:
                pos = i / n * (len(path) - 1)
                j = min(int(pos), len(path) - 2)
                w = pos - j
                w = w * w * (3 - 2 * w)
                f = VOWELS[path[j]][k] * (1 - w) + VOWELS[path[j + 1]][k] * w
                w0 = 2 * math.pi * f / RATE
                alpha = math.sin(w0) / (2 * f / bandwidths[k])
                a0 = 1 + alpha
                b0, b2 = alpha / a0, -alpha / a0
                a1, a2 = -2 * math.cos(w0) / a0, (1 - alpha) / a0
            y = b0 * x + b2 * x2 - a1 * y1 - a2 * y2
            x2, x1 = x1, x
            y2, y1 = y1, y
            out[i] += y * gains[k]
    return out


def groan(sec, base, seed, path=("uh", "o", "a", "u")):
    """A ruined throat: glottal pulses with jitter and shimmer, falling into
    creaky fry; breath; a wet rattle at the end; gliding vowels."""
    r = random.Random(seed)
    n = n_samples(sec)
    src = [0.0] * (n + n_samples(0.1))
    t = 0.02
    while t < sec - 0.05:
        x = t / sec
        f0 = base * (1.06 - 0.32 * x + 0.1 * math.sin(math.pi * x * 1.4)) * (1 + 0.03 * math.sin(2 * math.pi * 4.7 * t))
        period = 1 / f0 * (1 + r.uniform(-0.05, 0.05))
        if x > 0.55 and r.random() < 0.6:  # vocal fry: slow, irregular pulses
            period *= r.uniform(1.4, 2.3)
        amp = math.sin(math.pi * x) ** 0.6 * (1 + r.uniform(-0.18, 0.18))
        start, m = n_samples(t), max(4, n_samples(period))
        opening, closing = int(0.5 * m), max(2, int(0.18 * m))
        for k in range(opening):  # Rosenberg pulse
            src[start + k] += amp * 0.5 * (1 - math.cos(math.pi * k / opening))
        for k in range(closing):
            src[start + opening + k] += amp * math.cos(math.pi * k / (2 * closing))
        t += period
    src = src[:n]
    flow = [src[i] - src[i - 1] if i else 0.0 for i in range(n)]  # the lips radiate the derivative
    voiced = formant_track(flow, path)
    envelope = [abs(v) for v in lowpass(src, 30)]
    peak = max(envelope) or 1.0
    breath = [b * (0.25 + e / peak) for b, e in zip(bandpass(noise_r(r, sec), 300, 4000), envelope)]
    breath = formant_track(breath, path, (200, 260, 320))
    out = [math.tanh(3.0 * (v + 0.35 * b)) for v, b in zip(normalize(voiced, 1.0), normalize(breath, 1.0))]
    # A wet rattle in the throat towards the end.
    wet = bandpass(noise_r(r, sec * 0.45), 200, 900)
    rate = r.uniform(18, 26)
    wet = [v * (0.5 + 0.5 * math.copysign(1, math.sin(2 * math.pi * rate * i / RATE))) * math.sin(math.pi * i / len(wet))
           for i, v in enumerate(wet)]
    mix_into(out, normalize(wet, 0.25), sec * 0.5)
    out = out[:n]
    return fade_out(normalize(lowpass(highpass(out, 70), 3800), 0.75), 0.15)


def zombie_breath():
    """Loop: ragged breathing at the door, wet and uneven. Starts and ends silent."""
    r = random.Random(41)
    total = 7.4
    s = zeros(total)
    t = 0.15
    while t < total - 1.9:
        inh, exh = r.uniform(0.6, 0.95), r.uniform(0.9, 1.3)
        seg = formants(noise_r(r, inh), ((r.uniform(900, 1300), 4, 1.0), (2500, 6, 0.4)))
        mix_into(s, shaped(seg, lambda x: math.sin(math.pi * x) ** 1.5 * (0.4 + 0.6 * x)), t, 0.35)
        t += inh + r.uniform(0.05, 0.15)
        seg = formants(noise_r(r, exh), ((r.uniform(420, 620), 4, 1.0), (1100, 6, 0.45)))
        fry = r.uniform(38, 55)
        seg = [v * (0.55 + 0.45 * (1 if math.sin(2 * math.pi * fry * i / RATE) > 0.3 else 0)) for i, v in enumerate(seg)]
        mix_into(s, shaped(seg, lambda x: min(1.0, x * 8) * (1 - x) ** 1.2), t, 0.55)
        t += exh + r.uniform(0.25, 0.7)
    return normalize(lowpass(s, 4000), 0.5)


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


def footstep(seed, surface):
    """One step in shoes: heel, then toe, a scuff of the sole. Wooden boards
    ring and sometimes creak; the corridor runner swallows most of it."""
    r = random.Random(seed)
    soft = surface == "carpet"
    s = zeros(0.45)
    heel = r.uniform(0.85, 1.0)
    if soft:
        bank = ((r.uniform(70, 90), 0.03, 1.0), (r.uniform(140, 170), 0.02, 0.35))
        mix_into(s, lp(noise_r(r, 0.03, 0.006), 450), 0, 1.4 * heel)
    else:
        bank = ((r.uniform(90, 115), 0.035, 1.0), (r.uniform(185, 230), 0.025, 0.55),
                (r.uniform(330, 400), 0.016, 0.35), (r.uniform(600, 720), 0.009, 0.2))
        mix_into(s, lp(noise_r(r, 0.02, 0.003), 1600), 0, 1.3 * heel)
    mix_into(s, modes(bank, 0.3, r), 0, 0.55 * heel)
    toe = r.uniform(0.05, 0.085)
    mix_into(s, lp(noise_r(r, 0.015, 0.002), 700 if soft else 2200), toe, 0.5)
    mix_into(s, modes([(f * 1.12, d * 0.7, g) for f, d, g in bank], 0.15, r), toe, 0.2)
    scuff = bp(noise_r(r, r.uniform(0.05, 0.09)), 250 if soft else 900, 1200 if soft else 4000)
    mix_into(s, shaped(scuff, lambda x: math.sin(math.pi * x) ** 2), r.uniform(0.0, 0.03), 0.08 if soft else 0.12)
    if not soft and r.random() < 0.3:
        mix_into(s, creak(r.uniform(0.08, 0.16), 220, 160, r.uniform(500, 800)), 0.02, 0.22)
    return fade_out(normalize(s, 0.5), 0.05)


def drag_step(seed):
    """The thing's walk: a heavy flat-footed plant, then the bad foot dragged."""
    r = random.Random(seed)
    s = zeros(0.8)
    mix_into(s, lp(noise_r(r, 0.03, 0.006), 700), 0, 1.3)
    mix_into(s, modes(((r.uniform(60, 80), 0.05, 1.0), (r.uniform(130, 160), 0.03, 0.5),
                       (r.uniform(260, 320), 0.02, 0.25)), 0.35, r), 0, 0.6)
    drag = bp(noise_r(r, r.uniform(0.3, 0.45)), 200, 1400)
    wob = r.uniform(9, 14)
    drag = [v * (0.7 + 0.3 * math.sin(2 * math.pi * wob * i / RATE)) for i, v in enumerate(drag)]
    mix_into(s, shaped(drag, lambda x: min(1.0, x * 6) * (1 - x) ** 1.5), r.uniform(0.12, 0.2), 0.45)
    return fade_out(normalize(s, 0.55), 0.05)


def handle_rattle():
    """Trying a locked door: the handle goes down, the bolt knocks in the keep, twice."""
    r = random.Random(23)
    s = zeros(0.6)
    for at, g in ((0.0, 1.0), (0.24, 0.8)):
        mix_into(s, modes(((r.uniform(1900, 2300), 0.012, 1.0), (r.uniform(3300, 3800), 0.007, 0.6),
                           (r.uniform(5200, 6000), 0.004, 0.35)), 0.08, r), at, 0.5 * g)
        mix_into(s, door_hit(r, 0.25, 0.25), at + 0.03, 0.5 * g)
        mix_into(s, latch(0.5 * g), at + 0.09)
    return fade_out(normalize(s, 0.6), 0.04)


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


# ---------------------------------------------------------------- beds (loops)

def siren(r, sec):
    """A far-off wail, washed out by distance and bounced between buildings."""
    out, phase = [], 0.0
    rate = r.uniform(0.16, 0.22)
    for i in range(n_samples(sec)):
        t = i / RATE
        phase += (720 + 260 * math.sin(2 * math.pi * rate * t)) / RATE
        v = math.sin(2 * math.pi * phase) + 0.3 * math.sin(4 * math.pi * phase)
        out.append(v * math.sin(math.pi * t / sec) ** 1.5)
    out = lowpass(out, 1100)
    echoed = list(out)
    for delay, g in ((0.33, 0.45), (0.71, 0.3), (1.2, 0.18)):
        mix_into(echoed, out, delay, g)
    return echoed


def helicopter(r, sec):
    """Rotor thumps far away, swelling in and out."""
    out = zeros(sec)
    t, rate = 0.0, r.uniform(11.5, 13.5)
    while t < sec - 0.1:
        g = math.sin(math.pi * t / sec) ** 2
        mix_into(out, modes(((r.uniform(55, 70), 0.025, 1.0),), 0.08, r), t, g)
        mix_into(out, lowpass(noise_r(r, 0.04, 0.01), 300), t, 0.6 * g)
        t += 1 / rate
    return lowpass(out, 400)


def outside(day):
    """What comes through the glass: the city three days into it. Few cars,
    wind, a siren somewhere; by day birds and a helicopter far off."""
    r = random.Random(11 if day else 12)
    sec, pad = 24.0, 3.0
    total = sec + pad
    s = zeros(total)
    rumble = normalize(highpass(highpass(lowpass(brown(r, total), 160), 35), 35), 1.0)
    mix_into(s, [v * (0.75 + 0.25 * math.sin(2 * math.pi * 0.07 * i / RATE)) for i, v in enumerate(rumble)],
             0, 0.35 if day else 0.18)
    wind = normalize(bp(noise_r(r, total), 200, 800), 1.0)
    gust = [(0.55 + 0.45 * (math.sin(2 * math.pi * 0.11 * i / RATE) + 0.6 * math.sin(2 * math.pi * 0.043 * i / RATE + 1)) / 1.6)
            for i in range(len(wind))]
    mix_into(s, [w * g for w, g in zip(wind, gust)], 0, 0.12 if day else 0.2)
    mix_into(s, normalize(siren(r, 9.0), 1.0), 4.0 if day else 13.0, 0.13 if day else 0.08)
    if day:
        mix_into(s, normalize(helicopter(r, 10.0), 1.0), 13.0, 0.12)
        for at in (2.0, 9.5, 17.0, 21.5):
            mix_into(s, birds(), at, 0.18)
    else:
        crash = lowpass(highpass(noise_r(r, 0.5, 0.12), 900), 3000)
        mix_into(s, crash, 8.0, 0.06)
    return normalize(lp(loop_crossfade(s, sec, pad), 2500, 2), 0.6)


def fridge_hum():
    """An old fridge's compressor: mains hum and its harmonics, a faint whine."""
    r = random.Random(31)
    sec, pad = 6.0, 1.0
    s = []
    for i in range(n_samples(sec + pad)):
        t = i / RATE
        wob = 1 + 0.08 * math.sin(2 * math.pi * 0.5 * t)
        v = sum(g * math.sin(2 * math.pi * 50 * k * t + k) for k, g in
                ((1, 1.0), (2, 0.6), (3, 0.35), (4, 0.25), (6, 0.12), (8, 0.06)))
        s.append(v * wob + 0.04 * math.sin(2 * math.pi * 1000 * t))
    buzz = bandpass(noise_r(r, sec + pad), 100, 600)
    s = [v + b * 0.25 * (1 + math.sin(2 * math.pi * 100 * i / RATE)) for i, (v, b) in enumerate(zip(s, buzz))]
    return normalize(loop_crossfade(s, sec, pad), 0.5)


def bulb_hum():
    """A tired bulb on old wiring: a buzzing 100 Hz and the odd crackle."""
    r = random.Random(32)
    sec, pad = 4.0, 1.0
    s = []
    for i in range(n_samples(sec + pad)):
        t = i / RATE
        s.append(sum(math.sin(2 * math.pi * 100 * k * t) / k ** 1.3 for k in range(1, 12)))
    s = normalize(s, 1.0)
    for _ in range(14):
        at = r.uniform(0, sec + pad - 0.05)
        mix_into(s, highpass(noise_r(r, 0.006, 0.0015), 2000), at, r.uniform(0.2, 0.6))
    return normalize(loop_crossfade(s, sec, pad), 0.5)


def clock_tick():
    """Loop: tick ... tock. A small mechanism in a wooden case."""
    r = random.Random(33)
    s = zeros(2.0)
    for at, pitch in ((0.0, 1.0), (1.0, 0.86)):
        mix_into(s, bp(noise_r(r, 0.004, 0.0008), 1500, 5000, 1), at, 0.5)
        mix_into(s, modes(((3100 * pitch, 0.004, 1.0), (4700 * pitch, 0.003, 0.6), (6900 * pitch, 0.002, 0.4),
                           (880 * pitch, 0.012, 0.35)), 0.08, r), at, 0.5)
    return normalize(s, 0.6)


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

def write(name, make, loop=False, rate=44100):
    """Builds the sound at `rate` (the primitives read RATE) and saves it."""
    global RATE
    RATE = rate
    sig = make()
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
    write("switch_click", switch_click)
    write("door_open", door_open)
    write("door_close", door_close)
    write("cabinet_open", cabinet_open)
    write("cabinet_close", cabinet_close)
    write("radio_button", radio_button)
    write("radio_music", radio_music, loop=True, rate=22050)
    for i in range(3):
        write("knock_%d" % i, lambda: knock(100 + i))
    for i in range(2):
        write("bang_%d" % i, lambda: bang(200 + i))
    write("door_break", door_break)
    write("handle_rattle", handle_rattle)
    write("groan_a", lambda: groan(1.8, 92, 1))
    write("groan_b", lambda: groan(1.3, 108, 2, ("o", "a", "uh")))
    write("groan_c", lambda: groan(2.6, 84, 3, ("u", "o", "a", "uh", "u")))
    write("zombie_breath", zombie_breath, loop=True, rate=22050)
    for i in range(4):
        write("step_drag_%d" % i, lambda: drag_step(300 + i))
    for surface in ("wood", "carpet"):
        for i in range(6):
            write("step_%s_%d" % (surface, i), lambda: footstep(400 + i + (0 if surface == "wood" else 50), surface))
    write("chair_pickup", chair_pickup)
    write("chair_wedge", chair_wedge)
    write("heartbeat", heartbeat, loop=True)
    write("radio_voice", radio_voice, loop=True, rate=22050)
    write("birds", birds)
    write("hammer", hammer)
    write("pry", pry)
    write("tear", tear)
    write("rummage", rummage)
    write("item_found", item_found)
    write("outside_day", lambda: outside(True), loop=True, rate=22050)
    write("outside_night", lambda: outside(False), loop=True, rate=22050)
    write("hum_fridge", fridge_hum, loop=True, rate=22050)
    write("hum_bulb", bulb_hum, loop=True, rate=22050)
    write("clock_tick", clock_tick, loop=True)
