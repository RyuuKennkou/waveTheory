import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import LogLocator, LogFormatterSciNotation
from stokes_order_curves import stokes_order_curves


def plot_base_chart(ax=None, font_name='Times New Roman',
                    axis_label_fs=11, tick_fs=10, text_fs=9):
    if ax is None:
        fig, ax = plt.subplots(figsize=(12/2.54, 12/2.54), dpi=150)
        fig.patch.set_facecolor('white')

    ax.set_xscale('log')
    ax.set_yscale('log')
    ax.set_xlim(1e-2, 1)
    ax.set_ylim(1e-5, 0.3)
    ax.set_xlabel(r'$d\,/\,L$  [-]', fontsize=axis_label_fs, fontname=font_name)
    ax.set_ylabel(r'$H\,/\,L$  [-]', fontsize=axis_label_fs, fontname=font_name)
    ax.tick_params(axis='both', which='major', labelsize=tick_fs, direction='in',
                   length=5, width=0.8, pad=3)
    ax.tick_params(axis='both', which='minor', direction='in', length=3, width=0.5)
    ax.xaxis.set_minor_locator(LogLocator(base=10, subs=np.arange(2, 10) * 0.1, numticks=100))
    ax.yaxis.set_minor_locator(LogLocator(base=10, subs=np.arange(2, 10) * 0.1, numticks=100))
    for spine in ax.spines.values():
        spine.set_linewidth(0.8)

    dL = np.logspace(np.log10(1e-2), np.log10(1), 400)
    HL2, HL3, HL4, HL5 = stokes_order_curves(dL)

    HLbreak = dL * (0.141063 * dL**2 + 0.0095721 * dL + 0.0077829) / \
              (dL**3 + 0.0788340 * dL**2 + 0.0317567 * dL + 0.0093407)
    HL_Ur = 26 * dL**3

    yMin, yMax = 1e-5, 0.3

    def fill_band(ylo, yhi, col, alpha):
        ylo = np.maximum(ylo, yMin)
        yhi = np.minimum(yhi, yMax)
        ok = ylo < yhi
        if not np.any(ok):
            return
        xf = np.concatenate([dL[ok], dL[ok][::-1]])
        yf = np.concatenate([ylo[ok], yhi[ok][::-1]])
        ax.fill(xf, yf, color=col, alpha=alpha, edgecolor='none', zorder=0)

    fill_band(np.full_like(dL, yMin), np.minimum(np.minimum(HL2, HL_Ur), HLbreak),
              (0.94, 0.97, 0.99), 0.55)
    fill_band(HL2, np.minimum(np.minimum(HL3, HL_Ur), HLbreak),
              (0.78, 0.90, 0.98), 0.55)
    fill_band(HL3, np.minimum(np.minimum(HL4, HL_Ur), HLbreak),
              (0.62, 0.82, 0.96), 0.55)
    fill_band(HL4, np.minimum(np.minimum(HL5, HL_Ur), HLbreak),
              (0.48, 0.72, 0.94), 0.55)
    fill_band(HL5, np.minimum(HL_Ur, HLbreak),
              (0.35, 0.60, 0.90), 0.55)
    fill_band(HL_Ur, HLbreak, (0.98, 0.82, 0.60), 0.60)
    fill_band(HLbreak, np.full_like(dL, yMax), (1, 1, 1), 1.0)

    HL2c = HL2.copy(); HL2c[HL2 > HLbreak] = np.nan
    HL3c = HL3.copy(); HL3c[HL3 > HLbreak] = np.nan
    HL4c = HL4.copy(); HL4c[HL4 > HLbreak] = np.nan
    HL5c = HL5.copy(); HL5c[HL5 > HLbreak] = np.nan
    HL_Urc = HL_Ur.copy(); HL_Urc[(HL_Ur > HLbreak) | (HL_Ur < yMin) | (HL_Ur > yMax)] = np.nan

    yLine = [yMin, yMax]
    ax.plot([0.05, 0.05], yLine, '--', color=(0.45, 0.45, 0.45), lw=0.6, zorder=1)
    ax.plot([0.5, 0.5], yLine, '--', color=(0.45, 0.45, 0.45), lw=0.6, zorder=1)

    ax.plot(dL, HL2c, 'k-', lw=0.8, zorder=2)
    ax.plot(dL, HL3c, 'k-', lw=0.8, zorder=2)
    ax.plot(dL, HL4c, 'k-', lw=0.8, zorder=2)
    ax.plot(dL, HL5c, 'k-', lw=0.8, zorder=2)
    ax.plot(dL, HLbreak, '-', color=(0.10, 0.45, 0.85), lw=1.5, zorder=2)
    msk = ~np.isnan(HL_Urc)
    ax.plot(dL[msk], HL_Urc[msk], ':', color=(0.85, 0.35, 0.10), lw=1.3, zorder=2)

    kw = dict(fontsize=text_fs, fontname=font_name, color=(0.3, 0.3, 0.3))
    ax.text(0.022, 3.5e-5, 'Shallow', ha='center', **kw)
    ax.text(0.158, 3.5e-5, 'Intermediate', ha='center', **kw)
    ax.text(0.72, 3.5e-5, 'Deep', ha='center', **kw)

    ax.text(0.05, 6e-4, r'$d/L = 0.05$', rotation=90, ha='center', va='center',
            fontsize=text_fs*0.9, fontname=font_name, color=(0.3, 0.3, 0.3),
            bbox=dict(facecolor='white', edgecolor='none', pad=1), zorder=3)
    ax.text(0.5, 6e-4, r'$d/L = 0.5$', rotation=90, ha='center', va='center',
            fontsize=text_fs*0.9, fontname=font_name, color=(0.3, 0.3, 0.3),
            bbox=dict(facecolor='white', edgecolor='none', pad=1), zorder=3)

    ax.text(0.93, 0.0268, '2nd order', ha='right', fontsize=text_fs, fontname=font_name)
    ax.text(0.93, 0.05, '3rd order', ha='right', fontsize=text_fs, fontname=font_name)
    ax.text(0.93, 0.071, '4th order', ha='right', fontsize=text_fs, fontname=font_name)
    ax.text(0.93, 0.100, '5th order', ha='right', fontsize=text_fs, fontname=font_name)

    ax.text(0.11, 0.20, 'Breaking criterion', color=(0.10, 0.45, 0.85),
            fontname=font_name, fontsize=text_fs, fontweight='bold')
    ax.text(0.027, 1.2e-3, 'Cnoidal wave theory', color=(0.85, 0.35, 0.10),
            fontname=font_name, fontsize=text_fs, rotation=58)
    ax.text(0.055, 2.0e-3, r'$Ur = 26$', color=(0.10, 0.45, 0.85),
            fontname=font_name, fontsize=text_fs, rotation=58)
    ax.text(0.12, 7e-4, 'Stokes wave, linear',
            fontname=font_name, fontsize=text_fs+1)

    ax.set_axisbelow(False)
    ax.set_zorder(10)
    return ax
