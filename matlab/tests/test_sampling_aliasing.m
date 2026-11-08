%% Teste de amostragem, Nyquist e aliasing
% Compativel com MATLAB R2013a.
%
% Este experimento compara senoides amostradas a 48 kS/s e demonstra que
% uma senoide de 30 kHz aparece como uma senoide de 18 kHz apos a
% amostragem, pois 30 kHz esta acima da frequencia de Nyquist de 24 kHz.

clear;
close all;
clc;

%% Parametros da simulacao
Fs = 48000;                 % Frequencia de amostragem (amostras/s)
Ts = 1/Fs;                  % Periodo de amostragem (s)
duration = 0.005;           % Duracao da simulacao (s)
f_nyquist = Fs/2;           % Frequencia de Nyquist (Hz)

% O uso do indice inteiro evita a inclusao acidental da amostra final.
n = 0:(duration*Fs - 1);
t = n*Ts;

%% Frequencias do experimento
f1 = 1000;                  % Senoide dentro da banda de audio
f2 = 15000;                 % Limite de audio adotado no projeto
f3 = 30000;                 % Frequencia acima de Nyquist
f_alias = abs(f3 - Fs);     % Alias esperado: 18 kHz

%% Geracao dos sinais
x1 = cos(2*pi*f1*t);
x2 = cos(2*pi*f2*t);
x3 = cos(2*pi*f3*t);
x_alias = cos(2*pi*f_alias*t);

%% Informacoes numericas
fprintf('Frequencia de amostragem: %.0f Hz\n', Fs);
fprintf('Periodo de amostragem: %.6f us\n', Ts*1e6);
fprintf('Frequencia de Nyquist: %.0f Hz\n', f_nyquist);
fprintf('Amostras por periodo em 1 kHz: %.2f\n', Fs/f1);
fprintf('Amostras por periodo em 15 kHz: %.2f\n', Fs/f2);
fprintf('Alias esperado para 30 kHz: %.0f Hz\n', f_alias);

%% Visualizacao no dominio do tempo
figure('Name', 'Amostragem e aliasing', 'NumberTitle', 'off');

subplot(3,1,1);
stem(t*1000, x1, '.');
grid on;
xlim([0 2]);
ylim([-1.2 1.2]);
title('Senoide de 1 kHz amostrada a 48 kS/s');
xlabel('Tempo (ms)');
ylabel('Amplitude');

subplot(3,1,2);
stem(t*1000, x2, '.');
grid on;
xlim([0 0.5]);
ylim([-1.2 1.2]);
title('Senoide de 15 kHz amostrada a 48 kS/s');
xlabel('Tempo (ms)');
ylabel('Amplitude');

subplot(3,1,3);
stem(t*1000, x3, '.');
grid on;
xlim([0 0.5]);
ylim([-1.2 1.2]);
title('Senoide de 30 kHz: alias em 18 kHz');
xlabel('Tempo (ms)');
ylabel('Amplitude');

%% Verificacao automatica do aliasing
max_error = max(abs(x3 - x_alias));
tolerance = 1e-10;

fprintf('Erro maximo entre 30 kHz e 18 kHz: %.12e\n', max_error);

assert(max_error < tolerance, ...
    'Falha: o sinal de 30 kHz nao corresponde ao alias esperado de 18 kHz.');

fprintf('TESTE APROVADO: 30 kHz e 18 kHz sao indistinguiveis em 48 kS/s.\n');
