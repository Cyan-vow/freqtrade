@echo off
echo ===============================================
echo   清理FreqAI模型数据
echo ===============================================
echo.

echo [1/3] 停止FreqAI机器人...
taskkill /f /im python.exe 2>nul
timeout /t 3 /nobreak >nul

echo [2/3] 清理模型目录...
if exist "user_data\models\rl_strategy_optimized_v1" (
    rmdir /s /q "user_data\models\rl_strategy_optimized_v1"
    echo 已删除: user_data\models\rl_strategy_optimized_v1
) else (
    echo 模型目录不存在，跳过
)

if exist "user_data\freqaimodels\rl_strategy_optimized_v1" (
    rmdir /s /q "user_data\freqaimodels\rl_strategy_optimized_v1"
    echo 已删除: user_data\freqaimodels\rl_strategy_optimized_v1
) else (
    echo FreqAI模型目录不存在，跳过
)

echo [3/3] 清理完成！
echo.
echo 现在可以重新启动FreqAI机器人，系统将重新训练模型。
echo.
pause 