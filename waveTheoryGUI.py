"""
Wave Theory GUI - Python/PyQt5 version
与 MATLAB 版本功能一致的桌面应用
运行: python waveTheoryGUI.py
"""
import sys
import os
import numpy as np
from datetime import datetime
from PyQt5.QtWidgets import (
    QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout,
    QGridLayout, QGroupBox, QLabel, QComboBox, QLineEdit, QPushButton,
    QTableWidget, QTableWidgetItem, QTextEdit, QCheckBox, QHeaderView
)
from PyQt5.QtCore import Qt
from PyQt5.QtGui import QFont
import matplotlib
matplotlib.use('Qt5Agg')
import matplotlib.pyplot as plt
plt.rcParams['font.family'] = 'serif'
plt.rcParams['font.serif'] = ['Times New Roman']
plt.rcParams['mathtext.fontset'] = 'stix'
from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
from matplotlib.lines import Line2D

from compute_wave_condition import compute_wave_condition

FONT = 'Times New Roman'

MARKER_COLORS = {
    'Red': (1, 0, 0), 'Green': (0, 0.55, 0), 'Blue': (0, 0.35, 0.8),
    'Yellow': (1, 1, 0), 'Magenta': (1, 0, 1), 'Cyan': (0, 1, 1),
    'Black': (0, 0, 0), 'White': (1, 1, 1),
}


class WaveChart(FigureCanvas):
    def __init__(self, parent=None):
        self.fig = Figure(figsize=(12/2.54, 12/2.54), dpi=200)
        self.fig.patch.set_facecolor('white')
        self.ax = self.fig.add_axes([0.15, 0.13, 0.80, 0.82])
        super().__init__(self.fig)
        self.setParent(parent)
        self.results = []
        self.current_marker_size = 10
        self._draw_base()

    def _draw_base(self):
        from plot_base_chart import plot_base_chart
        self.ax.clear()
        plot_base_chart(self.ax)
        self.draw()

    def add_point(self, cond, label, marker_size=24, marker_color=None, show_label=True):
        from plot_wave_point import plot_wave_point
        plot_wave_point(self.ax, cond, label,
                        marker_size=marker_size, marker_color=marker_color,
                        show_label=show_label)
        if marker_color is not None:
            actual_color = marker_color
        elif cond['broken']:
            actual_color = (1, 0, 0)
        elif cond['waveType'] == 'irregular':
            actual_color = (0, 0.35, 0.8)
        else:
            actual_color = (0, 0.55, 0)
        self.current_marker_size = marker_size
        self.results.append({'label': label, 'cond': cond, 'color': actual_color})
        self.draw()

    def clear_points(self):
        self.results.clear()
        self._draw_base()

    def toggle_legend(self):
        if not self.results:
            return False
        leg = self.ax.get_legend()
        if leg is not None:
            leg.remove()
            for line in self.ax.get_lines():
                if line.get_label() == '_nolegend_':
                    line.remove()
            self.draw()
            return False
        seen = {}
        for r in self.results:
            lab = r['label']
            if lab not in seen:
                seen[lab] = r
        handles = []
        for lab, r in seen.items():
            c = r['color'] if r['color'] else (0, 0.55, 0)
            mk = 'x' if r['cond']['broken'] else 'o'
            h = Line2D([0], [0], marker=mk, color='none', markerfacecolor=c,
                       markeredgecolor='none',
                       markersize=self.current_marker_size * 0.4,
                       label=lab)
            handles.append(h)
        self.ax.legend(handles=handles, loc='upper left',
                       fontsize=8, prop={'family': FONT, 'size': 8},
                       frameon=True, fancybox=False, shadow=False,
                       edgecolor='black', framealpha=1.0,
                       borderpad=0.4, labelspacing=0.25,
                       handlelength=1.5, handletextpad=0.4,
                       bbox_to_anchor=(0.01, 0.99))
        self.ax.get_legend().get_frame().set_linewidth(0.4)
        self.draw()
        return True


