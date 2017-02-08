# 对连续数据添加 dummy event

eeglab 函数 `EEGout = eeg_regepochs(EEG, 'key', val, ...);`

参数：
`recurrence` 事件之间的间隔，默认为 1 秒；
`limits` 相对于锁时事件的潜伏期，默认为 `[0 recurrence_interval]`
`rmbase` 矫正基线
* `NaN` 不进行基线的矫正
* `0` 以 0 时刻之前的为基线
* `<a value larger than the upper epoch limit>` 整个 epoch 为基线

`eventtype` 事件类型名称
`extractepochs` 是否提取epoch数据（是否分段）
* `on` 进行分段
* `off` 不进行分段，仅仅添加事件

实例

``` matlab
recr = 1;
lmts = [0 1];
rmbs = 999;
evnt = 'close';
extr = 'off';
EEG = eeg_regepochs(EEG, 'recurrence', recr, ...
                         'limits', lmts, ...
                         'rmbase', rmbs, ...
                         'eventtype', evnt, ...
                         'extractepochs', extr);
```

