function B = fast_boxcarmat(psdwin)
% B = fast_boxcarmat(psdwin)
%
% Creates a matrix that implements convolution with a boxcar.
%
% X = Xfir * B * Airf, Aerf = B * Airf
%   Xfir is built assuming the ERF
%
% B will be nerfpsdwin by nirfpsdwin
%
% $Id: fast_boxcarmat.m,v 1.2 2003/04/18 22:08:57 greve Exp $

B = [];

if(nargin ~= 1)
  fprintf('B = fast_boxcarmat(psdwin)\n');
  return;
end

if(fast_psdwin(psdwin,'check') ~= 1) return; end

psdmin = psdwin(1);
dpsd   = psdwin(2);
psdmax = psdwin(3);
if(length(psdwin) == 3) bcw = 0;
else                    bcw = psdwin(4);
end

Na = fast_psdwin(psdwin,'nirfpsdwin');
Nb = bcw/dpsd;

if(bcw == 0)
  B = eye(Na);
  return;
end

% M1 just pads Airf to be long enough to multiply
% by boxcar matrix
M1 = [zeros(Nb,Na); ...
      eye(Na); ];

% M2 is the transpose of an Xfir for a boxcar
b = [ones(1,Nb) zeros(1,Na)];
c = zeros(Na+Nb,1);
c(1) = 1;
M2 = toeplitz(c,b);

B = M2*M1;


return;