@echo off
rem =============================================================================
rem FreqAI强化学习交易机器人启动脚本
rem =============================================================================
rem 
rem 功能说明:
rem 1. 自动激活虚拟环境
rem 2. 下载必要的历史数据
rem 3. 启动FreqAI强化学习训练和交易
rem 
rem 使用方法:
rem 1. 双击运行此脚本
rem 2. 根据提示选择操作模式
rem 
rem 作者: FreqAI Team
rem =============================================================================

echo.
echo ===============================================
echo    FreqAI强化学习交易机器人启动脚本
echo ===============================================
echo.

rem 激活虚拟环境
echo [1/4] 正在激活虚拟环境...
call D:\bots\freqtrade\.venv\Scripts\activate.bat
if errorlevel 1 (
    echo 错误: 无法激活虚拟环境
    pause
    exit /b 1
)
echo ✓ 虚拟环境已激活

rem 切换到工作目录
cd /d D:\bots\freqtrade

echo.
echo 请选择操作模式:
echo 1. 下载数据 + 训练模型 + 开始交易 (推荐首次使用)
echo 2. 仅下载数据
echo 3. 直接开始交易 (需要已有训练数据)
echo 4. 运行回测分析
echo 5. 启动Hyperopt参数优化
echo.
set /p choice="请输入选择 (1-5): "

if "%choice%"=="1" goto full_process
if "%choice%"=="2" goto download_only
if "%choice%"=="3" goto trade_only
if "%choice%"=="4" goto backtest
if "%choice%"=="5" goto hyperopt
echo 无效选择，退出...
pause
exit /b 1

:full_process
echo.
echo [2/4] 正在下载历史数据...
freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT SOL/USDT MATIC/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_rl.json
if errorlevel 1 (
    echo 错误: 数据下载失败
    pause
    exit /b 1
)
echo ✓ 历史数据下载完成

echo.
echo [3/4] 正在启动FreqAI强化学习训练和交易...
echo 注意: 首次训练可能需要较长时间，请耐心等待...
echo.
freqtrade trade ^
    --config user_data/config_freqai_rl.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run
goto end

:download_only
echo.
echo [2/4] 正在下载历史数据...
freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT SOL/USDT MATIC/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_rl.json
echo ✓ 历史数据下载完成
goto end

:trade_only
echo.
echo [2/4] 正在启动FreqAI强化学习交易...
freqtrade trade ^
    --config user_data/config_freqai_rl.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run
goto end

:backtest
echo.
echo [2/4] 正在运行回测分析...
freqtrade backtesting ^
    --config user_data/config_freqai_rl.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241201
goto end

:hyperopt
echo.
echo [2/4] 正在启动Hyperopt参数优化...
echo 注意: 参数优化可能需要很长时间...
freqtrade hyperopt ^
    --config user_data/config_freqai_rl.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --hyperopt-loss SharpeHyperOptLoss ^
    --epochs 50 ^
    --spaces buy sell ^
    --timerange 20241001-20241201
goto end

:end
echo.
echo ===============================================
echo 操作完成！
echo.
echo Web界面访问地址: http://localhost:8080
echo 用户名: freqtrader
echo 密码: password123
echo.
echo 按任意键退出...
pause > nul 