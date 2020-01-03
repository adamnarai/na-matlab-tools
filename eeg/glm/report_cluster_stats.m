function report_str = report_cluster_stats(M, mask, MCC, name, LIMO)
% REPORT_CLUSTER_STATS  Generate report from LIMO statistics.
% Defining clusters in time (assuming 2D clusters do not overlap in time)
% and reporting temporal extent + cluster p values when available.
%
% Call [M, mask] = limo_stat_values(Type,FileName,p,MCC,LIMO) beforehand.
%
% INPUT:
%           M = (corrected) p values
%           mask = significe mask
%           MCC = multiple comparison type (1: none, 2: 2D clustering, 3: TFCE)
%           name = analysis name
%           LIMO = LIMO structure with analysis params
% OUTPUT:
%           report_str = formatted report string
%
% Adam Narai, RCNS, 2019
%

% Loop for clusters in time
clusters = bwlabel(any(mask,1));
for clust = unique(clusters(clusters > 0))
    clust_timevect = LIMO.data.timevect(clusters == clust);
    ch_idx = any(mask(:, clusters == clust), 2);
    all_ch = {LIMO.data.chanlocs.labels};
    ch_list = all_ch(ch_idx);
    
    % Generate temporal extent string
    temp_str = [
        num2str(clust_timevect(1)), '-',...
        num2str(clust_timevect(end)), ' (',...
        num2str(round(clust_timevect(1)/5)*5), '-',...
        num2str(round(clust_timevect(end)/5)*5), ') ms'];
    
    % MCC specific report string
    switch MCC
        case 1 % None
            report_str = [name, ' None ', num2str(clust), ': ', temp_str];
        case 2 % 2D clustering
            clust_p_data = M(:,clusters == clust);
            clust_p = clust_p_data(find(~isnan(clust_p_data),1));
            report_str = [name, ' Cluster ', num2str(clust), ': ', temp_str,...
                ' (p = ', num2str(clust_p), ')'];
        case 3  % TFCE
            report_str = [name, ' TFCE ', num2str(clust), ': ', temp_str];
    end
    
    % Adding channel list
    report_str = [report_str, char(10), 'Ch: ', strjoin(ch_list, ', '), char(10), char(10)];
end