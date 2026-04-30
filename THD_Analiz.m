%% THD Analizi — 0.5s Simülasyon
clc; close all;

% Veriyi çek
V_a = out.faz_A;

t_stop = 0.5;  % Yeni simülasyon süresi
N = length(V_a);
t = linspace(0, t_stop, N);

fprintf('Toplam örnek sayısı: %d\n', N);

% Kararlı hali al
t_start = 0.02;
idx_start = find(t >= t_start, 1);
V_steady = V_a(idx_start:end);
N_steady = length(V_steady);

% Hanning window
window = hann(N_steady);
V_windowed = V_steady .* window;

fs = N_steady / (t_stop - t_start);

fprintf('Örnekleme frekansı: %.0f Hz\n', fs);
fprintf('Frekans çözünürlüğü: %.3f Hz\n', fs/N_steady);

% FFT
Y = fft(V_windowed);
P2 = abs(Y/N_steady);
P1 = P2(1:floor(N_steady/2)+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:(floor(N_steady/2)))/N_steady;

% 50 Hz'i bul
[~, idx_50] = min(abs(f - 50));
V1 = P1(idx_50);

% Harmonikler
harmonics = [];
for h = 2:10
    [~, idx_h] = min(abs(f - h*50));
    harmonics(end+1) = P1(idx_h);
end

THD = sqrt(sum(harmonics.^2)) / V1 * 100;

fprintf('\n========== THD ANALİZİ ==========\n');
fprintf('Temel (50Hz): %.2f V\n', V1);
fprintf('THD:          %.3f%%\n', THD);
fprintf('IEEE 519:     5%%\n');
if THD < 5
    fprintf('Sonuç:        ✅ BAŞARILI\n');
else
    fprintf('Sonuç:        ⚠️ %.1f%% limit aşımı\n', THD-5);
end
fprintf('=================================\n');