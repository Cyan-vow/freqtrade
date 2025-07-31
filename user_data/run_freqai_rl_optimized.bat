@echo off
rem =============================================================================
rem FreqAI强化学习优化版交易机器人启动脚本
rem =============================================================================
rem
rem 功能说明:
rem 1. 自动激活虚拟环境
rem 2. 智能代币白名单管理
rem 3. 优化的风险控制策略
rem 4. 多种运行模式选择
rem 5. 完整的日志记录
rem
rem 版本: v2.0 - 优化版
rem 作者: FreqAI Team
rem =============================================================================

echo.
echo ===============================================
echo   FreqAI强化学习优化版交易机器人 v2.0
echo ===============================================
echo.
echo [INFO] 初始化系统...

rem 设置颜色和编码
chcp 65001 >nul
color 0A

rem 激活虚拟环境
echo [1/5] 正在激活虚拟环境...
call D:\bots\freqtrade\.venv\Scripts\activate.bat
if errorlevel 1 (
    color 0C
    echo [ERROR] 无法激活虚拟环境
    echo 请检查路径: D:\bots\freqtrade\.venv\Scripts\activate.bat
    pause
    exit /b 1
)
echo [✓] 虚拟环境已激活

rem 切换到工作目录
cd /d D:\bots\freqtrade

rem 检查关键文件是否存在
echo [2/5] 检查系统文件...
if not exist "user_data\strategies\FreqAIRLStrategyOptimized.py" (
    color 0C
    echo [ERROR] 找不到优化策略文件
    pause
    exit /b 1
)
if not exist "user_data\freqaimodels\RLModelOptimized.py" (
    color 0C
    echo [ERROR] 找不到优化模型文件
    pause
    exit /b 1
)
if not exist "user_data\config_freqai_rl_risk_optimized.json" (
    color 0C
    echo [ERROR] 找不到优化配置文件
    pause
    exit /b 1
)
echo [✓] 系统文件检查完成

echo [3/5] 系统准备就绪
echo.
color 0B
echo ===============================================
echo                  操作菜单
echo ===============================================
echo.
echo  基础操作:
echo    1. 快速启动 (推荐首次使用)
echo    2. 仅下载数据
echo    3. 直接开始交易
echo    4. 运行回测分析
echo.
echo  高级操作:
echo    5. 启动Hyperopt参数优化
echo    6. 模型性能分析
echo    7. 风险评估模式
echo    8. 策略对比测试
echo.
echo  系统维护:
echo    9. 清理旧数据
echo   10. 系统诊断
echo   11. 查看日志
echo   12. 退出程序
echo.
echo ===============================================
set /p choice="请输入选择 (1-12): "

rem 创建日志目录
if not exist "user_data\logs" mkdir "user_data\logs"
set LOG_FILE=user_data\logs\freqai_rl_%date:~0,4%%date:~5,2%%date:~8,2%_%time:~0,2%%time:~3,2%.log

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
echo [ERROR] 无效选择，退出...
pause
exit /b 1

:quick_start
echo.
echo [4/5] 快速启动模式
echo ===============================================
echo [INFO] 正在执行完整的初始化流程...

echo.
echo [步骤1] 下载历史数据...
freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT SOL/USDT XRP/USDT ADA/USDT AVAX/USDT LINK/USDT DOT/USDT MATIC/USDT LTC/USDT UNI/USDT ATOM/USDT NEAR/USDT FIL/USDT HBAR/USDT SUI/USDT ^
    --timeframes 5m 15m 1h ^
    --days 60 ^
    --config user_data/config_freqai_rl_risk_optimized.json

if errorlevel 1 (
    color 0C
    echo [ERROR] 数据下载失败
    goto error_handler
)
echo [✓] 历史数据下载完成

