"""
Wave Theory Interactive - matplotlib widgets version
运行: python interactive.py
"""
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from matplotlib.widgets import TextBox, Button, RadioButtons
import numpy as np
from compute_wave_condition import compute_wave_condition
from plot_base_chart import plot_base_chart
from plot_wave_point import plot_wave_point

fig = plt.figure(figsize=(18/2.54, 12/2.54), dpi=150)
fig.patch.set_facecolor('white')
fig.canvas.manager.set_window_title('Wave Theory Interactive')

ax_chart = fig.add_axes([0.05, 0.05, 0.60, 0.90])
plot_base_chart(ax_chart)

ax_input = fig.add_axes([0.70, 0.60, 0.28, 0.35])
ax_input.set_xlim(0, 1)
ax_input.set_ylim(0, 1)
ax_input.axis('off')
ax_input.set_title('Input', fontsize=11, fontweight='bold', pad=10)

ax_result = fig.add_axes([0.70, 0.05, 0.28, 0.50])
ax_result.set_xlim(0, 1)
ax_result.set_ylim(0, 1)
ax_result.axis('off')
ax_result.set_title('Result', fontsize=11, fontweight='bold', pad=10)

labels_text = []
results = []

def on_submit(text):
    try:
        parts = [x.strip() for x in text.split(',')]
        H, T, d = float(parts[0]), float(parts[1]), float(parts[2])
        label = parts[3] if len(parts) > 3 else f'C{len(results)+1}'

        c = compute_wave_condition(H, T, d)
        plot_wave_point(ax_chart, c, label)
        results.append((c, label))

        ax_result.clear()
        ax_result.axis('off')
        ax_result.set_title('Result', fontsize=11, fontweight='bold', pad=10)
        lines = [
            f'Label : {label}',
            f'H     = {H:.3f} m',
            f'T     = {T:.3f} s',
            f'd     = {d:.3f} m',
            f'L     = {c["L"]:.3f} m',
            f'd/L   = {c["dL"]:.4f}',
            f'H/L   = {c["HL"]:.4f}',
            f'Ur    = {c["Ur"]:.2f}',
            f'Regime: {c["regime"]}',
            f'Break : {"YES" if c["broken"] else "no"}',
            '---',
            f'Theory: {c["theory"]}',
        ]
        for i, line in enumerate(lines):
            ax_result.text(0.05, 0.92 - i * 0.07, line, fontsize=9,
                           fontname='Consolas', transform=ax_result.transAxes)
        fig.canvas.draw_idle()
    except Exception as e:
        ax_result.clear()
        ax_result.axis('off')
        ax_result.text(0.05, 0.9, f'Error: {e}', fontsize=9, color='red',
                       transform=ax_result.transAxes)

ax_textbox = fig.add_axes([0.70, 0.96, 0.28, 0.03])
textbox = TextBox(ax_textbox, 'H, T, d, Label: ', initial='1.0, 6.0, 5.0, C1')
textbox.on_submit(on_submit)

def on_clear(event):
    ax_chart.clear()
    plot_base_chart(ax_chart)
    results.clear()
    ax_result.clear()
    ax_result.axis('off')
    ax_result.set_title('Result', fontsize=11, fontweight='bold', pad=10)
    ax_result.text(0.05, 0.9, 'Cleared.', fontsize=9, transform=ax_result.transAxes)
    fig.canvas.draw_idle()

ax_clear = fig.add_axes([0.70, 0.92, 0.13, 0.03])
btn_clear = Button(ax_clear, 'Clear', color=(1, 0.82, 0.82))
btn_clear.on_clicked(on_clear)

def on_export(event):
    if not results:
        return
    import datetime
    ts = datetime.datetime.now().strftime('%Y%m%d_%H%M%S')
    fig.savefig(f'wave_theory_chart_{ts}.png', dpi=1200, bbox_inches='tight',
                facecolor='white')
    print(f'Exported: wave_theory_chart_{ts}.png')

ax_export = fig.add_axes([0.85, 0.92, 0.13, 0.03])
btn_export = Button(ax_export, 'Export PNG', color=(0.95, 0.88, 0.80))
btn_export.on_clicked(on_export)

plt.show()
