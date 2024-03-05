function [dataSegments , dim] = dataSet2Segments(data , segmentNum)

    
    totalClass = length(unique(data(: , end))); 
    dim = size(data , 2) - 1; 
    totalSample = size(data , 1);
    dataSegments = [];

    for i = 1 : totalClass 
        dataTemp{1 , i} = data(data(: , end) == i , 1 : end - 1);
        
        ithClassLength = size(dataTemp{1 , i} , 1); 
             
        index = randperm(ithClassLength); 
        segSize = floor(ithClassLength/segmentNum); 
        
        
        for j = 1: segmentNum - 1 
            dataSegments{j , i} = dataTemp{1 , i}(index(segSize * (j - 1) + 1 : segSize * j) , :);
            
        end
        dataSegments{j + 1 , i} = dataTemp{1 , i}(index(segSize * j + 1 : ithClassLength) , :);
        
    end
end