echo.
echo [步骤2] 启动优化的FreqAI强化学习交易...
echo [INFO] 使用优化配置: config_freqai_rl_risk_optimized.json
echo [INFO] 使用优化策略: FreqAIRLStrategyOptimized
echo [INFO] 使用优化模型: RLModelOptimized
echo [INFO] 首次训练可能需要20-30分钟，请耐心等待...
echo.

freqtrade trade ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --dry-run ^
    --logfile %LOG_FILE% 2>&1

goto end

:download_only
echo.
echo [4/5] 数据下载模式
echo ===============================================
freqtrade download-data ^
    --exchange binance ^
    --pairs BTC/USDT ETH/USDT SOL/USDT XRP/USDT ADA/USDT AVAX/USDT LINK/USDT DOT/USDT MATIC/USDT LTC/USDT UNI/USDT ATOM/USDT NEAR/USDT FIL/USDT HBAR/USDT SUI/USDT ^
    --timeframes 5m 15m 1h 4h 1d ^
    --days 90 ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler
echo [✓] 数据下载完成
goto end

:trade_only
echo.
echo [4/5] 直接交易模式
echo ===============================================
echo [INFO] 启动优化的FreqAI强化学习交易...

freqtrade trade ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --dry-run ^
    --logfile %LOG_FILE%

goto end

:backtest
echo.
echo [4/5] 回测分析模式
echo ===============================================
echo [INFO] 正在运行回测分析...

freqtrade backtesting ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --timerange 20241001-20241201 ^
    --export trades ^
    --export-filename user_data/backtest_results/backtest_optimized_%date:~0,4%%date:~5,2%%date:~8,2% ^
    --logfile %LOG_FILE%

if errorlevel 1 goto error_handler

echo.
echo [INFO] 生成回测报告...
freqtrade backtesting-analysis ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --analysis-groups "0,1,2,3,4,5"

goto end

:hyperopt
echo.
echo [4/5] Hyperopt参数优化模式
echo ===============================================
echo [WARNING] 参数优化是计算密集型任务，可能需要数小时
echo [INFO] 建议在性能较好的机器上运行

set /p confirm="确认开始参数优化? (y/n): "
if /i not "%confirm%"=="y" goto end

freqtrade hyperopt ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --hyperopt-loss SharpeHyperOptLoss ^
    --epochs 100 ^
    --spaces buy sell ^
    --timerange 20241001-20241201 ^
    --jobs 2 ^
    --logfile %LOG_FILE%

goto end

:performance_analysis
echo.
echo [4/5] 模型性能分析模式
echo ===============================================
echo [INFO] 分析模型性能和特征重要性...

if not exist "user_data\models" (
    echo [ERROR] 找不到训练好的模型
    goto end
)

echo [INFO] 生成性能报告...
freqtrade plot-dataframe ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --strategy FreqAIRLStrategyOptimized ^
    --pairs BTC/USDT ETH/USDT ^
    --timerange 20241101-20241130

echo [INFO] 生成利润曲线...
freqtrade plot-profit ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --timerange 20241101-20241130

goto end

:risk_assessment
echo.
echo [4/5] 风险评估模式
echo ===============================================
echo [INFO] 进行风险评估和压力测试...

echo [INFO] 运行多市场条件下的回测...
for %%p in (20240101-20240301 20240401-20240601 20240701-20240901 20241001-20241201) do (
    echo [INFO] 测试时间段: %%p
    freqtrade backtesting ^
        --config user_data/config_freqai_rl_risk_optimized.json ^
        --freqaimodel RLModelOptimized ^
        --strategy FreqAIRLStrategyOptimized ^
        --timerange %%p ^
        --export trades ^
        --export-filename user_data/backtest_results/risk_test_%%p
)

echo [✓] 风险评估完成，结果保存在 user_data/backtest_results/
goto end

:strategy_comparison
echo.
echo [4/5] 策略对比测试模式
echo ===============================================
echo [INFO] 对比不同策略的性能...

