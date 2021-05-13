# vim-badapple
vim版badapple

# Installation
推荐使用`plug.vim`进行安装，然后直接在插件目录下运行`install.sh`

# Basic Usage
```
:ZBadApple 
:ZBadApple adjustversion1
:ZBadApple version1
:ZBadApple version1extra
:ZBadApple clearmemory
:ZBadApple restoregui
```
* `:ZBadApple`默认表示`:ZBadApple version1`，注意这个命令会占用巨大的内存(在不重启vim的情况播放5次能占用将近2G内存)
* 因为不同的机器的运行速度不同，最好能至少运行两次`:ZBadApple adjustversion1`才能生效
* 有`+python3`支持的vim，才能播放音乐
* `:ZBadapple version1extra`是优化了内存占用大问题的版本，但可能会有问题，请不要在编辑文件的时候使用这个命令。而且不会生成统计数据，也不会自动调整时间以使得音画同步，如果你的音画不同步，请手动在源代码(autoload/badapple.vim)中修改`sleep 21m`。

# TODO
- [ ] Create a file format for ascii art video and encoding/decoding program.
