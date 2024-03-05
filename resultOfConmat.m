function [precision, recall, macroF1] = resultOfConmat(M)
    n = size(M, 1); % �Խ�Ԫ����
    for i =1 : n % 
        if sum(M(:, i)) ~=0
            pre(i) = M(i, i) / sum(M(:, i)); % �öԽ�Ԫ�س��Ը��кͣ�Ϊ��׼��precision
        else
            pre(i) = 0;
        end
        if sum(M(i, :)) ~=0
            rec(i) = M(i, i) / sum(M(i, :)); % �öԽ�Ԫ�س��Ը��кͣ�Ϊ�ٻ���Recall
        else
            rec(i) = 0;
        end
    end
    precision = mean(pre);
    recall = mean(rec);
    macroF1 = (2*precision*recall) / (precision+recall);
end