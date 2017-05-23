---
title: "mabin time frequency analysis"
author: lixiang
date: 2017-05-21 14:26
---

# 实验设计

被动观看

* 300~500ms +
* 1000ms blank
* 2000ms stimuli: neutral -> 1, negative -> 2
* 6000ms black
* -

# events

S  1 -> neutral
S  2 -> negative

11, neut_k
12, neut_zw
13, neut_qj
21, nega_k
22, nega_zw
23, nega_qj

# 数据整理

`.eeg`
`.vhdr`
`.vmrk`

`s1kan` `s1ziwo` `s1qingjinkan`

# learn to write eeglab script

* `EEG` `ALLEEG` `STUDY`
* `eegh`
* `EEG.history`
* help in eeglab GUI
* source code `edit <function>`
* eeglab directory
* `lookfor <function>`

# pipeline

1. rename event labels
2. merge datasets
3. preprocess (ICA)
4. identify artificial components
5. reject components, interpolate channels, extract datasets based on epochs
6. create study

function output = func_name(arg1, arg2)

% contents
