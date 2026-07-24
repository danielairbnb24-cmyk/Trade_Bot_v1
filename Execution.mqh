//+------------------------------------------------------------------+
//|                                              Execution.mqh       |
//|                                  Hybrid Scalper V3 - Execution   |
//|                                          Trade Execution Engine  |
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict

// Dependencies
#include "Structures.mqh"
#include "Utilities.mqh"
#include "Indicators.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| GLOBAL EXECUTION STATE                                           |
//+------------------------------------------------------------------+
static bool      g_ExecutionInitialized = false;
static int       g_LastTradeTicket = 0;
static datetime  g_LastTradeTime = 0;
static double    g_LastEntryPrice = 0;
static double    g_LastStopLoss = 0;
static double    g_LastTakeProfit = 0;
static double    g_LastLotSize = 0;
static ENUM_ORDER_TYPE g_LastOrderType = WRONG_VALUE;

// Execution Statistics
static int       g_TotalTradesExecuted = 0;
static int       g_SuccessfulTrades = 0;
static int       g_FailedTrades = 0;
static double    g_TotalVolume = 0;

//+------------------------------------------------------------------+
//| INITIALIZATION                                                   |
//+------------------------------------------------------------------+

// Initialize execution engine
bool InitializeExecution()
{
   if(g_ExecutionInitialized)
      return true;
   
   // Load execution inputs
   LoadExecutionInputs();
   
   // Validate execution inputs
   if(!ValidateExecutionInputs())
   {
      Logger::LogError("EXEC_INIT", "Invalid execution parameters");
      return false;
   }
   
   // Initialize trade engine
   InitializeTradeEngine();
   
   // Initialize risk manager
   InitializeRiskManager();
   
   // Reset execution state
   ResetExecution();
   ResetTradeState();
   
   g_ExecutionInitialized = true;
   
   Logger::LogInfo("EXEC_INIT", "Execution engine initialized successfully");
   return true;
}

// Shutdown execution engine
void ShutdownExecution()
{
   if(!g_ExecutionInitialized)
      return;
   
   CloseResources();
   ResetExecution();
   
   g_ExecutionInitialized = false;
   
   Logger::LogInfo("EXEC_SHUTDOWN", "Execution engine shutdown complete");
}

//+------------------------------------------------------------------+
//| MAIN ENGINE                                                      |
//+------------------------------------------------------------------+

// Execute trading decision
void ExecuteDecision(ENUM_SIGNAL_DECISION decision)
{
   if(!CanTrade())
      return;
   
   if(decision == SIGNAL_BUY)
   {
      ExecuteBuy();
   }
   else if(decision == SIGNAL_SELL)
   {
      ExecuteSell();
   }
}

//+------------------------------------------------------------------+
//| BUY EXECUTION                                                    |
//+------------------------------------------------------------------+

// Execute buy order
void ExecuteBuy()
{
   // Prepare buy order
   if(!PrepareBuyOrder())
      return;
   
   // Send buy order
   if(!SendBuyOrder())
      return;
   
   // Process trade result
   ProcessTradeResult();
   
   // Store trade information
   StoreTradeInformation();
}

// Prepare buy order parameters
bool PrepareBuyOrder()
{
   // Calculate lot size
   g_LastLotSize = CalculateLotSize();
   if(g_LastLotSize <= 0)
   {
      Logger::LogError("EXEC_BUY", "Invalid lot size calculation");
      return false;
   }
   
   // Calculate entry price (current ask)
   g_LastEntryPrice = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   // Calculate stop loss
   g_LastStopLoss = CalculateStopLoss(ORDER_TYPE_BUY);
   
   // Calculate take profit
   g_LastTakeProfit = CalculateTakeProfit(ORDER_TYPE_BUY);
   
   // Validate trade parameters
   if(!ValidateTrade(ORDER_TYPE_BUY))
   {
      Logger::LogError("EXEC_BUY", "Trade validation failed");
      return false;
   }
   
   g_LastOrderType = ORDER_TYPE_BUY;
   return true;
}

