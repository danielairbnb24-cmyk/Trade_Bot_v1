//+------------------------------------------------------------------+
//|                                         HybridScalperV3.mq5      |
//|                                  Hybrid Scalper V3 - Main EA     |
//|                                         Advanced Trading System  |
//+------------------------------------------------------------------+
#property copyright "Hybrid Scalper V3"
#property version   "3.00"
#property description "Advanced Multi-Indicator Scalping System"
#property strict

// Dependencies
#include "Structures.mqh"
#include "Utilities.mqh"
#include "Indicators.mqh"
#include "Execution.mqh"
#include "Dashboard.mqh"
#include "Logger.mqh"

//+==================================================================
// GLOBAL INPUTS
//+==================================================================

//--- General Inputs
input group "=== General Settings ==="
input bool     InpTradingEnabled = true;           // Enable Trading
input double   InpRiskPercent = 1.0;               // Risk Per Trade (%)
input int      InpMaxSpread = 30;                  // Maximum Spread (points)
input ulong    InpMagicNumber = 20240315;          // Magic Number

//--- Indicator Inputs
input group "=== Indicator Settings ==="
input int      InpFastEMAPeriod = 9;               // Fast EMA Period
input int      InpMediumEMAPeriod = 21;            // Medium EMA Period
input int      InpSlowEMAPeriod = 50;              // Slow EMA Period
input int      InpRSIPeriod = 14;                  // RSI Period
input int      InpFilteredRSIPeriod = 3;           // Smooth RSI Period
input int      InpADXPeriod = 14;                  // ADX Period
input int      InpATRPeriod = 14;                  // ATR Period
input int      InpWPRPeriod = 14;                  // Williams %R Period

//--- Strategy Inputs
input group "=== Strategy Settings ==="
input bool     InpUseTrendFilter = true;           // Use Trend Filter
input bool     InpUseMomentumFilter = true;        // Use Momentum Filter
input bool     InpUseVolatilityFilter = true;      // Use Volatility Filter
input int      InpMinADXForTrend = 25;             // Minimum ADX for Trend
input int      InpRSIOverbought = 70;              // RSI Overbought Level
input int      InpRSIOversold = 30;                // RSI Oversold Level

//--- Execution Inputs
input group "=== Execution Settings ==="
input bool     InpUseBreakEven = true;             // Use Break Even
input int      InpBreakEvenPoints = 20;            // Break Even Trigger (points)
input bool     InpUseTrailingStop = true;          // Use Trailing Stop
input int      InpTrailingMultiplier = 2;          // Trailing Stop Multiplier
input bool     InpAdaptiveManagement = true;       // Adaptive Management
input int      InpMaxTradeDuration = 60;           // Max Trade Duration (minutes)

//--- Dashboard Inputs
input group "=== Dashboard Settings ==="
input bool     InpShowDashboard = true;            // Show Dashboard
input int      InpDashboardX = 10;                 // Dashboard X Position
input int      InpDashboardY = 30;                 // Dashboard Y Position
input color    InpDashboardColor = clrWhite;       // Dashboard Text Color

//--- Logger Inputs
input group "=== Logger Settings ==="
input bool     InpEnableLogging = true;            // Enable Logging
input bool     InpLogTrades = true;                // Log Trades
input bool     InpLogErrors = true;                // Log Errors
input bool     InpLogDebug = false;                // Log Debug Info

//+==================================================================
// GLOBAL ENUMS
//+==================================================================

// Trading Enums
enum ENUM_TRADING_STATE
{
   TRADING_IDLE,
   TRADING_ACTIVE,
   TRADING_SUSPENDED,
   TRADING_EMERGENCY
};

// Indicator Enums
enum ENUM_INDICATOR_MODE
{
   INDICATOR_STANDARD,
   INDICATOR_SMOOTHED,
   INDICATOR_WEIGHTED
};

