@echo off
setlocal enabledelayedexpansion
rem =============================================================================
rem FreqAI强化学习交易机器人启动脚本 - 完全中文版
rem =============================================================================
rem
rem 功能说明:
rem 1. 自动激活虚拟环境
rem 2. 使用验证过的配置和模型
rem 3. 多种运行模式选择
rem 4. 完整的日志记录
rem 5. 完全中文界面
rem
rem 版本: v4.0 - 完全中文版
rem 作者: FreqAI Team
rem =============================================================================

echo.
echo ===============================================
echo   FreqAI强化学习交易机器人 v4.0 中文版
echo ===============================================
echo.
echo 信息: 正在初始化系统...

rem 设置中文编码
chcp 936 >nul 2>&1
color 0A

rem 激活虚拟环境
echo.
echo 步骤 1/5: 正在激活虚拟环境...
call D:\bots\freqtrade\.venv\Scripts\activate.bat
if errorlevel 1 (
    color 0C
    echo.
    echo 错误: 无法激活虚拟环境
    echo 请检查路径: D:\bots\freqtrade\.venv\Scripts\activate.bat
    echo.
    pause
    exit /b 1
)
echo 成功: 虚拟环境已激活

rem 切换到工作目录
cd /d D:\bots\freqtrade

rem 检查关键文件是否存在
echo.
echo 步骤 2/5: 正在检查系统文件...
if not exist "user_data\strategies\FreqAIRLStrategy.py" (
    color 0C
    echo 错误: 找不到策略文件
    pause
    exit /b 1
)
if not exist "user_data\freqaimodels\RLModel.py" (
    color 0C
    echo 错误: 找不到模型文件
    pause
    exit /b 1
)
if not exist "user_data\config_freqai_minimal.json" (
    color 0C
    echo 错误: 找不到最小配置文件
    pause
    exit /b 1
)
echo 成功: 系统文件检查完成

echo.
echo 步骤 3/5: 系统准备就绪
echo.
color 0B
echo ===============================================
echo                 操作菜单
echo ===============================================
echo.
echo  推荐选项 (稳定):
echo    1. 快速启动 (最小配置 - 推荐)
echo    2. 简单配置启动
echo    3. 仅下载数据
echo    4. 运行回测分析
echo.
echo  高级选项:
echo    5. Hyperopt参数优化
echo    6. 查看系统状态
echo    7. 查看日志
echo    8. 清理系统
echo.
echo  系统维护:
echo    9. 系统诊断
echo   10. 启动Web界面 (独立)
echo   11. 退出程序
echo.
echo ===============================================
set /p choice="请输入选择 (1-11): "

rem 创建日志目录
if not exist "user_data\logs" mkdir "user_data\logs"
set LOG_FILE=user_data\logs\freqai_chinese_%RANDOM%.log

if "%choice%"=="1" goto minimal_start
if "%choice%"=="2" goto simple_start
if "%choice%"=="3" goto download_only
if "%choice%"=="4" goto backtest
if "%choice%"=="5" goto hyperopt
if "%choice%"=="6" goto system_status
if "%choice%"=="7" goto view_logs
if "%choice%"=="8" goto cleanup
if "%choice%"=="9" goto system_diagnosis
if "%choice%"=="10" goto web_only
if "%choice%"=="11" goto exit_program
echo 错误: 无效选择，退出...
pause
exit /b 1

:minimal_start
echo.
echo 步骤 4/5: 最小配置启动模式
echo ===============================================
echo 信息: 使用最稳定的最小配置启动...
echo 信息: 交易对: SOL/USDT, XRP/USDT, ADA/USDT
echo 信息: 模式: 模拟交易 (虚拟资金 $10,000)
echo 信息: Web界面: http://localhost:8082
echo 信息: 登录: freqtrader / test123

echo.
echo 子步骤1: 检查并下载必要数据...
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT ^
    --timeframes 5m ^
    --days 30 ^
    --config user_data/config_freqai_minimal.json

if errorlevel 1 (
    color 0C
    echo 错误: 数据下载失败
    goto error_handler
)
echo 成功: 数据下载完成

echo.
echo 子步骤2: 启动FreqAI强化学习交易系统...
echo 信息: 首次AI模型训练可能需要5-10分钟，请耐心等待...
echo.

freqtrade trade ^
    --config user_data/config_freqai_minimal.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:simple_start
echo.
echo 步骤 4/5: 简单配置启动模式
echo ===============================================
echo 信息: 使用简单配置启动 (6个交易对)...

freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT SOL/USDT XRP/USDT ADA/USDT AVAX/USDT ^
    --timeframes 5m 15m ^
    --days 30 ^
    --config user_data/config_freqai_rl_simple.json

if errorlevel 1 goto error_handler

echo 信息: 启动交易系统...
freqtrade trade ^
    --config user_data/config_freqai_rl_simple.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:download_only
echo.
echo 步骤 4/5: 数据下载模式
echo ===============================================
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT BTC/USDT ETH/USDT AVAX/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_minimal.json ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler
echo 成功: 数据下载完成
goto end

:backtest
echo.
echo 步骤 4/5: 回测分析模式
echo ===============================================
echo 信息: 正在运行回测分析...

freqtrade backtesting ^
    --config user_data/config_freqai_minimal.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --export-filename user_data/backtest_results/backtest_minimal_%date:~0,4%%date:~5,2%%date:~8,2% ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler
echo 成功: 回测完成
goto end

:hyperopt
echo.
echo 步骤 4/5: Hyperopt参数优化模式
echo ===============================================
echo 警告: 参数优化是计算密集型任务，可能需要数小时

