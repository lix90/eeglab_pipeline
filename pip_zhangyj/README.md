# 基本介绍

请将该分析脚本所在的路径和其子路径添加至搜索路径中。

``` matlab
addpath(genpath(pwd));
savepath;
```

- `./dependencies/` 该路径下是分析脚本依赖的函数和文件。
- `zhangjy_ica.m` 用于对数据进行初步的预处理（注意，进行ICA的数据需要1Hz高通滤波）然后进行独立成分分析，计算得到两个矩阵：ICA weights matrices 和 sphere matrices。这两个矩阵可以应用到同一批数据中，无需重复进行独立成分分解。
- `zhangjy_epoch.m` 用于对数据进行预处理并将 `zhangyj_ica.m` 计算所得到的数据应用到未进行 1Hz 高通滤波的数据中。然后手动标记眨眼（垂直眼动）和眼睛横移（水平
  眼动）的伪迹。

---

读取错误反应代码

``` matlab
fname = '/path/to/fname.txt'
stims = {'fu', 'zhong', 'zheng'};
format_spec = '%s %s';

fid = fopen(fname);
txt = textscan(fid, format_spec);  % Cell string array
ind_stim = ismember(txt{1}, stims);

ls_stim = txt{1}(ind_stim);
ls_accs = str2double(txt{2}(ind_stim));
```

dsfadfafa
dsafdaf

    dafadf daf
