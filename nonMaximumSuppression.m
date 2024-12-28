function [row_keep, col_keep, width_keep, length_keep] = nonMaximumSuppresion(score, row, col, width, length, thresh_IoU)
    
%Using Bubble Sort algorithm to sort input Bounding Boxes based on confidence scores
for i = 1 : size(score)
    for j = i+1 : size(score)
       if score(i) < score(j)
           score([j i]) = score([i j]);
           row([j i]) = row([i j]);
           col([j i]) = col([i j]);
           width([j i]) = width([i j]);
           length([j i]) = length([i j]);
       end
    end
end

%'keep' set saves Bounding Boxes which have appropriate IoUs
row_keep = [];
col_keep = [];
width_keep = [];
length_keep = [];

for i = 1 : size(score)
    
    %Looping until input Bounding Boxes come to end
    if isequal(size(row),0) || isequal(size(col),0) || isequal(size(width),0) || isequal(size(length),0)
        break;
    end

    %Save values from input Bounding Boxes in 'keep' set
    row_keep(end+1) = row(i);
    col_keep(end+1) = col(i);
    width_keep(end+1) = width(i);
    length_keep(end+1) = length(i);

    %Remove saved values from input Bounding Boxes
    row(i) = [];
    col(i) = [];
    width(i) = [];
    length(i) = [];
    
    for j = 1 : size(score)-i

        %Calculate IoU of kept Bounding Boxes and not kept Bounding Boxes
        IoU = find_IoU(row_keep(i), col_keep(i), width_keep(i), length_keep(i), row(j), col(j), width(j), length(j));

        %Remove Bounding Boxes which have IoU bigger than the thresh
        if IoU > thresh_IoU
            row(j) = [];
            col(j) = [];
            width(j) = [];
            length(j) = [];
        end        
    end
end

end


function IoU = find_IoU(row1, col1, width1, length1, row2, col2, width2, length2)

%Compute areas of 2 boxes
area1 = width1 * length1;
area2 = width2 * length2;

%Compute co-ordinates of Intersection area
x = max(row1 - width1, row2 - width2);
y = max(col1, col2);
a = min(row1, row2);
b = min(col1 + length1, col2 + length2);

%Compute Intersection area
w = max(0, a - x);
l = max(0, b - y);
intersection_area = w*l;

%Compute Union area
union_area = area1 + area2 - intersection_area;

%Compute IoU
IoU = intersection_area / union_area;

end