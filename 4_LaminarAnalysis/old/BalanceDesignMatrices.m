% Resample existing ROI design matrices so that we force the overlap with
% cortical layers to be more or less balanced. Do this by forcing there to
% be an equal number of voxels with greatest overlap with deep, middle and
% superficial layers.

Subjects = {'sub-03'};

for SID = 1:length(Subjects)
    disp(['Processing ', Subjects{SID}]);  
    
    ROIs = {'V1_45deg', 'V1_135deg', 'V2_45deg', 'V2_135deg'};
    
    
    cd(['/Users/OliverW/Desktop/Project/Subjects/', Subjects{SID}, '/DesignMatrices']);
    
    for curROI = 1:length(ROIs)
        
        % Load design matrix for current ROI
        load([ROIs{curROI}, '.mat']);
        
        % Find indices of voxels that most overlap with deep, middle,
        % superficial layers
        deepInd = find(design.DesignMatrix(:,2) > design.DesignMatrix(:,3) & design.DesignMatrix(:,2) > design.DesignMatrix(:,4));
        middleInd = find(design.DesignMatrix(:,3) > design.DesignMatrix(:,2) & design.DesignMatrix(:,3) > design.DesignMatrix(:,4));
        superfInd = find(design.DesignMatrix(:,4) > design.DesignMatrix(:,2) & design.DesignMatrix(:,4) > design.DesignMatrix(:,3));
        
        % Identify which layer is least represented - we will make sure
        % that the same number of voxels are taken from each layer
        numDeepVox = length(deepInd);
        numMidVox = length(middleInd);
        numSuperfVox = length(superfInd);
        if numDeepVox < numMidVox && numDeepVox < numSuperfVox
            numVoxels = numDeepVox;
        elseif numMidVox < numDeepVox && numMidVox < numSuperfVox
            numVoxels = numMidVox;
        elseif numSuperfVox < numDeepVox && numSuperfVox < numMidVox
            numVoxels = numSuperfVox;
        else 
            % If we are here then multiple layers share the same number of
            % voxels. Going to assume that deep and middle are both equally
            % under-represented. This will nearly always be the case, but
            % we will check to be sure and adapt code further if we run
            % into a case where e.g. superficial and middle are equally
            % under-represented.
            if numDeepVox == numMidVox && numDeepVox < numSuperfVox
                numVoxels = numDeepVox;
            else
                error('Multiple layers (not deep and middle) are equally under-represented. Adapt code to account for this!');
            end
            
            
        end
        
        % Take all voxels from least represented layer and same number of
        % voxels from other layers
        % Select which voxels to take randomly
        deepVoxels = deepInd(randperm(numDeepVox, numVoxels));
        middleVoxels = middleInd(randperm(numMidVox, numVoxels));
        superfVoxels = superfInd(randperm(numSuperfVox, numVoxels));
        
        newDesign = [];
        newDesign.Indices = [design.Indices(deepVoxels,:); design.Indices(middleVoxels,:); design.Indices(superfVoxels,:)];
        newDesign.Locations = [design.Locations(deepVoxels,:); design.Locations(middleVoxels,:); design.Locations(superfVoxels,:)];
        newDesign.DesignMatrix = [design.DesignMatrix(deepVoxels,:); design.DesignMatrix(middleVoxels,:); design.DesignMatrix(superfVoxels,:)];
        
        % Find nonzero columns
        nonZeroColumns = ~all(newDesign.DesignMatrix == 0);
        newDesign.NonZerosColumns = find(nonZeroColumns);
        
        % Recalculate covariance matrx
        newDesign.CovarianceMatrix = zeros(5); % Assuming usual 5 layers
        newDesign.CovarianceMatrix(newDesign.NonZerosColumns, newDesign.NonZerosColumns) = inv(newDesign.DesignMatrix(:, newDesign.NonZerosColumns)' * newDesign.DesignMatrix(:, newDesign.NonZerosColumns));
        
        % Save new design matrix
        clear design;
        design = newDesign;
        save([ROIs{curROI}, '_balanced.mat'], 'design');
    end
end

% Done!
disp('Done!');