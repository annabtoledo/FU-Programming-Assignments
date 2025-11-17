%% Train the encoding models

% Load the data
load("data_assignment_5.mat")


% Get the data dimension sizes
[numTrials, numChannels, numTime] = size(eeg_train);
numFeatures = size(dnn_train, 2);

%% Q1. Effect of training data amount on encoding accuracy
train_sizes = [250 1000 10000 16540]; %this is for later reference when looping across each size

all_meanR = zeros(length(train_sizes), numTime); %for storing each curve across time; empty now but will fill up later



for i = 1:length(train_sizes) %putting this to train the model 4 times, each with differing amounts of training image conditions; the for loop fgrom before will go inside this one

    N = train_sizes(i); %if N = train_sizes(1), the 1st element is 250, so N = 250, then in the next line
    fprintf('\n=== Training with N = %d trials ===\n', N); %indication of which iteration of training size it will train now

    dnn_train_part = dnn_train(1:N, :); %use this instead of dnn_train og; indexing out first N images; so if N = train_sizes(1), it'll be selecting first 250 images
    eeg_train_part = eeg_train(1:N, :, :);
    
    %% now do the same thing as done before, but replacing previous dnn_train and eeg_train with the indexed versions, it'll go through all 4 conditions:
        % Store weights and intercepts
    W = zeros(numFeatures, numChannels, numTime); % regression coefficients
    b = zeros(numChannels, numTime);              % intercepts
    
    % Progressbar parameters
    totalModels = numChannels * numTime;
    modelCount = 0;
    
    % Train a linear regression independently for each EEG channel and time
    % poin

    for ch = 1:numChannels
        for t = 1:numTime
            
            % Extract EEG responses for this channel/time over all trials
            y = eeg_train_part(:, ch, t);   %% but replace with indexed training images from each iteration
            
            % Fit linear regression: y = DNN*w + b
            mdl = fitlm(dnn_train_part, y);
            
            % Save parameters
            W(:, ch, t) = mdl.Coefficients.Estimate(2:end); % weights
            b(ch, t)    = mdl.Coefficients.Estimate(1);     % intercept
    
            % Update progress bar
            modelCount = modelCount + 1;
            fprintf('\rTraining models: %d / %d (%.1f%%)', ...
                modelCount, totalModels, 100*modelCount/totalModels);
    
        end
    end
    fprintf('\nDone training for N = %d\n', N);

    %% Use the trained models to predict the EEG responses for the test images

    [numTest, numFeatures] = size(dnn_test); %% same test data so nothing needs to change here
    [~, numChannels, numTime] = size(W);
    
    eeg_test_pred = zeros(numTest, numChannels, numTime); % predictions
    
    for ch = 1:numChannels
        for t = 1:numTime
            eeg_test_pred(:, ch, t) = dnn_test * W(:, ch, t) + b(ch, t);
        end
    end
    %% Compute the prediction accuracy using Pearson's correlation\
    
    [Ntest, Nchannels, Ntime] = size(eeg_test);
    
    % Preallocate correlation matrix
    R = zeros(Nchannels, Ntime);
    
    for ch = 1:Nchannels
        for t = 1:Ntime
            % Get test responses across images
            real_vec = squeeze(eeg_test(:, ch, t));
            pred_vec = squeeze(eeg_test_pred(:, ch, t));
    
            % Compute Pearson correlation
            R(ch, t) = corr(real_vec, pred_vec, 'Type', 'Pearson');
        end
    end
    % Store the mean correlation for the current training size
    meanR = mean(R, 1);
    all_meanR(i, :) = meanR; %storing for this N
end

%now plotting all curves together
figure;
hold on; %since I'll be calling on plot several times
colors = lines(length(train_sizes)); %diff colors for diff image amounts
for i = 1:length(train_sizes) %loop for each; stored the mean accuracy over time for each training size in a different row, so picking each row of all_meanR.
    plot(all_meanR(i, :), 'Color', colors(i, :), 'DisplayName', sprintf('%d trials', train_sizes(i)));
end

%now just put some labels and titles, and voila!
xlabel('Time (seconds)');
xticks(1:Ntime);
xticklabels(times);
ylabel('Mean Pearson Correlation');
title('Effect of training data amount on encoding accuracy');
legend('Location', 'best'); %shows legen using 'DisplayName' set in plot and have matlab pick the best corner automatically
grid on;
set(gca, 'FontSize', 10);

