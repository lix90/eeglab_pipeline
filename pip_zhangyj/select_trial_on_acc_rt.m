function out = select_trial_on_acc_rt(fname, stims, format_spec)

% example:
% fname = '/path/to/fname.txt'
% stims = {'fu', 'zhong', 'zheng'};
% format_spec = '%s %s %s';

fid = fopen(fname);
txt = textscan(fid, format_spec);  % Cell string array

% find no_resp

ind_stim = ismember(txt{1}, stims);
ls_accs = str2double(txt{2}(ind_stim));
ls_rts = str2double(txt{3}(ind_stim));

no_resp = ls_rts==0;  % null responses
wr_resp = ls_accs==0;  % wrong responses
out = wr_resp(~no_resp);  % remove null responses
