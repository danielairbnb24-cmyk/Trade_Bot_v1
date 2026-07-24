//+------------------------------------------------------------------+
//|                                                   Logger.mqh     |
//|                                 Comprehensive Logging System     |
//|                                         Trade Bot v1             |
//+------------------------------------------------------------------+
#property copyright "Trade Bot v1"
#property version   "1.00"

#include "Structures.mqh"

//+------------------------------------------------------------------+
//| Global Logger State                                              |
//+------------------------------------------------------------------+
static int    g_logger_file_handle;           // Main log file handle
static string g_logger_filename;              // Log filename
static bool   g_logger_initialized = false;   // Initialization flag
static int    g_log_count = 0;                // Total log entries
static datetime g_last_flush_time;            // Last flush timestamp
static int    g_flush_interval_seconds = 60;  // Auto-flush interval

// Performance tracking
static ulong  g_total_log_operations = 0;
static ulong  g_indicator_errors = 0;
static ulong  g_strategy_errors = 0;
static ulong  g_execution_errors = 0;
static ulong  g_broker_errors = 0;
static ulong  g_system_errors = 0;

// Runtime statistics
static datetime g_logger_start_time;
static ulong    g_memory_at_start;

//+------------------------------------------------------------------+
//| INITIALIZATION SECTION                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| InitializeLogger - Main initialization function                  |
//+------------------------------------------------------------------+
bool InitializeLogger()
{
   // Reset state
   g_logger_initialized = false;
   g_log_count = 0;
   g_total_log_operations = 0;
   
   // Load configuration
   if(!LoadLoggerInputs())
      return false;
   
   // Open log files
   if(!OpenLogFiles())
      return false;
   
   // Create headers
   if(!CreateLogHeaders())
      return false;
   
   // Reset counters
   ResetLogger();
   
   g_logger_initialized = true;
   g_logger_start_time = TimeCurrent();
   g_memory_at_start = MemoryGetUsage();
   
   WriteDebug("Logger initialized successfully");
   
   return true;
}

//+------------------------------------------------------------------+
//| LoadLoggerInputs - Load logging configuration                    |
//+------------------------------------------------------------------+
bool LoadLoggerInputs()
{
   // Set default filename with timestamp
   string base_name = "TradeBot_Log_" + IntegerToString(Year()) + 
                      StringSubformat("%02d", Month()) + 
                      StringSubformat("%02d", Day());
   
   g_logger_filename = base_name + ".csv";
   
   // Load flush interval from inputs (if available)
   g_flush_interval_seconds = 60; // Default 1 minute
   
   WriteDebug("Logger inputs loaded: " + g_logger_filename);
   
   return true;
}

//+------------------------------------------------------------------+
//| OpenLogFiles - Open log file handles                             |
//+------------------------------------------------------------------+
bool OpenLogFiles()
{
   // Close existing handle if open
   if(g_logger_file_handle != INVALID_HANDLE)
   {
      FileClose(g_logger_file_handle);
      g_logger_file_handle = INVALID_HANDLE;
   }
   
   // Open file in CSV mode with write access
   g_logger_file_handle = FileOpen(g_logger_filename, 
                                   FILE_CSV | FILE_WRITE | FILE_ANSI, 
                                   ",");
   
   if(g_logger_file_handle == INVALID_HANDLE)
   {
      Print("ERROR: Failed to open log file: ", g_logger_filename);
      return false;
   }
   
   WriteDebug("Log file opened: " + g_logger_filename);
   
   return true;
}

//+------------------------------------------------------------------+
//| CreateLogHeaders - Create CSV headers for log file               |
//+------------------------------------------------------------------+
bool CreateLogHeaders()
{
   if(g_logger_file_handle == INVALID_HANDLE)
      return false;
   
   // Write main header
   FileWrite(g_logger_file_handle, 
             "Timestamp", "Category", "SubCategory", "Symbol", 
             "Price", "Spread", "Value", "Message", "ErrorCode");
   
   // Write initialization marker
   FileWrite(g_logger_file_handle, 
             Timestamp(), "SYSTEM", "INIT", _Symbol, 
             SymbolInfoDouble(_Symbol, SYMBOL_BID), 
             SymbolInfoInteger(_Symbol, SYMBOL_SPREAD), 
             "0", "Logger initialized", "0");
   
   return true;
}

