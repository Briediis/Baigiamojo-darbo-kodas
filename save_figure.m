function save_figure(output_path, filename, resolution)
% SAVE_FIGURE  Išsaugo dabartinį grafiką (gcf) į PNG failą.
%
% Bando išsaugoti naudojant exportgraphics (MATLAB R2020+);
% jei nepasiekiama – naudoja print kaip alternatyvą.
%
% Įvestis:
%   output_path - tikslinė direktorija
%   filename    - failo pavadinimas be plėtinio
%   resolution  - (neprivalomas) rezoliucija DPI (numatytasis: 200)

    if nargin < 3 || isempty(resolution)
        resolution = 200;
    end

    if ~exist(output_path, 'dir')
        try
            mkdir(output_path);
        catch err
            fprintf('    KLAIDA: nepavyko sukurti %s (%s)\n', ...
                    output_path, err.message);
            return;
        end
    end

    fig = gcf;
    drawnow;

    filepath = fullfile(output_path, [filename '.png']);

    saved = false;
    try
        exportgraphics(fig, filepath, 'Resolution', resolution);
        saved = true;
    catch
        % exportgraphics nepasiekiama – bandom print
    end

    if ~saved
        try
            print(fig, filepath, '-dpng', sprintf('-r%d', resolution));
            saved = true;
        catch err
            fprintf('    KLAIDA išsaugant %s: %s\n', filename, err.message);
            return;
        end
    end

    if saved
        fprintf('    Išsaugotas: %s.png\n', filename);
    end
end
