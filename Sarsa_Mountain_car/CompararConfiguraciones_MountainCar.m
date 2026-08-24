%% COMPARAR CONFIGURACIONES DE Q-LEARNING - MOUNTAIN CAR
% Requiere que los archivos Episode.m, BuildStateList.m,
% BuildActionList.m, BuildQTable.m y las demas funciones del proyecto
% se encuentren en la misma carpeta o en el path de MATLAB.
%
% Criterio de comparacion:
%   1. Mayor tasa de exito durante la evaluacion.
%   2. Menor promedio de pasos durante la evaluacion.
%   3. Menor variabilidad entre evaluaciones.
%
% Durante la evaluacion se usa epsilon = 0 y alpha = 0. De esta forma se
% mide solamente la politica aprendida, sin exploracion y sin modificar Q.

clc;
clear;
close all;

%% 1. PARAMETROS GENERALES

maxepisodes = 400;
maxsteps = 1000;

% Epsilon permanece igual para todas las configuraciones.
epsilonInicial = 0.01;
epsilonDecay = 0.99;

% Aumentar estos valores mejora la confiabilidad, pero tarda mas.
nRepeticiones = 10;
nEvaluaciones = 50;

% Numero de episodios finales usados para medir la convergencia.
nUltimos = 50;

grafica = false;

%% 2. CONFIGURACIONES [ALPHA, GAMMA]
% Puede agregar o quitar filas. No cambie epsilon para mantener una
% comparacion consistente con la consigna.

configuraciones = [
    0.50, 0.50;  % configuracion original
    0.50, 1.00;  % mejora propuesta: mayor valoracion del futuro
    0.10, 0.90;  % aprendizaje mas conservador
    0.10, 1.00   % aprendizaje conservador y sin descuento
];

nConfiguraciones = size(configuraciones,1);

%% 3. CONSTRUIR ESPACIOS DE ESTADOS Y ACCIONES

statelist = BuildStateList();
actionlist = BuildActionList();

nstates = size(statelist,1);
nactions = size(actionlist,1);

%% 4. RESERVAR MEMORIA PARA LOS RESULTADOS

pasosEntrenamiento = zeros(nConfiguraciones,nRepeticiones,maxepisodes);
recompensasEntrenamiento = zeros(nConfiguraciones,nRepeticiones,maxepisodes);

pasosEvaluacion = zeros(nConfiguraciones,nRepeticiones,nEvaluaciones);
recompensasEvaluacion = zeros(nConfiguraciones,nRepeticiones,nEvaluaciones);

epsilonFinal = zeros(nConfiguraciones,nRepeticiones);
Qresultados = cell(nConfiguraciones,nRepeticiones);

%% 5. ENTRENAMIENTO Y EVALUACION

fprintf('\nCOMPARACION DE CONFIGURACIONES DE Q-LEARNING\n');
fprintf('Epsilon inicial fijo: %.5f\n',epsilonInicial);
fprintf('Repeticiones por configuracion: %d\n',nRepeticiones);
fprintf('Evaluaciones por repeticion: %d\n\n',nEvaluaciones);

tic;

for c = 1:nConfiguraciones

    alpha = configuraciones(c,1);
    gamma = configuraciones(c,2);

    fprintf('===============================================\n');
    fprintf('Configuracion %d/%d: alpha = %.2f, gamma = %.2f\n', ...
        c,nConfiguraciones,alpha,gamma);
    fprintf('===============================================\n');

    for repeticion = 1:nRepeticiones

        % La misma repeticion utiliza la misma semilla en cada
        % configuracion, haciendo mas comparable la aleatoriedad inicial.
        rng(repeticion,'twister');

        % Q debe reiniciarse en cada entrenamiento.
        Q = BuildQTable(nstates,nactions);
        epsilon = epsilonInicial;

        % -------------------- ENTRENAMIENTO --------------------
        for episodio = 1:maxepisodes

            [reward,steps,Q] = Episode( ...
                maxsteps,Q,alpha,gamma,epsilon, ...
                statelist,actionlist,grafica);

            pasosEntrenamiento(c,repeticion,episodio) = steps;
            recompensasEntrenamiento(c,repeticion,episodio) = reward;

            % Mismo decaimiento para todas las configuraciones.
            epsilon = epsilon * epsilonDecay;
        end

        epsilonFinal(c,repeticion) = epsilon;
        Qresultados{c,repeticion} = Q;

        % --------------------- EVALUACION ----------------------
        % alpha = 0 evita modificar la tabla Q.
        % epsilon = 0 elimina las acciones exploratorias.
        alphaEvaluacion = 0;
        epsilonEvaluacion = 0;

        % Semilla de evaluacion comun para todas las configuraciones.
        rng(100000 + repeticion,'twister');

        for evaluacion = 1:nEvaluaciones

            [rewardEval,stepsEval,~] = Episode( ...
                maxsteps,Q,alphaEvaluacion,gamma,epsilonEvaluacion, ...
                statelist,actionlist,false);

            pasosEvaluacion(c,repeticion,evaluacion) = stepsEval;
            recompensasEvaluacion(c,repeticion,evaluacion) = rewardEval;
        end

        pasosEvalRepeticion = reshape( ...
            pasosEvaluacion(c,repeticion,:),[],1);

        fprintf(['Repeticion %2d/%d | media evaluacion: %7.2f', ...
                 ' | exito: %6.2f %%\n'], ...
            repeticion,nRepeticiones, ...
            mean(pasosEvalRepeticion), ...
            100*mean(pasosEvalRepeticion < maxsteps));
    end
