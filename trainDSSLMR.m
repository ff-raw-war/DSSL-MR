function [w, P] = trainDSSLMR(classOne, classTwo, alpha, beta, gamma, lambda, epsilon, totalIter)
    
    classOne = [classOne, repmat([1], size(classOne, 1), 1)];
    classTwo = [classTwo, repmat([1], size(classTwo, 1), 1)];

    X = [classOne ; classTwo];

    [lenOne, dim] = size(classOne); 
    lenTwo = size(classTwo , 1);
    lenAll = lenOne + lenTwo;
    labelsOne = repmat([1] , lenOne, 1);
    labelsTwo = repmat([-1], lenTwo, 1);
    
    w = rand(dim, 1);
    P = rand(dim, dim);
    y = [labelsOne; labelsTwo];

    [Lw , Lb , M] = getLwLbM(classOne , classTwo);
    L = getL(P, X, w, y, Lw, Lb, M, alpha, beta, gamma, lambda);
    iter = 1;
    while iter <= totalIter
        % disp(iter);
        L0 = L;
        w = getW(P, X, y, beta, gamma);
        Q = diag(0.5 ./ sqrt(sum(P .* P , 2) + eps));
        % d=1/(2*||wi||2); Q=diag(d);
        
        P = getP(X, w, y, Lw, Lb, M, Q, alpha, beta, lambda, P);
        L = getL(P, X, w, y, Lw, Lb, M, alpha, beta, gamma, lambda);
        % disp(L0-L);
        if ((L0-L)'*(L0-L) < epsilon) || (L > L0)
            break;
        end 
        iter = iter + 1;
    end 

end