// Send buy order to market
bool SendBuyOrder()
{
   string comment = "HybridScalperV3_BUY";
   
   bool result = Trade.Buy(
      g_LastLotSize,           // Lot size
      _Symbol,                 // Symbol
      g_LastEntryPrice,        // Open price
      g_LastStopLoss,          // Stop loss
      g_LastTakeProfit,        // Take profit
      comment                  // Comment
   );
   
   if(!result)
   {
      int error = GetLastError();
      Logger::LogError("EXEC_BUY_SEND", "Buy order failed. Error: " + IntegerToString(error));
      g_FailedTrades++;
      return false;
   }
   
   g_LastTradeTicket = Trade.ResultRetcode();
   g_SuccessfulTrades++;
   
   Logger::LogTrade("EXEC_BUY", "Buy order sent. Ticket: " + IntegerToString(g_LastTradeTicket));
   return true;
}

//+------------------------------------------------------------------+
//| SELL EXECUTION                                                   |
//+------------------------------------------------------------------+

// Execute sell order
void ExecuteSell()
{
   // Prepare sell order
   if(!PrepareSellOrder())
      return;
   
   // Send sell order
   if(!SendSellOrder())
      return;
   
   // Process trade result
   ProcessTradeResult();
   
   // Store trade information
   StoreTradeInformation();
}

// Prepare sell order parameters
bool PrepareSellOrder()
{
   // Calculate lot size
   g_LastLotSize = CalculateLotSize();
   if(g_LastLotSize <= 0)
   {
      Logger::LogError("EXEC_SELL", "Invalid lot size calculation");
      return false;
   }
   
   // Calculate entry price (current bid)
   g_LastEntryPrice = SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   // Calculate stop loss
   g_LastStopLoss = CalculateStopLoss(ORDER_TYPE_SELL);
   
   // Calculate take profit
   g_LastTakeProfit = CalculateTakeProfit(ORDER_TYPE_SELL);
   
   // Validate trade parameters
   if(!ValidateTrade(ORDER_TYPE_SELL))
   {
      Logger::LogError("EXEC_SELL", "Trade validation failed");
      return false;
   }
   
   g_LastOrderType = ORDER_TYPE_SELL;
   return true;
}

// Send sell order to market
bool SendSellOrder()
{
   string comment = "HybridScalperV3_SELL";
   
   bool result = Trade.Sell(
      g_LastLotSize,           // Lot size
      _Symbol,                 // Symbol
      g_LastEntryPrice,        // Open price
      g_LastStopLoss,          // Stop loss
      g_LastTakeProfit,        // Take profit
      comment                  // Comment
   );
   
   if(!result)
   {
      int error = GetLastError();
      Logger::LogError("EXEC_SELL_SEND", "Sell order failed. Error: " + IntegerToString(error));
      g_FailedTrades++;
      return false;
   }
   
   g_LastTradeTicket = Trade.ResultRetcode();
   g_SuccessfulTrades++;
   
   Logger::LogTrade("EXEC_SELL", "Sell order sent. Ticket: " + IntegerToString(g_LastTradeTicket));
   return true;
}

//+------------------------------------------------------------------+
//| POSITION MANAGEMENT                                              |
//+------------------------------------------------------------------+

// Manage open positions
void ManagePosition()
{
   if(!Position.Select(_Symbol))
      return;
   
   // Refresh trade state
   RefreshTradeState();
   
   // Check break even
   CheckBreakEven();
   
   // Check trailing stop
   CheckTrailingStop();
   
   // Adaptive trade management
   CheckAdaptiveManagement();
   
   // Check exit conditions
   CheckExitConditions();
   
   // Update trade statistics
   UpdateTradeStatistics();
}

// Refresh current trade state
void RefreshTradeState()
{
   if(Position.Select(_Symbol))
   {
      g_LastEntryPrice = Position.GetDouble(POSITION_PRICE_OPEN);
      g_LastStopLoss = Position.GetDouble(POSITION_SL);
      g_LastTakeProfit = Position.GetDouble(POSITION_TP);
      g_LastLotSize = Position.GetDouble(POSITION_VOLUME);
      g_LastOrderType = (ENUM_ORDER_TYPE)Position.GetInteger(POSITION_TYPE);
   }
}

// Check and execute break even
void CheckBreakEven()
{
   if(!BreakEvenEligible())
      return;
   
   double bePrice = CalculateBreakEvenPrice();
   
   if(MoveToBreakEven(bePrice))
   {
      Logger::LogInfo("EXEC_BE", "Position moved to break even");
   }
}

// Check if break even is eligible
bool BreakEvenEligible()
{
   if(!Position.Select(_Symbol))
      return false;
   
   double openPrice = Position.GetDouble(POSITION_PRICE_OPEN);
   double currentPrice = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double profitPoints = MathAbs(currentPrice - openPrice) / _Point;
   
   // Break even after X points of profit
   int beTriggerPoints = 20; // Configurable
   
   return (profitPoints >= beTriggerPoints);
}

