% Added task type anova
% Changed plotting parameters
% Added regress layer method
% Removed plot TD and V2
clear all; close all;

% allSubjects = {'sub-01', 'sub-02', 'sub-03', 'sub-04', 'sub-05', 'sub-06', 'sub-07', 'sub-08', 'sub-09', 'sub-10', ...
%     'sub-11', 'sub-12', 'sub-13', 'sub-14', 'sub-15'};

allSubjects = {'S01', 'S02', 'S03', 'S04', 'S05', 'S06', 'S07', 'S08', 'S09', 'S10', ...
    'S11', 'S12', 'S13', 'S14', 'S15'};

selSubjects = [2:3 5 7:15];
subjects = allSubjects(selSubjects);

% Find out which operating system we're running on
if ispc
    % set the root dir of the experiment
    rootDir = 'D:\Data\Laminar_expectations_7T';
    if ~exist(rootDir,'dir')
        fprintf('Root directory does not exist!\n%s\n',rootDir)
    end
    
    % set the path to the behavioural results (on Dropbox)
    behSourceDir = 'C:\Users\pkok\Dropbox\WellcomeCentre\Projects\Learning_predictions_fMRI\Behavioural_data';
    if ~exist(behSourceDir,'dir')
        fprintf('Behavioural results directory does not exist!\n%s\n',behSourceDir)
    end
    
    % set the path to SPM
    spmDir = 'D:\spm12';
    addpath(spmDir)
elseif isunix
    % set the root dir of the experiment
    rootDir = '/Volumes/OliverHardD/Laminar_expectations_7T/Subject_data';
    if ~exist(rootDir,'dir')
        fprintf('Root directory does not exist!\n%s\n',rootDir)
    end
end

ROIs = {'V1', 'V2'};

% load SPM basis functions from SPM model; convenient.
SPMmatFile = fullfile(rootDir,subjects{1},'FirstLevel','MainExp','SPM.mat');
load(SPMmatFile);
xBF = SPM.xBF;
clear SPM
%disp('Warning: haven''t cleared SPM variable')
% hack it so that only the canonical HRF is used
%xBF.order = 1;
%xBF.bf = xBF.bf(:,1);

TR = (48*74.65)/1000;
convertToPerc = false;

% height of regressors, for perc signal chance calculations
canonHeight = 0.0133;
tdHeight = 0.0047;

%% initialise some variables
nLayers = 5;
stimBetas = zeros(length(subjects), length(ROIs), 2, 2, 2, nLayers);
omitBetas = zeros(length(subjects), length(ROIs), 2, 2, 2, nLayers);
if xBF.order == 2
    stimBetasTD = zeros(length(subjects), length(ROIs), 2, 2, 2, nLayers);
    omitBetasTD = zeros(length(subjects), length(ROIs), 2, 2, 2, nLayers);
end
for iSubj = 1:length(subjects)
    
    fprintf('Subject %d / %d\n',iSubj,length(subjects))
    subjectDirectory = fullfile(rootDir, subjects{iSubj});
    
    %% find task onsets
    regressorFiles = dir(fullfile(subjectDirectory,'TaskRegressors','cond_run*.mat'));
    % determine how many runs there are of each task
    orientRuns = zeros(1,length(regressorFiles));
    contrastRuns = zeros(1,length(regressorFiles));
    for iRun = 1:length(regressorFiles)
        load(fullfile(regressorFiles(iRun).folder, regressorFiles(iRun).name));
        if names{1}(11) == 'O'
            orientRuns(iRun) = 1;
        elseif names{1}(11) == 'C'
            contrastRuns(iRun) = 1;
        end
    end
    
    %% find head motion parameters
    rpFiles = dir(fullfile(subjectDirectory,'Niftis','Realigned', 'rp_extended_Run*.mat'));
    
    %% load timecourse data
    timecourseFolder = fullfile(subjectDirectory,'TimeCourses');
    for iROI = 1:length(ROIs)
        for iOrient = 1:2
            if iOrient == 1
                %timecourseDataFiles = dir(fullfile(timecourseFolder,sprintf('%s_45deg_rRun*.mat',ROIs{iROI})));
                timecourseDataFiles = dir(fullfile(timecourseFolder,sprintf('zScored_%s_45deg_rRun*.mat',ROIs{iROI})));
            elseif iOrient == 2
                %timecourseDataFiles = dir(fullfile(timecourseFolder,sprintf('%s_135deg_rRun*.mat',ROIs{iROI})));
                timecourseDataFiles = dir(fullfile(timecourseFolder,sprintf('zScored_%s_135deg_rRun*.mat',ROIs{iROI})));
            end
            
            for iRun = 1:length(timecourseDataFiles)
                
                % load layer timecourses
                load(fullfile(timecourseDataFiles(iRun).folder, timecourseDataFiles(iRun).name));
                Y = timeCourses{1}';
                
                % regress layer timecourses
