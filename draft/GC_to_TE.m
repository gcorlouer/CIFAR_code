function TE = GC_to_TE(F, fs)

if nargin<2; fs = 500 ; end

bits = 1/log(2); % convert to bits
TE = 1/2*fs*bits*F; % TE is half GC
end