function save_all_figures(output_path, resolution)
% SAVE_ALL_FIGURES  Išsaugo visus atvirus grafikus į PNG failus.
%
% Automatiškai suranda visas atviras figūras, generuoja failų pavadinimus
% iš figure 'Name' lauko ir išsaugo PNG formatu. Lietuviškos raidės
% pavadinime keičiamos į ASCII atitikmenis.
%
% Įvestis:
%   output_path - tikslinė direktorija
%   resolution  - (neprivalomas) rezoliucija DPI (numatytasis: 200)

    if nargin < 2 || isempty(resolution)
        resolution = 200;
    end

    if ~exist(output_path, 'dir')
        try
            mkdir(output_path);
            fprintf('  Sukurta direktorija: %s\n', output_path);
        catch err
            fprintf('  KLAIDA: nepavyko sukurti direktorijos %s\n', output_path);
            fprintf('         %s\n', err.message);
            return;
        end
    end

    figs = findall(0, 'Type', 'figure');
    if isempty(figs)
        fprintf('  Nėra atvirų grafikų išsaugojimui.\n');
        return;
    end

    % findall grąžina atvirkščia tvarka – apverčiame
    figs = flipud(figs);
    fprintf('  Išsaugomi %d grafikai į: %s\n', numel(figs), output_path);

    for k = 1:numel(figs)
        fig = figs(k);
        try
            name = get(fig, 'Name');
        catch
            name = '';
        end

        if isempty(name)
            filename = sprintf('fig_%02d.png', k);
        else
            clean_name = sanitize_filename(name);
            if isempty(clean_name)
                filename = sprintf('fig_%02d.png', k);
            else
                filename = sprintf('fig_%02d_%s.png', k, clean_name);
            end
        end

        filepath = fullfile(output_path, filename);

        try
            print(fig, filepath, '-dpng', sprintf('-r%d', resolution));
            fprintf('    [%02d] %s\n', k, filename);
        catch err
            fprintf('    [%02d] KLAIDA (%s): %s\n', k, filename, err.message);
        end
    end

    fprintf('  Išsaugojimas baigtas.\n');
end

% ------------------------------------------------------------------
function clean = sanitize_filename(name)
% Sukuria saugų failo pavadinimą: keičia lietuviškas raides,
% šalina neleistinus simbolius, tarpus keičia pabraukimais.
    name = char(name);

    lt_pairs = {
        {'ą','a'},{'č','c'},{'ę','e'},{'ė','e'},{'į','i'},...
        {'š','s'},{'ų','u'},{'ū','u'},{'ž','z'},...
        {'Ą','A'},{'Č','C'},{'Ę','E'},{'Ė','E'},{'Į','I'},...
        {'Š','S'},{'Ų','U'},{'Ū','U'},{'Ž','Z'}
    };
    for k = 1:numel(lt_pairs)
        name = strrep(name, lt_pairs{k}{1}, lt_pairs{k}{2});
    end

    name = regexprep(name, '[\\/:*?"<>|.()\[\]{}]', '');
    name = regexprep(name, '\s+', '_');
    name = regexprep(name, '[^a-zA-Z0-9_-]', '');
    name = regexprep(name, '_+', '_');
    name = regexprep(name, '^_|_$', '');

    if length(name) > 60
        name = name(1:60);
    end

    clean = name;
end
