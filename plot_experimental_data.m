function plot_experimental_data(data)
% PLOT_EXPERIMENTAL_DATA  NASA B0005 celės eksperimentinių duomenų
%                         vizualizavimas.
%
% Šešių panelių grafikas (3x2):
%   (1,1) Iškrovos srovės profilis – pastovi srovė (1 C)
%   (1,2) Gnybtų įtampa iškrovos metu – mažėja su ciklo numeriu
%   (2,1) Celės temperatūra – kyla dėl varžinių nuostolių
%   (2,2) Įtampos profilis kaip talpos funkcija V(Q)
%   (3,1) Talpos mažėjimas per visus ciklus (Ah)
%   (3,2) Sveikatos būklė SOH per visus ciklus (%)
%
% Trys reprezentatyvūs ciklai: pirmas (nauja celė), vidurinis,
% paskutinis (pasenusi celė artima gyvavimo pabaigai).
%
% Įvestis:
%   data - NASA duomenų struktūra iš load_NASA_data.m

    figure('Name', '1 pav. NASA eksperimentiniai duomenys', ...
           'Color', 'w', 'Position', [100 100 1000 780]);

    cycles = data.dischargeCycles;
    Nc = numel(cycles);

    % Trys reprezentatyvūs ciklai
    if Nc >= 3
        idxShow = unique([1, round(Nc/2), Nc]);
    else
        idxShow = 1:Nc;
    end
    colors = lines(numel(idxShow));

    % Iš kiekvieno ciklo išrenkamas aktyvus iškrovos intervalas
    % (filtras: |I| > 1,5 A), pašalinant poilsio fazes.
    filtered = cell(numel(idxShow), 1);
    for k = 1:numel(idxShow)
        c = cycles(idxShow(k));
        I_abs = abs(c.current);
        mask = I_abs > 1.5;
        idx = find(mask);
        if isempty(idx)
            filtered{k} = struct('time', c.time - c.time(1), ...
                                 'current', c.current, ...
                                 'voltage', c.voltage, ...
                                 'temperature', c.temperature, ...
                                 'label', sprintf('Ciklas %d', c.cycleNumber));
        else
            i0 = idx(1); i1 = idx(end);
            filtered{k} = struct('time', c.time(i0:i1) - c.time(i0), ...
                                 'current', c.current(i0:i1), ...
                                 'voltage', c.voltage(i0:i1), ...
                                 'temperature', c.temperature(i0:i1), ...
                                 'label', sprintf('Ciklas %d', c.cycleNumber));
        end
    end
    legend_labels = cellfun(@(s) s.label, filtered, 'UniformOutput', false);

    %% --- (1,1) Srovės profilis ---
    subplot(3, 2, 1);
    hold on; grid on;
    for k = 1:numel(filtered)
        f = filtered{k};
        plot(f.time/60, f.current, 'Color', colors(k,:), 'LineWidth', 1);
    end
    xlabel('Laikas (min)');
    ylabel('Srovė I (A)');
    title('Iškrovos srovės profilis');
    legend(legend_labels, 'Location', 'best');

    %% --- (1,2) Gnybtų įtampa ---
    subplot(3, 2, 2);
    hold on; grid on;
    for k = 1:numel(filtered)
        f = filtered{k};
        plot(f.time/60, f.voltage, 'Color', colors(k,:), 'LineWidth', 1);
    end
    xlabel('Laikas (min)');
    ylabel('Gnybtų įtampa V (V)');
    title('Gnybtų įtampa iškrovos metu');

    %% --- (2,1) Temperatūra ---
    % Pasenusiose celėse temperatūros kilimas ryškesnis dėl didesnės R0.
    subplot(3, 2, 3);
    hold on; grid on;
    for k = 1:numel(filtered)
        f = filtered{k};
        plot(f.time/60, f.temperature, 'Color', colors(k,:), 'LineWidth', 1);
    end
    xlabel('Laikas (min)');
    ylabel('Temperatūra T (°C)');
    title('Celės temperatūra');

    %% --- (2,2) V(Q) charakteristika ---
    subplot(3, 2, 4);
    hold on; grid on;
    for k = 1:numel(filtered)
        f = filtered{k};
        Q_disch = cumtrapz(f.time, abs(f.current)) / 3600;
        plot(Q_disch, f.voltage, 'Color', colors(k,:), 'LineWidth', 1);
    end
    xlabel('Iškrauta talpa Q (Ah)');
    ylabel('Gnybtų įtampa V (V)');
    title('Iškrovos įtampos profilis');

    %% --- (3,1) Talpa per ciklus ---
    subplot(3, 2, 5);
    if ~isempty(data.capacity_vs_cycle)
        cv = data.capacity_vs_cycle;
        plot(cv(:,1), cv(:,2), 'b-', 'LineWidth', 1); hold on;
        plot(cv(:,1), cv(:,2), 'b.', 'MarkerSize', 4);
        yline(0.8 * cv(1,2), 'r--', 'EOL (80 %)', 'LineWidth', 1.2);
        grid on;
        xlabel('Ciklo numeris');
        ylabel('Talpa (Ah)');
        title('Talpos mažėjimas per ciklus');
    end

    %% --- (3,2) SOH per ciklus ---
    subplot(3, 2, 6);
    if ~isempty(data.capacity_vs_cycle)
        cv = data.capacity_vs_cycle;
        Q_ref = cv(1, 2);
        SOH = 100 * cv(:, 2) / Q_ref;
        plot(cv(:,1), SOH, 'b-', 'LineWidth', 1); hold on;
        plot(cv(:,1), SOH, 'b.', 'MarkerSize', 4);
        yline(80, 'r--', 'EOL (80 %)', 'LineWidth', 1.2);

        below = find(SOH < 80, 1, 'first');
        if ~isempty(below)
            xline(cv(below,1), 'r:', sprintf('Ciklas %d', cv(below,1)), ...
                  'LineWidth', 1.0);
        end
        grid on;
        xlabel('Ciklo numeris');
        ylabel('SOH (%)');
        title('Sveikatos būklė (SOH)');
        ylim([min(50, min(SOH)-5), 105]);
    end

    sgtitle(sprintf('NASA B0005 celė — eksperimentiniai duomenys (šaltinis: %s)', ...
                    data.source), 'FontSize', 11, 'FontWeight', 'bold');
end
