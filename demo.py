"""
Wave Theory Selector - Python Demo
运行: python demo.py
"""
import matplotlib
matplotlib.use('TkAgg')
import matplotlib.pyplot as plt
from compute_wave_condition import compute_wave_condition
from plot_base_chart import plot_base_chart
from plot_wave_point import plot_wave_point

fig, ax = plt.subplots(figsize=(12/2.54, 12/2.54), dpi=150)
fig.patch.set_facecolor('white')
fig.canvas.manager.set_window_title('Wave Theory Chart (12 x 12 cm)')

plot_base_chart(ax)

test_cases = [
    (1.0, 6.0, 5.0, 'regular', 'C1'),
    (2.0, 8.0, 5.0, 'regular', 'C2'),
    (3.0, 10.0, 8.0, 'regular', 'C3'),
]

for H, T, d, wtype, label in test_cases:
    c = compute_wave_condition(H, T, d, wave_type=wtype)
    plot_wave_point(ax, c, label)
    print(f'{label}: H={H}, T={T}, d={d} -> {c["theory"]}')

fig.tight_layout()
plt.show()
