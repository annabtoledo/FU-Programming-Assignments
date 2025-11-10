


%Q2. Finding mean EEG at time = 0.100 for occipital and frontal channels

%EEG Occipital Mean
eeg_time_occipital = eeg(:,contains(ch_names, 'O'),41); %indexing values from the tensor for all channels 
% that contain the letter O and at the position for time = 0.100 (there was only 1)

mean_eeg_occipital = mean(eeg_time_occipital,"all"); %this is getting the mean from the previous indexing, 
% I found in the help function that the "all" gives me the output for all means (instead of the mean of each row or column)


%EEG Frontal Mean
%running the same commands as before, but replacing 'O' for 'F' in the
%first command

eeg_time_frontal = eeg(:,contains(ch_names, 'F'),41); 

mean_eeg_frontal = mean(eeg_time_frontal,"all");

%Q3. Visualizing time course of mean EEG voltage across all image
%conditions and EEG channels, averaged across 200 image conditions (i.e.,
%how each EEG channel behaves over time regardledss of which image was
%shown; each line is one channel mean EEG time course across all trials)

%x-axis --> time
%y-axis --> EEG voltage


% Average over all 200 image conditions
mean_eeg_channel = mean(eeg, 1);  % averaging across 1st dimension (image)

%But this would give us a 1x63x140 array, so now that it is averaged,
%across the 200 image conditions (from 200 to 1) we can remove that
%dimension using the 'squeeze' command:

mean_eeg_channel_squeeze = squeeze(mean_eeg_channel); %now we see a 2 dimension array

% with the channel's EEG voltage mean for each time (we previously could
% only see the EEG voltage mean for only timepoint 1). You also see that
% the array was automatically transposed, putting the channels in rows, and
% times in columns

% Plot all 63 channels over time

figure;
plot(times, mean_eeg_channel_squeeze,'k');  %times on x axis, EEG mean voltage on y axis 

xlabel ("Time (s)")
ylabel ("Mean EEG Voltage (μV)")

%REFLECTION: you can see a similarity in pattern of channels, showing waves of 
% activity occuring at the same timepoints. These represent the brain's
% synchronized response to seeing an image. What differs, however, is each
% channel's response amplitude, you see some channels' ranging very largely
% (from -2.0 to +2.0, for example) and other ranging very small (sometimes
% barely moving from 0). This shows us how different areas respond more
% strongly to stimuli. For example, it is likely that the occipital
% channels are demonstrating greater amplitude since they would show
% stronger visual response to an image compared to a frontal channel (also
% shown in our mean computations from Q2!).
%different amounts of signal and noise (though you still have some shared
%signal and noise)


hold on; %prepping for Q4

%Q4. Visualize time course of a) mean EEG across all images and occipital
%channels and b) mean EEG across all image conditions and frontal channels

%similar to what we did above but first we have to index for occipital
%channels only (and then same for frontal):
figure;
mean_occipital = mean(mean_eeg_channel(:,contains(ch_names, 'O'),:), 2);
mean_occipital_squeeze = squeeze(mean_occipital);

mean_frontal = mean(mean_eeg_channel(:,contains(ch_names, 'F'),:), 2);
mean_frontal_squeeze = squeeze(mean_frontal);

%adding occipital and frontal plots
plot(times, mean_occipital_squeeze, "r", LineWidth=1.5); 


plot(times, mean_frontal_squeeze, "b", LineWidth=1.5); 

%I added a different line type and width to differentiate from all channels and
%different colors to differentiate occipital and frontal

legend('Mean Frontal', 'Mean Occipital'); %adding legends to better identify; here I had to check image before to 
%see which legend was being assigned to which color, how do I do that
%directly (i.e., without having to check)?

%REFLECTION: In terms of similarities, you still see the wave-type
%oscillation in both timecourses, again reflecting that frontal and
%occipital channels are responding to the stimuli at the same time and same speed 
% (width of waves seem to be the same for occipital and frontal channels).
%However, there are a few interesting discrepancies: 1) as mentioned in Q3,
%there are different amplitudes in responses (height-wise).
%This plot confirms that, indeed, occipital channels are responding more
%strongly to the images then the frontal channels. 


%Q5. Time course for a) mean EEG voltage across all occipital channels for
%first image condition and b) mean EEG voltage across all occipital
%channels for second image condition.

%now we need to get the mean of indexing the first and second image
%conditions for occipital channels. This should be only a slight change in
%the code from the previous question.

mean_occipital_c1 = mean(eeg(1,contains(ch_names, 'O'),:), 2); %since we are averaging across
%channels, that means we have to average on the 2nd dimenstion

mean_occipital_c1_squeeze = squeeze(mean_occipital_c1); %now we have the average EEG voltage across channels for the 1st condition

%do same for condition 2
figure;
mean_occipital_c2 = mean(eeg(2,contains(ch_names, 'O'),:), 2); 

mean_occipital_c2_squeeze = squeeze(mean_occipital_c2);

%plotting should be the same idea as before

plot(times, mean_occipital_c1_squeeze, "m", LineWidth=1.5); 


plot(times, mean_occipital_c2_squeeze, "y", LineWidth=1.5); 

%again setting different line types, colors, and line width to
%differentiate this new plot

legend('Frontal', 'Occipital', 'Condition 2', 'Condition 1'); %again, only after playing around with the order of legends and changing a couple time, I got to the correct order for each color

%REFLECTION: In terms of similarities, we can see that both conditions have
%similar trajectories in occipital channels, with some places lining up perfectly to eachother.
%It's possible that the image conditions have similar properties and that
%averaging across occipital channels reduces noise, demonstrating shared
%visual responses in the plot. Additionally, early visual processing could be the most
% similar in earlier timepoints, when the images first appear and full attention is directed 
% (where you see these almost-perfect line ups).
% Regarding differences, there are different patterns in trajectory that appear 
% in a few places across the timecourse (e.g., at Time =~ 0.2s), as well as some subtle timing and amplitude differences (even with similar
% trajectory patterns, condition 2 activity responds slightly earlier condition 1). 
% This could perhaps be due to differences in
%attention and recognition, which would appear in later timepoints
%(compared to the early stages when image is first presented) and specific
%image properties that would be processed a few ms after it was initially
%presented. 
