
%% ANFIS COMO CLASIFICADOR - DATASET DIABETES UCI / PIMA
clear; clc; close all;
rng(1);

%% 1) Descargar y leer la base de datos

%%url = "https://raw.githubusercontent.com/npradaschnor/Pima-Indians-Diabetes-Dataset/master/diabetes.csv";
filename = "Base_Prestamos_ANFIS_Sesgo_Oculto.csv";

if ~isfile(filename)
    websave(filename);
end

T = readtable(filename);

disp("Primeras 10 muestras:");
disp(T(1:10,:));

%% 2) Seleccionar variables para hacerlo interpretable
% Usaremos solo dos entradas:
% Glucose y BMI
% Salida: Outcome

X = [T.Genero T.Edad T.IngresoMensual T.AntiguedadLaboral T.IndiceDeuda];
Y = T.PrestamoAprobado;

%% 3) Normalizar entradas
Xn = normalize(X);

data = [Xn Y];

%% 4) Separar entrenamiento y prueba

N = size(data,1);
idx = randperm(N);

Ntrain = round(0.7*N);

trainData = data(idx(1:Ntrain),:);
testData  = data(idx(Ntrain+1:end),:);
tic
%% ============================================================
%% ANFIS 1: GRID PARTITION
%% ============================================================

optGrid = genfisOptions("GridPartition");
optGrid.NumMembershipFunctions = [3 3 3 3 3];
optGrid.InputMembershipFunctionType = "gbellmf";
optGrid.OutputMembershipFunctionType = "linear";

fisGrid0 = genfis(trainData(:,1:5),trainData(:,6),optGrid);

optAnfisGrid = anfisOptions("InitialFIS",fisGrid0);
optAnfisGrid.EpochNumber = 100;
optAnfisGrid.ValidationData = testData;

[fisGrid,trnErrorGrid,~,~,chkErrorGrid] = anfis(trainData,optAnfisGrid);

%% Evaluar salida continua
Ygrid_cont = evalfis(fisGrid,testData(:,1:5));

%% Convertir salida continua en clasificación
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

%% ============================================================
%% ANFIS 2: FUZZY C-MEANS
%% ============================================================

optFCM = genfisOptions("FCMClustering");
optFCM.NumClusters = 5;

fisFCM0 = genfis(trainData(:,1:5),trainData(:,6),optFCM);

optAnfisFCM = anfisOptions("InitialFIS",fisFCM0);
optAnfisFCM.EpochNumber = 100;
optAnfisFCM.ValidationData = testData;

[fisFCM,trnErrorFCM,~,~,chkErrorFCM] = anfis(trainData,optAnfisFCM);

%% Evaluar salida continua
Yfcm_cont = evalfis(fisFCM,testData(:,1:5));

%% Convertir salida continua en clasificación
Yfcm_class = double(Yfcm_cont >= umbral);

accuracyFCM = mean(Yfcm_class == Yreal)*100;

fprintf("\nANFIS Fuzzy C-Means\n");
fprintf("Accuracy = %.2f %%\n",accuracyFCM);

figure;
confusionchart(Yreal,Yfcm_class);
title("Matriz de confusión - ANFIS Fuzzy C-Means");

disp("Reglas ANFIS Fuzzy C-Means:");
showrule(fisFCM)

figure;
plot(trnErrorFCM,"LineWidth",1.5);
hold on;
plot(chkErrorFCM,"LineWidth",1.5);
grid on;
legend("Entrenamiento","Validación");
xlabel("Época");
ylabel("Error");
title("Error ANFIS - Fuzzy C-Means");

figure;
gensurf(fisFCM);
title("Superficie ANFIS - Fuzzy C-Means");
xlabel("Glucose normalizada");
ylabel("BMI normalizado");
zlabel("Salida ANFIS");

%% ============================================================
%% COMPARACIÓN FINAL
%% ============================================================

fprintf("\nCOMPARACIÓN FINAL\n");
%fprintf("Grid Partition Accuracy = %.2f %%\n",accuracyGrid);
fprintf("Fuzzy C-Means Accuracy  = %.2f %%\n",accuracyFCM);
fprintf("¿Vale la pena ganar 2 porciento de precisión si perdemos completamente la interpretabilidad?");
% if accuracyGrid > accuracyFCM
%     fprintf("\nEl mejor modelo fue: Grid Partition\n");
% else
%     fprintf("\nEl mejor modelo fue: Fuzzy C-Means\n");
% end

%% ============================================================
%% INTERPRETACIÓN DE UNA PACIENTE
%% ============================================================

%Caso_M = [1 46 6000 15 0.15];
Caso_H = [0 46 6000 15 0.15];


% Normalizar usando media y desviación del dataset original
mu = mean(X);
sigma = std(X);

x = (Caso_H - mu)./sigma;

[y,~,ruleFiring,ruleOutput] = evalfis(fisFCM,x);

clase = double(y >= 0.5);

fprintf("\nPaciente evaluada:\n");
% fprintf("Glucose = %.2f\n",Caso_H(1));
% fprintf("BMI     = %.2f\n",Caso_H(2));
fprintf("Salida ANFIS = %.4f\n",y);
fprintf("Clase predicha = %d\n",clase);

if clase == 1
    disp("Interpretación: el modelo clasifica como pago.");
else
    disp("Interpretación: el modelo clasifica como no pago.");
end

%% Mostrar reglas activadas

reglas = showrule(fisFCM);

fprintf("\nReglas activadas para la paciente:\n");

for i = 1:length(ruleFiring)
    if ruleFiring(i) > 0.00005
        fprintf("\nRegla %d\n",i);
        fprintf("%s\n",reglas(i,:));
        fprintf("Activación: %.4f\n",ruleFiring(i));
       % fprintf("Salida de la regla: %.4f\n",ruleOutput(i));
    end
end

toc