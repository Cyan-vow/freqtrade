# FreqAI强化学习配置说明文档

## 配置文件: `config_freqai_rl.json`

### 1. 基础交易配置
```json
"trading_mode": "spot"           // 交易模式: spot(现货), futures(期货), margin(保证金)
"max_open_trades": 3             // 最大同时开仓数量，控制风险分散
"stake_currency": "USDT"         // 基准货币，用于计算仓位大小
"stake_amount": 100              // 每笔交易的基准金额
"tradable_balance_ratio": 0.99   // 可用余额比例，99%用于交易，1%保留
"fiat_display_currency": "USD"   // 法币显示货币，用于盈亏计算显示
```

### 2. 模拟盘配置
```json
"dry_run": true                  // 启用模拟盘 (true=模拟, false=实盘)
"dry_run_wallet": 10000          // 模拟钱包起始金额，10000 USDT
"timeframe": "5m"                // 主要时间周期，5分钟K线
```

### 3. 订单管理配置
```json
"cancel_open_orders_on_exit": true  // 退出时取消未成交订单
"unfilledtimeout": {
    "entry": 10,                    // 入场订单超时时间(分钟)
    "exit": 30                      // 出场订单超时时间(分钟)
}
```

### 4. 交易所配置
```json
"exchange": {
    "name": "binance",              // 交易所名称，支持多个主流交易所
    "key": "",                      // API密钥 (模拟盘可为空)
    "secret": "",                   // API密钥 (模拟盘可为空)
    "pair_whitelist": [             // 交易对白名单
        "BTC/USDT",                 // 比特币/USDT - 市场风向标
        "ETH/USDT",                 // 以太坊/USDT - 第二大币种
        "ADA/USDT",                 // 卡尔达诺/USDT - 中等市值币
        "DOT/USDT",                 // 波卡/USDT - 跨链生态
        "SOL/USDT",                 // Solana/USDT - 高性能公链
        "MATIC/USDT"                // Polygon/USDT - 扩容方案
    ],
    "pair_blacklist": [             // 交易对黑名单
        "BNB/USDT"                  // 币安币/USDT (避免交易所币种)
    ]
}
```

### 5. 价格策略配置
```json
"entry_pricing": {
    "price_side": "same",           // 价格侧选择
    "use_order_book": true,         // 使用订单簿定价，更精确
    "order_book_top": 1             // 使用订单簿顶部第一档价格
},
"exit_pricing": {
    "price_side": "other",          // 出场时使用相对价格
    "use_order_book": true,         // 使用订单簿定价
    "order_book_top": 1             // 使用订单簿顶部第一档价格
}
```

### 6. FreqAI人工智能配置

#### 6.1 基本设置
```json
"freqai": {
    "enabled": true,                // 启用FreqAI功能
    "purge_old_models": 2,          // 保留最近2个模型版本，自动清理旧模型
    "train_period_days": 30,        // 训练数据周期，使用30天历史数据
    "backtest_period_days": 7,      // 回测周期，用7天数据验证模型
    "live_retrain_hours": 24,       // 实时重训练间隔，每24小时重新训练
    "identifier": "rl_strategy_v1", // 模型标识符，用于模型存储和恢复
    "continual_learning": true      // 启用持续学习，基于之前模型继续训练
}
```

#### 6.2 特征工程参数
```json
"feature_parameters": {
    "include_timeframes": ["5m", "15m", "1h"],  // 多时间周期分析
    "include_corr_pairlist": ["BTC/USDT", "ETH/USDT"],  // 相关性分析的基准币种
    "label_period_candles": 24,         // 预测窗口：24个5分钟=2小时
    "include_shifted_candles": 2,       // 包含前2个周期的滞后数据
    "DI_threshold": 0.9,                // 散度指数阈值，数据质量控制
    "weight_factor": 0.9,               // 新数据权重因子
    "principal_component_analysis": false,  // 主成分分析降维
    "use_SVM_to_remove_outliers": true,     // 使用SVM移除异常值
    "indicator_periods_candles": [10, 20, 50],  // 技术指标计算周期
    "noise_standard_deviation": 0.05,   // 数据增强的噪声水平
    "randomize_starting_position": true // RL训练时随机化起始位置
}
```

#### 6.3 数据分割参数
```json
"data_split_parameters": {
    "test_size": 0.25,              // 测试集比例，25%用于验证
    "random_state": 42              // 随机种子，确保结果可重现
}
```

#### 6.4 强化学习专用配置
```json
"rl_config": {
    "train_cycles": 25,             // 训练轮数，每轮遍历整个数据集
    "cpu_count": 4,                 // CPU核心数，并行训练加速
    "max_training_drawdown_pct": 0.05,  // 最大训练回撤5%，风险控制
    "model_type": "PPO",            // 算法类型：近端策略优化
    "policy_type": "MlpPolicy",     // 策略网络：多层感知机
    "max_trade_duration_candles": 300,  // 最大持仓时间：300*5分钟=25小时
    "model_reward_parameters": {
        "rr": 1,                    // 风险回报比
        "profit_aim": 0.02,         // 目标利润率2%
        "win_reward_factor": 2      // 盈利交易奖励倍数
    }
}
```

#### 6.5 模型训练参数
```json
"model_training_parameters": {
    "learning_rate": 0.00025,       // 学习率，控制训练步长
    "gamma": 0.9,                   // 折扣因子，未来奖励权重
    "verbose": 1                    // 详细输出级别
}
```

### 7. 系统配置

#### 7.1 机器人基本信息
```json
"bot_name": "FreqAI_RL_Bot",        // 机器人名称标识
"force_entry_enable": true,         // 启用强制入场功能
"initial_state": "running"          // 初始状态：自动开始运行
```

#### 7.2 内部配置
```json
"internals": {
    "process_throttle_secs": 5      // 处理间隔5秒，降低CPU使用
}
```

#### 7.3 通知配置
```json
"telegram": {
    "enabled": false,               // Telegram通知（可后续配置）
    "token": "",                    // Telegram机器人Token
    "chat_id": ""                   // Telegram聊天ID
}
```

#### 7.4 Web API服务器
```json
"api_server": {
    "enabled": true,                // 启用Web管理界面
    "listen_ip_address": "127.0.0.1",  // 本地访问
    "listen_port": 8080,            // 端口8080
    "username": "freqtrader",       // 登录用户名
    "password": "password123"       // 登录密码 (请修改)
}
```

## 重要说明

### 安全提醒
1. **API密钥**: 模拟盘可以留空，实盘使用时需要填入真实的交易所API密钥
2. **密码安全**: 请修改默认的Web界面登录密码
3. **权限控制**: API密钥建议设置为只读+交易权限，禁用提现权限

### 性能优化
1. **CPU使用**: `cpu_count`根据你的机器配置调整
2. **内存需求**: 强化学习训练需要较多内存，建议8GB+
3. **存储空间**: 模型文件会占用一定磁盘空间

### 风险控制
1. **仓位管理**: `max_open_trades`控制同时交易数量
2. **资金管理**: `stake_amount`控制单笔交易金额
3. **止损设置**: 在策略中实现具体的止损逻辑

### 监控建议
1. **Web界面**: 访问 http://localhost:8080 查看实时状态
2. **日志监控**: 观察训练进度和交易信号
3. **性能分析**: 定期检查收益率和回撤情况 