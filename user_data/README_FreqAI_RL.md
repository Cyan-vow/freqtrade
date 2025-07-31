# FreqAI强化学习交易系统使用指南

## 📋 目录
1. [系统概述](#系统概述)
2. [快速开始](#快速开始)
3. [配置文件说明](#配置文件说明)
4. [运行模式](#运行模式)
5. [监控和管理](#监控和管理)
6. [参数优化](#参数优化)
7. [性能分析](#性能分析)
8. [故障排除](#故障排除)
9. [进阶使用](#进阶使用)

## 🎯 系统概述

### 核心功能
- **FreqAI强化学习**: 使用PPO算法训练智能交易决策模型
- **多技术指标融合**: 结合传统技术分析和AI预测
- **风险管理**: 包含止损、仓位管理、风险控制
- **参数优化**: 支持Hyperopt自动参数调优
- **实时监控**: Web界面实时查看交易状态

### 技术架构
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   市场数据      │───▶│  FreqAI模型     │───▶│   交易执行      │
│  (OHLCV+指标)   │    │ (强化学习PPO)   │    │  (买卖决策)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         ▲                       ▲                       ▲
         │                       │                       │
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   数据下载      │    │   特征工程      │    │   风险管理      │
│  (历史数据)     │    │ (技术指标计算)  │    │ (止损/仓位)     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

## 🚀 快速开始

### 方法一：使用启动脚本（推荐）
```batch
# Windows用户
双击运行: user_data/run_freqai_rl.bat
选择选项1: 下载数据 + 训练模型 + 开始交易
```

### 方法二：手动命令行
```bash
# 1. 激活虚拟环境
D:\bots\freqtrade\.venv\Scripts\activate

# 2. 切换到工作目录
cd D:\bots\freqtrade

# 3. 下载历史数据
freqtrade download-data \
    --exchange binance \
    --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT SOL/USDT MATIC/USDT \
    --timeframes 5m 15m 1h \
    --days 60 \
    --config user_data/config_freqai_rl.json

# 4. 启动交易
freqtrade trade \
    --config user_data/config_freqai_rl.json \
    --freqaimodel RLModel \
    --strategy FreqAIRLStrategy \
    --dry-run
```

## ⚙️ 配置文件说明

### 主配置文件: `config_freqai_rl.json`

#### 关键配置项
```json
{
    "dry_run": true,                    // 模拟盘模式
    "dry_run_wallet": 10000,            // 起始资金
    "max_open_trades": 3,               // 最大同时持仓
    "stake_amount": 100,                // 单笔交易金额
    
    "freqai": {
        "identifier": "rl_strategy_v1", // 模型标识
        "train_period_days": 30,        // 训练数据天数
        "continual_learning": true,     // 持续学习
        
        "rl_config": {
            "train_cycles": 25,         // 训练轮数
            "model_type": "PPO",        // 算法类型
            "cpu_count": 4              // CPU核心数
        }
    }
}
```

### 重要参数调整建议

#### 性能优化
```json
// 根据你的硬件配置调整
"rl_config": {
    "cpu_count": 4,                     // CPU核心数 (建议设为实际核心数)
    "train_cycles": 25                  // 训练轮数 (更多=更好但更慢)
}
```

#### 风险控制
```json
"max_open_trades": 3,                   // 建议不超过5
"stake_amount": 100,                    // 根据资金量调整
"dry_run_wallet": 10000                 // 建议至少1000
```

## 🎮 运行模式

### 1. 首次使用 (完整流程)
```bash
# 推荐步骤
1. 运行 run_freqai_rl.bat
2. 选择选项1 (下载数据+训练+交易)
3. 等待数据下载完成 (~5-10分钟)
4. 等待模型训练完成 (~30-60分钟)
5. 开始模拟交易
```

### 2. 仅数据下载
```bash
freqtrade download-data \
    --exchange binance \
    --pairs BTC/USDT ETH/USDT ADA/USDT DOT/USDT SOL/USDT MATIC/USDT \
    --timeframes 5m 15m 1h \
    --days 60 \
    --config user_data/config_freqai_rl.json
```

### 3. 回测模式
```bash
freqtrade backtesting \
    --config user_data/config_freqai_rl.json \
    --freqaimodel RLModel \
    --strategy FreqAIRLStrategy \
    --timerange 20241001-20241201
```

### 4. 实时交易
```bash
freqtrade trade \
    --config user_data/config_freqai_rl.json \
    --freqaimodel RLModel \
    --strategy FreqAIRLStrategy \
    --dry-run
```

## 📊 监控和管理

### Web界面访问
```
网址: http://localhost:8080
用户名: freqtrader
密码: password123
```

### 主要功能
- **交易状态**: 实时查看开仓/平仓情况
- **收益分析**: 查看累计收益和回撤
- **性能指标**: 胜率、盈亏比、夏普比率
- **日志查看**: 实时交易日志和AI决策过程

### 命令行监控
```bash
# 查看交易历史
freqtrade show-trades --config user_data/config_freqai_rl.json

# 查看当前状态
freqtrade status --config user_data/config_freqai_rl.json

# 查看收益情况
freqtrade profit --config user_data/config_freqai_rl.json
```

## 🔧 参数优化

### Hyperopt优化 (推荐)
```bash
freqtrade hyperopt \
    --config user_data/config_freqai_rl.json \
    --freqaimodel RLModel \
    --strategy FreqAIRLStrategy \
    --hyperopt-loss SharpeHyperOptLoss \
    --epochs 100 \
    --spaces buy sell \
    --timerange 20241001-20241201 \
    --jobs 4
```

### 可优化参数
在`FreqAIRLStrategy.py`中定义：
- `buy_rsi_threshold`: RSI买入阈值 (20-40)
- `buy_mfi_threshold`: MFI买入阈值 (10-30)
- `sell_rsi_threshold`: RSI卖出阈值 (60-85)
- `sell_mfi_threshold`: MFI卖出阈值 (70-90)
- `bb_period`: 布林带周期 (15-25)
- `bb_std`: 布林带标准差 (1.8-2.5)

### 查看优化结果
```bash
# 查看最佳结果
freqtrade hyperopt-list --best --no-header

# 查看详细结果
freqtrade hyperopt-show -n 1
```

## 📈 性能分析

### 生成分析报告
```bash
# 生成收益图表
freqtrade plot-profit \
    --config user_data/config_freqai_rl.json \
    --strategy FreqAIRLStrategy

# 生成数据图表
freqtrade plot-dataframe \
    --config user_data/config_freqai_rl.json \
    --strategy FreqAIRLStrategy \
    --pair BTC/USDT
```

### 关键性能指标
- **总收益率**: 期间总盈亏百分比
- **夏普比率**: 风险调整后收益
- **最大回撤**: 最大连续亏损
- **胜率**: 盈利交易占比
- **盈亏比**: 平均盈利/平均亏损

### Tensorboard监控 (可选)
```bash
# 查看训练过程
tensorboard --logdir user_data/models/rl_strategy_v1/tensorboard
```

## 🛠️ 故障排除

### 常见问题

#### 1. 虚拟环境激活失败
```bash
# 解决方案
D:\bots\freqtrade\.venv\Scripts\activate.ps1
```

#### 2. 数据下载失败
```bash
# 检查网络连接
ping api.binance.com

# 手动重试下载
freqtrade download-data --exchange binance --pairs BTC/USDT --timeframes 5m --days 7
```

#### 3. 内存不足
```bash
# 减少训练周期
"train_cycles": 10  # 从25减少到10

# 减少CPU使用
"cpu_count": 2      # 从4减少到2
```

#### 4. 训练时间过长
```bash
# 优化建议
- 减少训练数据天数: "train_period_days": 15
- 减少训练轮数: "train_cycles": 15
- 增加CPU核心数: "cpu_count": 8
```

#### 5. 模型性能差
```bash
# 改进建议
1. 增加训练数据: "train_period_days": 60
2. 调整奖励函数 (在RLModel.py中)
3. 优化特征工程 (在FreqAIRLStrategy.py中)
4. 运行Hyperopt优化参数
```

### 日志分析
```bash
# 查看详细日志
tail -f logs/freqtrade.log

# 查看错误日志
grep -i error logs/freqtrade.log
```

## 🎓 进阶使用

### 自定义奖励函数
在`user_data/freqaimodels/RLModel.py`中修改`calculate_reward`方法：

```python
def calculate_reward(self, action: int) -> float:
    # 自定义奖励逻辑
    current_profit = self.get_unrealized_profit()
    
    # 示例：更激进的奖励策略
    if action == Actions.Buy.value and current_profit > 0:
        return current_profit * 200  # 增加奖励权重
    
    # 添加你的奖励逻辑...
    return reward
```

### 添加新的技术指标
在`FreqAIRLStrategy.py`的特征工程函数中：

```python
def feature_engineering_expand_all(self, dataframe, period, metadata, **kwargs):
    # 添加新指标
    dataframe[f"%-stoch_rsi-{period}"] = ta.STOCHRSI(dataframe, timeperiod=period)
    dataframe[f"%-williams_r-{period}"] = ta.WILLR(dataframe, timeperiod=period)
    
    return dataframe
```

### 自定义交易对
修改配置文件中的交易对列表：

```json
"pair_whitelist": [
    "BTC/USDT",
    "ETH/USDT", 
    "BNB/USDT",     // 添加新交易对
    "DOGE/USDT"     // 添加新交易对
]
```

### 实盘交易准备
```json
// 切换到实盘前的检查清单
{
    "dry_run": false,                   // 改为false
    "exchange": {
        "key": "your_real_api_key",     // 填入真实API密钥
        "secret": "your_real_secret"    // 填入真实密钥
    },
    "db_url": "sqlite:///tradesv3.live.sqlite"  // 使用实盘数据库
}
```

⚠️ **重要警告**: 
- 实盘交易前务必充分测试模拟盘
- 建议先用小资金测试
- 确保理解所有风险
- 设置合理的止损和仓位管理

### 多策略组合
```bash
# 同时运行多个策略实例
freqtrade trade --config config1.json --strategy Strategy1 &
freqtrade trade --config config2.json --strategy Strategy2 &
```

## 📞 技术支持

### 官方资源
- **Freqtrade文档**: https://www.freqtrade.io/
- **GitHub仓库**: https://github.com/freqtrade/freqtrade
- **Discord社区**: https://discord.gg/p7nuUNVfP7

### 常用命令参考
```bash
# 查看帮助
freqtrade --help
freqtrade trade --help
freqtrade hyperopt --help

# 验证配置
freqtrade show-config --config user_data/config_freqai_rl.json

# 检查策略
freqtrade list-strategies --strategy-path user_data/strategies/

# 测试策略
freqtrade test-pairlist --config user_data/config_freqai_rl.json
```

---

**祝您交易愉快！**
记住：加密货币交易有风险，投资需谨慎。本系统仅供学习和研究使用。 