#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
FRPS_PATH_FILE="$SCRIPT_DIR/.frps_path"
FRPS_CONFIG_PATH_FILE="$SCRIPT_DIR/.frps_config_path"
LAST_CHOICE_FILE="$SCRIPT_DIR/.last_frps_config_choice"
LOG_DIR="$SCRIPT_DIR/log"
mkdir -p $LOG_DIR
TODAY=$(date +%Y-%m-%d)
LOG_FILE="$LOG_DIR/$TODAY.log"

# Functions to find and set frps binary and configuration paths

function find_frps {
    which frps || find "$SCRIPT_DIR" -type f -name "frps" | head -n 1
}

function find_frps_config {
    find "$SCRIPT_DIR" -type f -name "frps.ini"
}

function set_paths {
    FRPS_BIN=$(<"$FRPS_PATH_FILE" 2>/dev/null)
    FRPS_CONFIG=$(<"$FRPS_CONFIG_PATH_FILE" 2>/dev/null)

    if [[ ! -x $FRPS_BIN ]]; then
        FRPS_BIN=$(find_frps)
        echo $FRPS_BIN > "$FRPS_PATH_FILE"
    fi

    if [[ ! -f $FRPS_CONFIG ]]; then
        local configs=($(find_frps_config))
        local count=${#configs[@]}

        case $count in
            0)
                read -p "未找到frps.ini，请提供frps.ini的完整路径/Couldn't find frps.ini, please provide the full path to frps.ini: " FRPS_CONFIG
                ;;
            1)
                FRPS_CONFIG=${configs[0]}
                ;;
            *)
                echo "找到多个frps.ini文件，请选择一个/Found multiple frps.ini files, please choose one:"
                for i in "${!configs[@]}"; do
                    echo "$((i+1)) - ${configs[$i]}"
                done
                read -p "请选择一个操作/Please select an operation: " choice
                FRPS_CONFIG=${configs[$((choice-1))]}
                ;;
        esac
        echo $FRPS_CONFIG > "$FRPS_CONFIG_PATH_FILE"
    fi
}

# Core functions for frps actions, log display, and configuration reset

function frps_action {
    case $1 in
        start)   nohup $FRPS_BIN -c $FRPS_CONFIG >> $LOG_FILE 2>&1 & ;;
        stop)    killall frps ;;
        restart) frps_action stop; frps_action start ;;
        check)   pgrep -x frps &>/dev/null && echo "frps正在运行/frps is running." || echo "frps未运行/frps is not running." ;;
    esac
}

function set_config {
    [[ -f "$SCRIPT_DIR/frpsConfig.sh" ]] && bash "$SCRIPT_DIR/frpsConfig.sh" || echo "未找到frpsConfig.sh脚本，请确保它位于 $SCRIPT_DIR 下/Cannot find frpsConfig.sh script, please ensure it's under $SCRIPT_DIR."
}

function reset_paths {
    rm -f "$FRPS_CONFIG_PATH_FILE" "$FRPS_PATH_FILE"
    set_paths
    echo "frps路径和配置路径都已重置/frps and configuration paths have been reset."
}

function display_log {
    tail -f $LOG_FILE
}

function display_manual {
    echo "
Usage: $(basename $0) [COMMAND]

Available commands:
    start      启动frps | Start frps
    stop       停止frps | Stop frps
    restart    重启frps | Restart frps
    check      检查frps进程 | Check frps process
    setConfig  设置frps配置 | Set frps configuration
    log        实时显示frps日志 | Display frps log in real-time
    resetPath  重置frps和配置路径 | Reset frps and configuration paths
    man        显示此功能手册 | Display this manual

Examples:
    $(basename $0) start     启动frps | Start frps
    $(basename $0) setConfig 设置frps配置 | Set frps configuration
    "
}

# User interface functions for menu and command-line actions

function display_menu {
    echo "1 - 启动frps Start frps"
    echo "2 - 停止frps Stop frps"
    echo "3 - 重启frps Restart frps"
    echo "4 - 检查frps进程 Check frps process"
    echo "5 - 设置frps配置 Set frps configuration"
    echo "6 - 实时显示frps日志 Display frps log in real-time"
    echo "7 - 重置frps和配置路径 Reset frps and configuration paths"
    echo "0 - 退出 Exit"
    read -p "请选择一个操作: Please select an operation: " choice

    case $choice in
        1) frps_action start ;;
        2) frps_action stop ;;
        3) frps_action restart ;;
        4) frps_action check ;;
        5) set_config ;;
        6) display_log ;;
        7) reset_paths ;;
        0) exit 0 ;;
        *) echo "无效的选择/Invalid choice." ;;
    esac
}

function command_line_action {
    case $1 in
        start)      frps_action start ;;
        stop)       frps_action stop ;;
        restart)    frps_action restart ;;
        check)      frps_action check ;;
        setConfig)  set_config ;;
        log)        display_log ;;
        resetPath)  reset_paths ;;
        man)        display_manual ;;
        *)          echo "无效的参数/Invalid argument: $1"; exit 1 ;;
    esac
}

# Execution starts here

set_paths

[[ -z $1 ]] && display_menu || command_line_action $1