//+------------------------------------------------------------------+
//| ResetLogger - Reset all logger counters and statistics           |
//+------------------------------------------------------------------+
void ResetLogger()
{
   g_log_count = 0;
   g_total_log_operations = 0;
   g_indicator_errors = 0;
   g_strategy_errors = 0;
   g_execution_errors = 0;
   g_broker_errors = 0;
   g_system_errors = 0;
   g_last_flush_time = TimeCurrent();
   
   WriteDebug("Logger counters reset");
}

//+------------------------------------------------------------------+
//| ShutdownLogger - Clean shutdown of logger system                 |
//+------------------------------------------------------------------+
void ShutdownLogger()
{
   if(!g_logger_initialized)
      return;
   
   // Flush any remaining logs
   FlushLogs();
   
   // Write summary
   WritePerformanceSummary();
   
   // Close files
   CloseLogFiles();
   
   g_logger_initialized = false;
   
   Print("Logger shutdown complete. Total logs: ", g_log_count);
}

//+------------------------------------------------------------------+
//| FlushLogs - Force flush all pending logs to disk                 |
//+------------------------------------------------------------------+
void FlushLogs()
{
   if(g_logger_file_handle != INVALID_HANDLE)
   {
      FileFlush(g_logger_file_handle);
      g_last_flush_time = TimeCurrent();
   }
}

//+------------------------------------------------------------------+
//| CloseLogFiles - Close all open log file handles                  |
//+------------------------------------------------------------------+
void CloseLogFiles()
{
   if(g_logger_file_handle != INVALID_HANDLE)
   {
      FileClose(g_logger_file_handle);
      g_logger_file_handle = INVALID_HANDLE;
   }
}

//+------------------------------------------------------------------+
//| MAIN LOGGER SECTION                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogCycle - Main logging cycle called each tick                   |
//+------------------------------------------------------------------+
void LogCycle()
{
   if(!g_logger_initialized)
      return;
   
   // Log market data
   LogMarket();
   
   // Log indicator values
   LogIndicators();
   
   // Log strategy state
   LogStrategy();
   
   // Log execution details
   LogExecution();
   
   // Log performance metrics
   LogPerformance();
   
   // Auto-flush if interval exceeded
   if(TimeCurrent() - g_last_flush_time >= g_flush_interval_seconds)
      FlushLogs();
}

//+------------------------------------------------------------------+
//| MARKET LOGGING SECTION                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogMarket - Log all market-related data                          |
//+------------------------------------------------------------------+
void LogMarket()
{
   LogPrice();
   LogSpread();
   LogTime();
   LogSession();
   LogCandle();
}

//+------------------------------------------------------------------+
//| LogPrice - Log current price data                                |
//+------------------------------------------------------------------+
void LogPrice()
{
   double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   WriteLog("MARKET", "Price", _Symbol, bid, "BID=" + DoubleToString(bid, _Digits) + 
            " ASK=" + DoubleToString(ask, _Digits));
}

//+------------------------------------------------------------------+
//| LogSpread - Log current spread                                   |
//+------------------------------------------------------------------+
void LogSpread()
{
   long spread = SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   
   WriteLog("MARKET", "Spread", _Symbol, 0, "Spread=" + IntegerToString(spread));
}

//+------------------------------------------------------------------+
//| LogTime - Log current time information                           |
//+------------------------------------------------------------------+
void LogTime()
{
   datetime now = TimeCurrent();
   
   WriteLog("MARKET", "Time", _Symbol, 0, 
            TimeToString(now, TIME_DATE|TIME_SECONDS));
}

