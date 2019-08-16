% Convert Freesurfer labels to Nifti ROI volumes
clear all

Subjects = {'sub-03'};
PrDir = '/Users/OliverW/Desktop/Project/Subjects';

for SID = 1:length(Subjects)
    ROIFolder = fullfile(PrDir, Subjects{SID}, 'Masks');
    meanEPIFile = fullfile(PrDir, Subjects{SID}, 'Functional', 'Cropped', 'cr_meanfunctional.nii');

    if ~exist(ROIFolder,'dir')
        mkdir(ROIFolder);
    end

    labelROIs = {'V1', 'V2'};
    hemis = {'lh','rh'};
    % set FreeSurfer subject dir
    unixCommand = sprintf('export SUBJECTS_DIR=%s', fullfile(PrDir, Subjects{SID}));
    unixCommand = sprintf('%s\nexport SUBJECT=Freesurfer', unixCommand);
    unixCommand = sprintf('%s\nexport FILLTHRESH=0.0', unixCommand); %threshold for incorporating a voxel in the mask, default = 0
    unixCommand = sprintf('%s\nexport REFERENCEVOLUME=%s', unixCommand, meanEPIFile);
    unixCommand = sprintf('%s\nexport REGISTERDAT=%s', unixCommand, fullfile(PrDir, Subjects{SID}, 'Coregistrations', 'register.dat'));
    for iLabel = 1:length(labelROIs)
        for iHemi = 1:length(hemis)
            unixCommand = sprintf('%s\nexport LABEL=%s/Freesurfer/label/%s.%s_exvivo.label', unixCommand, fullfile(PrDir, Subjects{SID}), hemis{iHemi}, labelROIs{iLabel});
            unixCommand = sprintf('%s\nexport DEST=%s/%s.%s.nii', unixCommand, ROIFolder, hemis{iHemi}, labelROIs{iLabel});
            unixCommand = sprintf('%s\nmri_label2vol --label $LABEL --o $DEST --reg $REGISTERDAT --temp $REFERENCEVOLUME --fillthresh $FILLTHRESH --proj frac -0.5 1.5 0.1 --subject $SUBJECT --hemi %s --surf white', unixCommand, hemis{iHemi});
            % Changed --proj frac from [0 1 0.1] to [-0.2 1.2 0.1] now to [-0.5 1.5 0.1]
        end
    end

    unix(unixCommand);
end