// Calculate break even price
double CalculateBreakEvenPrice()
{
   if(!Position.Select(_Symbol))
      return 0;
   
   double openPrice = Position.GetDouble(POSITION_PRICE_OPEN);
   double spread = Utilities::CurrentSpread(_Symbol) * _Point;
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return openPrice + spread;
   else
      return openPrice - spread;
}

// Move stop loss to break even
bool MoveToBreakEven(double bePrice)
{
   if(!Position.Select(_Symbol))
      return false;
   
   double currentSL = Position.GetDouble(POSITION_SL);
   
   // Only move if BE is better than current SL
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
   {
      if(bePrice <= currentSL || currentSL == 0)
         return false;
   }
   else
   {
      if(bePrice >= currentSL || currentSL == 0)
         return false;
   }
   
   bool result = Trade.PositionModify(_Symbol, bePrice, Position.GetDouble(POSITION_TP));
   
   if(result)
      g_LastStopLoss = bePrice;
   
   return result;
}

// Check and execute trailing stop
void CheckTrailingStop()
{
   if(!TrailingEnabled())
      return;
   
   double trailStop = CalculateTrailingStop();
   
   if(trailStop > 0 && ValidateTrailingStop(trailStop))
   {
      MoveTrailingStop(trailStop);
   }
}

// Check if trailing stop is enabled
bool TrailingEnabled()
{
   // Can be made configurable via inputs
   return true;
}

// Calculate trailing stop level
double CalculateTrailingStop()
{
   if(!Position.Select(_Symbol))
      return 0;
   
   double atr = Indicators::GetCurrentATR();
   int trailMultiplier = 2; // Configurable
   
   double currentPrice = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return currentPrice - (atr * trailMultiplier);
   else
      return currentPrice + (atr * trailMultiplier);
}

// Validate trailing stop movement
bool ValidateTrailingStop(double newStop)
{
   if(!Position.Select(_Symbol))
      return false;
   
   double currentSL = Position.GetDouble(POSITION_SL);
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return (newStop > currentSL);
   else
      return (newStop < currentSL);
}

// Move trailing stop
bool MoveTrailingStop(double newStop)
{
   if(!Position.Select(_Symbol))
      return false;
   
   bool result = Trade.PositionModify(_Symbol, newStop, Position.GetDouble(POSITION_TP));
   
   if(result)
      g_LastStopLoss = newStop;
   
   return result;
}

// Check adaptive management conditions
void CheckAdaptiveManagement()
{
   ENUM_MARKET_REGIME regime = Indicators::GetMarketRegime();
   
   // Detect trade environment
   DetectTradeEnvironment();
   
   // Detect trade momentum
   DetectTradeMomentum();
   
   // Adjust based on regime
   if(regime == REGIME_TRENDING_UP || regime == REGIME_TRENDING_DOWN)
   {
      DetectTrendCondition();
      ExtendTakeProfit();
   }
   else if(regime == REGIME_RANGING)
   {
      DetectRangeCondition();
      TightenTakeProfit();
   }
   
   // Check overbought/oversold
   if(Indicators::GetCurrentRSI() > 70)
      DetectOverBoughtCondition();
   else if(Indicators::GetCurrentRSI() < 30)
      DetectOverSoldCondition();
}

// Detect trade environment
void DetectTradeEnvironment()
{
   // Implementation for environment detection
}

// Detect trade momentum
void DetectTradeMomentum()
{
   // Implementation for momentum detection
}

// Detect overbought condition
void DetectOverBoughtCondition()
{
   // Tighten stops in overbought conditions
   TightenStopLoss();
}

// Detect oversold condition
void DetectOverSoldCondition()
{
   // Tighten stops in oversold conditions
   TightenStopLoss();
}

// Detect range condition
void DetectRangeCondition()
{
   // Adjust TP for ranging market
}

// Detect trend condition
void DetectTrendCondition()
{
   // Extend TP for trending market
}

// Tighten stop loss
void TightenStopLoss()
{
   if(!Position.Select(_Symbol))
      return;
   
   double atr = Indicators::GetCurrentATR();
   double currentPrice = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   double newSL = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                  currentPrice - (atr * 1.5) : 
                  currentPrice + (atr * 1.5);
   
   ModifyStopLoss(newSL);
}

