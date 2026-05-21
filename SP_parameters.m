function p = SP_parameters()
% Parametrai paimti iš Guo, Sikha ir White (2011), "Single-Particle
% Model for a Lithium-Ion Cell: Thermal Behavior" (JECS 158(2), A122),
% I lentelė / II lentelė. Šie parametrai atitinka Mine Safety Appliances
% LiCoO2/MCMB 1,656 Ah maišelinę celę ir yra naudojami kaip artimiausi
% NASA 18650 2 Ah LCO celės (B0005) analogai.

    p.F      = 96487;       % Faradėjaus konstanta [C/mol]
                            % Kiek elektrinio krūvio neša 1 molis Li+ jonų.
    p.R      = 8.3143;      % Universalioji dujų konstanta [J/(mol*K)]
                            % Boltzmanno konstanta x Avogadro skaičius.
    p.Tref   = 298.15;      % Referencinė temperatūra [K] (= 25 °C)
                            % Standartinė elektrochemijos sąlyga.
    p.T      = 298.15;      % Darbinė temperatūra [K] (izoterminė prielaida)
                            % NASA testavimo sąlyga (24 °C aplinkos T).

    %% ===================================================================
    %  CELĖS GEOMETRIJA IR NOMINALI TALPA
    %  ===================================================================
    p.Qnom   = 2.0;         % Nominali talpa [Ah] (NASA B0005 specifikacija)
                            % Reali matuota talpa yra ~1,856 Ah – gamintojo
                            % pateikta nominali yra optimistiška.
    p.A      = 1.0;         % Sąlyginis celės plotas [m^2]
                            % Naudojamas tik mastelio normalizacijai.

    %% ===================================================================
    %  TEIGIAMAS ELEKTRODAS – LiCoO2 (LCO katodas)
    %  Visi parametrai išmatuoti Guo et al. (2011) eksperimentiškai:
    %    - Rp, Lp – matuota SEM mikroskopu
    %    - cs_max_p – iš kristalinės struktūros tankio (XRD)
    %    - Ds_p – išmatuota GITT metodu (galvanostatic intermittent
    %             titration technique)
    %    - kp – išmatuota EIS (electrochemical impedance spectroscopy)
    %  ===================================================================
    p.Lp        = 70e-6;         % Elektrodo storis [m] (= 70 μm)
    p.Rp        = 8.5e-6;        % Aktyviosios dalelės spindulys [m] (= 8.5 μm)
                                 % Mažas dalelių dydis = trumpesnis Li
                                 % difuzijos kelias = greitesnė kinetika.
    p.Sp        = 1.1167;        % Bendras dalelių paviršiaus plotas [m^2]
                                 % Skaičiuojamas iš a_s = 3*eps_s/Rp formulės.
    p.cs_max_p  = 51410;         % Maks. ličio koncentracija [mol/m^3]
                                 % Atitinka pilnai litiuotą LiCoO2 kristalą.
    p.Ds_p      = 1.0e-14;       % Kietosios fazės difuzijos koef. [m^2/s]
                                 % Mažas Ds_p = stipri SPM dinamika
                                 % (didelis paviršiaus/vidutinės gradientas).
    p.kp        = 6.6667e-11;    % Reakcijos greičio konstanta
                                 % Naudojama Butlerio-Volmerio i0 skaičiavime.
    p.Ea_Dp     = 29e3;          % Difuzijos aktyvacijos energija [J/mol]
                                 % Reikalinga Arrhenius temperatūros įtakai
                                 % (šiame darbe nenaudojama – izoterminė prielaida).
    p.x_ini_p   = 0.4952;        % Pradinė (100 % SOC) stoichiometrija
                                 % LCO užpildymas, kai celė pilnai įkrauta.
                                 % NASA B0005 atveju koreguojama į 0.4216
                                 % (žr. fit_parameters_to_cell.m).
    p.alpha     = 0.5;           % Krūvio pernašos koeficientas
                                 % alpha = 0.5 -> simetriška reakcija
                                 % (klasikinė Newman, Plett prielaida).

    %% ===================================================================
    %  NEIGIAMAS ELEKTRODAS – MCMB grafitas (anodas)
    %  ===================================================================
    p.Ln        = 73.5e-6;       % Elektrodo storis [m] (= 73.5 μm)
    p.Rn        = 12.5e-6;       % Dalelės spindulys [m] (= 12.5 μm)
                                 % Didesnės nei LCO – dėl gamybos technologijos.
    p.Sn        = 0.7824;        % Bendras dalelių paviršiaus plotas [m^2]
    p.cs_max_n  = 31833;         % Maks. ličio koncentracija [mol/m^3]
                                 % Atitinka pilnai litiuotą LiC6 (interkalacija).
    p.Ds_n      = 3.9e-14;       % Kietosios fazės difuzijos koef. [m^2/s]
                                 % ~4x didesnis nei LCO – grafitas geriau
                                 % praleidžia Li difuziją.
    p.kn        = 1.764e-11;     % Reakcijos greičio konstanta
    p.Ea_Dn     = 35e3;          % Difuzijos aktyvacijos energija [J/mol]
    p.x_ini_n   = 0.7522;        % Pradinė (100 % SOC) stoichiometrija
                                 % Pilnai įkrautas grafitas užpildytas 75 %.
                                 % NASA B0005 atveju koreguojama į 0.7137.

    %% ===================================================================
    %  ELEKTROLITAS
    %  SPM modelis prielaida: elektrolitas yra vienodas (be gradientų).
    %  Tikslesni modeliai (SP+, SPMe) modeliuoja ir elektrolito difuziją.
    %  ===================================================================
    p.ce        = 1000;          % Konstanta koncentracija elektrolite [mol/m^3]
                                 % = 1 M – standartinė LiPF6 elektrolito
                                 % koncentracija komercinėse celėse.

    %% ===================================================================
    %  VIDINĖ OMICINĖ VARŽA
    %  Atspindi visus omicinius nuostolius: srovės kolektorius,
    %  separatorius, elektrolitas, jungtys.
    %  ===================================================================
    p.R0        = 0.0162;        % [Ohm] esant Tref
                                 % Guo maišelinei celei. NASA B0005 18650
                                 % atveju koreguojama į 0.1132 Ω (7x didesnė
                                 % dėl cilindrinės konstrukcijos).

    %% ===================================================================
    %  STOICHIOMETRINĖS RIBOS
    %  Apibrėžia darbo diapazoną tarp 0 % ir 100 % SOC.
    %  Naudojamos compute_SOC.m funkcijoje.
    %  ===================================================================
    %  Prielaida: 100 % SOC atitinka x_ini; iškrovos metu x_n mažėja
    %  (atiduoda Li), x_p didėja (priima Li). Ribos parinktos taip,
    %  kad išeitų maks. ~2 Ah talpa pagal V diapazoną 2.7-4.2 V.
    p.x_n_0    = 0.0100;     % Neigiamo el. min. (0 % SOC, pilnai iškrauta)
                             % Beveik tuščias grafitas – likę ~1 % Li.
    p.x_n_100  = p.x_ini_n;  % Neigiamo el. maks. (100 % SOC, pilnai įkrauta)
    p.x_p_0    = 0.9850;     % Teigiamo el. maks. (0 % SOC)
                             % Beveik pilnai užpildytas LCO.
    p.x_p_100  = p.x_ini_p;  % Teigiamo el. min. (100 % SOC)

    %% ===================================================================
    %  SKAITINĖS SIMULIACIJOS NUSTATYMAI
    %  ===================================================================
    p.Nr       = 20;         % Radialinių sluoksnių (sferinių "svogūno"
                             % lukštų) skaičius.
                             % 20 sluoksnių - kompromisas tarp tikslumo
                             % (<1 mV paklaida) ir greičio.
                             % Su 10 sl. paklaida ~5 mV, su 50 sl. ~0.5 mV.
    p.dt_sim   = 1.0;        % Integravimo laiko žingsnis [s]
                             % Eulerio metodas stabilus, kai dt yra mažas
                             % palyginti su charakteringu difuzijos laiku
                             % tau = Rp^2/Ds ~ 7000 s.

    %% ===================================================================
    %  PRADINĖS KONCENTRACIJOS
    %  Apskaičiuojamos iš pradinių stoichiometrijų ir maks. koncentracijų.
    %  ===================================================================
    p.c0_p     = p.x_ini_p * p.cs_max_p;  % Teigiamo el. pradinė c [mol/m^3]
                                          % = 0.4952 * 51410 = 25 459 mol/m^3
    p.c0_n     = p.x_ini_n * p.cs_max_n;  % Neigiamo el. pradinė c [mol/m^3]
                                          % = 0.7522 * 31833 = 23 944 mol/m^3
end
