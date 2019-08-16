
Subject = 'sub-03';
PrDir = '/Users/OliverW/Desktop/Project/Subjects/';

load(fullfile(PrDir, Subject, 'Timecourses', 'Run4', 'V1_45deg.mat'));

V1_pial = mean(timeCourses{1}(5, :));
V1_super = mean(timeCourses{1}(4, :));
V1_mid = mean(timeCourses{1}(3, :));
V1_deep = mean(timeCourses{1}(2, :));
V1_white = mean(timeCourses{1}(1, :));

depth_profile = [V1_white, V1_deep, V1_mid, V1_super, V1_pial];

figure
plot(depth_profile, 'g', 'LineWidth', 3)
title('Cortical depth profile');
xlabel('Cortical depth');
ylabel('fMRI signal');

ax = gca;
ax.XTick = [1, 2, 3, 4, 5];
ax.XTickLabel = {'White', 'Deep', 'Middle', 'Superficial', 'Pial'};
