## tmux install
```
yum -y install tmux
```
tmux 是 C-S 架构，server 可以在本地或其他服务器上。client 连接到 server，建立 session 会话。
每个终端可以建立多个 session，
每个 session 可以包含多个 window（从0开始编号，类似 SecureCRT 中每个连接对应的一个 tab），
一个 window 可以被分割为多个 pane（左右或上下分屏）。
关闭 client 窗口后，session 相关进程会持续在后台 server 上执行。除非关闭 session

## session 
### 创建session
#### 创建一个匿名的 session
```
tmux
```
#### 新建名字为 session_name 的命名 session
```
tmux new -s session_name
```
### 临时退出session
按下 Ctrl+b 命令前缀后，输入 d，会回到终端，此时所有 tmux 客户端相关进程仍在后台运行，d 表示 detach

### 进入已存在的session
```
tmux a -t $session_name
```

### 删除session
#### 删除当前所在 session
```
按下 Ctrl+b 命令前缀后，输入下面命令，注意用冒号开头：
:kill-session
```
#### 删除所有 session
+ tmux中删除
```
如果在 tmux 中，需要按下 Ctrl+b 命令前缀后，输入下面命令，注意用冒号开头：
:kill-server
```
+ tmux外删除

```
tmux kill-server
```
#### 删除指定 session
```
tmux kill-session -t session_name
```

## window
### 创建及切换窗口
按命令前缀 `Ctrl + b` 后，再按 c 键即可创建新窗口（类似新开的 tab 页）
按命令前缀 `Ctrl + b` 后，再按 0-9 数字键即可跳转到对应的窗口

### 关闭窗口
`C-b &` 关闭窗口
## panel
### 创建
#### 水平分屏 - 双引号
启动 tmux 后，按命令前缀 `Ctrl + b` 后，再按一次双引号 `"` 即可将当前屏幕分为上下两块
#### 垂直分屏 - 百分号
启动 tmux 后，按命令前缀 `Ctrl + b` 后，再按一次百分号 `%` 即可将当前屏幕分为左右两块

### 删除panel
启动 tmux 后，按命令前缀 `Ctrl + b` 后，再按一次 x 即可将当前 pane 删除

### 调整 pane 大小
按下命令前缀后，按住`ctrl` 然后用方向键改变分屏大小。注意不要松开 `Ctrl`

### 切换光标
分屏后，通过方向键可以在不同分屏之间切换光标。记得每次切换前仍需要命令前缀 `Ctrl + b`

### 分页查看
`ctrl ＋ｂ + [`

## 查看帮助
按下命令前缀 `Ctrl + b` 后，再按一次 `?` 键，可以查看 tmux 的帮助文档。
`C-b t` //显示时钟
`C-b &` // 确认后退出 tmux

