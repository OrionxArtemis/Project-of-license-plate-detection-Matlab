function [rowBB, colBB, widthBB, lengthBB] = drawBoundingBox(rowWindow, colWindow, rowDetected, colDetected)
%Function draw a Bounding Box for any particular given data in object detection

%INPUT => row, column of window and positions of windows which have object
%OUTPUT => position and size of the Bounding Box

%Assign position of Bounding Box
rowBB = max(rowDetected);
colBB = min(colDetected);

%Find the width of Bounding Box
row_minCol = [];
for i = 1 : length(colDetected)
    if colDetected(i) == colBB
            row_minCol(end+1) = rowDetected(i);
    end       
end
widthBB = rowBB - min(row_minCol) + rowWindow;
    
%Find the length of Bounding Box
col_maxRow = [];
for i = 1 : length(rowDetected)
    if rowDetected(i) == rowBB
            col_maxRow(end+1) = colDetected(i);
    end       
end
lengthBB = max(col_maxRow) - colBB + colWindow;