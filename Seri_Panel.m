%% Seri Panel Konfigürasyonu
clc; clear;

% Tek panel parametreleri
Vmp_tek  = 30.6;
Imp_tek  = 8.17;
Pmax_tek = 250;

% Seri panel sayısı
Ns_string = 13;

% String çıkış değerleri
Vmp_string = Ns_string * Vmp_tek;
Imp_string = Imp_tek;          % Seri bağlı → akım aynı
Pmax_string = Ns_string * Pmax_tek;

fprintf('===== STRING KONFIG =====\n');
fprintf('Panel sayısı  : %d\n',    Ns_string);
fprintf('String Vmp    : %.1f V\n', Vmp_string);
fprintf('String Imp    : %.2f A\n', Imp_string);
fprintf('Toplam Güç    : %.0f W\n', Pmax_string);
fprintf('DC Bara       : %.1f V\n', Vmp_string);
fprintf('=========================\n');