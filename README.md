# FU-Programming-Assignments
Matlab codes for FU Intro to Programming Assignments

## Assignment 2
The EEG data are a 3D tensor:
200 Image conditions × 63 EEG channels × 140 Time points (s)
1. Download eeg_data_assignment_2.mat from Blackboard, and load its contents in your workspace.
2. What is the mean EEG voltage at 0.1 seconds for occipital channels (i.e., channels whose name contains the
letter “O”)? And for frontal channels (i.e., channels whose name contains the letter “F”)?
3. On the same plot, visualize the timecourse of the mean EEG voltage across all image conditions and EEG
channels, averaged across the 200 image conditions.
a. For this, use Matlab’s figure, hold on, and plot functions.
b. The time dimension should be on the x-axis, and the EEG voltage on the y-axis.
What are the similarities and differences between timecourses of the different channels? What do you
think is the reason for these similarities and differences?
4. On the same plot, visualize the timecourse of the (i) mean EEG voltage across all image conditions and
occipital channels, as well as of the (ii) mean EEG voltage across all image conditions and frontal channels.
What are the similarities and differences between the two timecourses? What do you think is the reason for
these similarities and differences?
5. On the same plot, visualize the timecourse of the (i) mean EEG voltage across all occipital channels for the
first image condition, as well as of the (ii) mean EEG voltage across all occipital channels for the second
image condition. What are the similarities and differences between the two curves? What do you think is
the reason for these similarities and differences?

***See 'Assignment2_Toledo.m'***

## Assignment 3

It is common to **counterbalance** the order of conditions across participants (e.g., if we have two
experimental conditions “familiar” and “unfamiliar”, half of the participants will perform “familiar” first, and
the other half will perform “unfamiliar” first, so to control for order effects).

It is also common to **pseudorandomize** lists of stimuli / conditions, such that they do not occur completely
at random, but according to some rules.

**Assignment**: We’re creating a condition list for an experiment. In 6 blocks, participants will view images of
familiar and unfamiliar faces; these faces will also have a different emotional expression. It’s a 2x3 factorial
design:
- Factor 1 FAMILIARITY (“familiar” vs. “unfamiliar”).
- Factor 2 EMOTION (“positive” vs. “neutral” vs. “negative”).
  
We will test 60 participants.

We want to counterbalance the order of blocks across participants, such that:

(1) ½ of participants start with familiar blocks.
(2) ⅓ of participants start with blocks corresponding to each emotion.

We also want each participant to perform the blocks in a pseudorandom order, such that blocks
corresponding to the same emotion are presented consecutively (e.g., “positive familiar” is immediately
followed by “positive unfamiliar”), but the order of emotions should be random (e.g. “neutral” - “negative” -
“positive”). 

Create a structure or table containing information about the order of blocks for each of the 60
participants.

#### Examples

**Example 1**: We’re coding an experiment. We will test 20 participants. Each participant will perform 5 trials.
In each trial, they will first see a word selected without replacement from a list of 10 words.
Then, they will see a number selected with replacement from a list of 30 numbers (from 101 to 130).
The words and numbers should be randomized across participants.

``` matlab

wordlist = {'ace' 'bit' 'cat' 'dog' 'elk' 'fog' 'gut' 'hit' 'ice' 'joy'};
numlist = 101:130;

n_subjects = 20;
n_trials = 5;
stimlist = []; % empty variable, it will become a structure

for i = 1:n_subjects
  selected_words = wordlist( randperm(length(wordlist), n_trials) );
  selected_numbers = randsample( numlist, n_trials, true );
  stimlist(i).words = selected_words;
  stimlist(i).numbers = selected_numbers;
end
```

**Example 2**: We’re coding an experiment with the same stimuli. Each participant will perform 3 blocks, with 4 trials in each block.
In the first block, they will see 4 words selected randomly without replacement from a list of 12 words.
In the second block, they will see 4 words selected randomly out of the the remaining 8 words.
In the third block, they will see the 4 remaining words.

There are 2 ways to solve this:

*Option 1*

