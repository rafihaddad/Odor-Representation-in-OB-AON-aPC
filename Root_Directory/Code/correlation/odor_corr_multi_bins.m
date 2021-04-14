function [vecR, vecP, meanR, stdR, matR, matP] = odor_corr_multi_bins(data, params)

matFR = NaN(length(params.windows), size(data.data,1), size(data.data,2));
for kk=1:length(params.windows)
    % find window
    params.end_sniff_phase = params.windows(kk);
    if params.end_sniff_phase <= 0
        params.pre_end_sniff_phase = params.end_sniff_phase - 1;
    else
        phase = rem(params.end_sniff_phase,1);
        if phase == 0, params.pre_end_sniff_phase = 0; else params.pre_end_sniff_phase = phase - 1; end
    end
    if params.moving_window_flag
        if params.end_sniff_phase <= 0
            params.start_sniff_phase = params.windows(kk) - params.bin_size;
        else
            params.start_sniff_phase = max(params.start, params.windows(kk) - params.bin_size);
        end
    else
        if params.end_sniff_phase <= 0
            params.start_sniff_phase = params.end_sniff_phase - params.bin_size;
        else
            params.start_sniff_phase = params.start;
        end
    end
    matFR(kk,:,:) = get_mat_fr_phase(data, params);
end
matFR = reshape(matFR,[],size(matFR,3));
% corr and p values
[matR,matP] = corr(matFR, 'Type', params.corr_type);
vecR = upperRightTriAsVector(matR);
vecP = upperRightTriAsVector(matP);
meanR = mean(vecR);
stdR = std(vecR);
end