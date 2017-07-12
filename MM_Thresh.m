% NOTE - To run this testfile, you need to close all figures that are
% currently open. 

% Load test file:
aisha = load('../csvfiles/aisha.csv');
A = 8; % Set number of feature vectors in the audio shingles

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% Create color maps for images %
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %

% Making course colormap with white for those values above the thresh
colormap bone
cvals = colormap; % Save the color values
inds = 1:3:50;
map2 = [cvals(inds,:);ones(1,3)];

yerg = [ones(1,3); 0.75*ones(1,3);0.5*ones(1,3);0.25*ones(1,3);zeros(1,3)];

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% Create images such that 
%   1) if D_ij < T, then M_ij = D_ij
%   2) else, then M_ij = -1
% Example: 

% threshmat = (distAS<thresh);
% figure();imagesc((threshmat - 1)+(threshmat.*distAS))
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %


% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% =-=-= EXAMPLES in Paper =-=-= %
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %


% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% 1 - Lead Sheet
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %

% Create the distance matrix and find the 10% threshold
[distAS, matAS] = cosDistMat_from_FeatureVectors(aisha, A);
all_vals = distAS(:);
sort_vals = sort(all_vals);
thresh = sort_vals(round(size(all_vals,1)*.1));

% Create images of 1) chroma vectors, 
%                  2) SDM, 
%                  3) histogram of values, and
%                  4) thresholded SDM with values preserved
figure();imagesc(aisha);colormap(yerg);
set(gca,'fontsize',20)

figure();imagesc(distAS);colormap jet;
set(gca,'fontsize',20)

figure();histogram(all_vals, 'LineWidth',1.5, 'Facecolor', 'none', ...
    'BinLimits',[0,1], 'BinWidth', 0.02);
set(gca,'fontsize',20)

threshmat = (distAS<=thresh);
figure();imagesc((-1.1)*(threshmat - 1)+(threshmat.*distAS));
set(gca,'fontsize',20)
colormap(map2);caxis([0,.35]);


% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% 2 - Lead Sheet + Gaussian noise
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %

% Non-negative Gaussian Noise centered at mu = 0 with sd = 1/2
X = abs((1/2)*randn(size(aisha)));

% Chroma vectors for Lead Sheet plus Gaussian noise
extwo = aisha + X;

% Create the distance matrix and find the 10% threshold
[dist2AS, mat2AS] = cosDistMat_from_FeatureVectors(extwo, A);
all_vals2 = dist2AS(:);
sort_vals2 = sort(all_vals2);
thresh2 = sort_vals2(round(size(all_vals2,1)*.1));

% Create images of 1) histogram of values, and
%                  2) thresholded SDM with values preserved
figure();histogram(all_vals2, 'LineWidth',1.5, 'Facecolor', 'none', ...
    'BinLimits',[0,1], 'BinWidth', 0.02);
set(gca,'fontsize',20)

threshmat2 = (dist2AS<=thresh2);
figure();imagesc((-1.1)*(threshmat2 - 1)+(threshmat2.*dist2AS));
set(gca,'fontsize',20)
colormap(map2);caxis([0,0.35]);

% Create image comparing lead sheet with and without Gaussian noise
figure();imagesc(threshmat - threshmat2);
set(gca,'fontsize',20)

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% 3 - Lead Sheet + Restricted "Note" noise
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %

% To create "note noise" select a random sample from a vector of preset 
% note values.  

% Whole number to note converter - 
% 0 - rest
% 2 - trip eighth
% 3 - sixteenth
% 4 - trip quarter
% 6 - eighths
% 8 - 2 trip quarters
% 9 - dotted eighth or 2 sixteenths
% 10 - 5 trip eighths
% 12 - quarter
% 14 - quarter plus trip eighth
% 15 - quarter plus sixteenth
% 16 - quarter plus trip quarter
% 18 - dotted quarter
% 20 - quarter plus 2 trip quarters
% 21 - quarter plus dotted eighth or quarter plus 2 sixteenths
% 22 - quarter plus 5 trip eighths
% 24 - half note

note_vec = (1/12)*[0,0,0, 0,0,0, 2,2,2, 3,3,3,3,3,3, 4,4,4,4,4,4,4,4,4,...
    6,6,6, 6,6,6, 6,6,6, 6,6,6, 6, 8,9,10, 12,12,12, 12,12,12, ...
    12,12,12, 14,15,16, 18,18,18, 20,21,22,24,24];
