//+------------------------------------------------------------------+
//|                                              Structures.mqh      |
//|                                  Trade Bot v1 - Data Structures  |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Trade Bot v1"
#property version   "1.00"
#property description "Core data structures, enums, and constants for the trading system"

#ifndef STRUCTURES_MQH
#define STRUCTURES_MQH

//+------------------------------------------------------------------+
//| System Constants                                                 |
//+------------------------------------------------------------------+
#define MAX_INDICATORS          20        // Maximum number of indicators
#define MAX_SYMBOLS             5         // Maximum symbols to track
#define MAX_TIMEFRAMES          4         // Maximum timeframes per symbol
#define DECISION_HISTORY_SIZE   100       // Size of decision history buffer
#define TICK_BUFFER_SIZE        1000      // Tick data buffer size
#define DASHBOARD_UPDATE_MS     500       // Dashboard refresh interval (ms)

//+------------------------------------------------------------------+
//| Enumerations                                                     |
//+------------------------------------------------------------------+

// Trading Actions
enum EAction
{
   ACTION_NONE = 0,      // No action
   ACTION_BUY,           // Open/Maintain Buy
   ACTION_SELL,          // Open/Maintain Sell
   ACTION_CLOSE_BUY,     // Close Buy positions
   ACTION_CLOSE_SELL,    // Close Sell positions
   ACTION_MODIFY_SL,     // Modify Stop Loss
   ACTION_MODIFY_TP      // Modify Take Profit
};

// Signal Types
enum ESignalType
{
   SIGNAL_NONE = 0,      // No signal
   SIGNAL_BULLISH,       // Bullish signal
   SIGNAL_BEARISH,       // Bearish signal
   SIGNAL_NEUTRAL        // Neutral/Flat signal
};

// Market Regimes
enum EMarketRegime
{
   REGIME_UNKNOWN = 0,   // Undefined regime
   REGIME_TREND_UP,      // Strong uptrend
   REGIME_TREND_DOWN,    // Strong downtrend
   REGIME_RANGE,         // Ranging/Sideways market
   REGIME_VOLATILE,      // High volatility/Breakout
   REGIME_TRANSITION     // Transitioning between regimes
};

// Risk Levels
enum ERiskLevel
{
   RISK_LOW = 0,         // Low risk exposure
   RISK_MEDIUM,          // Medium risk exposure
   RISK_HIGH,            // High risk exposure
   RISK_CRITICAL         // Critical risk - reduce exposure
};

// Order Types
enum EOrderType
{
   ORDER_MARKET = 0,     // Market execution
   ORDER_LIMIT,          // Limit order
   ORDER_STOP,           // Stop order
   ORDER_STOP_LIMIT      // Stop-limit order
};

// Timeframe Mapping
enum ETimeframeMap
{
   TF_M1  = PERIOD_M1,
   TF_M5  = PERIOD_M5,
   TF_M15 = PERIOD_M15,
   TF_H1  = PERIOD_H1,
   TF_H4  = PERIOD_H4,
   TF_D1  = PERIOD_D1
};

//+------------------------------------------------------------------+
//| Data Structures                                                  |
//+------------------------------------------------------------------+

// Tick Data Structure
struct STickData
{
   datetime time;              // Tick timestamp
   double   bid;               // Bid price
   double   ask;               // Ask price
   double   last;              // Last traded price
   ulong    volume;            // Tick volume
   long     tick_value;        // Tick value in account currency
   double   spread;            // Current spread (points)
   
   void Reset()
   {
      time = 0;
      bid = 0;
      ask = 0;
      last = 0;
      volume = 0;
      tick_value = 0;
      spread = 0;
   }
};

// Candle/Bar Data Structure
struct SCandleData
{
   datetime time;              // Candle open time
   double   open;              // Open price
   double   high;              // High price
   double   low;               // Low price
   double   close;             // Close price
   ulong    volume;            // Tick volume
   ulong    real_volume;       // Real volume (if available)
   
   // Calculated properties
   double   range;             // High - Low
   double   body;              // |Close - Open|
   double   body_pct;          // Body as % of range
   bool     is_bullish;        // Close > Open
   bool     is_complete;       // Candle is closed
   
   void CalculateProperties()
   {
      range = high - low;
      body = MathAbs(close - open);
      body_pct = (range > 0) ? (body / range) : 0;
      is_bullish = (close >= open);
   }
   
   void Reset()
   {
      time = 0;
      open = 0;
      high = 0;
      low = 0;
      close = 0;
      volume = 0;
      real_volume = 0;
      range = 0;
      body = 0;
      body_pct = 0;
      is_bullish = false;
      is_complete = false;
   }
};