end

tiempoTotal = toc;
fprintf('\nTiempo total: %.2f segundos\n',tiempoTotal);

%% 6. CALCULAR METRICAS RESUMEN

resultadoAlpha = configuraciones(:,1);
resultadoGamma = configuraciones(:,2);
epsilonFinalPromedio = zeros(nConfiguraciones,1);
mediaUltimosEntrenamiento = zeros(nConfiguraciones,1);
mediaEvaluacion = zeros(nConfiguraciones,1);
medianaEvaluacion = zeros(nConfiguraciones,1);
desviacionEvaluacion = zeros(nConfiguraciones,1);
peorEvaluacion = zeros(nConfiguraciones,1);
tasaExito = zeros(nConfiguraciones,1);

for c = 1:nConfiguraciones

    ultimos = pasosEntrenamiento(c,:,maxepisodes-nUltimos+1:maxepisodes);
    ultimos = ultimos(:);

    evaluaciones = pasosEvaluacion(c,:,:);
    evaluaciones = evaluaciones(:);

    epsilonFinalPromedio(c) = mean(epsilonFinal(c,:));
    mediaUltimosEntrenamiento(c) = mean(ultimos);
    mediaEvaluacion(c) = mean(evaluaciones);
    medianaEvaluacion(c) = median(evaluaciones);
    desviacionEvaluacion(c) = std(evaluaciones);
    peorEvaluacion(c) = max(evaluaciones);
    tasaExito(c) = 100*mean(evaluaciones < maxsteps);
end

resultados = table( ...
    resultadoAlpha,resultadoGamma,epsilonFinalPromedio, ...
    mediaUltimosEntrenamiento,mediaEvaluacion,medianaEvaluacion, ...
    desviacionEvaluacion,peorEvaluacion,tasaExito, ...
    'VariableNames',{ ...
    'Alpha','Gamma','EpsilonFinal','MediaUltimos50Entrenamiento', ...
    'MediaEvaluacion','MedianaEvaluacion','DesviacionEvaluacion', ...
    'PeorEvaluacion','TasaExito'});

% Mayor tasa de exito primero; en caso de empate, menor media de pasos.
resultadosOrdenados = sortrows(resultados, ...
    {'TasaExito','MediaEvaluacion'}, {'descend','ascend'});

fprintf('\nRESULTADOS POR CONFIGURACION\n');
disp(resultados);

fprintf('\nRANKING FINAL\n');
disp(resultadosOrdenados);

% Guardar la tabla para utilizarla en el informe o presentacion.
writetable(resultadosOrdenados,'ResultadosConfiguracionesMountainCar.csv');

%% 7. IDENTIFICAR LA MEJOR CONFIGURACION

mejorTasaExito = max(tasaExito);
candidatas = find(tasaExito == mejorTasaExito);

[~,posicionMejor] = min(mediaEvaluacion(candidatas));
mejorConfiguracion = candidatas(posicionMejor);

fprintf('\nMEJOR CONFIGURACION\n');
fprintf('Alpha: %.2f\n',configuraciones(mejorConfiguracion,1));
fprintf('Gamma: %.2f\n',configuraciones(mejorConfiguracion,2));
fprintf('Epsilon inicial: %.5f\n',epsilonInicial);
fprintf('Epsilon final promedio: %.8f\n', ...
    epsilonFinalPromedio(mejorConfiguracion));
fprintf('Tasa de exito: %.2f %%\n',tasaExito(mejorConfiguracion));
fprintf('Promedio de pasos de evaluacion: %.2f\n', ...
    mediaEvaluacion(mejorConfiguracion));
fprintf('Desviacion de pasos de evaluacion: %.2f\n', ...
    desviacionEvaluacion(mejorConfiguracion));

%% 8. GRAFICO DE CONVERGENCIA PROMEDIO

colores = lines(nConfiguraciones);
leyendas = cell(nConfiguraciones,1);

figure('Name','Comparacion de convergencia');
hold on;
grid on;

for c = 1:nConfiguraciones

    datos = squeeze(pasosEntrenamiento(c,:,:));
    curvaPromedio = mean(datos,1);

    plot(1:maxepisodes,curvaPromedio, ...
        'LineWidth',1.5,'Color',colores(c,:));

    leyendas{c} = sprintf('alpha = %.2f, gamma = %.2f', ...
        configuraciones(c,1),configuraciones(c,2));