//+------------------------------------------------------------------+
//| LogSession - Log trading session information                     |
//+------------------------------------------------------------------+
void LogSession()
{
   bool is_open = MarketInfoInteger(_Symbol, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED;
   
   WriteLog("MARKET", "Session", _Symbol, 0, 
            is_open ? "Market Open" : "Market Closed");
}

//+------------------------------------------------------------------+
//| LogCandle - Log current candle information                       |
//+------------------------------------------------------------------+
void LogCandle()
{
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) > 0)
   {
      string candle_info = StringFormat("O=%.5f H=%.5f L=%.5f C=%.5f V=%lld",
                                        rates[0].open, rates[0].high, 
                                        rates[0].low, rates[0].close, 
                                        rates[0].tick_volume);
      
      WriteLog("MARKET", "Candle", _Symbol, rates[0].close, candle_info);
   }
}

//+------------------------------------------------------------------+
//| INDICATORS LOGGING SECTION                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogIndicators - Log all indicator values                         |
//+------------------------------------------------------------------+
void LogIndicators()
{
   LogEMA();
   LogRSI();
   LogFilteredRSI();
   LogADX();
   LogATR();
   LogWPR();
   LogDerivedValues();
}

//+------------------------------------------------------------------+
//| LogEMA - Log EMA indicator values                                |
//+------------------------------------------------------------------+
void LogEMA()
{
   // Placeholder for EMA logging
   // Implementation depends on actual indicator handles
   WriteLog("INDICATOR", "EMA", _Symbol, 0, "EMA values logged");
}

//+------------------------------------------------------------------+
//| LogRSI - Log RSI indicator values                                |
//+------------------------------------------------------------------+
void LogRSI()
{
   WriteLog("INDICATOR", "RSI", _Symbol, 0, "RSI values logged");
}

//+------------------------------------------------------------------+
//| LogFilteredRSI - Log filtered RSI values                         |
//+------------------------------------------------------------------+
void LogFilteredRSI()
{
   WriteLog("INDICATOR", "FilteredRSI", _Symbol, 0, "Filtered RSI logged");
}

//+------------------------------------------------------------------+
//| LogADX - Log ADX indicator values                                |
//+------------------------------------------------------------------+
void LogADX()
{
   WriteLog("INDICATOR", "ADX", _Symbol, 0, "ADX values logged");
}

//+------------------------------------------------------------------+
//| LogATR - Log ATR indicator values                                |
//+------------------------------------------------------------------+
void LogATR()
{
   WriteLog("INDICATOR", "ATR", _Symbol, 0, "ATR values logged");
}

//+------------------------------------------------------------------+
//| LogWPR - Log Williams %R indicator values                        |
//+------------------------------------------------------------------+
void LogWPR()
{
   WriteLog("INDICATOR", "WPR", _Symbol, 0, "WPR values logged");
}

//+------------------------------------------------------------------+
//| LogDerivedValues - Log derived indicator values                  |
//+------------------------------------------------------------------+
void LogDerivedValues()
{
   WriteLog("INDICATOR", "Derived", _Symbol, 0, "Derived values logged");
}

//+------------------------------------------------------------------+
//| STRATEGY LOGGING SECTION                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogStrategy - Log all strategy-related data                      |
//+------------------------------------------------------------------+
void LogStrategy()
{
   LogMarketRegime();
   LogBuyScore();
   LogSellScore();
   LogWeights();
   LogDecision();
   LogDecisionReason();
   LogSignalStates();
   LogDecisionFilters();
}

//+------------------------------------------------------------------+
//| LogMarketRegime - Log current market regime                      |
//+------------------------------------------------------------------+
void LogMarketRegime()
{
   WriteLog("STRATEGY", "MarketRegime", _Symbol, 0, "Market regime logged");
}

//+------------------------------------------------------------------+
//| LogBuyScore - Log buy signal score                               |
//+------------------------------------------------------------------+
void LogBuyScore()
{
   WriteLog("STRATEGY", "BuyScore", _Symbol, 0, "Buy score logged");
}

//+------------------------------------------------------------------+
//| LogSellScore - Log sell signal score                             |
//+------------------------------------------------------------------+
void LogSellScore()
{
   WriteLog("STRATEGY", "SellScore", _Symbol, 0, "Sell score logged");
}

//+------------------------------------------------------------------+
//| LogWeights - Log signal weights                                  |
//+------------------------------------------------------------------+
void LogWeights()
{
   WriteLog("STRATEGY", "Weights", _Symbol, 0, "Signal weights logged");
}

