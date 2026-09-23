%% RIESGO DE FRAUDE: SISTEMA FUZZY JERÁRQUICO
% Todas las entradas van de 0 (sin señal de riesgo) a 10 (riesgo alto).
% Para antigüedad, precio y fraccionamiento, ingresa una puntuación
% de riesgo previamente calculada, según las definiciones de abajo.

clear; clc;

% NIVEL 1: índices parciales
proveedor = crearFIS("Proveedor", ...
    ["vinculoPEPR3", "sanciones", "antiguedadRiesgo", ...
     "desajusteGiroObjeto"], "IF_proveedor");

proceso = crearFIS("Proceso", ...
    ["coparticipacionRecurrente", "rotacionGanadores", ...
     "requisitosDireccionados"], "IF_proceso");

economico = crearFIS("Economico", ...
    ["fraccionamiento", "precioAnomalo"], "IF_economico");

% NIVEL 2: combinación de los tres índices
experto = crearFIS("ExpertoRiesgos", ...
    ["IF_proveedor", "IF_proceso", "IF_economico"], ...
    "riesgoFraude");

% EJEMPLO. Sustituye estos valores por los de tu caso:
xProveedor = [8, 2, 7, 6];
xProceso   = [7, 5, 8];
xEconomico = [3, 9];

ifProveedor = evalfis(proveedor, xProveedor);
ifProceso   = evalfis(proceso, xProceso);
ifEconomico = evalfis(economico, xEconomico);

riesgoFraude = evalfis(experto, ...
    [ifProveedor, ifProceso, ifEconomico]);

fprintf("Índice proveedor: %.2f / 10\n", ifProveedor);
fprintf("Índice proceso:   %.2f / 10\n", ifProceso);
fprintf("Índice económico: %.2f / 10\n", ifEconomico);
fprintf("Riesgo de fraude: %.2f / 10\n", riesgoFraude);

% Opcional: inspeccionar los cuatro sistemas en Fuzzy Logic Designer
% fuzzyLogicDesigner(proveedor)
% fuzzyLogicDesigner(proceso)
% fuzzyLogicDesigner(economico)
% fuzzyLogicDesigner(experto)

%% FUNCIONES LOCALES

function fis = crearFIS(nombre, entradas, salida)
    fis = mamfis(Name=nombre);

    for i = 1:numel(entradas)
        fis = addInput(fis, [0 10], Name=entradas(i));
        fis = agregarConjuntos(fis, entradas(i));
    end

    fis = addOutput(fis, [0 10], Name=salida);
    fis = agregarConjuntos(fis, salida);

    % Una regla por cada combinación de Bajo, Medio y Alto.
    % Si alguna señal es Alta, el resultado es Alto.
    % Si ninguna es Alta pero alguna es Media, el resultado es Medio.
    % Solo todas Bajas producen resultado Bajo.
    n = numel(entradas);
    combinaciones = dec2base(0:(3^n - 1), 3, n) - '0' + 1;
    reglas = strings(size(combinaciones, 1), 1);

    etiquetas = ["Bajo", "Medio", "Alto"];

    for r = 1:size(combinaciones, 1)
        antecedentes = strings(1, n);

        for j = 1:n
            antecedentes(j) = entradas(j) + "==" + ...
                etiquetas(combinaciones(r, j));
        end

        nivelSalida = max(combinaciones(r, :));
        reglas(r) = strjoin(antecedentes, " | ") + ...
            " => " + salida + "=" + etiquetas(nivelSalida);
    end

    fis = addRule(fis, reglas);
end

function fis = agregarConjuntos(fis, variable)
    fis = addMF(fis, variable, "trapmf", [0 0 2 4], ...
        Name="Bajo");
    fis = addMF(fis, variable, "trimf", [2 5 8], ...
        Name="Medio");
    fis = addMF(fis, variable, "trapmf", [6 8 10 10], ...
        Name="Alto");
end