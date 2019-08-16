% Estimate the effects per layer for each condition
% Stim45, Stim135, Omis45, Omis135
% 5 Layers
% B = Design Matrix \ Y
clear all;

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

Runs = {'Run1' 'Run2' 'Run3' 'Run4'};
ROIs = {'V1_45deg' 'V1_135deg'};

for SID = 1:length(Subjects)
    
    SubDir = fullfile(PrDir, Subjects{SID});
    FirstDir = fullfile(SubDir, 'FirstLevel', 'MainExp');
    TimeCourseDir = fullfile(SubDir, 'Timecourses');
    
    load(fullfile(FirstDir, 'SPM.mat'));
    
    DesignM = SPM.xX.X;
    
    % Plot grayscale design matrix
    figure;
    imagesc(DesignM);
    colormap gray;
    ylabel('Scans');
        
    for iROI = 1:length(ROIs)

        load(fullfile(TimeCourseDir, 'Run1', ROIs{iROI})); % Runs{iRun} when script for all runs

        for iLayer = 1:size(timeCourses{1}, 1)

            Y = timeCourses{1}(iLayer, :);
            Y = reshape(Y, numel(Y), 1);

            switch iLayer
                case 1
                    White = DesignM \ Y;
                case 2
                    Deep = DesignM \ Y;
                case 3
                    Middle = DesignM \ Y;
                case 4
                    Superficial = DesignM \ Y;
                case 5
                    Pial = DesignM \ Y;
                otherwise
                    disp('Not a layer!');
            end
        end
        
        savefile = fullfile(TimeCourseDir, 'Run1', sprintf('%s_Layer.mat', ROIs{iROI}));
        save(savefile, 'White', 'Deep', 'Middle', 'Superficial', 'Pial');
   
    end
end
