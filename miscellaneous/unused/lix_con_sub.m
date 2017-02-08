function output = lix_con_sub(subflag)
% compute subtraction pain effect across mood levels, using data from pop_precomp
try
    S = 1:13; % Subjects
    C = [12, 11, 21, 22, 31, 32]; % mood (positive + negative + neutral) * pain (pain + no pain)
    E = 1:60; % Electrodes
    output.f = []; % Freqs
    output.t = []; % Times
    switch subflag
        case 1
            output.posi = zeros(100, 200, 60, 13);
            output.nega = zeros(100, 200, 60, 13);
            output.neut = zeros(100, 200, 60, 13);
            for indS = 1:length(S)
                fprintf('sub%d start\n', S);
                for indC = [1 3 5]
                    file_pain = ['design3_sub', int2str(S(indS)), '_S_', int2str(C(indC)), '.datersp'];
                    file_nopain = ['design3_sub', int2str(S(indS)), '_S_', int2str(C(indC+1)), '.datersp'];
                    pain = importdata(file_pain);
                    nopain = importdata(file_nopain);
                    for indE = E
                        fprintf('sub%d start\n', E);
                        tmpname = ['chan', int2str(indE), '_ersp'];
                        
                        if indC == 1
                            tmpstr = ['output.posi(:,:,indE,indS) = pain.', tmpname, '-nopain.', tmpname, ';'];
                        elseif indC == 3
                            tmpstr = ['output.nega(:,:,indE,indS) = pain.', tmpname, '-nopain.', tmpname, ';'];
                        else
                            tmpstr = ['output.neut(:,:,indE,indS) = pain.', tmpname, '-nopain.', tmpname, ';'];
                        end
                        eval(tmpstr);
                    end
                    % save freqs, times
                    if indS == 1 && indC == 1
                        output.f = pain.freqs; output.t = pain.times;
                    end
                end
            end
            %% do not subtract
        case 0
            output.posi_pn = zeros(100, 200, 60, 13);
            output.posi_np = zeros(100, 200, 60, 13);
            output.nega_pn = zeros(100, 200, 60, 13);
            output.nega_np = zeros(100, 200, 60, 13);
            output.neut_pn = zeros(100, 200, 60, 13);
            output.neut_np = zeros(100, 200, 60, 13);
            for indS = 1:length(S)
                fprintf('sub%d start\n', S);
                for indC = 1:length(C)
                    file = ['design3_sub', int2str(S(indS)), '_S_', int2str(C(indC)), '.datersp'];
                    tmpdata = importdata(file);
                    for indE = E
                        fprintf('sub%d start\n', E);
                        tmpname = ['chan', int2str(indE), '_ersp'];
                        if indC == 1
                            tmpstr = ['output.posi_pn(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        elseif indC == 2
                            tmpstr = ['output.posi_np(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        elseif indC == 3
                            tmpstr = ['output.nega_pn(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        elseif indC == 4
                            tmpstr = ['output.nega_np(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        elseif indC == 5
                            tmpstr = ['output.neut_pn(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        else
                            tmpstr = ['output.neut_np(:,:,indE,indS) = tmpdata.', tmpname, ';'];
                        end
                        eval(tmpstr);
                    end
                    % save freqs, times
                    if indS == 1 && indC == 1
                        output.f = tmpdata.freqs; output.t = tmpdata.times;
                    end
                end
            end
    end
catch err
    lix_disperr(err);
end
