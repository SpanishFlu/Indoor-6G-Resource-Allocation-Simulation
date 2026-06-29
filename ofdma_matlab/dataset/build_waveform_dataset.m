function ds_info = build_waveform_dataset(cfg, trace)
% BUILD_WAVEFORM_DATASET  Generate the balanced waveform_dataset.csv.
%
%   ds_info = build_waveform_dataset(cfg, trace)
%
%   Pipeline:
%     1. Extract 7 physical features from every simulation slot
%     2. Classify each snapshot → Class 1..10
%     3. Oversample with physical pipeline to fill under-represented classes
%     4. Balance to target class_counts
%     5. One-hot encode, shuffle, export CSV
%     6. Return ds_info struct with summary statistics
%
%   The features are NOT random: they are derived from the simulation's
%   actual channel, mobility, and traffic data combined with the 3GPP
%   TR 38.901 Indoor Factory delay-spread model.

    T = cfg.n_slots;

    fprintf('\n========== WAVEFORM DATASET GENERATION ==========\n');

    % =====================================================================
    % STEP 1: Extract features from every simulation slot
    % =====================================================================
    fprintf('Extracting features from %d simulation slots...\n', T);
    Features   = zeros(T, 7);
    ClassLabel = zeros(T, 1);

    for t = 1:T
        feat = extract_slot_features(cfg, trace, t);
        Features(t, :) = feat;

        % Classify using original agenerate_set.m logic
        numerology = assign_numerology(feat(5), feat(6), feat(7), feat(3));
        guard_band = assign_guard_band(feat(2));
        ClassLabel(t) = assign_class(guard_band, numerology);
    end

    fprintf('Slot-based extraction complete. Distribution:\n');
    tabulate(ClassLabel);

    % =====================================================================
    % STEP 2: Oversample with physical pipeline to build a large pool
    % =====================================================================
    target_total = sum(cfg.class_counts);
    pool_needed  = max(0, target_total * 5 - T);  % x5 oversample factor

    if pool_needed > 0
        fprintf('Generating %d additional physical snapshots...\n', pool_needed);
        extra_feat   = zeros(pool_needed, 7);
        extra_labels = zeros(pool_needed, 1);

        for s = 1:pool_needed
            [f, c] = generate_physical_snapshot(cfg);
            extra_feat(s, :) = f;
            extra_labels(s)  = c;
        end

        Features   = [Features;   extra_feat];
        ClassLabel = [ClassLabel; extra_labels];
    end

    fprintf('Total pool size: %d samples\n', length(ClassLabel));

    % =====================================================================
    % STEP 3: Balanced sampling per class
    % =====================================================================
    fprintf('Balancing to target distribution...\n');
    balanced_idx = [];

    for class_id = 1:10
        idx    = find(ClassLabel == class_id);
        needed = cfg.class_counts(class_id);

        if length(idx) >= needed
            sel = randsample(idx, needed);
        else
            % Generate more using physical pipeline until we have enough
            fprintf('  Class %d: have %d, need %d — generating extra...\n', ...
                class_id, length(idx), needed);
            extra_needed = needed - length(idx);
            count_valid  = 0;
            new_feat     = zeros(extra_needed, 7);
            new_labels   = zeros(extra_needed, 1);
            max_tries    = extra_needed * 200;
            tries        = 0;

            while count_valid < extra_needed && tries < max_tries
                tries = tries + 1;
                [f, c] = generate_physical_snapshot(cfg);
                if c == class_id
                    count_valid = count_valid + 1;
                    new_feat(count_valid, :) = f;
                    new_labels(count_valid)  = c;
                end
            end

            if count_valid < extra_needed
                warning('Class %d: only found %d of %d extra samples.', ...
                    class_id, count_valid, extra_needed);
                new_feat   = new_feat(1:count_valid, :);
                new_labels = new_labels(1:count_valid);
            end

            % Append to pool
            n_before   = size(Features, 1);
            Features   = [Features;   new_feat];    %#ok<AGROW>
            ClassLabel = [ClassLabel; new_labels];   %#ok<AGROW>
            new_idx    = (n_before + 1) : (n_before + count_valid);

            sel = [idx; new_idx(:)];
            if length(sel) > needed
                sel = randsample(sel, needed);
            end
        end

        balanced_idx = [balanced_idx; sel(:)]; %#ok<AGROW>
    end

    % =====================================================================
    % STEP 4: One-hot encoding
    % =====================================================================
    X_final  = Features(balanced_idx, :);
    Y_labels = ClassLabel(balanced_idx);
    N_final  = length(balanced_idx);

    Y_onehot = zeros(N_final, 10);
    for i = 1:N_final
        cid = Y_labels(i);
        if cid >= 1 && cid <= 10
            Y_onehot(i, cid) = 1;
        end
    end

    % =====================================================================
    % STEP 5: Merge, shuffle, export
    % =====================================================================
    full_dataset = [X_final, Y_onehot];
    perm = randperm(N_final);
    full_dataset = full_dataset(perm, :);

    col_names = {'Mean Excess Delay', 'Variance Excess Delay', ...
        'Mean Doppler Effect', 'Variance Doppler Effect', ...
        'Number of eMBB Users', 'Number of URLLC Users', ...
        'Number of mMTC Users', ...
        'Class 1', 'Class 2', 'Class 3', 'Class 4', 'Class 5', ...
        'Class 6', 'Class 7', 'Class 8', 'Class 9', 'Class 10'};

    dataset_table = array2table(full_dataset, 'VariableNames', col_names);
    writetable(dataset_table, 'waveform_dataset.csv');

    fprintf('\nDataset exported: waveform_dataset.csv\n');
    fprintf('  Total samples : %d\n', N_final);
    fprintf('  Columns       : 7 features + 10 one-hot = 17\n');

    % =====================================================================
    % STEP 6: Validation
    % =====================================================================
    fprintf('\n----- Dataset Validation -----\n');

    user_sums = X_final(:,5) + X_final(:,6) + X_final(:,7);
    fprintf('User count sum : min=%d, max=%d (expected %d)\n', ...
        min(user_sums), max(user_sums), cfg.dataset_N_users);
    fprintf('Mean Excess Delay  [us]  : min=%.4f, max=%.4f, mean=%.4f\n', ...
        min(X_final(:,1)), max(X_final(:,1)), mean(X_final(:,1)));
    fprintf('Var  Excess Delay  [us2] : min=%.4f, max=%.4f, mean=%.4f\n', ...
        min(X_final(:,2)), max(X_final(:,2)), mean(X_final(:,2)));
    fprintf('Mean Doppler       [Hz]  : min=%.2f, max=%.2f, mean=%.2f\n', ...
        min(X_final(:,3)), max(X_final(:,3)), mean(X_final(:,3)));
    fprintf('Var  Doppler       [Hz2] : min=%.2f, max=%.2f, mean=%.2f\n', ...
        min(X_final(:,4)), max(X_final(:,4)), mean(X_final(:,4)));
    fprintf('N_eMBB  range : [%d, %d]\n', min(X_final(:,5)), max(X_final(:,5)));
    fprintf('N_URLLC range : [%d, %d]\n', min(X_final(:,6)), max(X_final(:,6)));
    fprintf('N_mMTC  range : [%d, %d]\n', min(X_final(:,7)), max(X_final(:,7)));

    row_sums = sum(Y_onehot(perm,:), 2);
    fprintf('One-hot row sums : min=%d, max=%d (expected 1)\n', ...
        min(row_sums), max(row_sums));

    fprintf('\nFinal class distribution:\n');
    tabulate(Y_labels);

    % =====================================================================
    % Return info struct
    % =====================================================================
    ds_info.n_samples      = N_final;
    ds_info.features       = X_final;
    ds_info.labels         = Y_labels;
    ds_info.class_counts   = histcounts(Y_labels, 0.5:1:10.5);
    ds_info.filename       = 'waveform_dataset.csv';
end