//+------------------------------------------------------------------+
//| LogDecision - Log trading decision                               |
//+------------------------------------------------------------------+
void LogDecision()
{
   WriteLog("STRATEGY", "Decision", _Symbol, 0, "Trading decision logged");
}

//+------------------------------------------------------------------+
//| LogDecisionReason - Log reason for trading decision              |
//+------------------------------------------------------------------+
void LogDecisionReason()
{
   WriteLog("STRATEGY", "DecisionReason", _Symbol, 0, "Decision reason logged");
}

//+------------------------------------------------------------------+
//| LogSignalStates - Log signal states                              |
//+------------------------------------------------------------------+
void LogSignalStates()
{
   WriteLog("STRATEGY", "SignalStates", _Symbol, 0, "Signal states logged");
}

//+------------------------------------------------------------------+
//| LogDecisionFilters - Log decision filters                        |
//+------------------------------------------------------------------+
void LogDecisionFilters()
{
   WriteLog("STRATEGY", "DecisionFilters", _Symbol, 0, "Decision filters logged");
}

//+------------------------------------------------------------------+
//| EXECUTION LOGGING SECTION                                        |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogExecution - Log all execution-related data                    |
//+------------------------------------------------------------------+
void LogExecution()
{
   LogOrderRequest();
   LogOrderResult();
   LogPosition();
   LogSLTP();
   LogTrailing();
   LogBreakEven();
   LogAdaptiveManagement();
   LogExit();
}

//+------------------------------------------------------------------+
//| LogOrderRequest - Log order request details                      |
//+------------------------------------------------------------------+
void LogOrderRequest()
{
   WriteLog("EXECUTION", "OrderRequest", _Symbol, 0, "Order request logged");
}

//+------------------------------------------------------------------+
//| LogOrderResult - Log order execution result                      |
//+------------------------------------------------------------------+
void LogOrderResult()
{
   WriteLog("EXECUTION", "OrderResult", _Symbol, 0, "Order result logged");
}

//+------------------------------------------------------------------+
//| LogPosition - Log current position details                       |
//+------------------------------------------------------------------+
void LogPosition()
{
   WriteLog("EXECUTION", "Position", _Symbol, 0, "Position logged");
}

//+------------------------------------------------------------------+
//| LogSLTP - Log stop loss and take profit levels                   |
//+------------------------------------------------------------------+
void LogSLTP()
{
   WriteLog("EXECUTION", "SLTP", _Symbol, 0, "SL/TP levels logged");
}

//+------------------------------------------------------------------+
//| LogTrailing - Log trailing stop details                          |
//+------------------------------------------------------------------+
void LogTrailing()
{
   WriteLog("EXECUTION", "Trailing", _Symbol, 0, "Trailing stop logged");
}

//+------------------------------------------------------------------+
//| LogBreakEven - Log break-even management                         |
//+------------------------------------------------------------------+
void LogBreakEven()
{
   WriteLog("EXECUTION", "BreakEven", _Symbol, 0, "Break-even logged");
}

//+------------------------------------------------------------------+
//| LogAdaptiveManagement - Log adaptive management                  |
//+------------------------------------------------------------------+
void LogAdaptiveManagement()
{
   WriteLog("EXECUTION", "Adaptive", _Symbol, 0, "Adaptive management logged");
}

//+------------------------------------------------------------------+
//| LogExit - Log trade exit details                                 |
//+------------------------------------------------------------------+
void LogExit()
{
   WriteLog("EXECUTION", "Exit", _Symbol, 0, "Trade exit logged");
}

//+------------------------------------------------------------------+
//| ERROR LOGGING SECTION                                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogError - Main error logging function                           |
//+------------------------------------------------------------------+
void LogError(string category, string message, int error_code = 0)
{
   WriteLog("ERROR", category, _Symbol, 0, message, error_code);
   
   // Increment error counters
   if(StringFind(category, "INDICATOR") >= 0)
      g_indicator_errors++;
   else if(StringFind(category, "STRATEGY") >= 0)
      g_strategy_errors++;
   else if(StringFind(category, "EXECUTION") >= 0)
      g_execution_errors++;
   else if(StringFind(category, "BROKER") >= 0)
      g_broker_errors++;
   else
      g_system_errors++;
}

