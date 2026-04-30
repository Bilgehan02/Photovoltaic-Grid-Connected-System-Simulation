%% PV Panel — Kalibrasyonlu 5-Parametre Model
clc; clear; close all;

% Datasheet parametreleri
Isc = 8.72;  Voc = 37.8;
Imp = 8.17;  Vmp = 30.6;
Pmax_ref = 250;
Ns = 60;
q  = 1.6e-19;  k = 1.38e-23;  T = 298.15;

%% Optimizasyon ile Rs ve 'a' bul
params0 = [1.2, 0.3];
lb      = [0.9, 0.0];
ub      = [1.5, 1.0];
options = optimoptions('fmincon','Display','off');

cost = @(p) lokal_hata(p, Isc, Voc, Imp, Vmp, Ns, q, k, T);
params_opt = fmincon(cost, params0, [], [], [], [], lb, ub, [], options);

a_opt  = params_opt(1);
Rs_opt = params_opt(2);
Rsh    = 200;

fprintf('Kalibrasyon Sonucu:\n');
fprintf('  İdeallik faktörü (a) : %.4f\n', a_opt);
fprintf('  Seri direnç (Rs)     : %.4f Ω\n', Rs_opt);

%% Kalibre model ile I-V hesabı
Vt = (a_opt * k * T * Ns) / q;
I0 = Isc / (exp(Voc/Vt) - 1);
V  = linspace(0, Voc, 500);
I  = zeros(size(V));

fs_opts = optimoptions('fsolve','Display','off');
for i = 1:length(V)
    fun  = @(Ix) Ix - Isc + I0*(exp((V(i)+Ix*Rs_opt)/Vt)-1) + (V(i)+Ix*Rs_opt)/Rsh;
    I(i) = fsolve(fun, Isc/2, fs_opts);
end
I = max(I, 0);
P = V .* I;

[Pmax_sim, idx_max] = max(P);
fprintf('\n========== SONUÇLAR ==========\n');
fprintf('Simüle edilen Pmax : %.2f W\n', Pmax_sim);
fprintf('MPP Gerilimi (Vmp) : %.2f V\n', V(idx_max));
fprintf('MPP Akımı (Imp)    : %.2f A\n', I(idx_max));
fprintf('Datasheet Pmax     : %.2f W\n', Pmax_ref);
fprintf('Model Hatası       : %.2f%%\n', abs(Pmax_ref-Pmax_sim)/Pmax_ref*100);
fprintf('==============================\n');

%% Farklı Işınım Grafikleri
irradiance = [1000, 750, 500, 250];
renkler    = {'b','r','g','m'};
etiketler  = {'1000 W/m²','750 W/m²','500 W/m²','250 W/m²'};

figure('Name','PV Panel — Kalibrasyonlu Model','NumberTitle','off');

for idx = 1:length(irradiance)
    G      = irradiance(idx);
    Isc_G  = Isc * (G/1000);
    I_G    = zeros(size(V));

    for i = 1:length(V)
        fun    = @(Ix) Ix - Isc_G + I0*(exp((V(i)+Ix*Rs_opt)/Vt)-1) + (V(i)+Ix*Rs_opt)/Rsh;
        I_G(i) = fsolve(fun, Isc_G/2, fs_opts);
    end
    I_G = max(I_G, 0);
    P_G = V .* I_G;

    subplot(2,1,1); hold on;
    plot(V, I_G, renkler{idx}, 'LineWidth', 2);

    subplot(2,1,2); hold on;
    plot(V, P_G, renkler{idx}, 'LineWidth', 2);
end

subplot(2,1,1);
xlabel('Gerilim (V)'); ylabel('Akım (A)');
title('I-V Karakteristiği — Kalibrasyonlu Model');
legend(etiketler,'Location','southwest'); grid on;

subplot(2,1,2);
xlabel('Gerilim (V)'); ylabel('Güç (W)');
title('P-V Karakteristiği — Kalibrasyonlu Model');
legend(etiketler,'Location','northeast'); grid on;

%% Yardımcı Fonksiyon (dosya sonunda tanımla)
function hata = lokal_hata(params, Isc, Voc, Imp, Vmp, Ns, q, k, T)
a   = params(1);
Rs  = params(2);
Vt  = (a * k * T * Ns) / q;
I0  = Isc / (exp(Voc/Vt) - 1);
Rsh = 200;

fs_opts = optimoptions('fsolve','Display','off');
fun     = @(Ix) Ix - Isc + I0*(exp((Vmp+Ix*Rs)/Vt)-1) + (Vmp+Ix*Rs)/Rsh;
I_mp    = fsolve(fun, Imp, fs_opts);

hata = (I_mp - Imp)^2 + ((Vmp*I_mp) - (Vmp*Imp))^2;
end