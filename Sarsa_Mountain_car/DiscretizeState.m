function xp = DiscretizeState(x, statelist)

% Distancia euclidiana entre x y cada estado de statelist
diferencias = statelist - repmat(x(:)', size(statelist,1), 1);
distancias = sqrt(sum(diferencias.^2, 2));

% Índice del estado más cercano
[~, xp] = min(distancias);

end