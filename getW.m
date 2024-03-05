function w = getW(P, X, y, beta, gamma)
    w = pinv(P'*X'*X*P+gamma)*P'*X'*y;
    % w = beta*(beta*P'*X'*X*P+gamma)\(P'*X'*y);
end