// Market Enums
enum ENUM_CONNECTION_STATE
{
   CONNECTION_DISCONNECTED,
   CONNECTION_CONNECTING,
   CONNECTION_CONNECTED,
   CONNECTION_STABLE
};

// Execution Enums
enum ENUM_EXECUTION_STATE
{
   EXEC_READY,
   EXEC_PROCESSING,
   EXEC_WAITING,
   EXEC_ERROR
};

// Dashboard Enums
enum ENUM_DASHBOARD_MODE
{
   DASHBOARD_FULL,
   DASHBOARD_MINIMAL,
   DASHBOARD_HIDDEN
};

// Logger Enums
enum ENUM_LOG_LEVEL
{
   LOG_LEVEL_INFO,
   LOG_LEVEL_WARNING,
   LOG_LEVEL_ERROR,
   LOG_LEVEL_DEBUG,
   LOG_LEVEL_TRADE
};

//+==================================================================
// GLOBAL CONSTANTS
//+==================================================================

// EA Version
#define EA_VERSION "3.00"
#define EA_NAME "HybridScalperV3"

// Magic Number
ulong g_MagicNumber = 20240315;

// Program Constants
#define MAX_RETRIES 3
#define TIMEOUT_MS 5000
#define MIN_BAR_COUNT 100

// Broker Constants
#define MAX_SPREAD_POINTS 50
#define MIN_FREE_MARGIN 100.0
#define TRADE_ALLOWED_MASK 0x0007

//+==================================================================
// GLOBAL STRUCTURES
//+==================================================================

MarketData      g_Market;
IndicatorData   g_Indicators;
StrategyData    g_Strategy;
ExecutionData   g_Execution;
DashboardData   g_Dashboard;
LoggerData      g_Logger;

//+==================================================================
// GLOBAL OBJECTS
//+==================================================================

CTrade        g_Trade;
CPositionInfo g_Position;
CSymbolInfo   g_Symbol;

//+==================================================================
// GLOBAL INDICATOR HANDLES
//+==================================================================

int g_FastEMAHandle = INVALID_HANDLE;
int g_MediumEMAHandle = INVALID_HANDLE;
int g_SlowEMAHandle = INVALID_HANDLE;
int g_RSIHandle = INVALID_HANDLE;
int g_ADXHandle = INVALID_HANDLE;
int g_ATRHandle = INVALID_HANDLE;
int g_WPRHandle = INVALID_HANDLE;

//+==================================================================
// GLOBAL RUNTIME STATE
//+==================================================================

bool      g_EAInitialized = false;
bool      g_TradingEnabled = true;
bool      g_NewBar = false;
bool      g_CurrentTick = false;
int       g_CurrentBar = 0;
int       g_LastBar = 0;
datetime  g_LastTickTime = 0;
int       g_RuntimeError = 0;

ENUM_TRADING_STATE g_TradingState = TRADING_IDLE;
ENUM_CONNECTION_STATE g_ConnectionState = CONNECTION_DISCONNECTED;
ENUM_EXECUTION_STATE g_ExecutionState = EXEC_READY;

// Statistics
int       g_TickCounter = 0;
int       g_CycleCounter = 0;
datetime  g_StartTime = 0;

//+==================================================================
// INITIALIZATION
//+==================================================================

