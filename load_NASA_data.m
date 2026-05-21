function data = load_NASA_data(filename)
% LOAD_NASA_DATA  NASA Prognostics Data Repository baterijų duomenų
%                užkrovimas ir struktūrizavimas.
%
% Užkrauna NASA B0005 (arba analogiškos celės) .mat failą, išrenka
% iškrovos ciklus ir grąžina struktūrizuotus duomenis tolesnei analizei.
%
% NASA B0005 celės statistika:
%   616 ciklų iš viso: 170 įkrovos, 168 iškrovos, 278 impedanso.
%
% Srovės ženklų konvencija: NASA naudoja neigiamą srovę iškrovai;
% šiame darbe konvertuojama į teigiamą (I > 0 = iškrova).
%
% Įvestis:
%   filename - .mat failo pavadinimas (pvz., 'B0005.mat')
%
% Išvestis:
%   data.dischargeCycles   - iškrovos ciklų struktūrų masyvas
%   data.capacity_vs_cycle - matrica [N×2]: ciklo nr. ir talpa (Ah)
%   data.source            - failo pavadinimas

    if ~isfile(filename)
        error('load_NASA_data:fileNotFound', ...
              'Failas „%s" nerastas. Patikrinkite darbo direktoriją.', filename);
    end

    fprintf('Užkraunamas %s ...\n', filename);
    raw = load(filename);

    %% Struktūros navigacija
    % NASA failuose galimi du formatai:
    %   A: batteryData.cycle (struct array)
    %   B: batteryData(1,1).cycle
    fields = fieldnames(raw);
    if isempty(fields)
        error('load_NASA_data:emptyFile', 'Faile „%s" nėra duomenų.', filename);
    end

    cellName = fields{1};
    batteryData = raw.(cellName);

    if isstruct(batteryData) && isfield(batteryData, 'cycle')
        cycles = batteryData.cycle;
    elseif isstruct(batteryData) && numel(batteryData) > 0 && ...
           isfield(batteryData(1), 'cycle')
        cycles = batteryData(1).cycle;
    else
        error('load_NASA_data:invalidStructure', ...
              'Faile „%s" nepavyko rasti „cycle" lauko.', filename);
    end

    Nc_total = numel(cycles);
    fprintf('  Iš viso ciklų: %d\n', Nc_total);

    %% Pagalbinės funkcijos saugiam duomenų ištraukimui
    % Kai kurie laukai gali būti saugomi {cell} masyvuose –
    % funkcijos automatiškai išvynioja juos.

    function s = getType(c)
        t = c.type;
        if iscell(t), t = t{1}; end
        if ~ischar(t) && ~isstring(t)
            s = '';
        else
            s = char(t);
        end
    end

    function d = getData(c)
        d = c.data;
        if iscell(d) && ~isempty(d), d = d{1}; end
    end

    function v = getVec(d, fieldName)
        v = [];
        if ~isfield(d, fieldName), return; end
        f = d.(fieldName);
        if iscell(f) && ~isempty(f), f = f{1}; end
        v = double(f(:));
    end

    %% Ciklų tipų statistika
    n_charge = 0; n_discharge = 0; n_impedance = 0;
    for i = 1:Nc_total
        t = getType(cycles(i));
        switch t
            case 'charge';     n_charge = n_charge + 1;
            case 'discharge';  n_discharge = n_discharge + 1;
            case 'impedance';  n_impedance = n_impedance + 1;
        end
    end
    fprintf('    įkrovos:    %d\n', n_charge);
    fprintf('    iškrovos:   %d\n', n_discharge);
    fprintf('    impedanso:  %d\n', n_impedance);

    if n_discharge == 0
        error('load_NASA_data:noDischarge', 'Faile nėra iškrovos ciklų.');
    end

    %% Iškrovos ciklų ištraukimas
    % Naudojami tik iškrovos ciklai – jie tinkamiausi SPM modelio
    % validacijai dėl pastovios srovės režimo.
    dischargeCycles = struct('cycleNumber', {}, 'time', {}, ...
                              'current', {}, 'voltage', {}, ...
                              'temperature', {}, 'capacity', {});
    cap_list = [];

    for i = 1:Nc_total
        if ~strcmp(getType(cycles(i)), 'discharge'), continue; end

        d = getData(cycles(i));
        if isempty(d), continue; end

        t = getVec(d, 'Time');
        I_raw = getVec(d, 'Current_measured');
        V = getVec(d, 'Voltage_measured');
        T = getVec(d, 'Temperature_measured');

        if isempty(t) || isempty(I_raw) || isempty(V), continue; end

        % Ženklų konversija: NASA iškrovos srovė neigiama → keičiame į teigiamą
        I = -I_raw;

        % Talpa (ne visada prieinama)
        Q = NaN;
        if isfield(d, 'Capacity')
            cap_field = d.Capacity;
            if iscell(cap_field) && ~isempty(cap_field), cap_field = cap_field{1}; end
            if ~isempty(cap_field), Q = double(cap_field(1)); end
        end

        idx = numel(dischargeCycles) + 1;
        dischargeCycles(idx).cycleNumber = i;
        dischargeCycles(idx).time = t;
        dischargeCycles(idx).current = I;
        dischargeCycles(idx).voltage = V;
        dischargeCycles(idx).temperature = T;
        dischargeCycles(idx).capacity = Q;

        if ~isnan(Q)
            cap_list(end+1, :) = [i, Q]; %#ok<AGROW>
        end
    end

    %% Rezultatų struktūra
    data.dischargeCycles = dischargeCycles;
    data.capacity_vs_cycle = cap_list;
    data.source = filename;

    fprintf('  Ištraukti %d iškrovos ciklai.\n', numel(dischargeCycles));
    if ~isempty(cap_list)
        fprintf('  Talpos diapazonas: %.3f → %.3f Ah\n', ...
                cap_list(1, 2), cap_list(end, 2));
    end
end
