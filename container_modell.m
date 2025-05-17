% Container-Netzwerk-Visualisierung in MATLAB
% Datei: container_network.m

% CSV-Datei einlesen (alle Zeilen, ohne Begrenzung)
filename = 'container_data.csv';
opts = detectImportOptions(filename, 'Delimiter', ',', 'TextType', 'string', 'ReadVariableNames', true);
opts.DataLines = [2 Inf];  % Alle Zeilen einlesen, keine Begrenzung

% Dateigröße prüfen und Import anpassen
opts = setvaropts(opts, 'Container_ID', 'WhitespaceRule', 'preserve');
opts = setvaropts(opts, 'Container_ID', 'EmptyFieldRule', 'auto');

% Daten einlesen
data = readtable(filename, opts);

% Container-IDs bereinigen
data.Container_ID = strtrim(data.Container_ID);  % Leerzeichen entfernen
data.Container_ID = regexprep(data.Container_ID, '[^a-zA-Z0-9-]', '');  % Sonderzeichen entfernen
data.Container_ID = upper(data.Container_ID);  % Alles in Großbuchstaben

% Datum und Uhrzeit korrekt kombinieren
data.Timestamp = datetime(string(data.Datum) + " " + string(data.Uhrzeit), 'InputFormat', 'yyyy-MM-dd HH:mm');

% Nur den neuesten Eintrag pro Container-ID verwenden
data = sortrows(data, {'Container_ID', 'Timestamp'}, {'ascend', 'descend'});
[~, latestIdx] = unique(data.Container_ID, 'first');
data = data(latestIdx, :);

% Spalten extrahieren
containerIDs = data{:,'Container_ID'};
numContainers = numel(containerIDs);

% Zufällige Positionen in einem kartesischen 2D-Koordinatensystem
rng('shuffle');
x = randi([-100, 100], numContainers, 1);
y = randi([-100, 100], numContainers, 1);

% Kanten und Distanzen berechnen
edges = [];
weights = [];
distances = [];
for i = 1:numContainers
    % Zufälliger Ziel-Container (kein Selbstverweis)
    target = randi(numContainers);
    while target == i
        target = randi(numContainers);
    end
    
    % Kante hinzufügen
    edges = [edges; i, target];
    weights = [weights; 1];  % Alle Gewichte auf 1 setzen
    
    % Distanz berechnen
    dx = x(i) - x(target);
    dy = y(i) - y(target);
    distance = round(sqrt(dx^2 + dy^2), 1);  % Distanz mit 1 Dezimalstelle
    distances = [distances; distance];
end

% Netzwerk erstellen
G = graph(edges(:,1), edges(:,2), weights, containerIDs);

% Netzwerk zeichnen
figure;
p = plot(G, 'XData', x, 'YData', y, 'EdgeLabel', distances, 'LineWidth', 1.5, 'MarkerSize', 8);
title('Container-Netzwerk (Kartesische Positionen und Distanzen)');
xlabel('x (m)');
ylabel('y (m)');

% Füllstände als Node-Farben
nodeColors = data{:,'Fuellstand'} / 100;  % Normierung auf 0-1
highlight(p, 1:numContainers, 'NodeColor', [nodeColors zeros(numContainers, 1) 1-nodeColors]);
colorbar;
colormap jet;
title('Container-Netzwerk (mit kartesischen Positionen und Füllständen)');
