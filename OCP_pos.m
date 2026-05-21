function U = OCP_pos(x)
% OCP_POS  LiCoO2 (LCO) teigiamo elektrodo atviros grandinės potencialas.
%
% Skaičiuoja LCO elektrodo pusiausvyros potencialą prieš metalinio
% ličio atskaitos elektrodą (Li/Li+) kaip stoichiometrijos x funkciją.
%
% Įvestis:
%   x – paviršiaus stoichiometrija (c_s,surf / c_s,max), [0, 1]
%       x = 0 → LCO tuščias (visas Li atiduotas į anodinę pusę)
%       x = 1 → LCO pilnas (maksimalus Li kiekis įterptas)
%       Tipinis darbo diapazonas: x ∈ [0,40, 0,99]
%
% Išvestis:
%   U – potencialas [V vs. Li/Li+]
%       Tipinis diapazonas: 3,7–4,2 V
%
% Šaltinis: Guo, Sikha, White (2011), JECS 158(2), A122-A132.
% Empirinis fit'as gautas iš GITT matavimų (C/100 iškrova su
% pusiausvyros pauzėmis kas kelis procentus SOC).
%
% Funkcija vektorizuota: galima perduoti masyvą, pvz. OCP_pos([0.4:0.01:0.9]).

    % Apribojimas į [0,001, 0,999]: eksponentiniai nariai
    % turi singuliarumus prie x = 0 ir x = 1
    x = max(min(x, 0.999), 0.001);

    U =  4.04596 ...
        + exp(-42.30027 .* x + 16.56714) ...
        - 0.04880 .* atan(50.01833 .* x - 26.48897) ...
        - 0.05447 .* atan(18.99678 .* x - 12.32362) ...
        - exp(78.24095 .* x - 78.68074);
end