// Widen stop loss
void WidenStopLoss()
{
   // Implementation for widening stops
}

// Extend take profit
void ExtendTakeProfit()
{
   if(!Position.Select(_Symbol))
      return;
   
   double currentTP = Position.GetDouble(POSITION_TP);
   double atr = Indicators::GetCurrentATR();
   
   double extension = atr * 2;
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      ModifyTakeProfit(currentTP + extension);
   else
      ModifyTakeProfit(currentTP - extension);
}

// Lock profit
void LockProfit()
{
   // Implementation for profit locking
}

// Check exit conditions
void CheckExitConditions()
{
   if(StopLossHit() || TakeProfitHit())
   {
      ClosePosition();
      return;
   }
   
   // Check strategy-based exit
   if(StrategyExitRequested())
   {
      ClosePosition();
      return;
   }
   
   // Check time-based exit
   if(TimeExitRequested())
   {
      ClosePosition();
      return;
   }
   
   // Check emergency exit
   if(EmergencyExitRequired())
   {
      ClosePosition();
      return;
   }
}

// Check if stop loss is hit
bool StopLossHit()
{
   if(!Position.Select(_Symbol))
      return false;
   
   double sl = Position.GetDouble(POSITION_SL);
   if(sl == 0)
      return false;
   
   double currentPrice = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return (currentPrice <= sl);
   else
      return (currentPrice >= sl);
}

// Check if take profit is hit
bool TakeProfitHit()
{
   if(!Position.Select(_Symbol))
      return false;
   
   double tp = Position.GetDouble(POSITION_TP);
   if(tp == 0)
      return false;
   
   double currentPrice = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? 
                         SymbolInfoDouble(_Symbol, SYMBOL_BID) : 
                         SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   
   if(Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
      return (currentPrice >= tp);
   else
      return (currentPrice <= tp);
}

// Check if strategy requests exit
bool StrategyExitRequested()
{
   // Implement strategy-specific exit logic
   return false;
}

// Check if time exit is requested
bool TimeExitRequested()
{
   if(!Position.Select(_Symbol))
      return false;
   
   datetime openTime = (datetime)Position.GetInteger(POSITION_TIME);
   int maxDurationMinutes = 60; // Configurable
   
   return ((TimeCurrent() - openTime) > (maxDurationMinutes * 60));
}

// Check if emergency exit is required
bool EmergencyExitRequired()
{
   // Check for critical conditions
   if(Utilities::CurrentSpread(_Symbol) > 50) // Spread too high
      return true;
   
   return false;
}

// Close current position
void ClosePosition()
{
   if(!Position.Select(_Symbol))
      return;
   
   bool result = Trade.PositionClose(_Symbol);
   
   if(result)
   {
      Logger::LogTrade("EXEC_CLOSE", "Position closed");
      UpdateTradeStatistics();
   }
   else
   {
      Logger::LogError("EXEC_CLOSE", "Failed to close position");
   }
}

// Update trade statistics
void UpdateTradeStatistics()
{
   // Update counters
   g_TotalTradesExecuted++;
   
   // Log statistics
   Logger::LogInfo("EXEC_STATS", "Total: " + IntegerToString(g_TotalTradesExecuted) + 
                   " Success: " + IntegerToString(g_SuccessfulTrades) + 
                   " Failed: " + IntegerToString(g_FailedTrades));
}

//+------------------------------------------------------------------+
//| STOP LOSS MANAGEMENT                                             |
//+------------------------------------------------------------------+

// Manage stop loss
void ManageStopLoss()
{
   FixedStopManager();
   ATRStopManager();
}

// Fixed stop loss manager
void FixedStopManager()
{
   // Implementation for fixed SL management
}

// ATR-based stop loss manager
void ATRStopManager()
{
   // Implementation for ATR-based SL management
}

// Modify stop loss
bool ModifyStopLoss(double newSL)
{
   if(!Position.Select(_Symbol))
      return false;
   
   bool result = Trade.PositionModify(_Symbol, newSL, Position.GetDouble(POSITION_TP));
   
   if(result)
      g_LastStopLoss = newSL;
   
   return result;
}

//+------------------------------------------------------------------+
//| TAKE PROFIT MANAGEMENT                                           |
//+------------------------------------------------------------------+

// Manage take profit
void ManageTakeProfit()
{
   FixedTarget();
}

// Fixed take profit target
void FixedTarget()
{
   // Implementation for fixed TP management
}

// Tighten take profit
void TightenTakeProfit()
{
   // Implementation for tightening TP
}

// Modify take profit
bool ModifyTakeProfit(double newTP)
{
   if(!Position.Select(_Symbol))
      return false;
   
   bool result = Trade.PositionModify(_Symbol, Position.GetDouble(POSITION_SL), newTP);
   
   if(result)
      g_LastTakeProfit = newTP;
   
   return result;
}

//+------------------------------------------------------------------+
//| TRADE VALIDATION                                                 |
//+------------------------------------------------------------------+

// Check if trading is allowed
bool CanTrade()
{
   // Check if auto trading is enabled
   if(!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED))
      return false;
   
   // Check connection
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))
      return false;
   
   // Check spread
   if(Utilities::CurrentSpread(_Symbol) > 30) // Max spread filter
      return false;
   
   // Check margin
   if(AccountInfoDouble(ACCOUNT_MARGIN_FREE) < 100) // Minimum free margin
      return false;
   
   // Check if position already exists
   if(Position.Select(_Symbol))
      return false; // One position at a time
   
   // Check symbol trading
   if(!SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE))
      return false;
   
   return true;
}

