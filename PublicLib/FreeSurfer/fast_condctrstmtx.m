function R = fast_condctrstmtx(TER,TW,TPS,SumDelays,WDelays,RmPrestim)
% 
% R = fast_condctrstmtx(TER,TW,TPS,SumDelays,WDelays,RmPrestim)
%
% Computes the contrast matrix for a single condition.
%
% TER  - temporal estimation resolution (s)
% TW   - total time window (s)
% TPS  - prestimulus window (s), including delay = 0
%
% SumDelays = 1, forces Delays to be weighted by WDelays and summed.
%   Forces the contrast matrix to be a vector.
%
% WDelays - delay weighting vector. Ignored if SumDelays = 0. If
%  [], replaced with ones (ie, forces a simple average).
%
% RmPrestim = 1 subtract prestimulus average; will replace
%   the prestim components of WDelays. If the delays are not
%   summed, then the final matrix will have nPreStim fewer
%   rows than than if RmPrestim was not used.
%
% If the prestim is not removed and SumDelays=0
% then returns the identity of size nDelays = round(TW/TER).
%
% If the prestim is not removed and SumDelays=1, then returns 
% a vector of length nDelays with all the components 1/Nh.
%

R = [];

if(nargin ~= 6)
  fprintf('USAGE: R = fast_condctrstmtx(TER,TW,TPS,SumDelays,WDelays,RmPrestim)');
  return;
end

nDelays = round(TW/TER);

if(SumDelays)
  if(isempty(WDelays)) WDelays = ones(1,nDelays); end
  if(length(WDelays) ~= nDelays) 
     fprintf('ERROR: WDelays length = %d, should be %d\n',...
	     length(WDelays),nDelays);
     return;
  end
  WDelays = reshape(WDelays, [1 length(WDelays)]); 
end

if(RmPrestim)
  Nps = round(TPS/TER) + 1; % +1 includes Delay=0
else
  Nps = 0;
end

if(SumDelays)
  % ContrastMtx is a single row consisting of the weights
  R = WDelays;
  % If removing prestim, reset the first Nps components
  if(Nps > 0) R(1,1:Nps) = -1/Nps; end
else
  % ContrastMtx may be more than one row 
  % The matrix is divided into two parts: PreStim and PostStim
  % The PreStim part has all -1/Nps.
  % The PostStim part is diagonal with the PostStim Weights
  if(Nps > 0) Rpre = -ones(nDelays-Nps,Nps)/Nps;
  else        Rpre = [];
  end
  nnpost = [Nps+1:nDelays]; % PostStim Indicies
  Rpost  = diag(WDelays(nnpost)); % Diagonal PostStim Weights
  %Rpost = eye(nDelays-Nps);
  R = [Rpre Rpost];

  % Remove rows of R for which the PostStim weights are zero
  indnz = find(WDelays(nnpost) ~= 0);
  R = R(indnz,:);
end

% Make sure that the positives of each row sum to 1
% and that the negatives of each row sum to -1. This
% also assures that each row sums to zero if there
% are positives and negatives in the row.
for nthrow = 1:size(R,1);
  % positives %
  ind = find(R(nthrow,:)>0);
  if(~isempty(ind))
    xsum = sum(R(nthrow,ind));
    R(nthrow,ind) = R(nthrow,ind)/xsum;
  end
  % negatives %
  ind = find(R(nthrow,:)<0);
  if(~isempty(ind))
    xsum = sum(R(nthrow,ind));
    R(nthrow,ind) = R(nthrow,ind)/abs(xsum);
  end
end

return;
