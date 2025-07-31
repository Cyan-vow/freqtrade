@echo off
rem =============================================================================
rem FreqAI Reinforcement Learning Trading Bot - Simple Chinese Version
rem =============================================================================

echo.
echo ===============================================
echo   FreqAI RL Trading Bot v4.0 Simple
echo ===============================================
echo.
echo Step 1/3: Activating virtual environment...

call D:\bots\freqtrade\.venv\Scripts\activate.bat
if errorlevel 1 (
    echo ERROR: Cannot activate virtual environment
    pause
    exit /b 1
)
echo SUCCESS: Virtual environment activated

cd /d D:\bots\freqtrade

echo.
echo Step 2/3: Checking system files...
if not exist "user_data\strategies\FreqAIRLStrategy.py" (
    echo ERROR: Strategy file not found
    pause
    exit /b 1
)
if not exist "user_data\freqaimodels\RLModel.py" (
    echo ERROR: Model file not found
    pause
    exit /b 1
)
if not exist "user_data\config_freqai_minimal.json" (
    echo ERROR: Config file not found
    pause
    exit /b 1
)
echo SUCCESS: System files OK

echo.
echo Step 3/3: Ready to start
echo.
echo ===============================================
echo                Main Menu
echo ===============================================
echo.
echo  1. Quick Start (Minimal Config - Recommended)
echo  2. Simple Config Start (6 pairs)
echo  3. Download Data Only
echo  4. Run Backtest
echo  5. System Diagnosis
echo  6. Exit
echo.
echo ===============================================
set /p choice="Please enter choice (1-6): "

if not exist "user_data\logs" mkdir "user_data\logs"
set LOG_FILE=user_data\logs\freqai_simple_%RANDOM%.log

if "%choice%"=="1" goto minimal_start
if "%choice%"=="2" goto simple_start
if "%choice%"=="3" goto download_only
if "%choice%"=="4" goto backtest
if "%choice%"=="5" goto diagnosis
if "%choice%"=="6" goto exit_program
echo ERROR: Invalid choice
pause
exit /b 1

:minimal_start
echo.
echo Starting Minimal Configuration Mode...
echo Trading Pairs: SOL/USDT, XRP/USDT, ADA/USDT
echo Mode: Dry Run (Virtual $10,000)
echo Web Interface: http://localhost:8082
echo Login: freqtrader / test123
echo.

echo Downloading required data...
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT ^
    --timeframes 5m ^
    --days 30 ^
    --config user_data/config_freqai_minimal.json

if errorlevel 1 (
    echo ERROR: Data download failed
    pause
    exit /b 1
)
echo SUCCESS: Data download completed

echo.
echo Starting FreqAI RL Trading System...
echo NOTE: First AI training may take 5-10 minutes
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
echo Starting Simple Configuration Mode...
echo Trading Pairs: 6 major pairs
echo.

freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT SOL/USDT XRP/USDT ADA/USDT AVAX/USDT ^
    --timeframes 5m 15m ^
    --days 30 ^
    --config user_data/config_freqai_rl_simple.json

if errorlevel 1 (
    echo ERROR: Data download failed
    pause
    exit /b 1
)

echo Starting trading system...
freqtrade trade ^
    --config user_data/config_freqai_rl_simple.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:download_only
echo.
echo Data Download Mode...
freqtrade download-data ^
    --exchange binance ^
    --pairs SOL/USDT XRP/USDT ADA/USDT BTC/USDT ETH/USDT AVAX/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_minimal.json ^
    --logfile %LOG_FILE%

if errorlevel 1 (
    echo ERROR: Data download failed
    pause
    exit /b 1
)
echo SUCCESS: Data download completed
goto end

:backtest
echo.
echo Backtest Analysis Mode...
freqtrade backtesting ^
    --config user_data/config_freqai_minimal.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --logfile %LOG_FILE%

if errorlevel 1 (
    echo ERROR: Backtest failed
    pause
    exit /b 1
)
echo SUCCESS: Backtest completed
goto end

:diagnosis
echo.
echo System Diagnosis...
echo.
echo Checking Python...
python --version
echo.
echo Checking FreqTrade...
freqtrade --version
echo.
echo Checking Config...
freqtrade show-config --config user_data/config_freqai_minimal.json >nul 2>&1
if errorlevel 1 (
    echo ERROR: Config file has issues
) else (
    echo SUCCESS: Config file OK
)
echo.
echo Checking Strategy...
freqtrade list-strategies --strategy-path user_data/strategies/ | findstr FreqAIRLStrategy >nul 2>&1
if errorlevel 1 (
    echo ERROR: Strategy file has issues
) else (
    echo SUCCESS: Strategy file OK
)
echo.
echo Checking Model...
freqtrade list-freqaimodels --freqaimodel-path user_data/freqaimodels/ | findstr RLModel >nul 2>&1
if errorlevel 1 (
    echo ERROR: Model file has issues
) else (
    echo SUCCESS: Model file OK
)
echo.
echo System diagnosis completed
goto end

:exit_program
echo.
echo Exiting safely...
goto end

:end
echo.
echo ===============================================
echo Operation Completed!
echo ===============================================
echo.
echo System Info:
echo   Minimal Config Web: http://localhost:8082 (freqtrader/test123)
echo   Simple Config Web: http://localhost:8081 (freqtrader/password123)
echo   Log File: %LOG_FILE%
echo.
echo Important Notes:
echo   1. This is simulated trading with virtual funds
echo   2. Test thoroughly before live trading
echo   3. Monitor performance regularly
echo   4. Maintain risk control
echo.
echo Thank you for using FreqAI RL Trading System!
echo.
pause 