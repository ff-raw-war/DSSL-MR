function [trainSet , testSet] = getTrainAndTest(dataSet , ithCycle , totalCycle)

    
    totalClass = size(dataSet , 2);   
    testSet = [];
    trainSet = cell(1 , totalClass);
    temp = [];
    
    
    for i = 1 : totalClass 
        for j = 1 : totalCycle 
            segSize = size(dataSet{j , i} , 1); 
            label = repmat([i] , segSize , 1); 
            if j == ithCycle 
                tempTestSet = [dataSet{j , i} label]; 
                
                testSet = [testSet ; tempTestSet];
                
            else 
                
                trainSet{1 , i} = cat(1 , trainSet{1 , i}(: , :) , dataSet{j , i}); 
                
            end
             
        end
        
        % testSet = [testSet ; dataSet{i,}
    end

end