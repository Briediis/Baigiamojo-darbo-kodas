function U = OCP_neg(x)
% OCP_NEG  Grafito (MCMB) neigiamo elektrodo atviros grandinės potencialas.
%
% Skaičiuoja grafito elektrodo pusiausvyros potencialą prieš metalinio
% ličio atskaitos elektrodą (Li/Li+) kaip stoichiometrijos x funkciją.
%
% Įvestis:
%   x – paviršiaus stoichiometrija (c_s,surf / c_s,max), [0, 1]
%       x = 0 → grafitas tuščias (visas Li atiduotas, iškrova baigta)
%       x = 1 → grafitas pilnas (visas Li įterptas, įkrova baigta)
%
% Išvestis:
%   U – potencialas [V vs. Li/Li+]
%       Tipinis diapazonas: 0,07–0,85 V
%       Sparčiai auga artėjant x prie 0 – tai sukelia staigų gnybtų
%       įtampos kritimą iškrovos pabaigoje.
%
% Šaltinis: Guo, Sikha, White (2011), JECS 158(2), A122-A132.
% Empirinis polinominis fit'as gautas iš GITT matavimų.

    % Apribojimas į [0,001, 0,999]: formulės turi singuliarumus
    % prie x = 0 ir x = 1 (eksponentiniai nariai)
    x = max(min(x, 0.999), 0.001);

    U =  0.13966 ...
        + 0.68920 .* exp(-49.20361  .* x) ...
        + 0.41903 .* exp(-254.40067 .* x) ...
        - exp(49.97886 .* x - 43.37888) ...
        - 0.028221 .* atan(22.52300 .* x - 3.65328) ...
        - 0.01308  .* atan(28.34801 .* x - 13.43960);
end
