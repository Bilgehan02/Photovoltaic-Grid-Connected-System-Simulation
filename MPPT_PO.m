%% Modül 2 — MPPT Perturb & Observe Algoritması
clc; clear; close all;

%% Panel parametreleri (Modül 1'den)
Isc    = 8.72;  Voc = 37.8;
Ns     = 60;
q      = 1.6e-19;  k = 1.38e-23;  T = 298.15;
a_opt  = 1.05;     % Modül 1 kalibrasyonundan
Rs_opt = 0.25;     % Modül 1 kalibrasyonundan
Rsh    = 200;
Vt     = (a_opt * k * T * Ns) / q;
I0     = Isc / (exp(Voc/Vt) - 1);
fs_opts = optimoptions('fsolve','Display','off');

%% Simülasyon Ayarları
dt         = 0.01;        % Zaman adımı (s)
t_toplam   = 5;           % Toplam süre (s)
adim_boyutu = 0.2;        % Gerilim pertürbasyon adımı (V)
t          = 0:dt:t_toplam;
N          = length(t);

%% Değişen Işınım Profili
% 0-1s: 1000, 1-2s: 750, 2-3s: 500, 3-4s: 750, 4-5s: 1000 W/m²
G_profil = zeros(1, N);
for i = 1:N
    if t(i) < 1
        G_profil(i) = 1000;
    elseif t(i) < 2
        G_profil(i) = 750;
    elseif t(i) < 3
        G_profil(i) = 500;
    elseif t(i) < 4
        G_profil(i) = 750;
    else
        G_profil(i) = 1000;
    end
end

%% Kayıt Dizileri
V_kayit   = zeros(1, N);
I_kayit   = zeros(1, N);
P_kayit   = zeros(1, N);
Pmax_kayit = zeros(1, N);

%% MPPT Başlangıç Koşulları
V_ref  = 25;          % Başlangıç gerilimi
P_eski = 0;
V_eski = V_ref;

%% Ana Döngü — MPPT Çalışıyor
for i = 1:N
    G = G_profil(i);
    Isc_G = Isc * (G/1000);

    % Panel akımını hesapla
    fun  = @(Ix) Ix - Isc_G + I0*(exp((V_ref+Ix*Rs_opt)/Vt)-1) ...
                 + (V_ref+Ix*Rs_opt)/Rsh;
    I_pv = fsolve(fun, Isc_G/2, fs_opts);
    I_pv = max(I_pv, 0);
    P_pv = V_ref * I_pv;

    % P&O Karar Mekanizması
    dP = P_pv - P_eski;
    dV = V_ref - V_eski;

    V_eski = V_ref;
    P_eski = P_pv;

    if dP ~= 0
        if dP > 0
            if dV > 0
                V_ref = V_ref + adim_boyutu;
            else
                V_ref = V_ref - adim_boyutu;
            end
        else
            if dV > 0
                V_ref = V_ref - adim_boyutu;
            else
                V_ref = V_ref + adim_boyutu;
            end
        end
    end

    % Sınır kontrolü
    V_ref = max(min(V_ref, Voc-0.1), 0.1);

    % Teorik maksimum güç (karşılaştırma için)
    V_tarama = linspace(0.1, Voc-0.1, 200);
    P_tarama = zeros(size(V_tarama));
    for j = 1:length(V_tarama)
        f2 = @(Ix) Ix - Isc_G + I0*(exp((V_tarama(j)+Ix*Rs_opt)/Vt)-1) ...
                   + (V_tarama(j)+Ix*Rs_opt)/Rsh;
        I_t = fsolve(f2, Isc_G/2, fs_opts);
        P_tarama(j) = V_tarama(j) * max(I_t, 0);
    end
    Pmax_gercek = max(P_tarama);

    % Kayıt
    V_kayit(i)    = V_ref;
    I_kayit(i)    = I_pv;
    P_kayit(i)    = P_pv;
    Pmax_kayit(i) = Pmax_gercek;
end

%% Verimlilik Hesabı
verim_mppt = (mean(P_kayit) / mean(Pmax_kayit)) * 100;

fprintf('\n========== MPPT SONUÇLAR ==========\n');
fprintf('Ortalama Çekilen Güç : %.2f W\n', mean(P_kayit));
fprintf('Ortalama Maks Güç    : %.2f W\n', mean(Pmax_kayit));
fprintf('MPPT Verimliliği     : %.2f%%\n', verim_mppt);
fprintf('====================================\n');

%% Grafikler
figure('Name','MPPT P&O Algoritması','NumberTitle','off');

% Işınım profili
subplot(4,1,1);
plot(t, G_profil, 'k', 'LineWidth', 2);
ylabel('Işınım (W/m²)');
title('Değişen Işınım Profili');
ylim([0 1200]); grid on;

% Gerilim takibi
subplot(4,1,2);
plot(t, V_kayit, 'b', 'LineWidth', 1.5);
ylabel('Gerilim (V)');
title('MPPT Gerilim Takibi');
grid on;

% Akım
subplot(4,1,3);
plot(t, I_kayit, 'r', 'LineWidth', 1.5);
ylabel('Akım (A)');
title('Panel Akımı');
grid on;

% Güç karşılaştırması
subplot(4,1,4);
plot(t, Pmax_kayit, 'g--', 'LineWidth', 2); hold on;
plot(t, P_kayit,    'b',   'LineWidth', 1.5);
ylabel('Güç (W)');
xlabel('Zaman (s)');
title('MPPT Güç Takibi');
legend('Teorik Maks Güç','MPPT Çıkış Gücü','Location','best');
grid on;