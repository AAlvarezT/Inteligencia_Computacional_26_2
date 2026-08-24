% Comparación de configuraciones de Q-Learning para Mountain Car
% Epsilon se mantiene igual en todas las configuraciones

clc;
clear;
close all;

%% Parámetros generales

maxepisodes = 400;
maxsteps    = 1000;

epsilonInicial = 0.01;
epsilonDecay   = 0.99;

nRepeticiones = 10;   % entrenamientos por configuración
nEvaluaciones = 50;   % episodios de evaluación por entrenamiento

statelist  = BuildStateList();
actionlist = BuildActionList();

nstates  = size(statelist,1);
nactions = size(actionlist,1);

grafica = false;

%% Configuraciones que se van a comparar
% Cada fila contiene: [alpha, gamma]

configuraciones = [
    0.5, 0.5;   % configuración original
    0.5, 1.0;   % mejora propuesta
    0.1, 0.9;   % alternativa más conservadora
    0.1, 1.0    % aprendizaje más estable y largo plazo
];

nConfiguraciones = size(configuraciones,1);

%% Variables para almacenar resultados

pasosEntrenamiento = zeros( ...
    nConfiguraciones, nRepeticiones, maxepisodes);

pasosEvaluacion = zeros( ...
    nConfiguraciones, nRepeticiones, nEvaluaciones);

recompensaEvaluacion = zeros( ...
    nConfiguraciones, nRepeticiones, nEvaluaciones);

epsilonFinal = zeros(nConfiguraciones,nRepeticiones);

% Guardaremos las tablas Q obtenidas
Qresultados = cell(nConfiguraciones,nRepeticiones);

%% Entrenamiento y evaluación

tic;

for c = 1:nConfiguraciones

    alpha = configuraciones(c,1);
    gamma = configuraciones(c,2);

    fprintf('\n========================================\n');
    fprintf('Configuración %d: alpha = %.2f, gamma = %.2f\n', ...
        c, alpha, gamma);
    fprintf('========================================\n');

    for repeticion = 1:nRepeticiones

        % Misma semilla para la misma repetición de cada configuración
        % Esto hace más justa la comparación
        rng(repeticion);

        % Reiniciar completamente la tabla Q
        Q = BuildQTable(nstates,nactions);

        epsilon = epsilonInicial;

        %% Entrenamiento

        for episodio = 1:maxepisodes

            [~,steps,Q] = Episode( ...
                maxsteps, ...
                Q, ...
                alpha, ...
                gamma, ...
                epsilon, ...
                statelist, ...
                actionlist, ...
                false);

            pasosEntrenamiento(c,repeticion,episodio) = steps;

            % Mismo decaimiento para todas las configuraciones
            epsilon = epsilon * epsilonDecay;
        end

        epsilonFinal(c,repeticion) = epsilon;
        Qresultados{c,repeticion} = Q;

        %% Evaluación de la política aprendida
        %
        % alpha = 0: no se modifica Q
        % epsilon = 0: no se realizan acciones aleatorias

        alphaEvaluacion   = 0;
        epsilonEvaluacion = 0;

        for evaluacion = 1:nEvaluaciones

            [rewardEval,stepsEval,~] = Episode( ...
                maxsteps, ...
                Q, ...
                alphaEvaluacion, ...
                gamma, ...
                epsilonEvaluacion, ...
                statelist, ...
                actionlist, ...
                false);

            pasosEvaluacion(c,repeticion,evaluacion) = stepsEval;
            recompensaEvaluacion(c,repeticion,evaluacion) = rewardEval;
        end

        fprintf('Repetición %2d/%d - promedio evaluación: %.2f pasos\n', ...
            repeticion, ...
            nRepeticiones, ...
            mean(pasosEvaluacion(c,repeticion,:)));
    end
end

tiempoTotal = toc;

fprintf('\nTiempo total: %.2f segundos\n',tiempoTotal);

%% Resumen de resultados

resultadoAlpha = zeros(nConfiguraciones,1);
resultadoGamma = zeros(nConfiguraciones,1);
mediaEntrenamiento = zeros(nConfiguraciones,1);
mediaEvaluacion = zeros(nConfiguraciones,1);
medianaEvaluacion = zeros(nConfiguraciones,1);
desviacionEvaluacion = zeros(nConfiguraciones,1);
tasaExito = zeros(nConfiguraciones,1);
epsilonFinalPromedio = zeros(nConfiguraciones,1);

for c = 1:nConfiguraciones

    resultadoAlpha(c) = configuraciones(c,1);
    resultadoGamma(c) = configuraciones(c,2);

    % Últimos 50 episodios de todas las repeticiones
    ultimosEntrenamientos = pasosEntrenamiento( ...
        c,:,maxepisodes-49:maxepisodes);

    mediaEntrenamiento(c) = mean(ultimosEntrenamientos(:));

    % Todos los episodios de evaluación
    pasosConfig = pasosEvaluacion(c,:,:);
    pasosConfig = pasosConfig(:);

    mediaEvaluacion(c) = mean(pasosConfig);
    medianaEvaluacion(c) = median(pasosConfig);
    desviacionEvaluacion(c) = std(pasosConfig);

    % Un episodio es exitoso si termina antes de maxsteps
    tasaExito(c) = 100 * mean(pasosConfig < maxsteps);

    epsilonFinalPromedio(c) = mean(epsilonFinal(c,:));
end

resultados = table( ...
    resultadoAlpha, ...
    resultadoGamma, ...
    epsilonFinalPromedio, ...
    mediaEntrenamiento, ...
    mediaEvaluacion, ...
    medianaEvaluacion, ...
    desviacionEvaluacion, ...
    tasaExito, ...
    'VariableNames',{ ...
        'Alpha', ...
        'Gamma', ...
        'EpsilonFinal', ...
        'MediaUltimos50Entrenamiento', ...
        'MediaEvaluacion', ...
        'MedianaEvaluacion', ...
        'DesviacionEvaluacion', ...
        'TasaExito'});

disp(resultados);

% Ordenar: primero mayor tasa de éxito y luego menor media de pasos
resultadosOrdenados = sortrows( ...
    resultados, ...
    {'TasaExito','MediaEvaluacion'}, ...
    {'descend','ascend'});

fprintf('\nRanking de configuraciones:\n');
disp(resultadosOrdenados);