end

xlabel('Episodio');
ylabel('Promedio de pasos');
title('Convergencia promedio por configuracion');
legend(leyendas,'Location','best');
ylim([0 maxsteps]);

%% 9. GRAFICO DE CONVERGENCIA SUAVIZADA

ventana = 20;

figure('Name','Convergencia suavizada');
hold on;
grid on;

for c = 1:nConfiguraciones

    datos = squeeze(pasosEntrenamiento(c,:,:));
    curvaPromedio = mean(datos,1);
    curvaSuavizada = movmean(curvaPromedio,ventana);

    plot(1:maxepisodes,curvaSuavizada, ...
        'LineWidth',2,'Color',colores(c,:));
end

xlabel('Episodio');
ylabel('Promedio movil de pasos');
title(sprintf('Convergencia promedio - ventana de %d episodios',ventana));
legend(leyendas,'Location','best');
ylim([0 maxsteps]);

%% 10. COMPARACION DEL DESEMPENO DE EVALUACION

figure('Name','Desempeno de evaluacion');

subplot(2,1,1);
bar(mediaEvaluacion,'FaceColor',[0.20 0.55 0.85]);
hold on;
errorbar(1:nConfiguraciones,mediaEvaluacion,desviacionEvaluacion, ...
    '.k','LineWidth',1.3);
grid on;
xlabel('Configuracion');
ylabel('Pasos');
title('Promedio y desviacion de pasos en evaluacion');
set(gca,'XTick',1:nConfiguraciones,'XTickLabel',leyendas);
xtickangle(20);

subplot(2,1,2);
bar(tasaExito,'FaceColor',[0.25 0.70 0.35]);
grid on;
xlabel('Configuracion');
ylabel('Tasa de exito (%)');
title('Tasa de exito en evaluacion');
set(gca,'XTick',1:nConfiguraciones,'XTickLabel',leyendas);
xtickangle(20);
ylim([0 105]);

%% 11. ELEGIR LA MEJOR TABLA Q DE LA CONFIGURACION GANADORA

mediaPorRepeticion = zeros(nRepeticiones,1);
tasaPorRepeticion = zeros(nRepeticiones,1);

for repeticion = 1:nRepeticiones
    datos = reshape( ...
        pasosEvaluacion(mejorConfiguracion,repeticion,:),[],1);
    mediaPorRepeticion(repeticion) = mean(datos);
    tasaPorRepeticion(repeticion) = mean(datos < maxsteps);
end

mejorTasaRepeticion = max(tasaPorRepeticion);
repeticionesCandidatas = find(tasaPorRepeticion == mejorTasaRepeticion);

[~,posicionRepeticion] = min( ...
    mediaPorRepeticion(repeticionesCandidatas));
mejorRepeticion = repeticionesCandidatas(posicionRepeticion);

Qmejor = Qresultados{mejorConfiguracion,mejorRepeticion};

%% 12. SUPERFICIE 3D DE LA MEJOR TABLA Q

figure('Name','Mejor tabla Q');
surf(1:nactions,1:nstates,Qmejor);
xlabel('Accion');
ylabel('Estado');
zlabel('Valor Q');
title(sprintf(['Mejor tabla Q: alpha = %.2f, gamma = %.2f, ', ...
    'repeticion = %d'], ...
    configuraciones(mejorConfiguracion,1), ...
    configuraciones(mejorConfiguracion,2), ...
    mejorRepeticion));
colorbar;
grid on;

%% 13. EXTRAER Y GUARDAR LA POLITICA APRENDIDA

[mejorValorQ,politicaAprendida] = max(Qmejor,[],2);

tablaPolitica = table( ...
    (1:nstates)',politicaAprendida,mejorValorQ, ...
    'VariableNames',{'Estado','MejorAccion','ValorQ'});

fprintf('\nPOLITICA DE LA MEJOR TABLA Q\n');
disp(tablaPolitica);

writetable(tablaPolitica,'MejorPoliticaMountainCar.csv');

%% 14. GUARDAR TODO EL EXPERIMENTO

save('ResultadosCompletosMountainCar.mat', ...
    'configuraciones','epsilonInicial','epsilonDecay', ...
    'pasosEntrenamiento','recompensasEntrenamiento', ...
    'pasosEvaluacion','recompensasEvaluacion', ...
    'resultados','resultadosOrdenados', ...
    'mejorConfiguracion','mejorRepeticion','Qmejor', ...
    'tablaPolitica');

fprintf('\nARCHIVOS GENERADOS\n');
fprintf('- ResultadosConfiguracionesMountainCar.csv\n');
fprintf('- MejorPoliticaMountainCar.csv\n');
fprintf('- ResultadosCompletosMountainCar.mat\n');
fprintf('\nComparacion finalizada correctamente.\n');