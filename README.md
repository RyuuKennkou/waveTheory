# Wave Theory Selector - Python/PyQt5 Version

与 MATLAB 版本功能一致的 Python 实现。

## 依赖

```
pip install numpy matplotlib PyQt5 Pillow
```

## 使用

```bash
# 交互式 GUI（推荐）
python waveTheoryGUI.py

# 简单脚本
python demo.py
```

## 文件说明

| 文件 | 说明 |
|------|------|
| `waveTheoryGUI.py` | PyQt5 GUI 主程序 |
| `compute_wave_condition.py` | 波浪参数计算 |
| `stokes_order_curves.py` | Stokes 阶数分界曲线 |
| `plot_base_chart.py` | 理论选择图绘制 |
| `plot_wave_point.py` | 绘制数据点 |
| `demo.py` | 简单脚本示例 |
