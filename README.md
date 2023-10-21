# README

## Description
This Bash script is designed to manage the frps (Fast Reverse Proxy Server) service on a Linux system. It provides functionality to start, stop, restart, and check the status of frps, as well as set configurations and view logs in real-time.

## Installation
1. Download the script to your Linux system.
2. Ensure that the script is executable: `chmod +x script-name.sh`
3. Place the frps binary and frps configuration file (frps.toml) in the same directory as the script, or ensure they are in your system’s PATH.

## Usage
You can run the script in two modes: interactive menu mode and command-line mode.

### Interactive Menu Mode
Run the script without any arguments:
```bash
./script-name.sh
```
This will display a menu with options to manage frps. Follow the on-screen prompts to select an option.

### Command-Line Mode
Run the script with a command as an argument:
```bash
./script-name.sh [COMMAND]
```

Available commands:
- `start`: Start frps
- `stop`: Stop frps
- `restart`: Restart frps
- `check`: Check frps process
- `setConfig`: Set frps configuration
- `log`: Display frps log in real-time
- `resetPath`: Reset frps and configuration paths
- `man`: Display the manual

## Configuration
The script will attempt to find the frps binary and configuration file automatically. If it cannot find them, it will prompt you to enter the paths manually.

If you want to configure frps, ensure that a configuration script named `frpsConfig.sh` is present in the same directory as the main script. The `setConfig` command will execute this script.

## Logs
The script logs its activity to a file named with the current date in a `log` directory inside the script’s directory. You can view the logs in real-time using the `log` command.

---

# 说明

## 描述
这个Bash脚本是为了在Linux系统上管理frps（Fast Reverse Proxy Server）服务而设计的。它提供了启动、停止、重启frps，以及设置配置和实时查看日志的功能。

## 安装
1. 将脚本下载到您的Linux系统上。
2. 确保脚本是可执行的：`chmod +x script-name.sh`
3. 将frps二进制文件和frps配置文件（frps.toml）放在脚本的同一目录下，或确保它们在系统的PATH中。

## 使用
您可以在两种模式下运行脚本：交互式菜单模式和命令行模式。

### 交互式菜单模式
无参数运行脚本：
```bash
./script-name.sh
```
这将显示一个菜单，其中有选项来管理frps。按照屏幕上的提示选择一个选项。

### 命令行模式
带命令作为参数运行脚本：
```bash
./script-name.sh [COMMAND]
```

可用命令：
- `start`: 启动frps
- `stop`: 停止frps
- `restart`: 重启frps
- `check`: 检查frps进程
- `setConfig`: 设置frps配置
- `log`: 实时显示frps日志
- `resetPath`: 重置frps和配置路径
- `man`: 显示功能手册

## 配置
脚本将尝试自动查找frps二进制文件和配置文件。如果找不到，它将提示您手动输入路径。

如果您想要配置frps，请确保在主脚本的同一目录下有一个名为`frpsConfig.sh`的配置脚本。`setConfig`命令将执行这个脚本。

## 日志
脚本将其活动记录到脚本目录内的`log`目录中，文件名为当前日期。您可以使用`log`命令实时查看日志。