%                 Ynew = zeros(size(Y));
%                 [B,DEV,STATS] = glmfit(Y(:,3:4),Y(:,2));
%                 Ynew(:,2) = STATS.resid;
%                 
%                 [B,DEV,STATS] = glmfit(Y(:,[2, 4]),Y(:,3));
%                 Ynew(:,3) = STATS.resid;
% 
%                 [B,DEV,STATS] = glmfit(Y(:,2:3),Y(:, 4));
%                 Ynew(:,4) = STATS.resid;
%                 
%                 Y = Ynew;
                
                % load task onsets
                load(fullfile(regressorFiles(iRun).folder, regressorFiles(iRun).name));
                
                % load motion regressors
                load(fullfile(rpFiles(iRun).folder, rpFiles(iRun).name));
                
                % create GLM
                nScans = size(Y,1);
                timecourse_upSamp = zeros(1,nScans * round(TR * (1/xBF.dt)));
                
                designMatrix_upSamp = [];
                for iCond = 1:length(names)
                    % create stick functions
                    stickRegressor = timecourse_upSamp;
                    curOnsets = round(onsets{iCond} * TR * (1/xBF.dt));
                    stickRegressor(curOnsets) = 1;
                    %figure; plot(stickRegressor);
                    
                    % convolve with basis functions
                    for iBF = 1:xBF.order
                        regressor = conv(stickRegressor,xBF.bf(:,iBF));
                        %figure; plot(regressor)
                        designMatrix_upSamp = [designMatrix_upSamp regressor'];
                    end
                end
                startScan = 1; %round(0.5 * TR * (1/xBF.dt)); %round(0.5 * TR * (1/xBF.dt));
                interval = round(TR * (1/xBF.dt));
                endScan = round((nScans-1) * TR * (1/xBF.dt))+1; %round((nScans-0.5) * TR * (1/xBF.dt));
                designMatrix = designMatrix_upSamp(startScan:interval:endScan,:);
                
                % append head motion parameters
                designMatrix = [designMatrix R];
                
                % high-pass filter data and design matrix
                %disp('Warning: no high-pass filter implemented')
                K = [];
                K.RT = TR;
                K.HParam = 128;
                K.row = 1:nScans;
                Y = spm_filter(K,Y); % high-pass filter data
                designMatrix = spm_filter(K,designMatrix); % high-pass filter design matrix
                
                % add constant to design matrix
                designMatrix = [designMatrix ones(nScans,1)];
                
                % estimate betas
                betas = pinv(designMatrix) * Y;
                mainExpBetas = betas(1:xBF.order:(4*xBF.order),:);
                if convertToPerc
                   mainExpBetas = 100 * (mainExpBetas * canonHeight) ./ repmat(betas(end,:),size(mainExpBetas,1),1);
                end
                if xBF.order == 2
                    mainExpBetasTD = betas(2:xBF.order:(4*xBF.order),:);
                    if convertToPerc
                        mainExpBetasTD = 100 * (mainExpBetasTD * tdHeight) ./ repmat(betas(end,:),size(mainExpBetasTD,1),1);
                    end
                end
                if names{1}(11) == 'O'
                    iTask = 1;
                    stimBetas(iSubj,iROI,iOrient,iTask,:,:) = squeeze(stimBetas(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(orientRuns)) * mainExpBetas(1:2,:);
                    omitBetas(iSubj,iROI,iOrient,iTask,:,:) = squeeze(omitBetas(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(orientRuns)) * mainExpBetas(3:4,:);
                    if xBF.order == 2
                        stimBetasTD(iSubj,iROI,iOrient,iTask,:,:) = squeeze(stimBetasTD(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(orientRuns)) * mainExpBetasTD(1:2,:);
                        omitBetasTD(iSubj,iROI,iOrient,iTask,:,:) = squeeze(omitBetasTD(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(orientRuns)) * mainExpBetasTD(3:4,:);
                    end
                elseif names{1}(11) == 'C'
                    iTask = 2;
                    stimBetas(iSubj,iROI,iOrient,iTask,:,:) = squeeze(stimBetas(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(contrastRuns)) * mainExpBetas(1:2,:);
                    omitBetas(iSubj,iROI,iOrient,iTask,:,:) = squeeze(omitBetas(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(contrastRuns)) * mainExpBetas(3:4,:);
                    if xBF.order == 2
                        stimBetasTD(iSubj,iROI,iOrient,iTask,:,:) = squeeze(stimBetasTD(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(contrastRuns)) * mainExpBetasTD(1:2,:);
                        omitBetasTD(iSubj,iROI,iOrient,iTask,:,:) = squeeze(omitBetasTD(iSubj,iROI,iOrient,iTask,:,:)) + (1/sum(contrastRuns)) * mainExpBetasTD(3:4,:);
                    end
                end
                
            end
        end
    end
end

plotTD = false;

selLayers = 2:4;
selSubj = 1:length(subjects);

% collapse over orientation specific ROIs in two ways: averaging (non-specific BOLD amplitude) and
% subtracting (orientation specific BOLD amplitude).
stimOverallAmp = squeeze(mean(mean(stimBetas,5),3)); % mean over presented orientation and orientation preference ROIs
omitOverallAmp = squeeze(mean(mean(omitBetas,5),3));
if xBF.order == 2
    stimOverallTD = squeeze(mean(mean(stimBetasTD,5),3)); % mean over presented orientation and orientation preference ROIs
    omitOverallTD = squeeze(mean(mean(omitBetasTD,5),3));
end

stimOrientSpecAmp = squeeze((0.5*stimBetas(:,:,1,:,1,:) + 0.5*stimBetas(:,:,2,:,2,:)) - (0.5*stimBetas(:,:,1,:,2,:) + 0.5*stimBetas(:,:,2,:,1,:)));
omitOrientSpecAmp = squeeze((0.5*omitBetas(:,:,1,:,1,:) + 0.5*omitBetas(:,:,2,:,2,:)) - (0.5*omitBetas(:,:,1,:,2,:) + 0.5*omitBetas(:,:,2,:,1,:)));
if xBF.order == 2
    stimOrientSpecTD = squeeze((0.5*stimBetasTD(:,:,1,:,1,:) + 0.5*stimBetasTD(:,:,2,:,2,:)) - (0.5*stimBetasTD(:,:,1,:,2,:) + 0.5*stimBetasTD(:,:,2,:,1,:)));
    omitOrientSpecTD = squeeze((0.5*omitBetasTD(:,:,1,:,1,:) + 0.5*omitBetasTD(:,:,2,:,2,:)) - (0.5*omitBetasTD(:,:,1,:,2,:) + 0.5*omitBetasTD(:,:,2,:,1,:)));
end

%% plot overall amplitude
selROIs = [1];



% plot results: overall amp, per task
% for iROI = selROIs
%     figure;
%     % Enlarge figure to full screen.
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
%     % Get rid of tool bar and pulldown menus that are along top of figure.
% %     set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% 
%     plot1 = subplot(2,1,1);
%     plotData = squeeze(mean(stimOverallAmp(selSubj,iROI,:,selLayers),1));
%     errorData = squeeze(std(stimOverallAmp(selSubj,iROI,:,selLayers),0,1)) / sqrt(length(selSubj));
%     h = mseb(selLayers, plotData, errorData);
%     title([ROIs{iROI} ' Stimulus']) % stimOverallAmp per task
%     ax = gca;
%     ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
%     ax.XTick = [2, 3, 4];
%     ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
%     ax.FontName = 'TimesNewRoman';
%     ax.FontSize = 16;
%     xlabel('Cortical Depth');
%     ylabel({'BOLD signal' ; '(Arbitary Units)'});
%     lgd = legend(plot1, {'Orientation Task', 'Contrast Task'}, 'Location', 'best');
%     lgd.FontSize = 16;
%     
%     plot2 = subplot(2,1,2);
%     plotData = squeeze(mean(omitOverallAmp(selSubj,iROI,:,selLayers),1));
%     errorData = squeeze(std(omitOverallAmp(selSubj,iROI,:,selLayers),0,1)) / sqrt(length(selSubj));
%     h = mseb(selLayers, plotData, errorData);
%     title([ROIs{iROI} ' Omission']) % ' omitOverallAmp per task'
%     ax = gca;
%     ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
%     ax.XTick = [2, 3, 4];
%     ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
%     ax.FontName = 'TimesNewRoman';
%     ax.FontSize = 16;
%     xlabel('Cortical Depth');
%     ylabel({'BOLD signal' ; '(Arbitary Units)'});
%     lgd = legend(plot2, {'Orientation Task', 'Contrast Task'}, 'Location', 'best');
%     lgd.FontSize = 16;
% end



% % plot results: overall amp, meaned over tasks
% for iROI = selROIs
%     figure;
%     % Enlarge figure to full screen.
%     set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
%     % Get rid of tool bar and pulldown menus that are along top of figure.
% %     set(gcf, 'Toolbar', 'none', 'Menu', 'none');
%     
%     subplot(2,1,1)
%     plotData = squeeze(mean(mean(stimOverallAmp(selSubj,iROI,:,selLayers),3),1));
%     errorData = squeeze(std(mean(stimOverallAmp(selSubj,iROI,:,selLayers),3),0,1)) / sqrt(length(selSubj));
%     h = mseb(selLayers, plotData', errorData');
%     title([ROIs{iROI} ' Stimulus']) % stimOverallAmp meaned over task
%     ax = gca;
%     ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
%     ax.XTick = [2, 3, 4];
%     ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
%     ax.FontName = 'TimesNewRoman';
%     ax.FontSize = 16;
%     xlabel('Cortical Depth');
%     ylabel({'BOLD signal' ; '(Arbitary Units)'});
%     
%     subplot(2,1,2)
%     plotData = squeeze(mean(mean(omitOverallAmp(selSubj,iROI,:,selLayers),3),1));
%     errorData = squeeze(std(mean(omitOverallAmp(selSubj,iROI,:,selLayers),3),0,1)) / sqrt(length(selSubj));
%     h = mseb(selLayers, plotData', errorData');
%     title([ROIs{iROI} ' Omission']) % omitOverallAmp meaned over task
%     ax = gca;
%     ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
%     ax.XTick = [2, 3, 4];
%     ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
%     ax.FontName = 'TimesNewRoman';
%     ax.FontSize = 16;
%     xlabel('Cortical Depth');
%     ylabel({'BOLD signal' ; '(Arbitary Units)'});
% end



%% plot orientation specific amplitude
% plot results: orientation specific amp, per task
for iROI = selROIs
    figure;
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    % Get rid of tool bar and pulldown menus that are along top of figure.
%     set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
    plot1 = subplot(2,1,1);
    plotData = squeeze(mean(stimOrientSpecAmp(selSubj,iROI,:,selLayers),1));
    errorData = squeeze(std(stimOrientSpecAmp(selSubj,iROI,:,selLayers),0,1)) / sqrt(length(selSubj));
    h = mseb(selLayers, plotData, errorData);
    title([ROIs{iROI} ' Stimulus']) % stimOrientSpecAmp per task
    ax = gca;
    ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
    ax.XTick = [2, 3, 4];
    ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
    ax.FontName = 'TimesNewRoman';
    ax.FontSize = 16;
    xlabel('Cortical Depth');
    ylabel({'Preferred - non-preferred'; '(Arbitary Units)'});
    legend(plot1, {'Orientation Task', 'Contrast Task'});
    
    plot2 = subplot(2,1,2);
    plotData = squeeze(mean(omitOrientSpecAmp(selSubj,iROI,:,selLayers),1));
    errorData = squeeze(std(omitOrientSpecAmp(selSubj,iROI,:,selLayers),0,1)) / sqrt(length(selSubj));
    h = mseb(selLayers, plotData, errorData);
    title([ROIs{iROI} ' Omission']) % omitOrientSpecAmp per task
    ax = gca;
    ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
    ax.XTick = [2, 3, 4];
    ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
    ax.FontName = 'TimesNewRoman';
    ax.FontSize = 16;
    xlabel('Cortical Depth');
    ylabel({'Preferred - non-preferred'; '(Arbitary Units)'});
    legend(plot2, {'Orientation Task', 'Contrast Task'});
end



% plot results: orientation specific amp, meaned over tasks
for iROI = selROIs
    figure;
    % Enlarge figure to full screen.
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0 0 1 1]);
    % Get rid of tool bar and pulldown menus that are along top of figure.
%     set(gcf, 'Toolbar', 'none', 'Menu', 'none');
    
    subplot(2,1,1)
    plotData = squeeze(mean(mean(stimOrientSpecAmp(selSubj,iROI,:,selLayers),3),1));
    errorData = squeeze(std(mean(stimOrientSpecAmp(selSubj,iROI,:,selLayers),3),0,1)) / sqrt(length(selSubj));
    h = mseb(selLayers, plotData', errorData');
    title([ROIs{iROI} ' Stimulus']) % stimOrientSpecAmp meaned over task
    ax = gca;
    ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
    ax.XTick = [2, 3, 4];
    ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
    ax.FontName = 'TimesNewRoman';
    ax.FontSize = 16;
    xlabel('Cortical Depth');
    ylabel({'Preferred - non-preferred'; '(Arbitary Units)'});
    
    subplot(2,1,2)
    plotData = squeeze(mean(mean(omitOrientSpecAmp(selSubj,iROI,:,selLayers),3),1));
    errorData = squeeze(std(mean(omitOrientSpecAmp(selSubj,iROI,:,selLayers),3),0,1)) / sqrt(length(selSubj));
    h = mseb(selLayers, plotData', errorData');
    title([ROIs{iROI} ' Omission']) % omitOrientSpecAmp meaned over task
    ax = gca;
    ax.XLim = [1.75, 4.25]; % Adds some white space to end of lines
    ax.XTick = [2, 3, 4];
    ax.XTickLabel = {'Deep', 'Middle', 'Superficial'};
    ax.FontName = 'TimesNewRoman';
    ax.FontSize = 16;
    xlabel('Cortical Depth');
    ylabel({'Preferred - non-preferred'; '(Arbitary Units)'});
end

selROI = 1
[squeeze(mean(mean(stimOrientSpecAmp(:,selROI,:,selLayers),4),3)) squeeze(mean(mean(omitOrientSpecAmp(:,selROI,:,selLayers),4),3))]
[h,p,ci,stats] = ttest(squeeze(mean(omitOrientSpecAmp(selSubj,selROI,:,selLayers),3)))
[h,p,ci,stats] = ttest(squeeze(mean(stimOrientSpecAmp(selSubj,selROI,:,selLayers),3)))

% Do a 2-way repeated measures ANOVA with factors 'effect type' and
% 'layer'.
disp('Effect type ANOVA');
Y = [squeeze(mean(stimOrientSpecAmp(selSubj,selROI,:,selLayers),3)) squeeze(mean(omitOrientSpecAmp(selSubj,selROI,:,selLayers),3))];
Y = Y(:);
S = repmat((1:length(selSubj))',2*length(selLayers),1);
F1 = [ones(length(Y)/2,1) ; 2*ones(length(Y)/2,1)]; % effect type
F2 = repmat(1:length(selLayers),length(selSubj),2); % layers
F2 = F2(:);
FACTNAMES = {'effectType','Layers'};
table = rm_anova2(Y,S,F1,F2,FACTNAMES)
text = sprintf('      interaction between effect type and layer: F%d,%d = %g, p = %g',table{4,3},table{7,3},table{4,5},table{4,6});
disp(text);

% Do a 2-way repeated measures ANOVA with factors 'layer' and
% 'task'.
disp('Task Type ANOVA');
Y = [squeeze(mean(omitOrientSpecAmp(selSubj,selROI,1,selLayers),3)) squeeze(mean(omitOrientSpecAmp(selSubj,selROI,2,selLayers),3))];
Y = Y(:);
S = repmat((1:length(selSubj))',2*length(selLayers),1);
F1 = [ones(length(Y)/2,1) ; 2*ones(length(Y)/2,1)]; % task type
F2 = repmat(1:length(selLayers),length(selSubj),2); % layers
F2 = F2(:);
FACTNAMES = {'taskType','Layers'};
table = rm_anova2(Y,S,F1,F2,FACTNAMES)
text = sprintf('      interaction between task type and layer: F%d,%d = %g, p = %g',table{4,3},table{7,3},table{4,5},table{4,6});
disp(text);

disp('ORIENTATION');
[h,p,ci,stats] = ttest(squeeze(mean(omitOrientSpecAmp(selSubj,selROI,1,selLayers),3)))
disp('CONTRAST');
[h,p,ci,stats] = ttest(squeeze(mean(omitOrientSpecAmp(selSubj,selROI,2,selLayers),3)))

disp('Stimulus Orientation');
[h,p,ci,stats] = ttest(squeeze(mean(stimOrientSpecAmp(selSubj,selROI,1,selLayers),3)))
disp('Stimulus Contrast');
[h,p,ci,stats] = ttest(squeeze(mean(stimOrientSpecAmp(selSubj,selROI,2,selLayers),3)))