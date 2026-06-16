import numpy as np


def plot_wave_point(ax, cond, label='', marker_size=24, font_size=11,
                    font_name='Times New Roman', marker_color=None,
                    show_label=True):
    if marker_color is not None:
        col = marker_color
    elif cond['broken']:
        col = (1, 0, 0)
    elif cond['waveType'] == 'irregular':
        col = (0, 0.35, 0.8)
    else:
        col = (0, 0.55, 0)

    if cond['broken']:
        mk = 'x'
        sz = marker_size + 12
    else:
        mk = 'o'
        sz = marker_size

    s = sz ** 2 / 4
    ax.scatter(cond['dL'], cond['HL'], s=s, c=[col], marker=mk,
               edgecolors='none', zorder=5)

    if show_label and label:
        ax.text(cond['dL'] * 1.08, cond['HL'] * 1.05, label,
                fontsize=font_size, fontname=font_name, fontweight='bold',
                color=col, zorder=6)
