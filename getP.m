function P = getP(X, w, y, Lw, Lb, M, Q, alpha, beta, lambda, P0)

    A = pinv(X'*X)*(alpha*X'*Lw*X-beta*M*Lb*M'+0.5*lambda*Q);

    B = w*w';
    C = -pinv(X'*X)*X'*y*w';
    
    try
        P = lyap(A, B, C);
    catch error
        disp(error);
        P = P0;
    end
end