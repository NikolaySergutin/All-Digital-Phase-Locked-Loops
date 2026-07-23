%%Fixed
clear all
clc
close all

%% Canonical 2nd-order system
%% W(s) = wn^2 / (s^2 + 2*xi*wn*s + wn^2)
%% DC-gain = 1

%% 1. Damping cases
wn = 1000;   % natural frequency [rad/s]

%% 1.1 Critically damped (xi = 1)
xi = 1;
sysc = tf(wn^2, [1 2*xi*wn wn^2]);

figure(1)
step(sysc), grid on, title('Critically damped (\xi = 1)')

figure(2)
bode(sysc), grid on

pole(sysc)

%% 1.2 Underdamped (xi = 0.5)
xi = 0.5;
sysc = tf(wn^2, [1 2*xi*wn wn^2]);

figure(3)
step(sysc), grid on, title('Underdamped (\xi = 0.5)')

figure(4)
bode(sysc), grid on

pole(sysc)

%% 1.3 Overdamped (xi = 1.5)
xi = 1.5;
sysc = tf(wn^2, [1 2*xi*wn wn^2]);

figure(5)
step(sysc), grid on, title('Overdamped (\xi = 1.5)')

figure(6)
bode(sysc), grid on

pole(sysc)

%% 2. Study effect of wn (speed only)

xi = 0.55;

figure(7), clf, hold on, grid on
title('Step response: effect of \\omega_n')

figure(8), clf, hold on, grid on
title('Bode magnitude: effect of \\omega_n')

Legend = {};
i = 1;

for wn = 500:500:4000
    sysc = tf(wn^2, [1 2*xi*wn wn^2]);

    figure(7)
    step(sysc)

    figure(8)
    bode(sysc)

    Legend{i} = sprintf('\\omega_n = %d', wn);
    i = i + 1;
end

figure(7), legend(Legend)
figure(8), legend(Legend)

%% 3. Study effect of xi (phase margin only)

wn = 1000;

figure(9), clf, hold on, grid on
title('Step response: effect of \\xi')

figure(10), clf, hold on, grid on
title('Bode response: effect of \\xi')

Legend = {};
i = 1;

for xi = 0.2:0.2:1.4
    sysc = tf(wn^2, [1 2*xi*wn wn^2]);

    figure(9)
    step(sysc)

    figure(10)
    bode(sysc)

    Legend{i} = sprintf('\\xi = %.1f', xi);
    i = i + 1;
end

figure(9), legend(Legend)
figure(10), legend(Legend)

%% 4. ADPLL - equivalent 2nd-order model

Kp   = 1;
Ki   = 1/64;
Kdco = 1;

% Equivalent parameters
wn = sqrt(Kp * Kdco * Ki);
xi = 0.5 * sqrt((Kp * Kdco) / Ki);

sysc = tf(wn^2, [1 2*xi*wn wn^2]);

figure(11)
step(sysc), grid on
title('ADPLL equivalent step response')

figure(12)
bode(sysc), grid on
title('ADPLL equivalent Bode response')

pole(sysc)