class WaveTheoryGUI(QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle('Wave Theory Controls v5')
        self.setFixedSize(1000, 720)

        central = QWidget()
        self.setCentralWidget(central)
        main_layout = QHBoxLayout(central)
        main_layout.setSpacing(8)

        left = QVBoxLayout()
        left.setSpacing(6)
        left.addWidget(self._create_input_panel())
        left.addWidget(self._create_result_panel())
        main_layout.addLayout(left, 1)

        right = QVBoxLayout()
        right.setSpacing(6)
        right.addWidget(self._create_batch_panel())
        right.addWidget(self._create_action_panel())
        right.addWidget(self._create_export_panel())
        main_layout.addLayout(right, 2)

        self.chart = WaveChart()
        self.chart.setWindowTitle('Wave Theory Chart  (12 x 12 cm)')
        self.chart.show()

        self._on_type_changed()

    def _create_input_panel(self):
        grp = QGroupBox('Single wave condition')
        grp.setFont(QFont(FONT, 10, QFont.Bold))
        grid = QGridLayout(grp)
        grid.setVerticalSpacing(6)
        grid.setHorizontalSpacing(8)

        row = 0
        grid.addWidget(self._label('Wave type'), row, 0)
        self.dd_type = QComboBox()
        self.dd_type.addItems(['regular', 'irregular'])
        self.dd_type.currentTextChanged.connect(self._on_type_changed)
        grid.addWidget(self.dd_type, row, 1)

        row += 1
        grid.addWidget(self._label('H  (m)'), row, 0)
        self.eH = QLineEdit('1.0')
        grid.addWidget(self.eH, row, 1)

        row += 1
        grid.addWidget(self._label('T  (s)'), row, 0)
        self.eT = QLineEdit('6.0')
        grid.addWidget(self.eT, row, 1)

        row += 1
        grid.addWidget(self._label('d  (m)'), row, 0)
        self.eh = QLineEdit('5.0')
        grid.addWidget(self.eh, row, 1)

        row += 1
        grid.addWidget(self._label('Label'), row, 0)
        self.eLab = QLineEdit('C1')
        grid.addWidget(self.eLab, row, 1)

        row += 1
        grid.addWidget(self._label('Marker color'), row, 0)
        self.dd_marker = QComboBox()
        self.dd_marker.addItems(['Auto', 'Red', 'Green', 'Blue', 'Yellow',
                                 'Magenta', 'Cyan', 'Black', 'White'])
        grid.addWidget(self.dd_marker, row, 1)

        row += 1
        grid.addWidget(self._label('Point size'), row, 0)
        self.eSize = QLineEdit('10')
        grid.addWidget(self.eSize, row, 1)

        row += 1
        self.cb_label = QCheckBox('Show label')
        self.cb_label.setChecked(False)
        self.cb_label.setFont(QFont(FONT, 9))
        grid.addWidget(self.cb_label, row, 0, 1, 2)

        row += 1
        self.lbl_hkind = self._label('Input H is')
        grid.addWidget(self.lbl_hkind, row, 0)
        self.dd_hkind = QComboBox()
        self.dd_hkind.addItems(['Hs', 'H1/3', 'Hm0', 'Hrms', 'Hmax'])
        grid.addWidget(self.dd_hkind, row, 1)

        row += 1
        self.lbl_plot = self._label('Plot as')
        grid.addWidget(self.lbl_plot, row, 0)
        self.dd_plot = QComboBox()
        self.dd_plot.addItems(['Hs', 'H1/3', 'Hrms', 'Hmax'])
        grid.addWidget(self.dd_plot, row, 1)

        row += 1
        self.lbl_n = self._label('N waves')
        grid.addWidget(self.lbl_n, row, 0)
        self.eN = QLineEdit('1000')
        grid.addWidget(self.eN, row, 1)

        return grp

    def _create_result_panel(self):
        grp = QGroupBox('Result')
        grp.setFont(QFont(FONT, 10, QFont.Bold))
        layout = QVBoxLayout(grp)
        self.result_text = QTextEdit()
        self.result_text.setReadOnly(True)
        self.result_text.setFont(QFont('Consolas', 10))
        self.result_text.setPlainText('Result will be shown here.')
        layout.addWidget(self.result_text)
        return grp

    def _create_batch_panel(self):
        grp = QGroupBox('Batch input')
        grp.setFont(QFont(FONT, 10, QFont.Bold))
        layout = QVBoxLayout(grp)
        layout.setSpacing(6)

        self.table = QTableWidget(2, 5)
        self.table.setHorizontalHeaderLabels(['H(m)', 'T(s)', 'd(m)', 'Type', 'Label'])
        self.table.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
        self.table.verticalHeader().setVisible(False)
        self.table.setFont(QFont(FONT, 9))
        self.table.setItem(0, 0, QTableWidgetItem('1.0'))
        self.table.setItem(0, 1, QTableWidgetItem('6.0'))
        self.table.setItem(0, 2, QTableWidgetItem('5.0'))
        self.table.setItem(0, 3, QTableWidgetItem('regular'))
        self.table.setItem(0, 4, QTableWidgetItem('C1'))
        self.table.setItem(1, 0, QTableWidgetItem('2.0'))
        self.table.setItem(1, 1, QTableWidgetItem('8.0'))
        self.table.setItem(1, 2, QTableWidgetItem('5.0'))
        self.table.setItem(1, 3, QTableWidgetItem('irregular'))
        self.table.setItem(1, 4, QTableWidgetItem('C2'))
        layout.addWidget(self.table)

        btn_row = QHBoxLayout()
        btn_row.setSpacing(6)
        btn_add = QPushButton('Add')
        btn_add.setFont(QFont(FONT, 9))
        btn_add.setFixedHeight(30)
        btn_add.clicked.connect(self._add_row)
        btn_row.addWidget(btn_add)

        btn_rm = QPushButton('Remove')
        btn_rm.setFont(QFont(FONT, 9))
        btn_rm.setFixedHeight(30)
        btn_rm.clicked.connect(self._remove_row)
        btn_row.addWidget(btn_rm)

        btn_plot = QPushButton('Plot all')
        btn_plot.setFont(QFont(FONT, 9, QFont.Bold))
        btn_plot.setFixedHeight(30)
        btn_plot.setStyleSheet('background-color: #ccf2cc;')
        btn_plot.clicked.connect(self._on_plot_batch)
        btn_row.addWidget(btn_plot)

        layout.addLayout(btn_row)
        return grp

    def _create_action_panel(self):
        widget = QWidget()
        layout = QHBoxLayout(widget)
        layout.setContentsMargins(0, 0, 0, 0)
        layout.setSpacing(6)

        btn_plot = QPushButton('Plot')
        btn_plot.setFont(QFont(FONT, 10, QFont.Bold))
        btn_plot.setFixedHeight(45)
        btn_plot.setStyleSheet('background-color: #ccf2cc;')
        btn_plot.clicked.connect(self._on_plot_single)
        layout.addWidget(btn_plot)

        btn_clear = QPushButton('Clear')
        btn_clear.setFont(QFont(FONT, 10, QFont.Bold))
        btn_clear.setFixedHeight(45)
        btn_clear.setStyleSheet('background-color: #ffcccc;')
        btn_clear.clicked.connect(self._on_clear)
        layout.addWidget(btn_clear)

        btn_legend = QPushButton('Legend')
        btn_legend.setFont(QFont(FONT, 10, QFont.Bold))
        btn_legend.setFixedHeight(45)
        btn_legend.setStyleSheet('background-color: #d9e0f8;')
        btn_legend.clicked.connect(self._on_legend)
        layout.addWidget(btn_legend)

        return widget

    def _create_export_panel(self):
        grp = QGroupBox('Export')
        grp.setFont(QFont(FONT, 10, QFont.Bold))
        grid = QGridLayout(grp)
        grid.setVerticalSpacing(8)

        grid.addWidget(self._label('DPI'), 0, 0)
        self.eDPI = QLineEdit('1200')
        self.eDPI.setFont(QFont(FONT, 9))
        grid.addWidget(self.eDPI, 0, 1)

        btn_png = QPushButton('Export PNG + SVG')
        btn_png.setFont(QFont(FONT, 9, QFont.Bold))
        btn_png.setFixedHeight(35)
        btn_png.setStyleSheet('background-color: #f2e0cc;')
        btn_png.clicked.connect(self._on_export_fig)
        grid.addWidget(btn_png, 1, 0, 1, 2)

        btn_csv = QPushButton('Export CSV')
        btn_csv.setFont(QFont(FONT, 9, QFont.Bold))
        btn_csv.setFixedHeight(35)
        btn_csv.setStyleSheet('background-color: #e6e6f0;')
        btn_csv.clicked.connect(self._on_export_csv)
        grid.addWidget(btn_csv, 2, 0, 1, 2)

        note = QLabel('Note: Batch table uses H,T,d,Type,Label.')
        note.setFont(QFont(FONT, 8))
        note.setStyleSheet('color: #666;')
        grid.addWidget(note, 3, 0, 1, 2)

        return grp

    def _label(self, text):
        lbl = QLabel(text)
        lbl.setFont(QFont(FONT, 9))
        return lbl

    def _on_type_changed(self):
        is_irr = self.dd_type.currentText() == 'irregular'
        for w in [self.dd_hkind, self.dd_plot, self.eN]:
            w.setEnabled(is_irr)
        gray = '#000' if is_irr else '#888'
        for lbl in [self.lbl_hkind, self.lbl_plot, self.lbl_n]:
            lbl.setStyleSheet(f'color: {gray};')

    def _get_cond(self, H, T, d, wave_type='regular'):
        if wave_type == 'regular':
            return compute_wave_condition(H, T, d)
        else:
            return compute_wave_condition(
                H, T, d, wave_type='irregular',
                Hkind=self.dd_hkind.currentText(),
                plot_kind=self.dd_plot.currentText(),
                N_waves=int(self.eN.text()))

    def _format_result(self, c, label):
        return (
            f'Label    : {label}\n'
            f'Wave     : {c["waveType"]}  (input: {c["Hkind"]}, plot: {c["plotKind"]})\n'
            f'Hinput   = {c["Hinput"]:.3f} m   Hplot = {c["Hplot"]:.3f} m   Hs = {c["Hs"]:.3f} m\n'
            f'T        = {c["T"]:.3f} s\n'
            f'L        = {c["L"]:.3f} m\n'
            f'd/L      = {c["dL"]:.4f}\n'
            f'H/L      = {c["HL"]:.4f}\n'
            f'Ur       = {c["Ur"]:.2f}\n'
            f'Regime   : {c["regime"]}\n'
            f'Breaking : {"YES" if c["broken"] else "no"}  (limit H/L = {c["HLbreak"]:.3f})\n'
            f'------------------------------\n'
            f'Theory   : {c["theory"]}')

    def _on_plot_single(self):
        try:
            H = float(self.eH.text())
            T = float(self.eT.text())
            d = float(self.eh.text())
            if H <= 0 or T <= 0 or d <= 0:
                self.result_text.setPlainText('Error: H, T, d must all be positive.')
                return
            c = self._get_cond(H, T, d, self.dd_type.currentText())
            col = MARKER_COLORS.get(self.dd_marker.currentText())
            sz = int(self.eSize.text())
            self.chart.add_point(c, self.eLab.text(), marker_size=sz,
                                 marker_color=col, show_label=self.cb_label.isChecked())
            self.result_text.setPlainText(self._format_result(c, self.eLab.text()))
        except Exception as e:
            self.result_text.setPlainText(f'Error: {e}')

    def _on_plot_batch(self):
        msgs = []
        for row in range(self.table.rowCount()):
            try:
                H = float(self.table.item(row, 0).text())
                T = float(self.table.item(row, 1).text())
                d = float(self.table.item(row, 2).text())
                wtype = self.table.item(row, 3).text()
                lab = self.table.item(row, 4).text()
                c = self._get_cond(H, T, d, wtype)
                col = MARKER_COLORS.get(self.dd_marker.currentText())
                sz = int(self.eSize.text())
                self.chart.add_point(c, lab, marker_size=sz,
                                     marker_color=col, show_label=self.cb_label.isChecked())
                msgs.append(f'{lab}: {c["theory"]}')
            except Exception as e:
                msgs.append(f'Row {row} ERROR: {e}')
        self.result_text.setPlainText('\n'.join(msgs) if msgs else 'No rows to plot.')

    def _on_clear(self):
        self.chart.clear_points()
        self.result_text.setPlainText('Cleared all points.')

    def _on_legend(self):
        shown = self.chart.toggle_legend()
        self.result_text.setPlainText('Legend shown.' if shown else 'Legend hidden.')

    def _add_row(self):
        r = self.table.rowCount()
        self.table.insertRow(r)
        for col, val in enumerate(['1.0', '6.0', '5.0', 'regular', f'C{r+1}']):
            self.table.setItem(r, col, QTableWidgetItem(val))

    def _remove_row(self):
        if self.table.rowCount() > 0:
            self.table.removeRow(self.table.rowCount() - 1)

    def _on_export_fig(self):
        if not self.chart.results:
            self.result_text.setPlainText('No points to export.')
            return
        from PIL import Image
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        base = f'wave_theory_chart_{ts}'
        dpi = int(self.eDPI.text())
        w_cm, h_cm = 12.0, 12.0
        w_px = int(w_cm / 2.54 * dpi)
        h_px = int(h_cm / 2.54 * dpi)

        # 导出无白边
        pos = self.chart.ax.get_position()
        self.chart.ax.set_position([0, 0, 1, 1])
        self.chart.fig.savefig(f'{base}_raw.png', dpi=dpi, facecolor='white',
                               bbox_inches='tight', pad_inches=0)
        self.chart.ax.set_position(pos)
        self.chart.draw()

        # 裁剪到精确 12x12 cm
        img = Image.open(f'{base}_raw.png')
        img = img.resize((w_px, h_px), Image.LANCZOS)
        img.save(f'{base}.png', dpi=(dpi, dpi))
        os.remove(f'{base}_raw.png')

        # SVG 直接导出
        self.chart.ax.set_position([0, 0, 1, 1])
        self.chart.fig.savefig(f'{base}.svg', facecolor='white',
                               bbox_inches='tight', pad_inches=0)
        self.chart.ax.set_position(pos)
        self.chart.draw()

        self.result_text.setPlainText(
            f'Exported at {w_cm:.1f} x {h_cm:.1f} cm, {dpi} dpi:\n'
            f'  {base}.png\n  {base}.svg')

    def _on_export_csv(self):
        if not self.chart.results:
            self.result_text.setPlainText('No results to export.')
            return
        ts = datetime.now().strftime('%Y%m%d_%H%M%S')
        fn = f'wave_theory_results_{ts}.csv'
        with open(fn, 'w') as f:
            f.write('Label,waveType,Hinput,Hkind,Hplot,plotKind,Hs,'
                    'T,d,L,d_over_L,H_over_L,Ur,d_over_gT2,H_over_gT2,'
                    'Regime,Breaking,Theory\n')
            for r in self.chart.results:
                c = r['cond']
                f.write(f'{r["label"]},{c["waveType"]},{c["Hinput"]:.4f},'
                        f'{c["Hkind"]},{c["Hplot"]:.4f},{c["plotKind"]},'
                        f'{c["Hs"]:.4f},{c["T"]:.3f},{c["d"]:.3f},{c["L"]:.3f},'
                        f'{c["dL"]:.3f},{c["HL"]:.5f},{c["Ur"]:.3f},'
                        f'{c["dgT2"]:.3e},{c["HgT2"]:.3e},'
                        f'{c["regime"]},{"YES" if c["broken"] else "no"},'
                        f'{c["theory"]}\n')
        self.result_text.setPlainText(f'Exported {len(self.chart.results)} rows to {fn}')

    def closeEvent(self, event):
        self.chart.close()
        event.accept()


if __name__ == '__main__':
    app = QApplication(sys.argv)
    gui = WaveTheoryGUI()
    gui.show()
    sys.exit(app.exec_())
