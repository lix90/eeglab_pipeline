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

# pipeline

1. rename event labels
2. merge datasets
3. preprocess (ICA)
4. identify artificial components
5. reject components, interpolate channels, extract datasets based on epochs
6. create study

# learn matlab

* 使用搜索引擎：英文选google，中文选搜狗
* 学习google检索技巧：`site:` `inlink:` `intitle:` `""` `filetype:` ...
* 掌握matlab帮助和文档查询：`doc` `help` `docsearch` `lookfor`
* 在matlab命令行中测试和调试代码：在错误和反馈中学习
* 掌握一个编辑器写代码和做笔记：Sublime Text或Atom

# learn EEGLAB

* variables: `EEG` `ALLEEG` `STUDY`
* `eegh`
* `EEG.history`
* `lookfor <function>`
* read source code `edit <function>`
* click help in eeglab GUI
* see eeglab directory

# learn EEG data analysis

* 擅用英文搜索引擎：中文互联网脑电相关靠谱信息太少
* 熟悉一门编程语言：matlab or python
* 了解一点信号处理知识：信号、噪音、滤波器、功率谱、傅立叶变换、小波变换、主成分分析、独立成分分析等
* 整理数据、记录过程
* 用肉眼观察数据：时域（波形图）＋频域（功率谱）＋空间（通道地形图）
* 根据数据情况选择合适的分析策略

# Learn everything

* 科学上网（翻墙）＋搜索引擎（谷歌、DuckDuckGo、搜狗、必应等）
* 先了解领域总体框架，知道有什么，从哪儿获取靠谱的学习资料
* 明确需求，根据具体需求，选择学习的具体内容
* 习惯边做边学，边学边做
