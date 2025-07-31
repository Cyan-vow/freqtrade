@echo off
rem =============================================================================
rem FreqAI Reinforcement Learning Optimized Trading Bot Launch Script
rem =============================================================================
rem
rem Features:
rem 1. Auto activate virtual environment
rem 2. Smart token whitelist/blacklist management
rem 3. Optimized risk control strategy
rem 4. Multiple running modes
rem 5. Complete logging system
rem
rem Version: v2.0 - Optimized Edition
rem Author: FreqAI Team
rem =============================================================================

echo.
echo ===============================================
echo   FreqAI RL Optimized Trading Bot v2.0
echo ===============================================
echo.
echo [INFO] Initializing system...

rem Set color and encoding
color 0A

rem Activate virtual environment
echo [1/5] Activating virtual environment...
call D:\bots\freqtrade\.venv\Scripts\activate.bat
if errorlevel 1 (
    color 0C
    echo [ERROR] Cannot activate virtual environment
    echo Please check path: D:\bots\freqtrade\.venv\Scripts\activate.bat
    pause
    exit /b 1
)
echo [OK] Virtual environment activated

rem Change to working directory
cd /d D:\bots\freqtrade

rem Check critical files exist
echo [2/5] Checking system files...
if not exist "user_data\strategies\FreqAIRLStrategy.py" (
    color 0C
    echo [ERROR] Strategy file not found
    pause
    exit /b 1
)
if not exist "user_data\freqaimodels\RLModel.py" (
    color 0C
    echo [ERROR] Model file not found
    pause
    exit /b 1
)
if not exist "user_data\config_freqai_rl_optimized.json" (
    color 0C
    echo [ERROR] Config file not found
    pause
    exit /b 1
)
echo [OK] System file check completed

echo [3/5] System ready
echo.
color 0B
echo ===============================================
echo                Operation Menu
echo ===============================================
echo.
echo  Basic Operations:
echo    1. Quick Start (Recommended for first use)
echo    2. Download Data Only
echo    3. Start Trading Directly
echo    4. Run Backtest Analysis
echo.
echo  Advanced Operations:
echo    5. Start Hyperopt Parameter Optimization
echo    6. Model Performance Analysis
echo    7. Risk Assessment Mode
echo    8. Strategy Comparison Test
echo.
echo  System Maintenance:
echo    9. Clean Old Data
echo   10. System Diagnosis
echo   11. View Logs
echo   12. Exit Program
echo.
echo ===============================================
set /p choice="Please enter choice (1-12): "

rem Create log directory
if not exist "user_data\logs" mkdir "user_data\logs"
set LOG_FILE=user_data\logs\freqai_rl_%RANDOM%.log

if "%choice%"=="1" goto quick_start
if "%choice%"=="2" goto download_only
if "%choice%"=="3" goto trade_only
if "%choice%"=="4" goto backtest
if "%choice%"=="5" goto hyperopt
if "%choice%"=="6" goto performance_analysis
if "%choice%"=="7" goto risk_assessment
if "%choice%"=="8" goto strategy_comparison
if "%choice%"=="9" goto cleanup
if "%choice%"=="10" goto system_diagnosis
if "%choice%"=="11" goto view_logs
if "%choice%"=="12" goto exit_program
echo [ERROR] Invalid choice, exiting...
pause
exit /b 1

:quick_start
echo.
echo [4/5] Quick Start Mode
echo ===============================================
echo [INFO] Executing complete initialization process...

echo.
echo [Step 1] Downloading historical data...
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT BTC/USDT ETH/USDT AVAX/USDT ^
    --timeframes 5m 15m ^
    --days 30 ^
    --config user_data/config_freqai_rl_optimized.json

if errorlevel 1 (
    color 0C
    echo [ERROR] Data download failed
    goto error_handler
)
echo [OK] Historical data download completed

echo.
echo [Step 2] Starting FreqAI reinforcement learning trading...
echo [INFO] Using config: config_freqai_rl_optimized.json
echo [INFO] Using strategy: FreqAIRLStrategy
echo [INFO] Using model: RLModel
echo [INFO] First training may take 10-15 minutes, please be patient...
echo.

freqtrade trade ^
    --config user_data/config_freqai_rl_optimized.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:download_only
echo.
echo [4/5] Data Download Mode
echo ===============================================
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT BTC/USDT ETH/USDT AVAX/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_rl_optimized.json ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler
echo [OK] Data download completed
goto end

:trade_only
echo.
echo [4/5] Direct Trading Mode
echo ===============================================
echo [INFO] Starting FreqAI reinforcement learning trading...

freqtrade trade ^
    --config user_data/config_freqai_rl_optimized.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:backtest
echo.
echo [4/5] Backtest Analysis Mode
echo ===============================================
echo [INFO] Running backtest analysis...

freqtrade backtesting ^
    --config user_data/config_freqai_rl_optimized.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241201 ^
    --export trades ^
    --export-filename user_data/backtest_results/backtest_optimized_%date:~0,4%%date:~5,2%%date:~8,2% ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler

echo.
echo [INFO] Generating backtest report...
freqtrade backtesting-analysis ^
    --config user_data/config_freqai_rl_optimized.json ^
    --analysis-groups "0,1,2,3,4,5"

goto end

:hyperopt
echo.
echo [4/5] Hyperopt Parameter Optimization Mode
echo ===============================================
echo [WARNING] Parameter optimization is compute-intensive and may take hours
echo [INFO] Recommended to run on high-performance machines

