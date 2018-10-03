# vim-badapple
这是vim版的badapple

# Basic Usage
```
:BadApple 
:BadApple adjustversion1
:BadApple version1
:BadApple version1extra
:BadApple clearmemory
:BadApple restoregui
```
* `:BadApple`默认表示`:BadApple version1`
* 因为不同的机器的运行速度不同，最好能至少运行两次`:BadApple adjust`开头的命令才能生效

# TODO List
* 用户交互界面的优化
* 修复：播放音乐偶尔会失效
* version1extra的开发（为了解决version1内存占用很大的问题）
* 使用python进行播放数据的统计分析（现采用vimscript进行线性回归分析）