int OnInit()
{
   PrintFormat("%s v%s initializing...", EA_NAME, EA_VERSION);
   
   // Initialize inputs
   if(!InitializeInputs())
   {
      Print("Failed to initialize inputs");
      return(INIT_FAILED);
   }
   
   // Initialize structures
   if(!InitializeStructures())
   {
      Print("Failed to initialize structures");
      return(INIT_FAILED);
   }
   
   // Initialize utilities
   if(!Utilities::InitializeUtilities())
   {
      Print("Failed to initialize utilities");
      return(INIT_FAILED);
   }
   
   // Initialize indicators
   if(!Indicators::InitializeIndicators())
   {
      Print("Failed to initialize indicators");
      return(INIT_FAILED);
   }
   
   // Initialize strategy
   if(!InitializeStrategy())
   {
      Print("Failed to initialize strategy");
      return(INIT_FAILED);
   }
   
   // Initialize execution
   if(!Execution::InitializeExecution())
   {
      Print("Failed to initialize execution");
      return(INIT_FAILED);
   }
   
   // Initialize dashboard
   if(!Dashboard::InitializeDashboard())
   {
      Print("Failed to initialize dashboard");
      return(INIT_FAILED);
   }
   
   // Initialize logger
   if(!Logger::InitializeLogger())
   {
      Print("Failed to initialize logger");
      return(INIT_FAILED);
   }
   
   // Create indicator handles
   if(!CreateIndicatorHandles())
   {
      Print("Failed to create indicator handles");
      return(INIT_FAILED);
   }
   
   // Validate initialization
   if(!ValidateInitialization())
   {
      Print("Initialization validation failed");
      return(INIT_FAILED);
   }
   
   // Print startup information
   PrintStartupInformation();
   
   g_EAInitialized = true;
   g_StartTime = TimeCurrent();
   g_TradingState = TRADING_ACTIVE;
   
   PrintFormat("%s v%s initialized successfully", EA_NAME, EA_VERSION);
   return(INIT_SUCCEEDED);
}

//+==================================================================
// DEINITIALIZATION
//+==================================================================

void OnDeinit(const int reason)
{
   PrintFormat("%s deinitializing... Reason: %d", EA_NAME, reason);
   
   // Release indicator handles
   ReleaseIndicatorHandles();
   
   // Shutdown dashboard
   Dashboard::ShutdownDashboard();
   
   // Shutdown logger
   Logger::ShutdownLogger();
   
   // Shutdown execution
   Execution::ShutdownExecution();
   
   // Shutdown strategy
   ShutdownStrategy();
   
   // Shutdown indicators
   Indicators::ShutdownIndicators();
   
   // Shutdown utilities
   Utilities::ShutdownUtilities();
   
   // Shutdown structures
   ShutdownStructures();
   
   // Print shutdown information
   PrintShutdownInformation();
   
   g_EAInitialized = false;
}

//+==================================================================
// MAIN LOOP
//+==================================================================

void OnTick()
{
   if(!g_EAInitialized)
      return;
   
   g_CurrentTick = true;
   g_TickCounter++;
   
   // Check terminal status
   if(!CheckTerminalStatus())
      return;
   
   // Check connection
   CheckConnection();
   
   // Detect new bar
   g_NewBar = DetectNewBar();
   
   // Run trading cycle
   RunTradingCycle();
   
   // Save current state
   SaveCurrentState();
}

//+==================================================================
// TRADING CYCLE
//+==================================================================

void RunTradingCycle()
{
   g_CycleCounter++;
   
   // Reset tick state
   ResetTickState();
   
   // Update tick data
   UpdateTickData();
   
   // Manage emergency conditions
   ManageEmergencyConditions();
   
   // Process on new bar
   if(g_NewBar)
   {
      UpdateBarData();
   }
   
   // Execute decision
   ExecuteDecision(g_Strategy.decision);
   
   // Manage position
   Execution::ManagePosition();
   
   // Update dashboard
   if(InpShowDashboard)
      Dashboard::UpdateDashboard();
   
   // Log cycle
   LogCycle();
}

//+==================================================================
// TICK DATA
//+==================================================================

void UpdateTickData()
{
   // Update market data
   Utilities::UpdateMarket(_Symbol);
   
   // Update account data
   Utilities::UpdateAccount();
   
   // Update position data
   Utilities::RefreshPositionState();
   
   // Validate tick data
   ValidateTickData();
}

//+==================================================================
// BAR DATA
//+==================================================================

void UpdateBarData()
{
   // Update indicators
   Indicators::UpdateIndicators();
   
   // Generate trading decision
   GenerateDecision();
   
   // Update statistics
   UpdateStatistics();
   
   // Validate bar data
   ValidateBarData();
}