// Indicator Handle Wrapper
struct SIndicatorHandle
{
   string name;                // Indicator name
   int    handle;              // MT5 indicator handle
   int    buffer_count;        // Number of buffers
   bool   is_valid;            // Handle validity flag
   datetime last_update;       // Last update timestamp
   
   void Invalidate()
   {
      if(handle != INVALID_HANDLE)
      {
         IndicatorRelease(handle);
         handle = INVALID_HANDLE;
      }
      is_valid = false;
   }
   
   void Reset()
   {
      name = "";
      handle = INVALID_HANDLE;
      buffer_count = 0;
      is_valid = false;
      last_update = 0;
   }
};

// Indicator Values Container
struct SIndicatorValues
{
   double ema_fast;            // Fast EMA value
   double ema_slow;            // Slow EMA value
   double rsi;                 // RSI value
   double macd_main;           // MACD main line
   double macd_signal;         // MACD signal line
   double macd_hist;           // MACD histogram
   double bb_upper;            // Bollinger Band upper
   double bb_middle;           // Bollinger Band middle
   double bb_lower;            // Bollinger Band lower
   double atr;                 // ATR value
   double wpr;                 // Williams %R value
   double adx;                 // ADX value
   double plus_di;             // +DI value
   double minus_di;            // -DI value
   
   void Reset()
   {
      ema_fast = EMPTY_VALUE;
      ema_slow = EMPTY_VALUE;
      rsi = EMPTY_VALUE;
      macd_main = EMPTY_VALUE;
      macd_signal = EMPTY_VALUE;
      macd_hist = EMPTY_VALUE;
      bb_upper = EMPTY_VALUE;
      bb_middle = EMPTY_VALUE;
      bb_lower = EMPTY_VALUE;
      atr = EMPTY_VALUE;
      wpr = EMPTY_VALUE;
      adx = EMPTY_VALUE;
      plus_di = EMPTY_VALUE;
      minus_di = EMPTY_VALUE;
   }
   
   bool IsValid() const
   {
      return (ema_fast != EMPTY_VALUE && rsi != EMPTY_VALUE && atr != EMPTY_VALUE);
   }
};

// Trading Signal Structure
struct STradingSignal
{
   ESignalType type;           // Signal type (bullish/bearish)
   double      strength;       // Signal strength (0.0 - 1.0)
   string      source;         // Signal source (indicator name)
   datetime    timestamp;      // Signal generation time
   double      price;          // Price at signal generation
   int         timeframe;      // Timeframe of signal
   
   void Reset()
   {
      type = SIGNAL_NONE;
      strength = 0.0;
      source = "";
      timestamp = 0;
      price = 0.0;
      timeframe = 0;
   }
};

// Decision Structure
struct STradingDecision
{
   EAction    action;                  // Recommended action
   double     confidence;              // Confidence level (0.0 - 1.0)
   double     entry_price;             // Suggested entry price
   double     stop_loss;               // Suggested stop loss
   double     take_profit;             // Suggested take profit
   double     position_size;           // Suggested position size (lots)
   ERiskLevel risk_level;              // Risk assessment
   EMarketRegime market_regime;        // Current market regime
   datetime   timestamp;               // Decision timestamp
   string     rationale;               // Decision reasoning
   
   void Reset()
   {
      action = ACTION_NONE;
      confidence = 0.0;
      entry_price = 0.0;
      stop_loss = 0.0;
      take_profit = 0.0;
      position_size = 0.0;
      risk_level = RISK_LOW;
      market_regime = REGIME_UNKNOWN;
      timestamp = 0;
      rationale = "";
   }
   
   bool IsValid() const
   {
      return (action != ACTION_NONE && confidence > 0.0);
   }
};

// Position Information Structure
struct SPositionInfo
{
   ulong    ticket;                // Position ticket
   string   symbol;                // Symbol name
   ENUM_POSITION_TYPE type;        // Position type (BUY/SELL)
   double   volume;                // Position volume (lots)
   double   open_price;            // Open price
   double   current_price;         // Current market price
   double   sl;                    // Current stop loss
   double   tp;                    // Current take profit
   double   swap;                  // Swap value
   double   commission;            // Commission value
   double   profit;                // Current profit
   datetime open_time;             // Open time
   string   comment;               // Position comment
   ulong    magic;                 // Magic number
   ulong    external_id;           // External ID
   
   void Reset()
   {
      ticket = 0;
      symbol = "";
      type = POSITION_TYPE_BUY;
      volume = 0.0;
      open_price = 0.0;
      current_price = 0.0;
      sl = 0.0;
      tp = 0.0;
      swap = 0.0;
      commission = 0.0;
      profit = 0.0;
      open_time = 0;
      comment = "";
      magic = 0;
      external_id = 0;
   }
};

