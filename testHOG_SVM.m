function [check, predictedLabel, confidenceScore, rowBBox, colBBox, widthBBox, lengthBBox] = testHOG_SVM(img)
%Program to test HOG based object detection

%INPUT => input image
%OUTPUT => label, confidence score and position, size of Bounding Box

load('data.mat', 'classifier');


if size(img, 3) == 3
    img_test = rgb2gray(img);
end
[row, column] = size(img_test);

%Choose your window size equal to trained images size
rowWindow = 48;
colWindow = 96;

check = 0; %Variable checks that image has object or not

rowDetected = [];
colDetected = [];

%Bounding Boxes set of all rescaled images
rowBB_all = [];
colBB_all = [];
widthBB_all = [];
lengthBB_all = [];

confScore = [];
predictedLabel = [];

%%Object Detection via each window and rescaled image

%Using Image Pyramid to rescaled image from original to the smallest
for p = 1 : floor(min(size(img_test,1)/rowWindow, size(img_test,2)/colWindow))

    score_window = [];
    label_pyramid = [];
    
    %Using Sliding Window to identify each window and they could overlap each others
    for i = 0 : size(img_test,1)/(rowWindow/2) - 2
        for j = 0 : size(img_test,2)/(colWindow/2) - 2
        
            window = img_test(i*(rowWindow/2)+1 : i*(rowWindow/2) + rowWindow, j*(colWindow/2)+1 : j*(colWindow/2) + colWindow);
            HOGFeature = HOGExtract(window); %Getting HOG feature of each window
            [label, score] = predict(classifier, HOGFeature);
        
            if strcmp(char(label), 'License Plate 1 Line') == 1
                label_window = 1;
            elseif strcmp(char(label), 'License Plate 2 Line') == 1
                label_window = 2;
            else
                label_window = 0;
            end

            if isequal(label_window,1) || isequal(label_window,2)
                                   
                rowDetected(end+1) = i*(rowWindow/2)+1;
                colDetected(end+1) = j*(colWindow/2)+1;
                
                check = check + 1;
                label_pyramid(end+1) = label_window;
                
                if isequal(label_window,1)
                    score_window(end+1) = score(1);
                else
                    score_window(end+1) = score(2);
                end
            end
        end
    end

    if length(label_pyramid) ~= 0
    
        predictedLabel(end+1) = mode(label_pyramid);
        confScore(end+1) = max(score_window);
    
        %Draw Bounding Box of rescaled image
        [rowBB, colBB, widthBB, lengthBB] = drawBoundingBox(rowWindow, colWindow, rowDetected, colDetected);       
        
        %Bounding Boxes set of all rescaled images
        rowBB_all(end+1) = rowBB * row / size(img_test,1); 
        colBB_all(end+1) = colBB * column / size(img_test,2); 
        widthBB_all(end+1) = widthBB * row / size(img_test,1);    
        lengthBB_all(end+1) = lengthBB * column / size(img_test,2);    
        
        clear rowBB, clear colBB, clear widthBB, clear lengthBB, clear rowDetected, clear colDetected;
    end

    %Rescale image size to 0.5
    img_test = impyramid(img_test,'reduce');

end

%%Show result and select the best Bounding Box

if check ~= 0
    
    %Using Bubble Sort algorithm to sort labels based on confidence scores
    for i = 1 : length(confScore)
        for j = i+1 : length(confScore)
           if confScore(i) < confScore(j)
               predictedLabel([j i]) = predictedLabel([i j]);
           end
        end
    end

    predictedLabel = predictedLabel(1);
    confidenceScore = (max(confScore) + 1)*100;

    %Using Non Maximum Suppression to find the best Bounding Box
    thresh_IoU = 0.5;
    [rowBBox, colBBox, widthBBox, lengthBBox] = nonMaximumSuppression(confScore, rowBB_all, colBB_all, widthBB_all, lengthBB_all, thresh_IoU);
else confidenceScore = [];
    rowBBox = []
    colBBox = []
    widthBBox = []
    lengthBBox = []
end