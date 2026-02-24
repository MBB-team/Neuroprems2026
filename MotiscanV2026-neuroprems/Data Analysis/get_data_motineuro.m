function [datasub] = get_data_motineuro(subID,sess)
% get_data_FTDISI gets model free data for subject 'subID' in the FTDISI
% study

%% Set Analysis

%resdir_patients   = 'C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\Données brutes\patients\Data MATLAB\diagnosed';
%resdir_controls   = 'C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\Données brutes\temoins\Data MATLAB';
% resdir_pilots   = 'C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\Données brutes\phase pilote';
% resdir_AD_FTD    = 'C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\Données brutes\patients\Data MATLAB\AD_FTD';
% resdir_psy_FTD   = 'C:\Users\raphael.joly\ownCloud - JOLY Raphael (raphael.joly@icm-institute.org)@owncloud.icm-institute.org2\Données brutes\patients\Data MATLAB\psy_FTD';
resdir_pilots   = '/Users/adriaanapsv/desktop/MotiscanV2024/data/motineuro';
resdir_patients   = '/Users/adriaanapsv/desktop/MotiscanV2024/data/motineuro';
resdir = '/Users/adriaanapsv/desktop/MotiscanV2024/data/motineuro';


if subID >=200 && subID<500
    resdir = resdir_patients;
%elseif (subID >=300 & subID<400) | (subID<100)
    %resdir = resdir_controls;
elseif subID >= 77 && subID <= 79 || subID > 99 && subID <110
    resdir = resdir_pilots ;
% elseif subID >=400 & subID<500
%     resdir = resdir_AD_FTD
% elseif subID >=500
%     resdir = resdir_psy_FTD
end

%% Load data

datasub = load([resdir,filesep,'sub',num2str(subID),filesep,'motineuro_sub',num2str(subID),'_sess',num2str(sess),'_subdata.mat']);


end