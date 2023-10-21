#!/bin/bash

# Define constants
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"
SAVE_FILE="$SCRIPT_DIR/.frpsSetSave"
LOG_DIR="$SCRIPT_DIR/log"
LOG_FILE="$LOG_DIR/$(date +%Y-%m-%d).log"

# --------------------- Utility Functions ---------------------
function log {
    echo "-------- $(date) -------- $1 --------" >> $LOG_FILE
}

function find_frps {
    which frps 2>/dev/null || find "$SCRIPT_DIR" -type f -name "frps" 2>/dev/null
}

function find_frps_config {
    find "$SCRIPT_DIR" -type f -name "frps.toml" 2>/dev/null
}

function save_to_file {
    echo "FRPS_BIN=$1" > $SAVE_FILE
    echo "FRPS_CONFIG=$2" >> $SAVE_FILE
}

function load_from_file {
    if [[ -f $SAVE_FILE ]]; then
        source $SAVE_FILE
    fi
}

# --------------------- Core Functions ---------------------
function frps_action {
    case $1 in
        start)
            log "FRPS STARTED"
            nohup $FRPS_BIN -c $FRPS_CONFIG >> $LOG_FILE 2>&1 &
            sleep 2
            frps_action check
            ;;
        stop)
            log "FRPS STOPPED"
            pkill -x frps
            sleep 2
            frps_action check
            ;;
        restart)
            frps_action stop
            frps_action start
            ;;
        check)
            pgrep -x frps &>/dev/null && echo "frps正在运行/frps is running." || echo "frps未运行/frps is not running."
            ;;
    esac
}

function set_config {
    [[ -f "$SCRIPT_DIR/frpsConfig.sh" ]] && bash "$SCRIPT_DIR/frpsConfig.sh" || echo "未找到frpsConfig.sh脚本，请确保它位于 $SCRIPT_DIR 下/Cannot find frpsConfig.sh script, please ensure it's under $SCRIPT_DIR."
}

function reset_paths {
    rm -f "$SAVE_FILE"
    unset FRPS_BIN FRPS_CONFIG
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
    "
}

function display_menu {
    echo "当前使用的frps路径/Current frps path: $FRPS_BIN"
    echo "当前使用的frps配置文件路径/Current frps config file path: $FRPS_CONFIG"
    echo "----------------------------------------------"
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

function set_paths {
    load_from_file

    if [[ -z $FRPS_BIN || ! -x $FRPS_BIN ]]; then
        local frps_binaries=($(find_frps))
        case ${#frps_binaries[@]} in
            0)
                read -p "未找到frps，请提供frps的完整路径/Couldn't find frps, please provide the full path to frps: " FRPS_BIN
                ;;
            1)
                FRPS_BIN=${frps_binaries[0]}
                ;;
            *)
                echo "找到多个frps，请选择一个/Found multiple frps, please choose one:"
                select choice in "${frps_binaries[@]}"; do
                    FRPS_BIN=$choice
                    break
                done
                ;;
        esac
    fi

    if [[ -z $FRPS_CONFIG || ! -f $FRPS_CONFIG ]]; then
        local configs=($(find_frps_config))
        case ${#configs[@]} in
            0)
                read -p "未找到frps配置，请提供frps配置的完整路径/Couldn't find frps configuration, please provide the full path to the configuration: " FRPS_CONFIG
                ;;
            1)
                FRPS_CONFIG=${configs[0]}
                ;;
            *)
                echo "找到多个frps配置文件，请选择一个/Found multiple frps configuration files, please choose one:"
                select choice in "${configs[@]}"; do
                    FRPS_CONFIG=$choice
                    break
                done
                ;;
        esac
    fi

    save_to_file $FRPS_BIN $FRPS_CONFIG
}

# Execution starts here
set_paths
[[ -z $1 ]] && display_menu || command_line_action $1
