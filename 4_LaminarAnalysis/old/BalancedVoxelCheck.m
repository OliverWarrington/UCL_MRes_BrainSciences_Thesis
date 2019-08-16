% Determine number of voxels in balanced masks for each subject and ROI

% Subjects to process
Subjects = {'S01' 'S02' 'S04' 'S05' 'S06' 'S07' 'S09' 'S10' 'S11' 'S12' 'S13' 'S14' 'S15' 'S16' 'S17' 'S18' 'S19' 'S20' 'S21' 'S22' 'S23'};

for SID = 1:length(Subjects)
    
    cd(['/Users/OliverW/Desktop/Project/Subjects/', Subjects{SID}]);
    
    load('DesignMatrices/V1_45deg_balanced.mat');
    V1(SID,1) = size(design.Indices,1);
    
    load('DesignMatrices/V1_v2_135deg_balanced.mat');
    V1(SID,2) = size(design.Indices,1);

end