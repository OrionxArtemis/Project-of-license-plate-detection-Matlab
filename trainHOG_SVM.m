function accuracy = trainHOG_SVM(path1, path2)
%Program to implement object detection using HOG features

%Path 1 is folder containing train images
%Path 2 is folder containing test images

warning off
traindb = imageDatastore(path1, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');
testdb = imageDatastore(path2, 'IncludeSubfolders', true, 'LabelSource', 'foldernames');

%Get the length of HOG features
img_train = readimage(traindb, 1);
HOGFeature = HOGExtract(img_train);
HOGFeatureSize = length(HOGFeature);

totalTrainImages = numel(traindb.Files);
trainFeatures = zeros(totalTrainImages, HOGFeatureSize, 'double'); %Feature database

for i = 1 : totalTrainImages
   img_train = readimage(traindb, i);
   trainFeatures(i, :) = HOGExtract(img_train);
end

trainLabels = traindb.Labels; %Getting train labels

%Training by SVM learners and a 'One-vs-Rest' encoding scheme
classifier = fitcecoc(trainFeatures, trainLabels);

save('data.mat','classifier');

%%Testing test folder and get accuracy

%Testing all test images
totalTestImages = numel(testdb. Files);
testFeatures = zeros(totalTestImages, HOGFeatureSize, 'single');

for i = 1 : totalTestImages
   img_test = readimage(testdb, i);
   testFeatures(i, :) = HOGExtract(img_test);
end

testLabels = testdb.Labels; %Getting test labels

predictedLabels = predict(classifier, testFeatures);

accuracy = (sum(predictedLabels == testLabels)/numel(testLabels))*100;

%plotconfusion(testLabels, predictedLabels);