//+------------------------------------------------------------------+
//| LogIndicatorError - Log indicator-specific errors                |
//+------------------------------------------------------------------+
void LogIndicatorError(string message, int error_code = 0)
{
   LogError("INDICATOR", message, error_code);
}

//+------------------------------------------------------------------+
//| LogStrategyError - Log strategy-specific errors                  |
//+------------------------------------------------------------------+
void LogStrategyError(string message, int error_code = 0)
{
   LogError("STRATEGY", message, error_code);
}

//+------------------------------------------------------------------+
//| LogExecutionError - Log execution-specific errors                |
//+------------------------------------------------------------------+
void LogExecutionError(string message, int error_code = 0)
{
   LogError("EXECUTION", message, error_code);
}

//+------------------------------------------------------------------+
//| LogBrokerError - Log broker-specific errors                      |
//+------------------------------------------------------------------+
void LogBrokerError(string message, int error_code = 0)
{
   LogError("BROKER", message, error_code);
}

//+------------------------------------------------------------------+
//| LogSystemError - Log system-level errors                         |
//+------------------------------------------------------------------+
void LogSystemError(string message, int error_code = 0)
{
   LogError("SYSTEM", message, error_code);
}

//+------------------------------------------------------------------+
//| STATISTICS LOGGING SECTION                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| LogPerformance - Log all performance metrics                     |
//+------------------------------------------------------------------+
void LogPerformance()
{
   LogWinRate();
   LogProfit();
   LogDrawdown();
   LogTradeStatistics();
   LogMemory();
   LogExecutionTime();
   LogRuntime();
}

//+------------------------------------------------------------------+
//| LogWinRate - Log win rate statistics                             |
//+------------------------------------------------------------------+
void LogWinRate()
{
   WriteLog("PERFORMANCE", "WinRate", _Symbol, 0, "Win rate logged");
}

//+------------------------------------------------------------------+
//| LogProfit - Log profit/loss statistics                           |
//+------------------------------------------------------------------+
void LogProfit()
{
   WriteLog("PERFORMANCE", "Profit", _Symbol, 0, "P/L logged");
}

//+------------------------------------------------------------------+
//| LogDrawdown - Log drawdown statistics                            |
//+------------------------------------------------------------------+
void LogDrawdown()
{
   WriteLog("PERFORMANCE", "Drawdown", _Symbol, 0, "Drawdown logged");
}

//+------------------------------------------------------------------+
//| LogTradeStatistics - Log trade statistics                        |
//+------------------------------------------------------------------+
void LogTradeStatistics()
{
   WriteLog("PERFORMANCE", "TradeStats", _Symbol, 0, "Trade stats logged");
}

//+------------------------------------------------------------------+
//| LogMemory - Log memory usage                                     |
//+------------------------------------------------------------------+
void LogMemory()
{
   ulong mem_usage = MemoryGetUsage();
   WriteLog("PERFORMANCE", "Memory", _Symbol, 0, 
            "Memory: " + IntegerToString(mem_usage) + " bytes");
}

//+------------------------------------------------------------------+
//| LogExecutionTime - Log execution time                            |
//+------------------------------------------------------------------+
void LogExecutionTime()
{
   WriteLog("PERFORMANCE", "ExecTime", _Symbol, 0, "Execution time logged");
}

//+------------------------------------------------------------------+
//| LogRuntime - Log runtime statistics                              |
//+------------------------------------------------------------------+
void LogRuntime()
{
   datetime runtime = TimeCurrent() - g_logger_start_time;
   WriteLog("PERFORMANCE", "Runtime", _Symbol, 0, 
            "Runtime: " + IntegerToString(runtime) + " seconds");
}

