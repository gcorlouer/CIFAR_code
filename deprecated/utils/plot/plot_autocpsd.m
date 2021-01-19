%% Plot autospec
%Plot autospectral density
function plot_autocpsd(cpsd,f,fs)
%log_cpsd=20*log10(cpsd);
loglog(f,cpsd);
xlabel('frequency (Hz)');
ylabel('power (dB)');
xlim([0.8 fs/2]);
grid on
end