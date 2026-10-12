clear; clc; close all
%% Programa
rng(1)

filename = "Base_Prestamos_ANFIS_Sesgo_Oculto.csv";

T = readtable(filename);

disp("primeras 10:");
disp(T(1:10,:));

%% Acá separamos la dependiente de la independiente
X = [T.Genero T.Edad T.IngresoMensual T.AntiguedadLaboral T.IndiceDeuda];
Y = T.PrestamoAprobado;
% Formamos nuestra variable normalizada para poder añadir el algoritmo

Xn = normalize(X);
data = [Xn Y];

N = size(data, 1);
idx = randperm(N);
Ntrain = round(0.7*N);

trainData = data(idx(1:Ntrain),:);
testData = data(idx(Ntrain+1:end), :);
%Ya hasta ahora solo hemos manipulado data
%% Ahora sí empieza el algoritmo
% ANFIS 1: GRID PARTITION
tic
optGrid = genfisOptions("GridPartition");
optGrid.NumMembershipFunctions = [3 3 3 3 3];
optGrid.InputMembershipFunctionType = "gbellmf";
optGrid.OutputMembershipFunctionType = "linear";

fisGrid0 = genfis(trainData(:,1:5),trainData(:,6),optGrid);

% Comprobar los datos antes de entrenar
disp("Tamaño de trainData:");
disp(size(trainData));

disp("Tamaño de testData:");
disp(size(testData));

assert(~isempty(testData), ...
    "testData está vacío: revisa N y la división entrenamiento/prueba.");

assert(size(testData,2) == 6, ...
    "testData debe contener 5 entradas y 1 salida.");

% Configurar entrenamiento y validación
optAnfisGrid = anfisOptions("InitialFIS", fisGrid0);
optAnfisGrid.EpochNumber = 100;
optAnfisGrid.ValidationData = testData;

disp("Tamaño de ValidationData:");
disp(size(optAnfisGrid.ValidationData));

% Entrenar
[fisGrid, trnErrorGrid, ~, fisGridVal, chkErrorGrid] = ...
    anfis(trainData, optAnfisGrid);

% Evaluar el modelo con menor error de validación
Ygrid_cont = evalfis(fisGridVal, testData(:,1:5));%% Convertir salida continua en clasificación
 umbral = 0.5;
Ygrid_class = double(Ygrid_cont >= umbral);

 Yreal = testData(:,6);

accuracyGrid = mean(Ygrid_class == Yreal)*100;

fprintf("\nANFIS Grid Partition\n");
fprintf("Accuracy = %.2f %%\n",accuracyGrid);

figure;
confusionchart(Yreal,Ygrid_class);
title("Matriz de confusión - ANFIS Grid Partition");

disp("Reglas ANFIS Grid Partition:");
showrule(fisGrid)

figure;
plot(trnErrorGrid,"LineWidth",1.5);
hold on;
plot(chkErrorGrid,"LineWidth",1.5);
grid on;
legend("Entrenamiento","Validación");
xlabel("Época");
ylabel("Error");
title("Error ANFIS - Grid Partition");

figure;
gensurf(fisGrid);
title("Superficie ANFIS - Grid Partition");
xlabel("Glucose normalizada");
ylabel("BMI normalizado");
zlabel("Salida ANFIS");
