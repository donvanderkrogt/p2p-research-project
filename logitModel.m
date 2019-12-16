% destination path for the file
rootFilePath = '/Users/donvanderkrogt/matlab/fintech/';

filename = strcat(rootFilePath, 'cleanData.csv');
delimiterIn = ',';
headerlinesIn = 1;
T = readtable(filename);

independentVars = ["appliedamount", "interest", "noofpreviousloansbeforeloan", "incometotal", "liabilitiestotal", "verificationtype4", "education6"];
X = zeros(length(T.default), length(independentVars));
for i = 1:length(independentVars)
    X(:, i) = T.(independentVars(i));
end

% [B, dev, stats] = mnrfit(X, categorical(T.default));
% b = glmfit(X, T.default, 'binomial', 'link','logit');
b = fitglm(X, T.default, 'Distribution', 'binomial', 'link','logit');
scores = b.Fitted.Probability;
predictions = zeros(length(T.default), 1);
% predictions = zeros(2, 1);
for i = 1:length(T.default)
   nonConstant = 0;
   for j = 1:length(independentVars)
       nonConstant = nonConstant + b(j + 1) * T.(independentVars(j))(i);
       % disp(nonConstant);
   end
   predictions(i) = 1 / (1 + exp(-(b(1) + nonConstant)));
end

noDefaultN = zeros(2, 1);
defaultN = zeros(2, 1);
for i = 1:length(T.default)
    if T.default(i) == 1 && predictions(i) > 0.5
        defaultN(2, 1) = defaultN(2, 1) + 1;
    elseif T.default(i) == 1 && predictions(i) < 0.5
        noDefaultN(2, 1) = noDefaultN(2, 1) + 1;
    elseif T.default(i) == 0 && predictions(i) > 0.5
        defaultN(1, 1) = defaultN(1, 1) + 1;
    else
        noDefaultN(1, 1) = noDefaultN(1, 1) + 1;
    end
end

% disp("Accuracy: ");
accuracy = (defaultN(2, 1) + noDefaultN(1, 1)) / length(T.default)
precision = defaultN(2, 1) / (defaultN(2, 1) + defaultN(1, 1))
recall = defaultN(2, 1) / (defaultN(2, 1) + noDefaultN(1, 1))

% Compute Area under the curve
[X, Y, T, AUC] = perfcurve(T.default, scores, 1);
plot(X,Y)
xlabel('False positive rate') 
ylabel('True positive rate')
title('ROC for Classification by Logistic Regression')
