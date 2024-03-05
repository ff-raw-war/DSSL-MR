function L = getL(P, X, w, y, Lw, Lb, M, alpha, beta, gamma, lambda)
    
    %{
    ||XPw-y||^2 _2 + ¦Átr(PT XT Lw X P) - ¦Âtr( PT M Lb MT P) 
    + ¦ÃwT w +¦Ë||P||_2,1
    %}
    l21fs = 0; % L21
    dimP = size(P , 2);
    for i = 1 : dimP
        l21fs = l21fs + norm(P( : , i), 2); 
    end
    lossMain = norm(X*P*w-y , 2)^2; % 
    lossAlpha = alpha*trace(P'*X'*Lw*X*P); % Lw
    lossBeta = beta*trace(P'*M*Lb*M'*P); % Lb
    lossGamma = gamma*(w'*w); % w
    lossLambda = lambda*l21fs; % P
    L = lossMain + lossAlpha - lossBeta + lossGamma + lossLambda;
    % fprintf('Loss:%f+%f-%f+%f+%f=%f\n',lossMain,lossAlpha,lossBeta,lossGamma,lossLambda,L);
    % disp(norm(X*P*w-y , 2)^2);
end