// Validate trade parameters
bool ValidateTrade(ENUM_ORDER_TYPE orderType)
{
   // Validate entry price
   if(g_LastEntryPrice <= 0)
      return false;
   
   // Validate lot size
   if(!ValidateLot(g_LastLotSize))
      return false;
   
   // Validate stop loss
   if(!ValidateSL(g_LastStopLoss, orderType, g_LastEntryPrice))
      return false;
   
   // Validate take profit
   if(!ValidateTP(g_LastTakeProfit, orderType, g_LastEntryPrice))
      return false;
   
   // Validate risk
   if(!ValidateRisk(g_LastLotSize, g_LastEntryPrice, g_LastStopLoss))
      return false;
   
   return true;
}

// Validate lot size
bool ValidateLot(double lots)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   if(lots < minLot || lots > maxLot)
      return false;
   
   // Check lot step
   double normalized = MathRound(lots / lotStep) * lotStep;
   if(MathAbs(normalized - lots) > lotStep / 2)
      return false;
   
   return true;
}

// Validate stop loss
bool ValidateSL(double sl, ENUM_ORDER_TYPE orderType, double entry)
{
   if(sl == 0)
      return true; // No SL is valid
   
   double slDistance = MathAbs(entry - sl) / _Point;
   double minSL = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   
   if(slDistance < minSL)
      return false;
   
   return true;
}

// Validate take profit
bool ValidateTP(double tp, ENUM_ORDER_TYPE orderType, double entry)
{
   if(tp == 0)
      return true; // No TP is valid
   
   double tpDistance = MathAbs(entry - tp) / _Point;
   double minTP = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   
   if(tpDistance < minTP)
      return false;
   
   return true;
}

// Validate risk
bool ValidateRisk(double lots, double entry, double sl)
{
   if(sl == 0)
      return true; // No SL means undefined risk
   
   double riskPerTrade = lots * MathAbs(entry - sl) * 10; // Approximate
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double maxRiskPercent = 2.0; // Configurable
   
   double maxRiskAmount = accountEquity * (maxRiskPercent / 100.0);
   
   return (riskPerTrade <= maxRiskAmount);
}

//+------------------------------------------------------------------+
//| PRICE & LOT UTILITIES                                            |
//+------------------------------------------------------------------+

// Calculate lot size
double CalculateLotSize()
{
   // Risk-based lot calculation
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskPercent = 1.0; // Configurable
   double riskAmount = accountEquity * (riskPercent / 100.0);
   
   double atr = Indicators::GetCurrentATR();
   double slDistance = atr * 2; // 2 ATR stop
   
   if(slDistance == 0)
      return 0.01; // Default minimum
   
   double lotSize = riskAmount / (slDistance * 10); // Approximate tick value
   
   // Normalize lot size
   return NormalizeLot(lotSize);
}

// Fixed lot size
double FixedLot()
{
   return 0.01; // Default fixed lot
}

// Risk-based lot calculation
double RiskBasedLot()
{
   double accountEquity = AccountInfoDouble(ACCOUNT_EQUITY);
   double riskPercent = 1.0;
   
   return (accountEquity * riskPercent / 100.0) / 1000; // Simplified
}

