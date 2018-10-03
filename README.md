# vim-badapple
这是vim版的badapple

# Installation
推荐使用`plug.vim`进行安装，然后直接在插件目录下运行`install.sh`

# Basic Usage
```
:BadApple 
:BadApple adjustversion1
:BadApple version1
:BadApple version1extra
:BadApple clearmemory
:BadApple restoregui
```
* `:BadApple`默认表示`:BadApple version1`，注意这个命令会占用巨大的内存(在不重启vim的情况播放5次能占用将近2G内存)
* 因为不同的机器的运行速度不同，最好能至少运行两次`:BadApple adjustversion1`才能生效
* 有`+python3`支持的vim，才能播放音乐
* `:Badapple version1extra`是优化了内存占用大问题的版本，但可能会有问题，请不要在编辑文件的时候使用这个命令。而且不会生成统计数据，也不会自动调整时间以使得音画同步，如果你的音画不同步，请手动在源代码(autoload/badapple.vim)中修改`sleep 21m`。

# TODO List
* 用户交互界面的优化
* 修复：播放音乐偶尔会失效
* 使用python进行播放数据的统计分析(现采用vimscript进行线性回归分析)