set /p confirm="确认开始参数优化? (y/n): "
if /i not "%confirm%"=="y" goto end

freqtrade hyperopt ^
    --config user_data/config_freqai_minimal.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --hyperopt-loss SharpeHyperOptLoss ^
    --epochs 50 ^
    --spaces buy sell ^
    --timerange 20241001-20241130 ^
    --jobs 1 ^
    --logfile %LOG_FILE%

goto end

:system_status
echo.
echo 步骤 4/5: 系统状态检查
echo ===============================================
echo 信息: 检查运行中的进程...
tasklist | findstr python.exe
echo.
echo 信息: 检查端口使用情况...
netstat -an | findstr ":808"
echo.
echo 信息: 检查最新日志...
if exist "user_data\logs\*.log" (
    for /f %%i in ('dir "user_data\logs\*.log" /od /b 2^>nul') do (
        set LATEST_LOG=%%i
    )
    if defined LATEST_LOG (
        echo 最新日志文件: !LATEST_LOG!
        echo 最后几行内容:
        tail -5 "user_data\logs\!LATEST_LOG!" 2>nul
    )
) else (
    echo 没有找到日志文件
)
goto end

:view_logs
echo.
echo 步骤 4/5: 日志查看模式
echo ===============================================
if not exist "user_data\logs" (
    echo 信息: 没有找到日志文件
    goto end
)

echo 信息: 最近的日志文件:
dir "user_data\logs\*.log" /od /b 2>nul
echo.

echo 信息: 显示最新日志文件的最后20行:
for /f %%i in ('dir "user_data\logs\*.log" /od /b 2^>nul') do (
    set LATEST_LOG=%%i
)
if defined LATEST_LOG (
    echo ======== !LATEST_LOG! ========
    tail -20 "user_data\logs\!LATEST_LOG!" 2>nul
)
goto end

:cleanup
echo.
echo 步骤 4/5: 系统清理模式
echo ===============================================
echo 警告: 这将删除旧的模型和临时文件

set /p confirm="确认清理系统? (y/n): "
if /i not "%confirm%"=="y" goto end

echo 信息: 清理旧模型...
if exist "user_data\models" rmdir /s /q "user_data\models"

echo 信息: 清理旧日志 (保留最近7天)...
if exist "user_data\logs" (
    forfiles /p "user_data\logs" /m "*.log" /d -7 /c "cmd /c del @path" 2>nul
)

echo 信息: 清理临时文件...
if exist "user_data\data\*.tmp" del /q "user_data\data\*.tmp"

echo 成功: 系统清理完成
goto end

:system_diagnosis
echo.
echo 步骤 4/5: 系统诊断模式
echo ===============================================
echo 信息: 运行完整系统诊断...

echo.
echo 检查1: Python环境...
python --version
echo.

echo 检查2: FreqTrade版本...
freqtrade --version
echo.

echo 检查3: 关键依赖包...
echo 正在检查依赖包...
pip list | findstr "freqtrade" >nul 2>&1
if errorlevel 1 (
    echo 错误: FreqTrade未安装
) else (
    echo 成功: FreqTrade已安装
)

pip list | findstr "stable-baselines3" >nul 2>&1
if errorlevel 1 (
    echo 错误: stable-baselines3未安装
) else (
    echo 成功: stable-baselines3已安装
)

echo.
echo 检查4: 配置文件验证...
freqtrade show-config --config user_data/config_freqai_minimal.json >nul 2>&1
if errorlevel 1 (
    echo 错误: 配置文件有问题
) else (
    echo 成功: 配置文件正常
)

echo.
echo 检查5: 策略文件...
freqtrade list-strategies --strategy-path user_data/strategies/ | findstr FreqAIRLStrategy >nul 2>&1
if errorlevel 1 (
    echo 错误: 策略文件有问题
) else (
    echo 成功: 策略文件正常
)

echo.
echo 检查6: FreqAI模型...
freqtrade list-freqaimodels --freqaimodel-path user_data/freqaimodels/ | findstr RLModel >nul 2>&1
if errorlevel 1 (
    echo 错误: 模型文件有问题
) else (
    echo 成功: 模型文件正常
)

echo.
echo 成功: 系统诊断完成
goto end

:web_only
echo.
echo 步骤 4/5: 独立Web界面模式
echo ===============================================
echo 信息: 启动独立的Web服务器...

freqtrade webserver ^
    --config user_data/config_freqai_minimal.json ^
    --logfile %LOG_FILE%

goto end

:error_handler
color 0C
echo.
echo ===============================================
echo 错误: 操作失败！
echo ===============================================
echo.
echo 信息: 错误信息已记录到日志文件: %LOG_FILE%
echo 信息: 请检查以下常见问题:
echo   1. 网络连接是否正常
echo   2. 虚拟环境是否正确激活
echo   3. 磁盘空间是否充足
echo   4. 端口是否被占用
echo.
echo 信息: 如需技术支持，请提供日志文件
pause
exit /b 1

:exit_program
echo.
echo 信息: 正在安全退出...
goto end

:end
echo.
echo ===============================================
echo 操作完成！
echo ===============================================
echo.
echo 信息: 系统信息:
echo   最小配置Web界面: http://localhost:8082 (freqtrader/test123)
echo   简单配置Web界面: http://localhost:8081 (freqtrader/password123)
echo   日志文件: %LOG_FILE%
echo.
echo 信息: 重要提醒:
echo   1. 这是模拟交易，使用虚拟资金
echo   2. 实盘交易前请充分测试
echo   3. 定期检查交易表现
echo   4. 注意风险控制
echo.
color 0A
echo 感谢使用 FreqAI 强化学习交易系统！
echo.
pause 