// Account Information Structure
struct SAccountInfo
{
   double   balance;               // Account balance
   double   equity;                // Account equity
   double   margin;                // Used margin
   double   margin_free;           // Free margin
   double   margin_level;          // Margin level (%)
   double   profit;                // Total profit
   double   leverage;              // Account leverage
   string   currency;              // Account currency
   long     login;                 // Account login
   
   void Reset()
   {
      balance = 0.0;
      equity = 0.0;
      margin = 0.0;
      margin_free = 0.0;
      margin_level = 0.0;
      profit = 0.0;
      leverage = 0;
      currency = "";
      login = 0;
   }
};

// Market Information Structure
struct SMarketInfo
{
   string   symbol;                // Symbol name
   double   bid;                   // Current bid
   double   ask;                   // Current ask
   double   spread;                // Current spread (points)
   double   point;                 // Point value
   double   tick_size;             // Minimum price movement
   double   tick_value;            // Tick value
   long     digits;                // Number of digits
   double   volume_min;            // Minimum lot size
   double   volume_max;            // Maximum lot size
   double   volume_step;           // Lot size step
   double   swap_long;             // Swap for long positions
   double   swap_short;            // Swap for short positions
   ENUM_ORDER_FILL_MODE fill_mode; // Order fill mode
   ENUM_ORDER_EXECUTION_MODE exec_mode; // Order execution mode
   
   void Reset()
   {
      symbol = "";
      bid = 0.0;
      ask = 0.0;
      spread = 0.0;
      point = 0.0;
      tick_size = 0.0;
      tick_value = 0.0;
      digits = 0;
      volume_min = 0.0;
      volume_max = 0.0;
      volume_step = 0.0;
      swap_long = 0.0;
      swap_short = 0.0;
      fill_mode = ORDER_FILLING_FOK;
      exec_mode = ORDER_EXECUTION_IMMEDIATE;
   }
};

// Statistics Structure
struct SStatistics
{
   // Performance Metrics
   int      total_trades;          // Total trades executed
   int      winning_trades;        // Number of winning trades
   int      losing_trades;         // Number of losing trades
   double   gross_profit;          // Gross profit
   double   gross_loss;            // Gross loss
   double   net_profit;            // Net profit
   double   profit_factor;         // Profit factor
   double   recovery_factor;       // Recovery factor
   
   // Risk Metrics
   double   max_drawdown;          // Maximum drawdown
   double   max_drawdown_pct;      // Maximum drawdown (%)
   double   avg_win;               // Average win
   double   avg_loss;              // Average loss
   double   win_rate;              // Win rate (%)
   
   // Session Metrics
   datetime session_start;         // Session start time
   int      session_trades;        // Trades in current session
   double   session_profit;        // Profit in current session
   
   void Reset()
   {
      total_trades = 0;
      winning_trades = 0;
      losing_trades = 0;
      gross_profit = 0.0;
      gross_loss = 0.0;
      net_profit = 0.0;
      profit_factor = 0.0;
      recovery_factor = 0.0;
      max_drawdown = 0.0;
      max_drawdown_pct = 0.0;
      avg_win = 0.0;
      avg_loss = 0.0;
      win_rate = 0.0;
      session_start = 0;
      session_trades = 0;
      session_profit = 0.0;
   }
   
   void CalculateMetrics()
   {
      if(total_trades > 0)
      {
         win_rate = (double)winning_trades / total_trades * 100.0;
         
         if(gross_loss != 0)
            profit_factor = MathAbs(gross_profit / gross_loss);
         
         if(max_drawdown != 0)
            recovery_factor = MathAbs(net_profit / max_drawdown);
         
         if(winning_trades > 0)
            avg_win = gross_profit / winning_trades;
         
         if(losing_trades > 0)
            avg_loss = gross_loss / losing_trades;
      }
   }
};

// Error Information Structure
struct SErrorInfo
{
   int      error_code;            // Error code
   string   error_message;         // Error message
   string   function_name;         // Function where error occurred
   datetime timestamp;             // Error timestamp
   bool     is_fatal;              // Fatal error flag
   bool     is_recoverable;        // Recoverable error flag
   
   void Reset()
   {
      error_code = 0;
      error_message = "";
      function_name = "";
      timestamp = 0;
      is_fatal = false;
      is_recoverable = false;
   }
};

// Configuration Structure
struct SConfig
{
   // General Settings
   string   expert_name;           // Expert Advisor name
   ulong    magic_number;          // Magic number for orders
   bool     is_live_trading;       // Live trading mode flag
   
