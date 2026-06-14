function [HL2, HL3, HL4, HL5] = stokesOrderCurves(dL)
% STOKESORDERCURVES  Demarcation curves H/L vs d/L for Stokes 2-5 order.
%
%   - 2nd order: exact, R_2 = pi*H/L*B22(kh) = 1%
%   - 3rd-5th order: 1/(n-1) power scaling calibrated to deep-water
%     asymptotes of Zhao, Wang & Liu (2024), Table 1.
%
%   To get pointwise agreement with the paper, replace the high-order
%   blocks with the closed-form B_{nm} from
%   https://github.com/KuifengZhao/waveModelSelection

    HLinf = struct('n2',0.0064,'n3',0.0472,'n4',0.0697,'n5',0.0896);
    kh    = 2*pi*dL;
    B22   = cosh(kh).*(2 + cosh(2*kh)) ./ (4*sinh(kh).^3);
    B22_inf = 0.5;
    shape2 = B22_inf ./ B22;

    HL2 = HLinf.n2 * shape2;
    HL3 = HLinf.n3 * shape2.^(1/2);
    HL4 = HLinf.n4 * shape2.^(1/3);
    HL5 = HLinf.n5 * shape2.^(1/4);
end