//+==================================================================
// POSITION MANAGEMENT
//+==================================================================

void ManageOpenPositions()
{
   Execution::ManagePosition();
}

//+==================================================================
// OPTIONAL EVENTS
//+==================================================================

void OnTrade()
{
   // Handle trade events
   Logger::LogInfo("ON_TRADE", "Trade event detected");
}

void OnTradeTransaction(const MqlTradeTransaction& trans,
                        const MqlTradeRequest& request,
                        const MqlTradeResult& result)
{
   // Handle trade transactions
   if(trans.type == TRADE_TRANSACTION_DEAL_ADD)
   {
      Logger::LogTrade("ON_TRANSACTION", "Deal added: " + IntegerToString(trans.deal));
   }
}

void OnTimer()
{
   // Handle timer events
   if(!g_EAInitialized)
      return;
   
   // Periodic checks
   CheckConnection();
}

void OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   // Handle chart events
   if(id == CHARTEVENT_OBJECT_CLICK)
   {
      // Handle button clicks on dashboard
      Dashboard::HandleChartEvent(id, lparam, dparam, sparam);
   }
}

//+==================================================================
// RUNTIME VALIDATION
//+==================================================================

bool CheckTerminalStatus()
{
   // Check if terminal is connected
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      g_ConnectionState = CONNECTION_DISCONNECTED;
      return false;
   }
   
   // Check if auto trading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
   {
      Logger::LogError("TERMINAL", "Auto trading disabled");
      return false;
   }
   
   // Check if symbol is selected
   if(!SymbolSelect(_Symbol))
   {
      Logger::LogError("TERMINAL", "Symbol not selected");
      return false;
   }
   
   // Check time synchronization
   if(TimeCurrent() < 1000000000)
   {
      Logger::LogError("TERMINAL", "Time not synchronized");
      return false;
   }
   
   g_ConnectionState = CONNECTION_CONNECTED;
   return true;
}

void CheckConnection()
{
   // Check broker connection
   if(TerminalInfoInteger(TERMINAL_CONNECTED))
   {
      // Check server response
      if(TerminalInfoInteger(TERMINAL_PING_LAST) < TIMEOUT_MS)
      {
         g_ConnectionState = CONNECTION_STABLE;
      }
      else
      {
         g_ConnectionState = CONNECTION_CONNECTING;
      }
   }
   else
   {
      g_ConnectionState = CONNECTION_DISCONNECTED;
   }
   
   // Check market data availability
   if(!SymbolInfoDouble(_Symbol, SYMBOL_BID))
   {
      Logger::LogError("CONNECTION", "Market data unavailable");
   }
}

bool ValidateInitialization()
{
   // Check all components are initialized
   if(!g_EAInitialized)
      return false;
   
   // Check indicator handles
   if(g_FastEMAHandle == INVALID_HANDLE ||
      g_MediumEMAHandle == INVALID_HANDLE ||
      g_SlowEMAHandle == INVALID_HANDLE)
   {
      return false;
   }
   
   // Check minimum bars
   if(iBars(_Symbol, _Period) < MIN_BAR_COUNT)
   {
      Logger::LogError("VALIDATION", "Insufficient bar data");
      return false;
   }
   
   return true;
}

bool ValidateTickData()
{
   // Validate tick data integrity
   if(g_Market.bid <= 0 || g_Market.ask <= 0)
      return false;
   
   if(g_Market.ask <= g_Market.bid)
      return false;
   
   return true;
}

bool ValidateBarData()
{
   // Validate bar data integrity
   MqlRates rates[];
   ArraySetAsSeries(rates, true);
   
   if(CopyRates(_Symbol, _Period, 0, 1, rates) != 1)
      return false;
   
   if(rates[0].open <= 0 || rates[0].close <= 0)
      return false;
   
   return true;
}

//+==================================================================
// STATE MANAGEMENT
//+==================================================================

