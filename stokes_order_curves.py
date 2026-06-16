import numpy as np


def stokes_order_curves(dL):
    HLinf = {'n2': 0.0064, 'n3': 0.0472, 'n4': 0.0697, 'n5': 0.0896}
    kh = 2 * np.pi * dL
    B22 = np.cosh(kh) * (2 + np.cosh(2 * kh)) / (4 * np.sinh(kh)**3)
    B22_inf = 0.5
    shape2 = B22_inf / B22

    HL2 = HLinf['n2'] * shape2
    HL3 = HLinf['n3'] * shape2**(1/2)
    HL4 = HLinf['n4'] * shape2**(1/3)
    HL5 = HLinf['n5'] * shape2**(1/4)
    return HL2, HL3, HL4, HL5
