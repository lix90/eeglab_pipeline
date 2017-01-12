function mkdir_p(output_dir)

if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end