``` matlab
wordlist = {'ace' 'bit' 'cat' 'dog' 'elk' 'fog' 'gut' 'hit' 'ice' 'joy' 'keg' 'lip'};

n_blocks = 3;
n_words_per_block = 4;

words_per_block = cell(n_blocks,n_words_per_block); % create a cell array

all_words_shuffled = wordlist(randperm(length(wordlist))); % shuffle entire list once

for i = 1:n_blocks
  pick_words = (i-1)*n_words_per_block+1 : i*n_words_per_block; % pick 1:4, then 5:8
  ...
  words_per_block(i,:) = all_words_shuffled(pick_words); % fill the cell array by block
end
```
*Option 2* 
  
``` matlab
wordlist = {'ace' 'bit' 'cat' 'dog' 'elk' 'fog' 'gut' 'hit' 'ice' 'joy' 'keg' 'lip'};

n_words_per_block = 4;
words_per_block = cell(0); % create an empty cell array with no elements

while length(wordlist)>0
  pick_words = randsample(wordlist,4); % pick 4 random words
  wordlist = setdiff(wordlist, pick_words); % data in wordlist not in pick_words
  words_per_block = vertcat(words_per_block, pick_words); % add a new row to cell array
end
```
***See 'Assignment3_Toledo.m'***

## Assignment 5

1.  Effect of training data amount on encoding accuracy:
- Train EEG encoding models using different amounts of training image conditions
[250, 1000, 10000, 16540].
- Test each of the encoding models on the same test data (i.e., the 200 test images
and corresponding fMRI responses).
- Plot the prediction accuracies of each amount of training image conditions over
time, averaged across all EEG channels (i.e., one time course curve per amount of
training data).
- What pattern do you observe, and what do you think are the reasons of this
pattern?

2. Effect of DNN feature amount on encoding accuracy:
- Train EEG encoding models using different amounts of DNN features [25, 50, 75,
100].
- Test each of the encoding models on the same test data (i.e., the 200 test images
and corresponding fMRI responses).
- Plot the prediction accuracies of each amount of DNN features over time, averaged
across all EEG channels (i.e., one time course curve per amount of DNN Features).
- What pattern do you observe, and what do you think are the reasons of this
pattern?

#### Example for training all data amount and all dnn features:
``` matlab
%% Train the encoding models

% Load the data
load("data_assignment_5.mat")

% Get the data dimension sizes
[numTrials, numChannels, numTime] = size(eeg_train);
numFeatures = size(dnn_train, 2);

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
        y = eeg_train(:, ch, t);   % [N x 1]
        
        % Fit linear regression: y = DNN*w + b
        mdl = fitlm(dnn_train, y);
        
        % Save parameters
        W(:, ch, t) = mdl.Coefficients.Estimate(2:end); % weights
        b(ch, t)    = mdl.Coefficients.Estimate(1);     % intercept

        % Update progress bar
        modelCount = modelCount + 1;
        fprintf('\rTraining models: %d / %d (%.1f%%)', ...
            modelCount, totalModels, 100*modelCount/totalModels);

    end
end



%% Use the trained models to predict the EEG responses for the test images

[numTest, numFeatures] = size(dnn_test);
[~, numChannels, numTime] = size(W);

eeg_test_pred = zeros(numTest, numChannels, numTime); % predictions

for ch = 1:numChannels
    for t = 1:numTime
        eeg_test_pred(:, ch, t) = dnn_test * W(:, ch, t) + b(ch, t);
    end
end



%% Compute the prediction accuracy using Pearson's correlation
% If you are not sure what a correlation is, don't worry! For now, all you 
% need to know is that it is a measure of similarity between two vectors,
% where a correlation score of 0 indicates no similarity, and a correlation
% score of 1 indicates perfect similarity.

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



%% Plot the prediction accuracy over time, averaged across channels

% Average the correlation across channels
meanR = mean(R, 1);

% Plot the mean correlation over time
figure;
plot(meanR);
xlabel('Time (seconds)');
xticks(1:Ntime);
xticklabels(times);
ylabel('Mean Pearson Correlation');
title('Prediction Accuracy Over Time');
grid on;
set(gca, 'FontSize', 20);
```

***See 'Assignment5_Toledo.m'***
