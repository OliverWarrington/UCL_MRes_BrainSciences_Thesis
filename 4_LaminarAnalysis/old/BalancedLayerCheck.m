% Determine number of voxels in balanced masks for each subject and ROI and
% layers

% Subjects to process
Subjects = {'sub-03'};

for SID = 1:length(Subjects)
    
    cd(['/Users/OliverW/Desktop/Project/Subjects/', Subjects{SID}]);
    
    load('DesignMatrices/V1_45deg.mat');
    
    % Find indices of voxels that most overlap with deep, middle,
    % superficial layers
    deepInd = find(design.DesignMatrix(:,2) > design.DesignMatrix(:,3) & design.DesignMatrix(:,2) > design.DesignMatrix(:,4));
    middleInd = find(design.DesignMatrix(:,3) > design.DesignMatrix(:,2) & design.DesignMatrix(:,3) > design.DesignMatrix(:,4));
    superfInd = find(design.DesignMatrix(:,4) > design.DesignMatrix(:,2) & design.DesignMatrix(:,4) > design.DesignMatrix(:,3));
    
    V1(SID,1:3) = [length(deepInd), length(middleInd), length(superfInd)];
    
    load('DesignMatrices/V1_135deg.mat');
    
    % Find indices of voxels that most overlap with deep, middle,
    % superficial layers
    deepInd = find(design.DesignMatrix(:,2) > design.DesignMatrix(:,3) & design.DesignMatrix(:,2) > design.DesignMatrix(:,4));
    middleInd = find(design.DesignMatrix(:,3) > design.DesignMatrix(:,2) & design.DesignMatrix(:,3) > design.DesignMatrix(:,4));
    superfInd = find(design.DesignMatrix(:,4) > design.DesignMatrix(:,2) & design.DesignMatrix(:,4) > design.DesignMatrix(:,3));
    
    V1(SID,4:6) = [length(deepInd), length(middleInd), length(superfInd)];

    load('DesignMatrices/V2_45deg.mat');
    % Find indices of voxels that most overlap with deep, middle,
    % superficial layers
    deepInd = find(design.DesignMatrix(:,2) > design.DesignMatrix(:,3) & design.DesignMatrix(:,2) > design.DesignMatrix(:,4));
    middleInd = find(design.DesignMatrix(:,3) > design.DesignMatrix(:,2) & design.DesignMatrix(:,3) > design.DesignMatrix(:,4));
    superfInd = find(design.DesignMatrix(:,4) > design.DesignMatrix(:,2) & design.DesignMatrix(:,4) > design.DesignMatrix(:,3));

    V2(SID,1:3) = [length(deepInd), length(middleInd), length(superfInd)];

    load('DesignMatrices/V2_135deg.mat');
    % Find indices of voxels that most overlap with deep, middle,
    % superficial layers
    deepInd = find(design.DesignMatrix(:,2) > design.DesignMatrix(:,3) & design.DesignMatrix(:,2) > design.DesignMatrix(:,4));
    middleInd = find(design.DesignMatrix(:,3) > design.DesignMatrix(:,2) & design.DesignMatrix(:,3) > design.DesignMatrix(:,4));
    superfInd = find(design.DesignMatrix(:,4) > design.DesignMatrix(:,2) & design.DesignMatrix(:,4) > design.DesignMatrix(:,3));

    V2(SID,4:6) = [length(deepInd), length(middleInd), length(superfInd)];

end