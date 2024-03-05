
function [Lw , Lb , M] = getLwLbM(dataOne, dataTwo)

    t = 1;
    
    %% cal matC
    lenOne = size(dataOne, 1);
    lenTwo = size(dataTwo, 1);

    for i = 1 : lenOne + lenTwo
        for j = 1 : lenOne + lenTwo
            matC(i , j) = 0;
        end
    end
       
    for i = 1 : lenOne
        for j = 1 : lenOne
            matC(i , j) = exp(-dot(dataOne(i, :) - dataOne(j, :) , dataOne(i, :) - dataOne(j, :))/t);
        end
    end

    for i = 1 : lenTwo
        for j = 1 : lenTwo
            matC(i+lenOne , j+lenOne) = exp(-dot(dataTwo(i, :) - dataTwo(j, :) , dataTwo(i, :) - dataTwo(j, :))/t);
        end
    end
    
    

    Dw = diag(sum(matC , 1)); % Dw is a diagonal matrix with Dwii being the column (or row) sum of C
    % Dw1,...,Dwc represent a point¡¯s importance in its class
    % imagesc(matC);
    Lw = Dw - matC; % Laplacian matrix
    Dw1 = Dw(1 : lenOne , 1 : lenOne); 
    Dw2 = Dw(lenOne + 1 : lenOne + lenTwo , lenOne + 1 : lenOne + lenTwo); 
    
   
    sigma1 = 0; 
    sigma2 = []; 
    for i = 1 : lenOne
        sigma1 = sigma1 + Dw1(i , i);
        sigma2 = Dw1(i , i) * dataOne(i , :);
    end
    m1 = 1 / sigma1 * sigma2; 

    
    
    sigma1 = 0; 
    sigma2 = [];
    for i = 1 : lenTwo
        sigma1 = sigma1 + Dw2(i , i);
        sigma2 = Dw2(i , i) * dataTwo(i , :);
    end
    m2 = 1 / sigma1 * sigma2; 
    
    M = [m1' , m2'];
    

    B(1 , 1) = exp(-dot(m1 - m1 , m1 - m1) / t);
    B(1 , 2) = exp(-dot(m1 - m2 , m1 - m2) / t);
    B(2 , 1) = exp(-dot(m2 - m1 , m2 - m1) / t);
    B(2 , 2) = exp(-dot(m2 - m2 , m2 - m2) / t);
    Db = diag(sum(B , 1));
    Lb = Db - B;
    % imagesc(B);
end