   // Risk Management
   double   risk_per_trade;        // Risk per trade (% of equity)
   double   max_daily_loss;        // Maximum daily loss (%)
   double   max_drawdown_limit;    // Maximum drawdown limit (%)
   int      max_open_positions;    // Maximum open positions
   double   max_total_volume;      // Maximum total volume (lots)
   
   // Trading Settings
   double   default_sl;            // Default stop loss (points)
   double   default_tp;            // Default take profit (points)
   double   trailing_stop;         // Trailing stop (points)
   double   break_even_offset;     // Break-even offset (points)
   
   // Time Filters
   bool     use_time_filter;       // Enable time filter
   int      trading_start_hour;    // Trading start hour
   int      trading_end_hour;      // Trading end hour
   
   // Symbol Settings
   string   primary_symbol;        // Primary trading symbol
   double   lot_size;              // Fixed lot size (if not using risk %)
   
   void Reset()
   {
      expert_name = "TradeBot_v1";
      magic_number = 123456;
      is_live_trading = false;
      risk_per_trade = 1.0;
      max_daily_loss = 5.0;
      max_drawdown_limit = 20.0;
      max_open_positions = 3;
      max_total_volume = 1.0;
      default_sl = 500;
      default_tp = 1000;
      trailing_stop = 200;
      break_even_offset = 100;
      use_time_filter = false;
      trading_start_hour = 8;
      trading_end_hour = 20;
      primary_symbol = _Symbol;
      lot_size = 0.01;
   }
};

//+------------------------------------------------------------------+
//| Global Utility Functions                                         |
//+------------------------------------------------------------------+

// Convert EAction to string
string ActionToString(EAction action)
{
   switch(action)
   {
      case ACTION_NONE:       return "NONE";
      case ACTION_BUY:        return "BUY";
      case ACTION_SELL:       return "SELL";
      case ACTION_CLOSE_BUY:  return "CLOSE_BUY";
      case ACTION_CLOSE_SELL: return "CLOSE_SELL";
      case ACTION_MODIFY_SL:  return "MODIFY_SL";
      case ACTION_MODIFY_TP:  return "MODIFY_TP";
      default:                return "UNKNOWN";
   }
}

// Convert ESignalType to string
string SignalTypeToString(ESignalType type)
{
   switch(type)
   {
      case SIGNAL_NONE:     return "NONE";
      case SIGNAL_BULLISH:  return "BULLISH";
      case SIGNAL_BEARISH:  return "BEARISH";
      case SIGNAL_NEUTRAL:  return "NEUTRAL";
      default:              return "UNKNOWN";
   }
}

// Convert EMarketRegime to string
string MarketRegimeToString(EMarketRegime regime)
{
   switch(regime)
   {
      case REGIME_UNKNOWN:    return "UNKNOWN";
      case REGIME_TREND_UP:   return "TREND_UP";
      case REGIME_TREND_DOWN: return "TREND_DOWN";
      case REGIME_RANGE:      return "RANGE";
      case REGIME_VOLATILE:   return "VOLATILE";
      case REGIME_TRANSITION: return "TRANSITION";
      default:                return "UNKNOWN";
   }
}

// Convert ERiskLevel to string
string RiskLevelToString(ERiskLevel level)
{
   switch(level)
   {
      case RISK_LOW:      return "LOW";
      case RISK_MEDIUM:   return "MEDIUM";
      case RISK_HIGH:     return "HIGH";
      case RISK_CRITICAL: return "CRITICAL";
      default:            return "UNKNOWN";
   }
}

// Normalize value to 0-1 range
double NormalizeValue(double value, double min_val, double max_val)
{
   if(max_val == min_val) return 0.5;
   double normalized = (value - min_val) / (max_val - min_val);
   return MathMax(0.0, MathMin(1.0, normalized));
}

// Calculate position size based on risk
double CalculatePositionSize(double account_equity, double risk_percent, 
                             double stop_loss_points, double tick_value)
{
   if(stop_loss_points <= 0 || tick_value <= 0) return 0.0;
   
   double risk_amount = account_equity * (risk_percent / 100.0);
   double position_size = risk_amount / (stop_loss_points * tick_value);
   
   return NormalizeLotSize(position_size);
}

// Normalize lot size to broker specifications
double NormalizeLotSize(double lots)
{
   double min_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double max_lot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lot_step = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   lots = MathFloor(lots / lot_step) * lot_step;
   lots = MathMax(min_lot, MathMin(max_lot, lots));
   
   return lots;
}

// Check if current time is within trading hours
bool IsWithinTradingHours(int start_hour, int end_hour)
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   
   if(start_hour == end_hour) return true;
   
   if(start_hour < end_hour)
      return (dt.hour >= start_hour && dt.hour < end_hour);
   else
      return (dt.hour >= start_hour || dt.hour < end_hour);
}

#endif // STRUCTURES_MQH