void ResetTickState()
{
   // Reset strategy decision
   g_Strategy.decision = SIGNAL_NONE;
   g_Strategy.buyScore = 0;
   g_Strategy.sellScore = 0;
   
   // Reset temporary flags
   g_NewBar = false;
   g_CurrentTick = false;
   
   // Clear runtime errors
   g_RuntimeError = 0;
}

void SaveCurrentState()
{
   // Save current bar
   g_LastBar = g_CurrentBar;
   
   // Save current indicators
   // (Already stored in g_Indicators structure)
   
   // Save current position
   if(g_Position.Select(_Symbol))
   {
      g_Execution.currentPositionType = (ENUM_POSITION_TYPE)g_Position.GetInteger(POSITION_TYPE);
      g_Execution.entryPrice = g_Position.GetDouble(POSITION_PRICE_OPEN);
   }
   else
   {
      g_Execution.currentPositionType = POSITION_TYPE_BUY; // None
      g_Execution.entryPrice = 0;
   }
   
   // Save execution state
   g_Execution.executionState = (int)g_ExecutionState;
}

//+==================================================================
// STATISTICS
//+==================================================================

void UpdateStatistics()
{
   // Update cycle counter
   g_CycleCounter++;
   
   // Update tick counter
   g_TickCounter++;
   
   // Update runtime
   datetime runtime = TimeCurrent() - g_StartTime;
   
   // Update performance metrics
   g_Logger.stats.totalTicks = g_TickCounter;
   g_Logger.stats.totalCycles = g_CycleCounter;
   g_Logger.stats.runtimeSeconds = (int)runtime;
}

//+==================================================================
// ERROR HANDLING
//+==================================================================

void HandleRecoverableError(string function, string message)
{
   Logger::LogError(function, message);
   g_RuntimeError++;
   
   // Attempt recovery
   if(g_RuntimeError > MAX_RETRIES)
   {
      Logger::LogError("RECOVERY", "Max retries exceeded");
      g_TradingState = TRADING_SUSPENDED;
   }
}

void HandleFatalError(string function, string message)
{
   Logger::LogError(function, "FATAL: " + message);
   g_TradingState = TRADING_EMERGENCY;
   
   // Emergency close all positions
   Execution::ClosePosition();
   
   // Disable trading
   g_TradingEnabled = false;
}

//+==================================================================
// HELPERS
//+==================================================================

bool InitializeInputs()
{
   // Load input parameters
   g_MagicNumber = InpMagicNumber;
   g_TradingEnabled = InpTradingEnabled;
   
   return true;
}

bool InitializeStructures()
{
   // Initialize global structures
   ZeroMemory(g_Market);
   ZeroMemory(g_Indicators);
   ZeroMemory(g_Strategy);
   ZeroMemory(g_Execution);
   ZeroMemory(g_Dashboard);
   ZeroMemory(g_Logger);
   
   // Set symbol info
   g_Symbol.Name(_Symbol);
   
   return true;
}

bool InitializeStrategy()
{
   // Initialize strategy parameters
   g_Strategy.useTrendFilter = InpUseTrendFilter;
   g_Strategy.useMomentumFilter = InpUseMomentumFilter;
   g_Strategy.useVolatilityFilter = InpUseVolatilityFilter;
   g_Strategy.minADX = InpMinADXForTrend;
   g_Strategy.rsiOverbought = InpRSIOverbought;
   g_Strategy.rsiOversold = InpRSIOversold;
   
   return true;
}

