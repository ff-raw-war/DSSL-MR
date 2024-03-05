function resultPredict = predictDSSLMR(testNoLabel , P , w)
    totalTest = size(testNoLabel , 1);
    resultPredict = [testNoLabel , ones(totalTest , 1)] * P * w;
end