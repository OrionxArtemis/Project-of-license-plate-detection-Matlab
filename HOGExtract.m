function [feature] = HOGExtract(image)
%Function finds HOG features for any given image

%INPUT => input image
%OUTPUT => HOG feature vector for that particular image

% subplot(1,3,1);
% imshow(image);
% title('Original Image');

%Convert image to grayscale
if size(image,3) == 3
    image = rgb2gray(image);
end
image = double(image);
[row, column] = size(image);

%Basic matrix assignment
Gx = image;
Gy = image;

%Gradient X and Y direction
for i = 2 : column-1
   Gx(:, i) = image(:, i-1) - image(:, i+1);
end
for i = 2 : row-1
   Gy(i, :) = image(i-1, :) - image(i+1, :);
end

magnitude = sqrt(Gx.^2 + Gy.^2); %Get magnitude mu
angle = atand(Gy./Gx); %Angle theta of each edge gradient
angle = angle + 90; %Angle theta in range (0, 180)
 
angle(isnan(angle)) = 0; %Remove infinity values

% subplot(1,3,2);
% imshow(uint8(magnitude));
% title('Magnitude mu');
% subplot(1,3,3);
% imshow(uint8(angle));
% title('Angle theta');

feature = []; %Create a feature vector of the image

%Iteration for blocks
for x = 0 : row/8 - 2
    for y = 0 : column/8 - 2
        
        %Divide the image to 16x16 pixels blocks
        mag_block = magnitude(8*x+1 : 8*x+16 , 8*y+1 : 8*y+16);
        ang_block = angle(8*x+1 : 8*x+16 , 8*y+1 : 8*y+16);
        
        block_feature = []; %Create a feature vector of the block
        
        %Iteration for cells in a block
        for m = 0 : 1
            for n = 0 : 1
                
               %Divide a block to 8x8 pixels cells
               ang_cell = ang_block(8*m+1 : 8*m+8, 8*n+1 : 8*n+8);
               mag_cell = mag_block(8*m+1 : 8*m+8, 8*n+1 : 8*n+8);
               
               histogram = zeros(1,9); %A histogram of cell contains 9 bins and each bin keeps 20 degrees
               
               %Iteration for pixels in a cell
               for i = 1 : 8
                  for j = 1 : 8
                     
                     %The nth Bin which value of that pixel assigned to
                     if ang_cell(i,j) < 10
                        bin = 0;
                     else 
                        bin = floor((ang_cell(i,j)/20) - 1/2);
                     end
                     
                     center = (bin + 1/2)*20; %The value in the center of the nth Bin 

                     %Bi-linear interpolation
                     value = mag_cell(i,j)*((center+20) - ang_cell(i,j))/20; %Value assigned to the nth Bin
                     if value == mag_cell(i,j)
                        histogram(bin+1) = histogram(bin+1) + mag_cell(i,j);
                     else 
                        value2 = mag_cell(i,j)*(ang_cell(i,j) - center)/20; %Value assigned to the (n+1)th Bin
                  
                        %Add each value into the histogram
                        if ang_cell(i,j) < 10
                            histogram(1) = histogram(1) + mag_cell(i,j)*(10+ang_cell(i,j))/20;
                            histogram(9) = histogram(9) + mag_cell(i,j)*(10-ang_cell(i,j))/20;                      
                        else
                            histogram(bin+1) = histogram(bin+1) + value;
                            if bin == 8
                                histogram(1) = histogram(1) + value2;
                            else
                                histogram(bin+2) = histogram(bin+2) + value2;
                            end
                        end                                      
                     end
                  end
               end

               %Concatention of four histograms to one block feature
               block_feature = [block_feature, histogram];
            end
        end

        %Normalize the values in the block using L2 Norm with constant epsilon = 0.01
        block_feature = block_feature / sqrt(norm(block_feature)^2 + 0.01);
        
        feature = [feature, block_feature]; %Features concatenation
    end
end

%Normalization of the feature vector using L2 Norm
feature = feature/sqrt(norm(feature)^2 + 0.01);

end