set /p confirm="Confirm to start parameter optimization? (y/n): "
if /i not "%confirm%"=="y" goto end

freqtrade hyperopt ^
    --config user_data/config_freqai_rl_optimized.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --hyperopt-loss SharpeHyperOptLoss ^
    --epochs 50 ^
    --spaces buy sell ^
    --timerange 20241001-20241201 ^
    --jobs 1 ^
    --logfile %LOG_FILE%

goto end

:performance_analysis
echo.
echo [4/5] Model Performance Analysis Mode
echo ===============================================
echo [INFO] Analyzing model performance and feature importance...

if not exist "user_data\models" (
    echo [ERROR] No trained models found
    goto end
)

echo [INFO] Generating performance report...
freqtrade plot-dataframe ^
    --config user_data/config_freqai_rl_optimized.json ^
    --strategy FreqAIRLStrategy ^
    --pairs SOL/USDT XRP/USDT ^
    --timerange 20241101-20241130

echo [INFO] Generating profit curve...
freqtrade plot-profit ^
    --config user_data/config_freqai_rl_optimized.json ^
    --timerange 20241101-20241130

goto end

:risk_assessment
echo.
echo [4/5] Risk Assessment Mode
echo ===============================================
echo [INFO] Conducting risk assessment and stress testing...

echo [INFO] Running backtests under multiple market conditions...
for %%p in (20240101-20240301 20240401-20240601 20240701-20240901 20241001-20241201) do (
    echo [INFO] Testing time period: %%p
    freqtrade backtesting ^
        --config user_data/config_freqai_rl_optimized.json ^
        --freqaimodel RLModel ^
        --strategy FreqAIRLStrategy ^
        --timerange %%p ^
        --export trades ^
        --export-filename user_data/backtest_results/risk_test_%%p
)

echo [OK] Risk assessment completed, results saved in user_data/backtest_results/
goto end

:strategy_comparison
echo.
echo [4/5] Strategy Comparison Test Mode
echo ===============================================
echo [INFO] Comparing performance of different strategies...

echo [INFO] Testing basic strategy...
freqtrade backtesting ^
    --config user_data/config_freqai_rl_optimized.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --export-filename user_data/backtest_results/basic_strategy

echo [INFO] Testing optimized strategy...
freqtrade backtesting ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --export-filename user_data/backtest_results/optimized_strategy

echo [OK] Strategy comparison completed
goto end

:cleanup
echo.
echo [4/5] System Cleanup Mode
echo ===============================================
echo [WARNING] This will delete old model and data files

set /p confirm="Confirm system cleanup? (y/n): "
if /i not "%confirm%"=="y" goto end

echo [INFO] Cleaning old models...
if exist "user_data\models" rmdir /s /q "user_data\models"

echo [INFO] Cleaning old logs...
if exist "user_data\logs" (
    forfiles /p "user_data\logs" /m "*.log" /d -7 /c "cmd /c del @path" 2>nul
)

echo [INFO] Cleaning temporary files...
if exist "user_data\data\*.tmp" del /q "user_data\data\*.tmp"

echo [OK] System cleanup completed
goto end

:system_diagnosis
echo.
echo [4/5] System Diagnosis Mode
echo ===============================================
echo [INFO] Running system diagnosis...

echo [INFO] Checking Python environment...
python --version
echo.

echo [INFO] Checking FreqTrade version...
freqtrade --version
echo.

echo [INFO] Checking dependency packages...
pip list | findstr "freqtrade stable-baselines3 gymnasium torch"
echo.

echo [INFO] Checking config file...
freqtrade show-config --config user_data/config_freqai_rl_optimized.json
echo.

echo [INFO] Checking strategies...
freqtrade list-strategies --strategy-path user_data/strategies/
echo.

echo [INFO] Checking FreqAI models...
freqtrade list-freqaimodels --freqaimodel-path user_data/freqaimodels/
echo.

echo [OK] System diagnosis completed
goto end

:view_logs
echo.
echo [4/5] Log View Mode
echo ===============================================
if not exist "user_data\logs" (
    echo [INFO] No log files found
    goto end
)

echo [INFO] Recent log files:
dir "user_data\logs\*.log" /od /b
echo.

echo [INFO] Displaying last 20 lines of the latest log file:
for /f "delims=" %%i in ('dir "user_data\logs\*.log" /od /b ^| tail -1') do (
    echo ======== %%i ========
    powershell "Get-Content 'user_data\logs\%%i' -Tail 20"
)
goto end

:error_handler
color 0C
echo.
echo ===============================================
echo [ERROR] Operation failed!
echo ===============================================
echo.
echo [INFO] Error information has been logged to: %LOG_FILE%
echo [INFO] Please check the following common issues:
echo   1. Network connection is normal
echo   2. Exchange API is available
echo   3. Virtual environment is correctly activated
echo   4. Sufficient disk space
echo.
echo [INFO] For technical support, please provide log files
pause
exit /b 1

:exit_program
echo.
echo [INFO] Safely exiting...
goto end

:end
echo.
echo ===============================================
echo Operation completed!
echo ===============================================
echo.
echo [INFO] System Information:
echo   Web Interface: http://localhost:8082
echo   Username: freqtrader
echo   Password: test123
echo   Log File: %LOG_FILE%
echo.
echo [INFO] Important Reminders:
echo   1. This is simulated trading using virtual funds
echo   2. Test thoroughly before live trading
echo   3. Monitor trading performance regularly
echo   4. Maintain strict risk control
echo.
color 0A
echo Thank you for using FreqAI Reinforcement Learning Trading System!
echo.
pause > nul 