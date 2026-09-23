%% RIESGO DE FRAUDE: SISTEMA FUZZY JERÁRQUICO
% Todas las entradas van de 0 (sin señal de riesgo) a 10 (riesgo alto).
% Para antigüedad, precio y fraccionamiento, ingresa una puntuación
% de riesgo previamente calculada, según las definiciones de abajo.

clear; clc;

% NIVEL 1: índices parciales
% NIVEL 1: índices parciales
proveedor = crearFIS("Proveedor", ...
    ["vinculoPEPR3", "sanciones", "antiguedadRiesgo", ...
     "desajusteGiroObjeto"], "IF_proveedor", "proveedor");

proceso = crearFIS("Proceso", ...
    ["coparticipacionRecurrente", "rotacionGanadores", ...
     "requisitosDireccionados"], "IF_proceso", "proceso");

economico = crearFIS("Economico", ...
    ["fraccionamiento", "precioAnomalo"], ...
    "IF_economico", "economico");

% NIVEL 2: combinación de los tres índices
experto = crearFIS("ExpertoRiesgos", ...
    ["IF_proveedor", "IF_proceso", "IF_economico"], ...
    "riesgoFraude", "final");

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

function fis = crearFIS(nombre, entradas, salida, subsistema)
    fis = mamfis(Name=nombre);

    for i = 1:numel(entradas)
        fis = addInput(fis, [0 10], Name=entradas(i));
        fis = agregarConjuntos(fis, entradas(i));
    end

    fis = addOutput(fis, [0 10], Name=salida);
    fis = agregarConjuntos(fis, salida);

    % Genera una regla específica para cada combinación lingüística.
    % 1 = Bajo, 2 = Medio, 3 = Alto.
    n = numel(entradas);
    combinaciones = dec2base(0:3^n-1, 3, n) - '0' + 1;

    % Formato MATLAB: [antecedentes, consecuente, peso, conexión].
    % Conexión 1 = AND entre las entradas de cada regla.
    reglas = zeros(size(combinaciones, 1), n + 3);

    for r = 1:size(combinaciones, 1)
        niveles = combinaciones(r, :);
        nivelSalida = decidirNivel(subsistema, niveles);

        reglas(r, :) = [niveles, nivelSalida, 1, 1];
    end

    fis = addRule(fis, reglas);
end

function nivelSalida = decidirNivel(subsistema, x)
    switch subsistema

        case "proveedor"
            % x = [PEP, sanciones, antigüedad, desajuste].
            % Sanción confirmada es una alerta fuerte; PEP aislado no.
            pep        = [0 1 2];
            sancion    = [0 2 5];
            antiguedad = [0 0.5 1];
            desajuste  = [0 1 2];

            puntaje = pep(x(1)) + sancion(x(2)) + ...
                      antiguedad(x(3)) + desajuste(x(4));

            if x(1) == 3 && x(2) >= 2
                puntaje = puntaje + 1;
            end
            if x(3) == 3 && x(4) == 3
                puntaje = puntaje + 1;
            end

        case "proceso"
            % x = [coparticipación, rotación, requisitos].
            coparticipacion = [0 1 2];
            rotacion        = [0 1 2];
            requisitos      = [0 1 2];

            puntaje = coparticipacion(x(1)) + ...
                      rotacion(x(2)) + requisitos(x(3));

            if x(1) >= 2 && x(2) >= 2
                puntaje = puntaje + 2;
            end
            if x(1) >= 2 && x(3) >= 2
                puntaje = puntaje + 1;
            end

        case "economico"
            % x = [fraccionamiento, precio anómalo].
            fraccionamiento = [0 1 2];
            precio          = [0 1 3];

            puntaje = fraccionamiento(x(1)) + precio(x(2));

            if x(1) >= 2 && x(2) >= 2
                puntaje = puntaje + 2;
            end

        case "final"
            % x = [IF_proveedor, IF_proceso, IF_economico].
            riesgoProveedor = [0 1 2];
            riesgoProceso   = [0 1 3];
            riesgoEconomico = [0 1 2];

            puntaje = riesgoProveedor(x(1)) + ...
                      riesgoProceso(x(2)) + riesgoEconomico(x(3));

            if x(2) >= 2 && x(3) >= 2
                puntaje = puntaje + 1;
            end
            if x(1) >= 2 && x(2) >= 2
                puntaje = puntaje + 1;
            end

        otherwise
            error("Subsistema desconocido: %s", subsistema);
    end

    if puntaje >= 5
        nivelSalida = 3;  % Alto
    elseif puntaje >= 2
        nivelSalida = 2;  % Medio
    else
        nivelSalida = 1;  % Bajo
    end
end

function fis = agregarConjuntos(fis, variable)
    fis = addMF(fis, variable, "trapmf", [0 0 2 4], ...
        Name="Bajo");
    fis = addMF(fis, variable, "trimf", [2 5 8], ...
        Name="Medio");
    fis = addMF(fis, variable, "trapmf", [6 8 10 10], ...
        Name="Alto");
end