import numpy as np
from stokes_order_curves import stokes_order_curves


def compute_wave_condition(H, T, d, wave_type='regular', Hkind='Hs',
                           plot_kind='Hs', N_waves=1000, g=9.81):
    omega = 2 * np.pi / T
    k = omega**2 / g
    for _ in range(200):
        f = g * k * np.tanh(k * d) - omega**2
        fp = g * np.tanh(k * d) + g * k * d / np.cosh(k * d)**2
        dk = -f / fp
        k += dk
        if abs(dk) < 1e-12:
            break
    L = 2 * np.pi / k

    if wave_type == 'regular':
        Hs = H
        Hplot = H
    else:
        Hs = _to_hs(H, Hkind, N_waves)
        Hplot = _from_hs(Hs, plot_kind, N_waves)

    dL = d / L
    HL = Hplot / L
    Ur = HL / dL**3
    dgT2 = d / (g * T**2)
    HgT2 = Hplot / (g * T**2)

    if dL < 0.05:
        regime = 'Shallow water'
    elif dL > 0.5:
        regime = 'Deep water'
    else:
        regime = 'Intermediate depth'

    HLbreak = dL * (0.141063 * dL**2 + 0.0095721 * dL + 0.0077829) / \
              (dL**3 + 0.0788340 * dL**2 + 0.0317567 * dL + 0.0093407)
    broken = HL > HLbreak

    if broken:
        theory = 'BREAKING - no periodic theory valid'
    elif Ur > 26:
        theory = 'Cnoidal wave theory'
    else:
        HL2, HL3, HL4, HL5 = stokes_order_curves(np.array([dL]))
        HL2, HL3, HL4, HL5 = HL2[0], HL3[0], HL4[0], HL5[0]
        if HL <= HL2:
            theory = 'Linear (Airy) wave'
        elif HL <= HL3:
            theory = 'Stokes 2nd order'
        elif HL <= HL4:
            theory = 'Stokes 3rd order'
        elif HL <= HL5:
            theory = 'Stokes 4th order'
        else:
            theory = 'Stokes 5th order'

    return {
        'waveType': wave_type, 'Hkind': Hkind, 'plotKind': plot_kind,
        'Hinput': H, 'Hs': Hs, 'Hplot': Hplot,
        'T': T, 'd': d, 'L': L, 'k': k,
        'dL': dL, 'HL': HL, 'Ur': Ur,
        'dgT2': dgT2, 'HgT2': HgT2,
        'regime': regime, 'HLbreak': HLbreak,
        'broken': broken, 'theory': theory,
    }


def _to_hs(H, kind, N):
    kind = kind.upper().replace('/', '')
    if kind in ('HS', 'HM0', 'H13'):
        return H
    elif kind == 'HRMS':
        return H * np.sqrt(2)
    elif kind == 'HMAX':
        return H / np.sqrt(0.5 * np.log(N))
    else:
        raise ValueError(f'Unknown Hkind: {kind}')


def _from_hs(Hs, kind, N):
    kind = kind.upper().replace('/', '')
    if kind in ('HS', 'HM0', 'H13'):
        return Hs
    elif kind == 'HRMS':
        return Hs / np.sqrt(2)
    elif kind == 'HMAX':
        return Hs * np.sqrt(0.5 * np.log(N))
    else:
        raise ValueError(f'Unknown plotKind: {kind}')