bool CreateIndicatorHandles()
{
   // Create EMA handles
   g_FastEMAHandle = iMA(_Symbol, _Period, InpFastEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_MediumEMAHandle = iMA(_Symbol, _Period, InpMediumEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   g_SlowEMAHandle = iMA(_Symbol, _Period, InpSlowEMAPeriod, 0, MODE_EMA, PRICE_CLOSE);
   
   // Create RSI handle
   g_RSIHandle = iRSI(_Symbol, _Period, InpRSIPeriod, PRICE_CLOSE);
   
   // Create ADX handle
   g_ADXHandle = iADX(_Symbol, _Period, InpADXPeriod);
   
   // Create ATR handle
   g_ATRHandle = iATR(_Symbol, _Period, InpATRPeriod);
   
   // Create WPR handle
   g_WPRHandle = iWPR(_Symbol, _Period, InpWPRPeriod);
   
   // Validate handles
   if(g_FastEMAHandle == INVALID_HANDLE ||
      g_MediumEMAHandle == INVALID_HANDLE ||
      g_SlowEMAHandle == INVALID_HANDLE ||
      g_RSIHandle == INVALID_HANDLE ||
      g_ADXHandle == INVALID_HANDLE ||
      g_ATRHandle == INVALID_HANDLE ||
      g_WPRHandle == INVALID_HANDLE)
   {
      return false;
   }
   
   return true;
}

void ReleaseIndicatorHandles()
{
   // Release all indicator handles
   if(g_FastEMAHandle != INVALID_HANDLE)
      IndicatorRelease(g_FastEMAHandle);
   
   if(g_MediumEMAHandle != INVALID_HANDLE)
      IndicatorRelease(g_MediumEMAHandle);
   
   if(g_SlowEMAHandle != INVALID_HANDLE)
      IndicatorRelease(g_SlowEMAHandle);
   
   if(g_RSIHandle != INVALID_HANDLE)
      IndicatorRelease(g_RSIHandle);
   
   if(g_ADXHandle != INVALID_HANDLE)
      IndicatorRelease(g_ADXHandle);
   
   if(g_ATRHandle != INVALID_HANDLE)
      IndicatorRelease(g_ATRHandle);
   
   if(g_WPRHandle != INVALID_HANDLE)
      IndicatorRelease(g_WPRHandle);
}

void PrintStartupInformation()
{
   PrintFormat("=============================================");
   PrintFormat("%s v%s Started", EA_NAME, EA_VERSION);
   PrintFormat("Symbol: %s", _Symbol);
   PrintFormat("Timeframe: %s", EnumToString(_Period));
   PrintFormat("Magic Number: %lu", g_MagicNumber);
   PrintFormat("Risk: %.1f%%", InpRiskPercent);
   PrintFormat("Max Spread: %d points", InpMaxSpread);
   PrintFormat("=============================================");
}

void PrintShutdownInformation()
{
   datetime runtime = TimeCurrent() - g_StartTime;
   int hours = (int)(runtime / 3600);
   int minutes = ((int)runtime % 3600) / 60;
   
   PrintFormat("=============================================");
   PrintFormat("%s Shutdown", EA_NAME);
   PrintFormat("Runtime: %dh %dm", hours, minutes);
   PrintFormat("Total Ticks: %d", g_TickCounter);
   PrintFormat("Total Cycles: %d", g_CycleCounter);
   PrintFormat("=============================================");
}

//+==================================================================
// TRADING LOGIC
//+==================================================================

bool DetectNewBar()
{
   datetime currentBarTime = iTime(_Symbol, _Period, 0);
   
   if(currentBarTime != g_LastTickTime)
   {
      g_LastTickTime = currentBarTime;
      g_CurrentBar = iBarShift(_Symbol, _Period, currentBarTime);
      
      return (g_CurrentBar != g_LastBar);
   }
   
   return false;
}

void GenerateDecision()
{
   // Get indicator values
   double fastEMA = Indicators::GetCurrentFastEMA();
   double mediumEMA = Indicators::GetCurrentMediumEMA();
   double slowEMA = Indicators::GetCurrentSlowEMA();
   double rsi = Indicators::GetCurrentRSI();
   double adx = Indicators::GetCurrentADX();
   double atr = Indicators::GetCurrentATR();
   double wpr = Indicators::GetCurrentWPR();
   
   // Calculate scores
   g_Strategy.buyScore = 0;
   g_Strategy.sellScore = 0;
   
   // Trend filter
   if(InpUseTrendFilter)
   {
      if(fastEMA > mediumEMA && mediumEMA > slowEMA)
         g_Strategy.buyScore += 30;
      else if(fastEMA < mediumEMA && mediumEMA < slowEMA)
         g_Strategy.sellScore += 30;
      
      if(adx >= InpMinADXForTrend)
      {
         if(fastEMA > mediumEMA)
            g_Strategy.buyScore += 20;
         else
            g_Strategy.sellScore += 20;
      }
   }
   
   // Momentum filter
   if(InpUseMomentumFilter)
   {
      if(rsi < InpRSIOversold)
         g_Strategy.buyScore += 25;
      else if(rsi > InpRSIOverbought)
         g_Strategy.sellScore += 25;
      
      if(wpr < -80)
         g_Strategy.buyScore += 15;
      else if(wpr > -20)
         g_Strategy.sellScore += 15;
   }
   
   // Volatility filter
   if(InpUseVolatilityFilter)
   {
      if(atr > 0)
      {
         g_Strategy.volatilityOK = true;
         g_Strategy.buyScore += 10;
         g_Strategy.sellScore += 10;
      }
   }
   
   // Determine decision
   int threshold = 50;
   
   if(g_Strategy.buyScore >= threshold && g_Strategy.buyScore > g_Strategy.sellScore)
   {
      g_Strategy.decision = SIGNAL_BUY;
      g_Strategy.signalStrength = g_Strategy.buyScore;
   }
   else if(g_Strategy.sellScore >= threshold && g_Strategy.sellScore > g_Strategy.buyScore)
   {
      g_Strategy.decision = SIGNAL_SELL;
      g_Strategy.signalStrength = g_Strategy.sellScore;
   }
   else
   {
      g_Strategy.decision = SIGNAL_NONE;
      g_Strategy.signalStrength = 0;
   }
   
   // Log decision
   if(g_Strategy.decision != SIGNAL_NONE)
   {
      Logger::LogInfo("DECISION", 
         "Signal: " + EnumToString(g_Strategy.decision) + 
         " Strength: " + IntegerToString(g_Strategy.signalStrength));
   }
}

void ManageEmergencyConditions()
{
   // Check max spread
   int currentSpread = (int)Utilities::CurrentSpread(_Symbol);
   if(currentSpread > InpMaxSpread)
   {
      Logger::LogWarning("EMERGENCY", "Spread too high: " + IntegerToString(currentSpread));
      g_TradingState = TRADING_SUSPENDED;
      return;
   }
   
   // Check margin call risk
   double marginLevel = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   if(marginLevel > 0 && marginLevel < 100)
   {
      Logger::LogError("EMERGENCY", "Margin call risk!");
      Execution::ClosePosition();
      g_TradingState = TRADING_EMERGENCY;
      return;
   }
   
   // Resume trading if conditions are normal
   if(g_TradingState == TRADING_SUSPENDED)
   {
      g_TradingState = TRADING_ACTIVE;
   }
}

void LogCycle()
{
   // Log periodic statistics
   static datetime lastLogTime = 0;
   
   if(TimeCurrent() - lastLogTime >= 300) // Every 5 minutes
   {
      Logger::LogInfo("CYCLE", 
         "Ticks: " + IntegerToString(g_TickCounter) + 
         " Cycles: " + IntegerToString(g_CycleCounter));
      lastLogTime = TimeCurrent();
   }
}

void ShutdownStrategy()
{
   // Cleanup strategy resources
   g_Strategy.decision = SIGNAL_NONE;
   g_Strategy.buyScore = 0;
   g_Strategy.sellScore = 0;
}

void ShutdownStructures()
{
   // Cleanup structure resources
   ZeroMemory(g_Market);
   ZeroMemory(g_Indicators);
   ZeroMemory(g_Strategy);
   ZeroMemory(g_Execution);
   ZeroMemory(g_Dashboard);
   ZeroMemory(g_Logger);
}

//+------------------------------------------------------------------+