echo [INFO] 测试基础策略...
freqtrade backtesting ^
    --config user_data/config_freqai_rl.json ^
    --freqaimodel RLModel ^
    --strategy FreqAIRLStrategy ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --export-filename user_data/backtest_results/basic_strategy

echo [INFO] 测试优化策略...
freqtrade backtesting ^
    --config user_data/config_freqai_rl_risk_optimized.json ^
    --freqaimodel RLModelOptimized ^
    --strategy FreqAIRLStrategyOptimized ^
    --timerange 20241001-20241130 ^
    --export trades ^
    --export-filename user_data/backtest_results/optimized_strategy

echo [✓] 策略对比完成
goto end

:cleanup
echo.
echo [4/5] 系统清理模式
echo ===============================================
echo [WARNING] 这将删除旧的模型和数据文件

set /p confirm="确认清理系统? (y/n): "
if /i not "%confirm%"=="y" goto end

echo [INFO] 清理旧模型...
if exist "user_data\models" rmdir /s /q "user_data\models"

echo [INFO] 清理旧日志...
if exist "user_data\logs" (
    forfiles /p "user_data\logs" /m "*.log" /d -7 /c "cmd /c del @path" 2>nul
)

echo [INFO] 清理临时文件...
if exist "user_data\data\*.tmp" del /q "user_data\data\*.tmp"

echo [✓] 系统清理完成
goto end

:system_diagnosis
echo.
echo [4/5] 系统诊断模式
echo ===============================================
echo [INFO] 运行系统诊断...

echo [INFO] 检查Python环境...
python --version
echo.

echo [INFO] 检查FreqTrade版本...
freqtrade --version
echo.

echo [INFO] 检查依赖包...
pip list | findstr "freqtrade\|stable-baselines3\|gymnasium\|torch"
echo.

echo [INFO] 检查配置文件...
freqtrade show-config --config user_data/config_freqai_rl_risk_optimized.json
echo.

echo [INFO] 检查策略...
freqtrade list-strategies --strategy-path user_data/strategies/
echo.

echo [INFO] 检查FreqAI模型...
freqtrade list-freqaimodels --freqaimodel-path user_data/freqaimodels/
echo.

echo [✓] 系统诊断完成
goto end

:view_logs
echo.
echo [4/5] 日志查看模式
echo ===============================================
if not exist "user_data\logs" (
    echo [INFO] 没有找到日志文件
    goto end
)

echo [INFO] 最近的日志文件:
dir "user_data\logs\*.log" /od /b | tail -5
echo.

echo [INFO] 显示最新日志文件的最后50行:
for /f "delims=" %%i in ('dir "user_data\logs\*.log" /od /b ^| tail -1') do (
    echo ======== %%i ========
    tail -50 "user_data\logs\%%i"
)
goto end

:error_handler
color 0C
echo.
echo ===============================================
echo [ERROR] 操作失败！
echo ===============================================
echo.
echo [INFO] 错误信息已记录到日志文件: %LOG_FILE%
echo [INFO] 请检查以下常见问题:
echo   1. 网络连接是否正常
echo   2. 交易所API是否可用
echo   3. 虚拟环境是否正确激活
echo   4. 磁盘空间是否充足
echo.
echo [INFO] 如需技术支持，请提供日志文件
pause
exit /b 1

:exit_program
echo.
echo [INFO] 正在安全退出...
goto end

:end
echo.
echo ===============================================
echo 操作完成！
echo ===============================================
echo.
echo [INFO] 系统信息:
echo   Web界面: http://localhost:8080
echo   用户名: freqtrader
echo   密码: password123
echo   日志文件: %LOG_FILE%
echo.
echo [INFO] 重要提醒:
echo   1. 这是模拟交易，使用虚拟资金
echo   2. 实盘交易前请充分测试
echo   3. 定期检查交易表现
echo   4. 注意风险控制
echo.
color 0A
echo 感谢使用 FreqAI 强化学习交易系统！
echo.
pause > nul 