figure();histogram(note_vec, 'LineWidth',1.5, 'Facecolor', 'none', ...
    'BinLimits',[0,2], 'BinWidth', 1/12);
set(gca,'fontsize',20)
% Note Distribution is as follows: 
%   6 rests, 3 trip eigths, 6 sixteenths 9 trip quarters,
%   13 eighths, 1 each of {2 trip quarters, dotted eighth or 2 sixteenths,
%                           and, 5 trip eighths}, 
%   9 quarter notes,
%   1 each of {quarter plus trip eighth, quarter plus sixteenth and 
%               quarter plus trip quarter}, 
%   3 dotted quarters, 
%   1 each of {quarter plus 2 trip quarters,  quarter plus dotted eighth,
%               quarter plus 5 trip eighths}
%   2 half notes

% Note noise pulled from NOTE_VEC with replacement
X = reshape(datasample(note_vec,numel(aisha),'Replace',true), size(aisha));

% Restrict note noise to notes that are activated by the chord, then 
% add to the lead sheet
mask = (aisha > 0);
exthree = aisha + X.*mask;

% Create the distance matrix and find the 10% threshold
[dist3AS, mat3AS] = cosDistMat_from_FeatureVectors(exthree, A);

all_vals3 = dist3AS(:);
sort_vals3 = sort(all_vals3);
thresh3 = sort_vals3(round(size(all_vals3,1)*.1));

% Create images of 1) histogram of values, and
%                  2) thresholded SDM with values preserved
figure();histogram(all_vals3, 'LineWidth',1.5, 'Facecolor', 'none', ...
    'BinLimits',[0,1], 'BinWidth', 0.02);
set(gca,'fontsize',20)

threshmat3 = (dist3AS<=thresh3);
figure();imagesc((-1.1)*(threshmat3 - 1)+(threshmat3.*dist3AS));
set(gca,'fontsize',20)
colormap(map2);caxis([0,0.35]);

% Comparing with and without restricted note noise
figure();imagesc(threshmat - threshmat3);
set(gca,'fontsize',20)

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% 4 - Lead sheet + Restricted Note noise + Gausian noise
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %


% Non-negative Gaussian Noise centered at mu = 2 with sd = 1/2
X = abs((1/2)*randn(size(aisha)));
Y = reshape(datasample(note_vec,numel(aisha),'Replace',true), size(aisha));

% Restrict Note noise to notes that are activated by the chord, then 
% add to the lead sheet with Gaussian noise
mask = (aisha > 0);
exfour = aisha + Y.*mask + X;

% Create the distance matrix and find the 10% threshold
[dist4AS, mat4AS] = cosDistMat_from_FeatureVectors(exfour, 8);

all_vals4 = dist4AS(:);
sort_vals4 = sort(all_vals4);
thresh4 = sort_vals4(round(size(all_vals4,1)*.1));

% Create images of 1) histogram of values, and
%                  2) thresholded SDM with values preserved
figure();histogram(all_vals4, 'LineWidth',1.5, 'Facecolor', 'none', ...
    'BinLimits',[0,1], 'BinWidth', 0.02);
set(gca,'fontsize',20)

threshmat4 = (dist4AS<=thresh4);
figure();imagesc((-1.1)*(threshmat4 - 1)+(threshmat4.*dist4AS));
set(gca,'fontsize',20)
colormap(map2);caxis([0,1]);

% Comparing with and without restricted Gaussian noise
figure();imagesc(threshmat - threshmat4);
set(gca,'fontsize',20)

% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %
% Create Summary Statistics for test run %
% =-=-=-=-=-=-=-=-=-=-=-=-=-=-= %

% List out the cosine dissimilarity threshold values
thresh_vec = [thresh,thresh2,thresh3,thresh4];

% List out the corresponding angle values
angle_vec = acosd(1- [thresh,thresh2,thresh3,thresh4]);

% Find values for rho
rho1 = sqrt(1-(1-thresh)^2)/(1-thresh);
rho2 = sqrt(1-(1-thresh2)^2)/(1-thresh2);
rho3 = sqrt(1-(1-thresh3)^2)/(1-thresh3);
rho4 = sqrt(1-(1-thresh4)^2)/(1-thresh4);

rho_vec = [rho1, rho2, rho3, rho4];