%% What pattern do you observe and what do you think are the reasons of this pattern
% I see the same pattern as the OG (training with all image conditions),
% but the correlation becomes weaker as the amount of training images
% reduce. This could simply be with fewer training images, the model estimates 
% the regression weights less reliably, so prediction accuracy drops. As the sample 
% size increases, the estimates become more stable and the correlations improve.

%% Q2. Effect of DNN feature amount on encoding accuracy

feature_sizes = [25 50 75 100]; %creating an array w differing feature sizes to iterate through later
all_meanR_feat = zeros(length(feature_sizes), numTime); %same premise as before, to store each curve for each feature size here

for i = 1:length(feature_sizes)

    K = feature_sizes(i);
    fprintf('\n=== Training with K = %d DNN features ===\n', K);

    dnn_train_part = dnn_train(:, 1:K); % use columns now, not rows since we are looking at DNN features
    dnn_test_part = dnn_test(:, 1:K); % here the test columns much match the training columns bc we need to feed the model the test sets with the same K features (otherwise matrix multiplication wont work, as we learned in stats class last week!)
          
    % Store weights and intercepts
   
    W = zeros(K, numChannels, numTime); % regression coefficients; num features is now K
    b = zeros(numChannels, numTime);              % intercepts
    
    % Progressbar parameters
    totalModels = numChannels * numTime;
    modelCount = 0;
    
    % Train a linear regression independently for each EEG channel and time
    % poin
    %% the rest stays the same for the most part

    for ch = 1:numChannels
        for t = 1:numTime
            
            % Extract EEG responses for this channel/time over all trials
            y = eeg_train(:, ch, t); %back to eeg_train, no indexing training conditions
            
            % Fit linear regression: y = DNN*w + b
            mdl = fitlm(dnn_train_part, y);
            
            % Save parameters
            W(:, ch, t) = mdl.Coefficients.Estimate(2:end); % weights
            b(ch, t)    = mdl.Coefficients.Estimate(1);     % intercept
    
            % Update progress bar
            modelCount = modelCount + 1;
            fprintf('\rTraining models: %d / %d (%.1f%%)', ...
                modelCount, totalModels, 100*modelCount/totalModels);
    
        end
    end
    fprintf('\nDone training for K = %d\n', K);

    %% Use the trained models to predict the EEG responses for the test images

    %[numTest, numFeatures] = size(dnn_test); %% same test data so nothing needs to change here
    %[~, numChannels, numTime] = size(W); 
    % remove the lines above bc W changes each time
    
    eeg_test_pred = zeros(numTest, numChannels, numTime); % predictions
    
    for ch = 1:numChannels
        for t = 1:numTime
            eeg_test_pred(:, ch, t) = dnn_test_part * W(:, ch, t) + b(ch, t); %replace dnn_test with indexed version
        end
    end
    %% Compute the prediction accuracy using Pearson's correlation\
    
    [Ntest, Nchannels, Ntime] = size(eeg_test);
    
    % Preallocate correlation matrix
    R = zeros(Nchannels, Ntime);
    
    for ch = 1:Nchannels
        for t = 1:Ntime
            % Get test responses across images
            real_vec = squeeze(eeg_test(:, ch, t));
            pred_vec = squeeze(eeg_test_pred(:, ch, t));
    
            % Compute Pearson correlation
            R(ch, t) = corr(real_vec, pred_vec, 'Type', 'Pearson');
        end
    end
    % Store the mean correlation for the current DNN feature size
    meanR = mean(R, 1);
    all_meanR_feat(i, :) = meanR; %storing for this K
end

% plot prediction accuracies for each amt of DNN features over time (one
% curve per DNN feature)

figure; hold on;
colors = lines(length(feature_sizes));

for i = 1:length(feature_sizes)
    plot(all_meanR_feat(i, :), 'Color', colors(i,:),'DisplayName', sprintf('%d features', feature_sizes(i)));
end

xlabel('Time (seconds)');
xticks(1:Ntime);
xticklabels(times);
ylabel('Mean Pearson Correlation');
title('Effect of DNN feature amount on encoding accuracy');
legend('Location','best');
grid on;
set(gca, 'FontSize', 10);

%% What pattern do you observe and what do you think are the reasons of this pattern?
% Again, I see the same pattern as before, with reduced accuracy for less
% DNN features. This could be because including more DNN features gives the 
% encoding model more information about the visual stimulus, allowing it to learn 
% a better mapping between the DNN representation and the EEG responses. The 
% timing of the curve stays the same across conditions, since increasing
% amount of feature dimensionality does not change when the brain responds 
% to visual information, only how well the model can capture those responses.