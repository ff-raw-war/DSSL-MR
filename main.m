clc; clear; 
recordMaxAcc = 0; 
recordMaxMacroF1 = 0; 
type = 0; 
directory = '.\datasets\';
fileName = 'UMIST';
fileType = '.mat';
file = strcat(directory, fileName, fileType);
load(file);
fprintf('dataset file: %s' , fileName);


ithView = 1; 

dataSet = [A' , labels']; 

postName = strcat(fileName , '.txt');
saveFileName = strcat('.\report\' , postName);
warning off;
fid=fopen(saveFileName,'a');    
fclose(fid);

%% datasets pre-process
totalCycle = 5; 
[dataSet , dim] = dataSet2Segments(dataSet , totalCycle);
totalClass = size(dataSet , 2); 


%% parameters init
parameter.para = [10^8; 10^4; 10^0; 10^-4; 10^-8];
parameter.fix = 1;
parameter.hang = 10^-4;
parameter.ablation = 0;
parameter.alpha = parameter.fix;
parameter.beta = parameter.fix;
parameter.gamma = parameter.hang;
parameter.lambda = parameter.para;
parameter.M = 1 ;        
parameter.C = 2^(-4) * ones(parameter.M+1 , 1) ;      
parameter.kdelta = 2^(-3)+(2^3 - 2^(-3))*rand(parameter.M,1) ;
                  
parameter.kType = 'linear' ; % RBF
parameter.C((parameter.M+1),1) = 0.01 ; 
parameter.rho = 0.99 * ones(parameter.M,1);
parameter.totalIter = 30 ; 
parameter.epsilon = 1e-3 ;

%% one vs one class
U = [];
a = [1 : totalClass];
b = [1 : totalClass];
for i  = 1  : totalClass
    for j = 1 : totalClass
        vsTemp = sort([a(i);b(j)]);
        if a(i) ~= b(j)
            U = [U , vsTemp];
        end
    end
end
VS = unique(U','rows');

%% grid search for optimal parameters
FinalRes = [];
FinalRecord = [];

for ithAlpha = 1 : size(parameter.alpha)
    for ithBeta = 1: size(parameter.beta)
        for ithGamma = 1: size(parameter.gamma)
            for ithLambda = 1:size(parameter.lambda)
                alpha = parameter.alpha(ithAlpha, :);
                beta = parameter.beta(ithBeta, :);
                gamma = parameter.gamma(ithGamma, :);
                lambda = parameter.lambda(ithLambda, :);
      
                
                fid=fopen(saveFileName,'a');
                
                fprintf('\n\n parameters----¦Á: %f£¬\t ¦Â£º%f \t£¬¦Ã£º%f\t£¬¦Ë£º%f\n' , alpha, beta, gamma, lambda);
                fprintf(fid,'\n\n parameters----¦Á: %f£¬\t ¦Â£º%f \t£¬¦Ã£º%f\t£¬¦Ë£º%f\n' , alpha, beta, gamma, lambda);

                
                res = []; 
                
                % cross-validation
                
                for cycleIndex = 1 : totalCycle

                    [trainSet , testSet] = getTrainAndTest(dataSet , cycleIndex , totalCycle);

                    labelTest = testSet( : , end); 
                    lenTest = size(labelTest , 1);
                    resultMat = zeros(lenTest , totalClass); 
                    
                    testNoLabel = testSet( : , 1 : end - 1);

                    % one vs one
                    for vsIndex = 1 : size(VS,1)
                        classOneIndex = VS(vsIndex , 1);
                        classTwoIndex = VS(vsIndex , 2);
                        classOne = trainSet{1 , classOneIndex};
                        classTwo = trainSet{1 , classTwoIndex};
                        
                        
                        label = [ones(size(classOne, 1), 1); zeros(size(classTwo, 1), 1)]; 
                        X1= [classOne;classTwo]; 
                        X= [X1, ones(size(X1, 1), 1)]; 
                        
                        
                        %% train
                        tic;

                        [w, P] = trainDSSLMR(classOne, classTwo, alpha, beta, gamma, lambda, parameter.epsilon, parameter.totalIter);
                        timePerTrain = toc; 
                        

                        resultPredict = predictDSSLMR(testNoLabel , P , w);
                        

                        indexClassOne = find(resultPredict > 0) ; 
                        resultMat(indexClassOne , classOneIndex) = resultMat(indexClassOne , classOneIndex) + 1 ; 
                        
                        indexClassTwo = find(resultPredict < 0) ;
                        resultMat(indexClassTwo , classTwoIndex) = resultMat(indexClassTwo , classTwoIndex) + 1 ; 

                        
                    end 
                    
                    [valueMax, labelPredict] = max((resultMat'));
                    
                    acc = size(find(labelPredict' == labelTest), 1)/lenTest; 
                    [confMat, order] = confusionmat(labelTest, labelPredict'); 
                    drawConMat(labelTest, labelPredict'); 
                    [precision, recall, macroF1] = resultOfConmat(confMat); 

                    acc = size(find(labelPredict' == labelTest), 1)/lenTest; 
                    [confMat, order] = confusionmat(labelTest, labelPredict');
                    [precision, recall, macroF1] = resultOfConmat(confMat); 
                    res = [res; [acc macroF1]];
                    fid=fopen(saveFileName,'a');
                    fprintf('%d -th cycle ACC: %f\t macroF1£º%f\t train time:%f \n' , cycleIndex , acc, macroF1, timePerTrain);
                    fprintf(fid,'%d -th cycle ACC: %f\t macroF1£º%f\t train time:%f \n' , cycleIndex , acc, macroF1, timePerTrain);
                    fclose(fid);

                end 
                
                res(totalCycle+1 , :) = mean(res) ; 
                res(totalCycle+2 , :) = std(res(1:totalCycle , :)) ; 
                res(totalCycle+3 , :) = max(res); 
                % FinalRes = [FinalRes ; {res}] ; 

                fid=fopen(saveFileName,'a');
                meanAcc = res(totalCycle+1 , 1); 
                stdAcc = res(totalCycle+2 , 1); 
                meanMacroF1 = res(totalCycle+1, 2); 
                stdMacroF1 = res(totalCycle+2, 2); 
                fprintf('mean ACC%f, STD%f:' , meanAcc , stdAcc) ;
                fprintf(fid,'mean ACC%f, STD%f:' , meanAcc , stdAcc) ;
                fprintf('mean macroF1%f, STD%f:' , meanMacroF1 , stdMacroF1) ;
                fprintf(fid,'mean macroF1%f, STD%f:' , meanMacroF1 , stdMacroF1) ;
                fprintf('mean train-time%f:' , timePerTrain) ;
                fprintf(fid,'mean train-time%f:' , timePerTrain) ;
                fprintf('max ACC%f:' , res(totalCycle+3 , 1)) ;
                fprintf(fid,'max ACC%f:' , res(totalCycle+3 , 1)) ;
                fclose(fid);


                if meanAcc > recordMaxAcc
                    recordMaxAcc = meanAcc;
                    recordStdAcc = stdAcc;
                    recordMaxPara = [alpha, beta, gamma, lambda];
                end
                if meanMacroF1 > recordMaxMacroF1
                    recordMaxMacroF1 = meanMacroF1;
                    recordStdMacroF1 = stdMacroF1;
                end
 
            end % ¦Ë
        end % ¦Ã
    end % ¦Â
end % ¦Á



fid=fopen(saveFileName,'a');
fprintf('\n----------------------------------------\n') ;
fprintf(fid,'\n----------------------------------------\n') ;
fprintf('.......  ACC%f\t STD%f ........\t\n' , recordMaxAcc, recordStdAcc) ;
fprintf(fid,'.......  ACC%f\t STD%f ........\t\n' , recordMaxAcc, recordStdAcc) ;
fprintf('.......  macroF1%f\t STD%f ........\t\n' , recordMaxMacroF1, recordStdMacroF1) ;
fprintf(fid,'.......  macroF1%f\t STD%f  ........\t\n' , recordMaxMacroF1, recordStdMacroF1) ;
fprintf('.......  time%f.......\n' , timePerTrain) ;
fprintf(fid,'.......  time%f.......\n' , timePerTrain) ;

fprintf('.......  parameters:¦Á=%f\t¦Â=%f\t¦Ã=%f\t¦Ë=%f .......\n' , recordMaxPara(1,1),recordMaxPara(1,2),recordMaxPara(1,3),recordMaxPara(1,4)) ;
fprintf(fid,'.......  parameters:¦Á=%f\t¦Â=%f\t¦Ã=%f\t¦Ë=%f .......\n' , recordMaxPara(1,1),recordMaxPara(1,2),recordMaxPara(1,3),recordMaxPara(1,4)) ;

fclose(fid);