// Normalize lot size to broker requirements
double NormalizeLot(double lots)
{
   double minLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   double maxLot = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   double lotStep = SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   
   // Round to lot step
   lots = MathRound(lots / lotStep) * lotStep;
   
   // Clamp to min/max
   lots = MathMax(minLot, MathMin(maxLot, lots));
   
   return lots;
}

// Calculate entry price
double CalculateEntryPrice(ENUM_ORDER_TYPE orderType)
{
   if(orderType == ORDER_TYPE_BUY)
      return SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   else
      return SymbolInfoDouble(_Symbol, SYMBOL_BID);
}

// Calculate stop loss
double CalculateStopLoss(ENUM_ORDER_TYPE orderType)
{
   double entry = (orderType == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double atr = Indicators::GetCurrentATR();
   double slMultiplier = 2.0; // Configurable
   
   double slDistance = atr * slMultiplier;
   
   if(orderType == ORDER_TYPE_BUY)
      return entry - slDistance;
   else
      return entry + slDistance;
}

// Calculate take profit
double CalculateTakeProfit(ENUM_ORDER_TYPE orderType)
{
   double entry = (orderType == ORDER_TYPE_BUY) ? 
                  SymbolInfoDouble(_Symbol, SYMBOL_ASK) : 
                  SymbolInfoDouble(_Symbol, SYMBOL_BID);
   
   double atr = Indicators::GetCurrentATR();
   double tpMultiplier = 3.0; // Configurable (1:3 RR)
   
   double tpDistance = atr * tpMultiplier;
   
   if(orderType == ORDER_TYPE_BUY)
      return entry + tpDistance;
   else
      return entry - tpDistance;
}

//+------------------------------------------------------------------+
//| TRADE RESULTS                                                    |
//+------------------------------------------------------------------+

// Process trade result
void ProcessTradeResult()
{
   // Implementation for processing trade results
}

// Log trade execution
void LogTrade()
{
   Logger::LogTrade("EXEC_LOG", "Trade executed. Type: " + 
                    EnumToString(g_LastOrderType) + 
                    " Lots: " + DoubleToString(g_LastLotSize, 2));
}

// Log trade error
void LogTradeError(int errorCode)
{
   Logger::LogError("EXEC_ERROR", "Trade error: " + IntegerToString(errorCode));
}

//+------------------------------------------------------------------+
//| HELPERS                                                          |
//+------------------------------------------------------------------+

// Get trade duration in seconds
int TradeDuration()
{
   if(!Position.Select(_Symbol))
      return 0;
   
   datetime openTime = (datetime)Position.GetInteger(POSITION_TIME);
   return (int)(TimeCurrent() - openTime);
}

// Get current position info
string GetCurrentPosition()
{
   if(!Position.Select(_Symbol))
      return "No Position";
   
   string type = (Position.GetInteger(POSITION_TYPE) == POSITION_TYPE_BUY) ? "BUY" : "SELL";
   double profit = Position.GetDouble(POSITION_PROFIT);
   
   return type + " " + DoubleToString(Position.GetDouble(POSITION_VOLUME), 2) + 
          " Profit: " + DoubleToString(profit, 2);
}

// Reset execution state
void ResetExecution()
{
   g_LastTradeTicket = 0;
   g_LastTradeTime = 0;
   g_LastEntryPrice = 0;
   g_LastStopLoss = 0;
   g_LastTakeProfit = 0;
   g_LastLotSize = 0;
   g_LastOrderType = WRONG_VALUE;
}

// Reset trade state
void ResetTradeState()
{
   g_TotalTradesExecuted = 0;
   g_SuccessfulTrades = 0;
   g_FailedTrades = 0;
   g_TotalVolume = 0;
}

// Load execution inputs from EA parameters
void LoadExecutionInputs()
{
   // Inputs would be passed from main EA file
   // This is a placeholder for input loading
}

// Validate execution inputs
bool ValidateExecutionInputs()
{
   // Validate that execution parameters are within acceptable ranges
   return true;
}

// Initialize trade engine
void InitializeTradeEngine()
{
   // Trade object is global, already initialized
}

// Initialize risk manager
void InitializeRiskManager()
{
   // Risk management initialization
}

// Close resources
void CloseResources()
{
   // Cleanup any allocated resources
}

// Store trade information
void StoreTradeInformation()
{
   g_LastTradeTime = TimeCurrent();
   g_TotalVolume += g_LastLotSize;
}

//+------------------------------------------------------------------+
