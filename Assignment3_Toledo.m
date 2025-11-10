
%creating variable names and values

n_subjects = 60;
n_blocks = 6;
familiarity = {'familiar', 'unfamiliar'};
emotions = {'positive', 'neutral', 'negative'};


%first deciding the starting condition combo
start_combo = [];

for i = 1:length(emotions) %starting at 1st emotion and looping through the 3 possible ones
    for e = 1:length(familiarity) %each emotion will be paired with familiarity condition
        start_combo = [start_combo; i, e]; %gives us a 6x2 matrix, adding a row for each iteration of i and e (youll see i repeated because it has to go through the iterations of e first)
    end
end

%assign sort combos evenly across participants (we'll have 10 participants
%per combo, half start with familiar, and 1/3 starting w a specific emotion

shuffled_combo = start_combo(randperm(size(start_combo, 1)), :); %shuffling starting combos across participants (I'm not sure if this is necessary but just in case)
stimlist = repmat(shuffled_combo, n_subjects / size(shuffled_combo, 1), 1); %repeating suffled combo 10x (60/6 = 10) and vertically

participant_stim = struct('ID', [], 'Starting_Block', [], 'Block_Order', []); %setting up the structure for all participants block order info; they are empty now but will fill up

participant_stim(n_subjects).ID = []; %preallocating 60 spaces in my array, telling matlab to have 60 elements in my structure and each element will have at least 1 field called ID

%assign start settings for each participant

for s = 1:n_subjects
    start_emotion_idx = stimlist(s,1); %indexing from row s and column 1 (emotion)
    start_fam_idx = stimlist(s,2); %indexing from row s and column 2 (familiarity: 1 = familiar, 2 = unfamiliar)

    start_emotion = emotions{start_emotion_idx}; %transforming indexed value into text (emotion: 1 = positive, 2 = neutral, 3 = negative); using {} pulls out the actual string apparently

    if start_fam_idx == 1 %decide which order familiarity to use for first pair of blocks (since it has to be same emotion consecutively w the different familiarities paired w each of them)
        start_fam = familiarity([1 2]); %take element 1 (familiar) then 2 after (unfamiliar) from the initial assignment
    else %i.e., if they start with 2 (unfamiliar)
        start_fam = familiarity([2 1]);
    end 

    %now we have the first pair, we have to get order of the remaining 2
    %emotions (randomly)

    remaining = setdiff(1:3, start_emotion_idx); %of the 3 emotions, give me the ones i havent used yet
    remaining = remaining(randperm(2)); % shuffle the order of the remaining 2

    block_order = {}; %creating an empty cell array to fill with the info of block orders for all participants

    for f = 1:2 %bc we're going to have each emotion show up twice (once for each familiarity condition)
        block_order{end+1} = [start_emotion '_' start_fam{f}];%adding to the array, at the beginning (empty), this means 1, and the next loop it'll be 2
        %for that cell we added, we are assigning the emotion we start and
        %the familiarity condition that we assigned previously; the next
        %loop will have the same emotion but f = 2 (whatever familiarity
        %was not used)
    end
    %now assign remaining pairs
    for k = 1:2 %i.e., the remaining emotions
        remain_emo = emotions{remaining(k)}; %assigning for each remaining emotion indexed from the setdiff from before
        rand_fam = familiarity(randperm(2)); %random order for familiarity
        for f = 1:2 %for each familiarity condition
            block_order{end+1} = [remain_emo '_' rand_fam{f}];
        end
    end

    %now we store everything into the participant_stim structure

    participant_stim(s).ID = s; % assign participant ID
    participant_stim(s).Starting_Block = [start_emotion '_' start_fam{1}]; % store starting block info, get first element of start_fam (since it has the pair stored, u only want one)
    participant_stim(s).Block_Order = block_order; % store the complete block order for the participant
end

participant_table = struct2table(participant_stim); %now you can see everything clearly without having to click on arrays stored within the table