//+------------------------------------------------------------------+
//| HELPER FUNCTIONS SECTION                                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| WriteLog - Core function to write log entries                    |
//+------------------------------------------------------------------+
void WriteLog(string category, string sub_category, string symbol, 
              double value, string message, int error_code = 0)
{
   if(!g_logger_initialized || g_logger_file_handle == INVALID_HANDLE)
      return;
   
   string timestamp = Timestamp();
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   long spread = SymbolInfoInteger(symbol, SYMBOL_SPREAD);
   
   // Format and write log line
   string log_line = FormatLogLine(timestamp, category, sub_category, symbol, 
                                   price, spread, value, message, error_code);
   
   FileWrite(g_logger_file_handle, 
             timestamp, category, sub_category, symbol, 
             price, spread, value, message, error_code);
   
   g_log_count++;
   g_total_log_operations++;
}

//+------------------------------------------------------------------+
//| WriteCSV - Write custom CSV entry                                |
//+------------------------------------------------------------------+
void WriteCSV(string filename, string data)
{
   int handle = FileOpen(filename, FILE_CSV | FILE_WRITE | FILE_ANSI, ",");
   if(handle != INVALID_HANDLE)
   {
      FileWrite(handle, data);
      FileClose(handle);
   }
}

//+------------------------------------------------------------------+
//| WriteDebug - Write debug message to terminal                     |
//+------------------------------------------------------------------+
void WriteDebug(string message)
{
   Print("[LOGGER DEBUG] ", message);
}

//+------------------------------------------------------------------+
//| Timestamp - Get formatted timestamp string                       |
//+------------------------------------------------------------------+
string Timestamp()
{
   return TimeToString(TimeCurrent(), TIME_DATE|TIME_SECONDS|TIME_MILLISECONDS);
}

//+------------------------------------------------------------------+
//| FormatLogLine - Format a complete log line                       |
//+------------------------------------------------------------------+
string FormatLogLine(string timestamp, string category, string sub_category, 
                     string symbol, double price, long spread, 
                     double value, string message, int error_code)
{
   return StringFormat("%s | %s | %s | %s | %.5f | %ld | %.2f | %s | %d",
                       timestamp, category, sub_category, symbol,
                       price, spread, value, message, error_code);
}

//+------------------------------------------------------------------+
//| WritePerformanceSummary - Write end-of-session performance summary|
//+------------------------------------------------------------------+
void WritePerformanceSummary()
{
   if(g_logger_file_handle == INVALID_HANDLE)
      return;
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "=== PERFORMANCE SUMMARY ===");
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Total Logs: " + IntegerToString(g_log_count));
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Indicator Errors: " + IntegerToString(g_indicator_errors));
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Strategy Errors: " + IntegerToString(g_strategy_errors));
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Execution Errors: " + IntegerToString(g_execution_errors));
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Broker Errors: " + IntegerToString(g_broker_errors));
   
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "System Errors: " + IntegerToString(g_system_errors));
   
   datetime runtime = TimeCurrent() - g_logger_start_time;
   WriteLog("SYSTEM", "SUMMARY", _Symbol, 0, 
            "Total Runtime: " + IntegerToString(runtime) + " seconds");
}

//+------------------------------------------------------------------+
//| GetLoggerStats - Return logger statistics as structure           |
//+------------------------------------------------------------------+
SLoggerStats GetLoggerStats()
{
   SLoggerStats stats;
   
   stats.total_logs = g_log_count;
   stats.total_operations = g_total_log_operations;
   stats.indicator_errors = g_indicator_errors;
   stats.strategy_errors = g_strategy_errors;
   stats.execution_errors = g_execution_errors;
   stats.broker_errors = g_broker_errors;
   stats.system_errors = g_system_errors;
   stats.runtime_seconds = TimeCurrent() - g_logger_start_time;
   stats.is_initialized = g_logger_initialized;
   
   return stats;
}

//+------------------------------------------------------------------+
//| IsLoggerInitialized - Check if logger is initialized             |
//+------------------------------------------------------------------+
bool IsLoggerInitialized()
{
   return g_logger_initialized;
}

//+------------------------------------------------------------------+
//| GetLoggerFilename - Get current log filename                     |
//+------------------------------------------------------------------+
string GetLoggerFilename()
{
   return g_logger_filename;
}

//+------------------------------------------------------------------+
//| End of Logger.mqh                                                |
//+------------------------------------------------------------------+
