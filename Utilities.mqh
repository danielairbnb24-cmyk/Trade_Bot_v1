//+------------------------------------------------------------------+
//|                                               Utilities.mqh      |
//|                                  Trade Bot v1 - Utility Functions|
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Trade Bot v1"
#property version   "1.00"
#property description "Core utility functions for market data, account info, positions, time, prices, and helpers"

#ifndef UTILITIES_MQH
#define UTILITIES_MQH

#include "Structures.mqh"

//+------------------------------------------------------------------+
//| Global Cache Variables                                           |
//+------------------------------------------------------------------+

// Symbol Cache
static string   g_symbol_name = "";
static long     g_symbol_digits = 0;
static double   g_symbol_point = 0.0;
static double   g_symbol_tick_size = 0.0;
static double   g_symbol_tick_value = 0.0;
static double   g_symbol_contract_size = 0.0;
static double   g_symbol_tick_value_profit = 0.0;
static double   g_symbol_tick_value_loss = 0.0;
static double   g_symbol_volume_min = 0.0;
static double   g_symbol_volume_max = 0.0;
static double   g_symbol_volume_step = 0.0;
static long     g_symbol_trade_allowed = 0;
static long     g_symbol_stop_level = 0;
static long     g_symbol_freeze_level = 0;

// Price Cache
static double   g_price_bid = 0.0;
static double   g_price_ask = 0.0;
static double   g_price_mid = 0.0;
static double   g_price_last = 0.0;
static double   g_price_spread = 0.0;
static double   g_price_spread_points = 0.0;
static double   g_price_spread_pips = 0.0;

// Current Candle Cache
static datetime g_candle_current_time = 0;
static double   g_candle_current_open = 0.0;
static double   g_candle_current_high = 0.0;
static double   g_candle_current_low = 0.0;
static double   g_candle_current_close = 0.0;
static ulong    g_candle_current_volume = 0;
static double   g_candle_current_body = 0.0;
static double   g_candle_current_range = 0.0;

// Previous Candle Cache
static datetime g_candle_prev_time = 0;
static double   g_candle_prev_open = 0.0;
static double   g_candle_prev_high = 0.0;
static double   g_candle_prev_low = 0.0;
static double   g_candle_prev_close = 0.0;
static ulong    g_candle_prev_volume = 0;
static double   g_candle_prev_body = 0.0;
static double   g_candle_prev_range = 0.0;

// Account Cache
static double   g_account_balance = 0.0;
static double   g_account_equity = 0.0;
static double   g_account_margin = 0.0;
static double   g_account_free_margin = 0.0;
static double   g_account_margin_level = 0.0;
static double   g_account_profit = 0.0;
static double   g_account_floating_profit = 0.0;
static double   g_account_drawdown = 0.0;
static double   g_account_leverage = 0.0;

// Time Cache
static datetime g_time_server = 0;
static datetime g_time_local = 0;
static datetime g_time_gmt = 0;
static datetime g_time_bar = 0;
static datetime g_time_elapsed = 0;
static datetime g_last_bar_time = 0;
static datetime g_last_trade_time = 0;

// Session Cache
static bool     g_session_is_open = false;
static bool     g_session_is_trading_day = false;
static bool     g_session_is_weekend = false;
static bool     g_session_is_holiday = false;
static bool     g_session_new_bar = false;

// Position Cache
static ulong    g_position_ticket = 0;
static ENUM_POSITION_TYPE g_position_type = WRONG_VALUE;
static double   g_position_volume = 0.0;
static double   g_position_entry_price = 0.0;
static double   g_position_current_price = 0.0;
static double   g_position_sl = 0.0;
static double   g_position_tp = 0.0;
static double   g_position_profit = 0.0;
static double   g_position_swap = 0.0;
static double   g_position_commission = 0.0;
static datetime g_position_open_time = 0;
static double   g_position_peak_profit = 0.0;
static bool     g_position_exists = false;

//+------------------------------------------------------------------+
//| INITIALIZATION                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Initialize all utilities                                         |
//+------------------------------------------------------------------+
bool InitializeUtilities()
{
   ResetUtilities();
   
   if(!LoadUtilitySettings())
      return false;
   
   if(!InitializeSymbolCache())
      return false;
   
   if(!InitializeTimeCache())
      return false;
   
   if(!InitializePriceCache())
      return false;
   
   if(!ValidateUtilities())
      return false;
   
   return true;
}

//+------------------------------------------------------------------+
//| Load utility settings from inputs or defaults                    |
//+------------------------------------------------------------------+
bool LoadUtilitySettings()
{
   // Settings can be loaded from input parameters
   // For now, use defaults
   return true;
}

//+------------------------------------------------------------------+
//| Initialize symbol cache with current symbol data                 |
//+------------------------------------------------------------------+
bool InitializeSymbolCache()
{
   return UpdateSymbolInformation();
}

//+------------------------------------------------------------------+
//| Initialize time cache                                            |
//+------------------------------------------------------------------+
bool InitializeTimeCache()
{
   return UpdateTime();
}

//+------------------------------------------------------------------+
//| Initialize price cache                                           |
//+------------------------------------------------------------------+
bool InitializePriceCache()
{
   return UpdatePrices();
}

//+------------------------------------------------------------------+
//| Validate utilities initialization                                |
//+------------------------------------------------------------------+
bool ValidateUtilities()
{
   return ValidateSymbol() && ValidatePrices() && ValidateTime();
}

//+------------------------------------------------------------------+
//| Reset all utilities to default state                             |
//+------------------------------------------------------------------+
void ResetUtilities()
{
   ClearCaches();
   
   g_symbol_name = "";
   g_symbol_digits = 0;
   g_symbol_point = 0.0;
   g_symbol_tick_size = 0.0;
   g_symbol_tick_value = 0.0;
   g_symbol_contract_size = 0.0;
   g_symbol_tick_value_profit = 0.0;
   g_symbol_tick_value_loss = 0.0;
   g_symbol_volume_min = 0.0;
   g_symbol_volume_max = 0.0;
   g_symbol_volume_step = 0.0;
   g_symbol_trade_allowed = 0;
   g_symbol_stop_level = 0;
   g_symbol_freeze_level = 0;
   
   g_price_bid = 0.0;
   g_price_ask = 0.0;
   g_price_mid = 0.0;
   g_price_last = 0.0;
   g_price_spread = 0.0;
   g_price_spread_points = 0.0;
   g_price_spread_pips = 0.0;
   
   g_candle_current_time = 0;
   g_candle_current_open = 0.0;
   g_candle_current_high = 0.0;
   g_candle_current_low = 0.0;
   g_candle_current_close = 0.0;
   g_candle_current_volume = 0;
   g_candle_current_body = 0.0;
   g_candle_current_range = 0.0;
   
   g_candle_prev_time = 0;
   g_candle_prev_open = 0.0;
   g_candle_prev_high = 0.0;
   g_candle_prev_low = 0.0;
   g_candle_prev_close = 0.0;
   g_candle_prev_volume = 0;
   g_candle_prev_body = 0.0;
   g_candle_prev_range = 0.0;
   
   g_account_balance = 0.0;
   g_account_equity = 0.0;
   g_account_margin = 0.0;
   g_account_free_margin = 0.0;
   g_account_margin_level = 0.0;
   g_account_profit = 0.0;
   g_account_floating_profit = 0.0;
   g_account_drawdown = 0.0;
   g_account_leverage = 0.0;
   
   g_time_server = 0;
   g_time_local = 0;
   g_time_gmt = 0;
   g_time_bar = 0;
   g_time_elapsed = 0;
   g_last_bar_time = 0;
   g_last_trade_time = 0;
   
   g_session_is_open = false;
   g_session_is_trading_day = false;
   g_session_is_weekend = false;
   g_session_is_holiday = false;
   g_session_new_bar = false;
   
   g_position_ticket = 0;
   g_position_type = WRONG_VALUE;
   g_position_volume = 0.0;
   g_position_entry_price = 0.0;
   g_position_current_price = 0.0;
   g_position_sl = 0.0;
   g_position_tp = 0.0;
   g_position_profit = 0.0;
   g_position_swap = 0.0;
   g_position_commission = 0.0;
   g_position_open_time = 0;
   g_position_peak_profit = 0.0;
   g_position_exists = false;
}

//+------------------------------------------------------------------+
//| Shutdown utilities and clear resources                           |
//+------------------------------------------------------------------+
void ShutdownUtilities()
{
   ClearCaches();
   ResetUtilities();
}

//+------------------------------------------------------------------+
//| Clear all caches                                                 |
//+------------------------------------------------------------------+
void ClearCaches()
{
   // Caches are cleared via ResetUtilities
   // Additional cleanup can be added here if needed
}

//+------------------------------------------------------------------+
//| MARKET UTILITIES                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update all market data                                           |
//+------------------------------------------------------------------+
bool UpdateMarket()
{
   bool result = true;
   
   result &= UpdateSymbolInformation();
   result &= UpdatePrices();
   result &= UpdateCurrentCandle();
   result &= UpdatePreviousCandle();
   result &= UpdateSession();
   
   if(result)
   {
      result &= ValidateMarketData();
      PublishMarketData();
   }
   
   return result;
}

//+------------------------------------------------------------------+
//| Update symbol information                                        |
//+------------------------------------------------------------------+
bool UpdateSymbolInformation()
{
   bool result = true;
   
   result &= UpdateSymbol();
   result &= UpdateDigits();
   result &= UpdatePoint();
   result &= UpdateTickSize();
   result &= UpdateTickValue();
   result &= UpdateContractSize();
   result &= UpdateTickValueProfit();
   result &= UpdateTickValueLoss();
   
   return result && ValidateSymbolInformation();
}

//+------------------------------------------------------------------+
//| Update symbol name                                               |
//+------------------------------------------------------------------+
bool UpdateSymbol()
{
   g_symbol_name = Symbol();
   return (g_symbol_name != "");
}

//+------------------------------------------------------------------+
//| Update digits                                                    |
//+------------------------------------------------------------------+
bool UpdateDigits()
{
   g_symbol_digits = SymbolInfoInteger(g_symbol_name, SYMBOL_DIGITS);
   return (g_symbol_digits > 0);
}

//+------------------------------------------------------------------+
//| Update point value                                               |
//+------------------------------------------------------------------+
bool UpdatePoint()
{
   g_symbol_point = SymbolInfoDouble(g_symbol_name, SYMBOL_POINT);
   return (g_symbol_point > 0);
}

//+------------------------------------------------------------------+
//| Update tick size                                                 |
//+------------------------------------------------------------------+
bool UpdateTickSize()
{
   g_symbol_tick_size = SymbolInfoDouble(g_symbol_name, SYMBOL_TRADE_TICK_SIZE);
   return (g_symbol_tick_size > 0);
}

//+------------------------------------------------------------------+
//| Update tick value                                                |
//+------------------------------------------------------------------+
bool UpdateTickValue()
{
   g_symbol_tick_value = SymbolInfoDouble(g_symbol_name, SYMBOL_TRADE_TICK_VALUE);
   return (g_symbol_tick_value >= 0);
}

//+------------------------------------------------------------------+
//| Update contract size                                             |
//+------------------------------------------------------------------+
bool UpdateContractSize()
{
   g_symbol_contract_size = SymbolInfoDouble(g_symbol_name, SYMBOL_TRADE_CONTRACT_SIZE);
   return (g_symbol_contract_size > 0);
}

//+------------------------------------------------------------------+
//| Update tick value for profit calculation                         |
//+------------------------------------------------------------------+
bool UpdateTickValueProfit()
{
   g_symbol_tick_value_profit = g_symbol_tick_value;
   return true;
}

//+------------------------------------------------------------------+
//| Update tick value for loss calculation                           |
//+------------------------------------------------------------------+
bool UpdateTickValueLoss()
{
   g_symbol_tick_value_loss = g_symbol_tick_value;
   return true;
}

//+------------------------------------------------------------------+
//| Validate symbol information                                      |
//+------------------------------------------------------------------+
bool ValidateSymbolInformation()
{
   return (g_symbol_digits > 0 && g_symbol_point > 0 && g_symbol_tick_size > 0);
}

//+------------------------------------------------------------------+
//| Update all prices                                                |
//+------------------------------------------------------------------+
bool UpdatePrices()
{
   bool result = true;
   
   result &= UpdateBid();
   result &= UpdateAsk();
   
   if(result)
   {
      CalculateMidPrice();
      CalculateSpread();
      CalculateSpreadPoints();
      CalculateSpreadPips();
      UpdateLastPrice();
   }
   
   return result && ValidatePrices();
}

//+------------------------------------------------------------------+
//| Update bid price                                                 |
//+------------------------------------------------------------------+
bool UpdateBid()
{
   g_price_bid = SymbolInfoDouble(g_symbol_name, SYMBOL_BID);
   return (g_price_bid > 0);
}

//+------------------------------------------------------------------+
//| Update ask price                                                 |
//+------------------------------------------------------------------+
bool UpdateAsk()
{
   g_price_ask = SymbolInfoDouble(g_symbol_name, SYMBOL_ASK);
   return (g_price_ask > 0);
}

//+------------------------------------------------------------------+
//| Calculate mid price                                              |
//+------------------------------------------------------------------+
bool CalculateMidPrice()
{
   if(g_price_bid > 0 && g_price_ask > 0)
   {
      g_price_mid = (g_price_bid + g_price_ask) / 2.0;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Calculate spread in points                                       |
//+------------------------------------------------------------------+
bool CalculateSpread()
{
   if(g_price_bid > 0 && g_price_ask > 0)
   {
      g_price_spread = g_price_ask - g_price_bid;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Calculate spread in points                                       |
//+------------------------------------------------------------------+
bool CalculateSpreadPoints()
{
   if(g_price_spread > 0 && g_symbol_point > 0)
   {
      g_price_spread_points = g_price_spread / g_symbol_point;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Calculate spread in pips                                         |
//+------------------------------------------------------------------+
bool CalculateSpreadPips()
{
   if(g_price_spread_points > 0)
   {
      double pip_size = (g_symbol_digits == 5 || g_symbol_digits == 3) ? 10 : 1;
      g_price_spread_pips = g_price_spread_points / pip_size;
      return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//| Update last traded price                                         |
//+------------------------------------------------------------------+
bool UpdateLastPrice()
{
   double last = SymbolInfoDouble(g_symbol_name, SYMBOL_LAST);
   if(last > 0)
      g_price_last = last;
   else
      g_price_last = g_price_mid;
   
   return (g_price_last > 0);
}

//+------------------------------------------------------------------+
//| Validate prices                                                  |
//+------------------------------------------------------------------+
bool ValidatePrices()
{
   return (g_price_bid > 0 && g_price_ask > 0 && g_price_ask >= g_price_bid);
}

//+------------------------------------------------------------------+
//| Update current candle data                                       |
//+------------------------------------------------------------------+
bool UpdateCurrentCandle()
{
   bool result = true;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, _Period, 0, 1, &bar) == 1)
   {
      g_candle_current_time = bar.time;
      g_candle_current_open = bar.open;
      g_candle_current_high = bar.high;
      g_candle_current_low = bar.low;
      g_candle_current_close = bar.close;
      g_candle_current_volume = bar.tick_volume;
      
      result &= UpdateTime();
      CalculateCurrentBody();
      CalculateCurrentRange();
   }
   else
      result = false;
   
   return result && ValidateCurrentCandle();
}

//+------------------------------------------------------------------+
//| Update current open                                              |
//+------------------------------------------------------------------+
bool UpdateOpen()
{
   return true; // Already updated in UpdateCurrentCandle
}

//+------------------------------------------------------------------+
//| Update current high                                              |
//+------------------------------------------------------------------+
bool UpdateHigh()
{
   return true; // Already updated in UpdateCurrentCandle
}

//+------------------------------------------------------------------+
//| Update current low                                               |
//+------------------------------------------------------------------+
bool UpdateLow()
{
   return true; // Already updated in UpdateCurrentCandle
}

//+------------------------------------------------------------------+
//| Update current close                                             |
//+------------------------------------------------------------------+
bool UpdateClose()
{
   return true; // Already updated in UpdateCurrentCandle
}

//+------------------------------------------------------------------+
//| Update current volume                                            |
//+------------------------------------------------------------------+
bool UpdateVolume()
{
   return true; // Already updated in UpdateCurrentCandle
}

//+------------------------------------------------------------------+
//| Update current time                                              |
//+------------------------------------------------------------------+
bool UpdateTime()
{
   return true; // Handled separately
}

//+------------------------------------------------------------------+
//| Calculate current candle body                                    |
//+------------------------------------------------------------------+
bool CalculateCurrentBody()
{
   g_candle_current_body = MathAbs(g_candle_current_close - g_candle_current_open);
   return true;
}

//+------------------------------------------------------------------+
//| Calculate current candle range                                   |
//+------------------------------------------------------------------+
bool CalculateCurrentRange()
{
   g_candle_current_range = g_candle_current_high - g_candle_current_low;
   return true;
}

//+------------------------------------------------------------------+
//| Validate current candle                                          |
//+------------------------------------------------------------------+
bool ValidateCurrentCandle()
{
   return (g_candle_current_time > 0 && g_candle_current_high >= g_candle_current_low);
}

//+------------------------------------------------------------------+
//| Update previous candle data                                      |
//+------------------------------------------------------------------+
bool UpdatePreviousCandle()
{
   bool result = true;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, _Period, 1, 1, &bar) == 1)
   {
      g_candle_prev_time = bar.time;
      g_candle_prev_open = bar.open;
      g_candle_prev_high = bar.high;
      g_candle_prev_low = bar.low;
      g_candle_prev_close = bar.close;
      g_candle_prev_volume = bar.tick_volume;
      
      CalculatePreviousBody();
      CalculatePreviousRange();
   }
   else
      result = false;
   
   return result && ValidatePreviousCandle();
}

//+------------------------------------------------------------------+
//| Update previous open                                             |
//+------------------------------------------------------------------+
bool UpdatePreviousOpen()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Update previous high                                             |
//+------------------------------------------------------------------+
bool UpdatePreviousHigh()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Update previous low                                              |
//+------------------------------------------------------------------+
bool UpdatePreviousLow()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Update previous close                                            |
//+------------------------------------------------------------------+
bool UpdatePreviousClose()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Update previous volume                                           |
//+------------------------------------------------------------------+
bool UpdatePreviousVolume()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Update previous time                                             |
//+------------------------------------------------------------------+
bool UpdatePreviousTime()
{
   return true; // Already updated
}

//+------------------------------------------------------------------+
//| Calculate previous candle body                                   |
//+------------------------------------------------------------------+
bool CalculatePreviousBody()
{
   g_candle_prev_body = MathAbs(g_candle_prev_close - g_candle_prev_open);
   return true;
}

//+------------------------------------------------------------------+
//| Calculate previous candle range                                  |
//+------------------------------------------------------------------+
bool CalculatePreviousRange()
{
   g_candle_prev_range = g_candle_prev_high - g_candle_prev_low;
   return true;
}

//+------------------------------------------------------------------+
//| Validate previous candle                                         |
//+------------------------------------------------------------------+
bool ValidatePreviousCandle()
{
   return (g_candle_prev_time > 0 && g_candle_prev_high >= g_candle_prev_low);
}

//+------------------------------------------------------------------+
//| Update session information                                       |
//+------------------------------------------------------------------+
bool UpdateSession()
{
   DetectTradingSession();
   DetectTradingDay();
   DetectNewBar();
   CheckMarketOpen();
   CheckTradingHours();
   CheckWeekend();
   CheckHoliday();
   
   return true;
}

//+------------------------------------------------------------------+
//| Detect if market is in trading session                           |
//+------------------------------------------------------------------+
bool DetectTradingSession()
{
   // Simple implementation - can be enhanced with specific session times
   g_session_is_open = !g_session_is_weekend && !g_session_is_holiday;
   return g_session_is_open;
}

//+------------------------------------------------------------------+
//| Detect if current day is a trading day                           |
//+------------------------------------------------------------------+
bool DetectTradingDay()
{
   datetime now = TimeCurrent();
   int day_of_week = TimeDayOfWeek(now);
   
   g_session_is_trading_day = (day_of_week >= 1 && day_of_week <= 5); // Mon-Fri
   return g_session_is_trading_day;
}

//+------------------------------------------------------------------+
//| Detect if a new bar has formed                                   |
//+------------------------------------------------------------------+
bool DetectNewBar()
{
   g_session_new_bar = (g_candle_current_time > g_last_bar_time);
   
   if(g_session_new_bar)
      g_last_bar_time = g_candle_current_time;
   
   return g_session_new_bar;
}

//+------------------------------------------------------------------+
//| Check if market is open                                          |
//+------------------------------------------------------------------+
bool CheckMarketOpen()
{
   g_session_is_open = MarketInfo(g_symbol_name, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED;
   return g_session_is_open;
}

//+------------------------------------------------------------------+
//| Check if within trading hours                                    |
//+------------------------------------------------------------------+
bool CheckTradingHours()
{
   // Can be enhanced with specific hour filters
   return g_session_is_open;
}

//+------------------------------------------------------------------+
//| Check if current day is weekend                                  |
//+------------------------------------------------------------------+
bool CheckWeekend()
{
   datetime now = TimeCurrent();
   int day_of_week = TimeDayOfWeek(now);
   
   g_session_is_weekend = (day_of_week == 0 || day_of_week == 6); // Sat or Sun
   return g_session_is_weekend;
}

//+------------------------------------------------------------------+
//| Check if current day is holiday                                  |
//+------------------------------------------------------------------+
bool CheckHoliday()
{
   // Simplified - would need holiday calendar for full implementation
   g_session_is_holiday = false;
   return g_session_is_holiday;
}

//+------------------------------------------------------------------+
//| Validate all market data                                         |
//+------------------------------------------------------------------+
bool ValidateMarketData()
{
   bool result = true;
   
   result &= ValidateSymbol();
   result &= ValidatePrices();
   result &= ValidateCandles();
   result &= ValidateSession();
   result &= ValidateMarketState();
   
   return result;
}

//+------------------------------------------------------------------+
//| Validate symbol                                                  |
//+------------------------------------------------------------------+
bool ValidateSymbol()
{
   return (g_symbol_name != "" && g_symbol_digits > 0);
}

//+------------------------------------------------------------------+
//| Validate candles                                                 |
//+------------------------------------------------------------------+
bool ValidateCandles()
{
   return ValidateCurrentCandle() && ValidatePreviousCandle();
}

//+------------------------------------------------------------------+
//| Validate session                                                 |
//+------------------------------------------------------------------+
bool ValidateSession()
{
   return true; // Session data is always valid once set
}

//+------------------------------------------------------------------+
//| Validate market state                                            |
//+------------------------------------------------------------------+
bool ValidateMarketState()
{
   return (g_price_bid > 0 && g_price_ask > 0);
}

//+------------------------------------------------------------------+
//| Publish market data (for debugging/logging)                      |
//+------------------------------------------------------------------+
void PublishMarketData()
{
   // Can be connected to logging system
   // Print("Market: ", g_symbol_name, " Bid: ", g_price_bid, " Ask: ", g_price_ask);
}

//+------------------------------------------------------------------+
//| ACCOUNT UTILITIES                                                |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update all account information                                   |
//+------------------------------------------------------------------+
bool UpdateAccount()
{
   bool result = true;
   
   g_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   g_account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   g_account_margin = AccountInfoDouble(ACCOUNT_MARGIN);
   g_account_free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   g_account_margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   g_account_profit = AccountInfoDouble(ACCOUNT_PROFIT);
   g_account_floating_profit = AccountInfoDouble(ACCOUNT_FLOATING_PROFIT);
   g_account_drawdown = AccountInfoDouble(ACCOUNT_DRAWDOWN);
   g_account_leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   
   result &= ValidateAccount();
   
   return result;
}

//+------------------------------------------------------------------+
//| Update balance                                                   |
//+------------------------------------------------------------------+
bool UpdateBalance()
{
   g_account_balance = AccountInfoDouble(ACCOUNT_BALANCE);
   return (g_account_balance >= 0);
}

//+------------------------------------------------------------------+
//| Update equity                                                    |
//+------------------------------------------------------------------+
bool UpdateEquity()
{
   g_account_equity = AccountInfoDouble(ACCOUNT_EQUITY);
   return (g_account_equity >= 0);
}

//+------------------------------------------------------------------+
//| Update margin                                                    |
//+------------------------------------------------------------------+
bool UpdateMargin()
{
   g_account_margin = AccountInfoDouble(ACCOUNT_MARGIN);
   return true;
}

//+------------------------------------------------------------------+
//| Update free margin                                               |
//+------------------------------------------------------------------+
bool UpdateFreeMargin()
{
   g_account_free_margin = AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   return true;
}

//+------------------------------------------------------------------+
//| Update margin level                                              |
//+------------------------------------------------------------------+
bool UpdateMarginLevel()
{
   g_account_margin_level = AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   return true;
}

//+------------------------------------------------------------------+
//| Update profit                                                    |
//+------------------------------------------------------------------+
bool UpdateProfit()
{
   g_account_profit = AccountInfoDouble(ACCOUNT_PROFIT);
   return true;
}

//+------------------------------------------------------------------+
//| Update floating profit                                           |
//+------------------------------------------------------------------+
bool UpdateFloatingProfit()
{
   g_account_floating_profit = AccountInfoDouble(ACCOUNT_FLOATING_PROFIT);
   return true;
}

//+------------------------------------------------------------------+
//| Update drawdown                                                  |
//+------------------------------------------------------------------+
bool UpdateDrawdown()
{
   g_account_drawdown = AccountInfoDouble(ACCOUNT_DRAWDOWN);
   return true;
}

//+------------------------------------------------------------------+
//| Update leverage                                                  |
//+------------------------------------------------------------------+
bool UpdateLeverage()
{
   g_account_leverage = AccountInfoInteger(ACCOUNT_LEVERAGE);
   return (g_account_leverage > 0);
}

//+------------------------------------------------------------------+
//| Validate account data                                            |
//+------------------------------------------------------------------+
bool ValidateAccount()
{
   return (g_account_equity > 0 && g_account_balance >= 0);
}

//+------------------------------------------------------------------+
//| POSITION UTILITIES                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Refresh position state for current symbol                        |
//+------------------------------------------------------------------+
bool RefreshPositionState()
{
   g_position_exists = false;
   
   if(PositionSelect(g_symbol_name))
   {
      g_position_exists = true;
      
      bool result = true;
      
      result &= ReadPosition();
      result &= UpdatePositionType();
      result &= UpdatePositionVolume();
      result &= UpdateEntryPrice();
      result &= UpdateCurrentPrice();
      result &= UpdateStopLoss();
      result &= UpdateTakeProfit();
      result &= UpdateProfit();
      result &= UpdateSwap();
      result &= UpdateCommission();
      result &= UpdatePositionAge();
      result &= UpdatePeakProfit();
      
      return result && ValidatePosition();
   }
   
   return true; // No position is also valid
}

//+------------------------------------------------------------------+
//| Read position data                                               |
//+------------------------------------------------------------------+
bool ReadPosition()
{
   g_position_ticket = PositionGetInteger(POSITION_TICKET);
   return (g_position_ticket > 0);
}

//+------------------------------------------------------------------+
//| Update position type                                             |
//+------------------------------------------------------------------+
bool UpdatePositionType()
{
   g_position_type = (ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
   return (g_position_type == POSITION_TYPE_BUY || g_position_type == POSITION_TYPE_SELL);
}

//+------------------------------------------------------------------+
//| Update position volume                                           |
//+------------------------------------------------------------------+
bool UpdatePositionVolume()
{
   g_position_volume = PositionGetDouble(POSITION_VOLUME);
   return (g_position_volume > 0);
}

//+------------------------------------------------------------------+
//| Update entry price                                               |
//+------------------------------------------------------------------+
bool UpdateEntryPrice()
{
   g_position_entry_price = PositionGetDouble(POSITION_PRICE_OPEN);
   return (g_position_entry_price > 0);
}

//+------------------------------------------------------------------+
//| Update current price                                             |
//+------------------------------------------------------------------+
bool UpdateCurrentPrice()
{
   if(g_position_type == POSITION_TYPE_BUY)
      g_position_current_price = g_price_bid;
   else if(g_position_type == POSITION_TYPE_SELL)
      g_position_current_price = g_price_ask;
   
   return (g_position_current_price > 0);
}

//+------------------------------------------------------------------+
//| Update stop loss                                                 |
//+------------------------------------------------------------------+
bool UpdateStopLoss()
{
   g_position_sl = PositionGetDouble(POSITION_SL);
   return true; // SL can be 0
}

//+------------------------------------------------------------------+
//| Update take profit                                               |
//+------------------------------------------------------------------+
bool UpdateTakeProfit()
{
   g_position_tp = PositionGetDouble(POSITION_TP);
   return true; // TP can be 0
}

//+------------------------------------------------------------------+
//| Update position profit                                           |
//+------------------------------------------------------------------+
bool UpdateProfit()
{
   g_position_profit = PositionGetDouble(POSITION_PROFIT);
   return true;
}

//+------------------------------------------------------------------+
//| Update swap                                                      |
//+------------------------------------------------------------------+
bool UpdateSwap()
{
   g_position_swap = PositionGetDouble(POSITION_SWAP);
   return true;
}

//+------------------------------------------------------------------+
//| Update commission                                                |
//+------------------------------------------------------------------+
bool UpdateCommission()
{
   g_position_commission = PositionGetDouble(POSITION_COMMISSION);
   return true;
}

//+------------------------------------------------------------------+
//| Update position age                                              |
//+------------------------------------------------------------------+
bool UpdatePositionAge()
{
   g_position_open_time = (datetime)PositionGetInteger(POSITION_TIME);
   return true;
}

//+------------------------------------------------------------------+
//| Update peak profit                                               |
//+------------------------------------------------------------------+
bool UpdatePeakProfit()
{
   if(g_position_profit > g_position_peak_profit)
      g_position_peak_profit = g_position_profit;
   
   return true;
}

//+------------------------------------------------------------------+
//| Validate position data                                           |
//+------------------------------------------------------------------+
bool ValidatePosition()
{
   if(!g_position_exists)
      return true;
   
   return (g_position_volume > 0 && g_position_entry_price > 0);
}

//+------------------------------------------------------------------+
//| TIME UTILITIES                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Update all time information                                      |
//+------------------------------------------------------------------+
bool UpdateTime()
{
   bool result = true;
   
   result &= UpdateServerTime();
   result &= UpdateLocalTime();
   result &= UpdateGMTTime();
   result &= UpdateBarTime();
   result &= UpdateElapsedTime();
   
   return result && ValidateTime();
}

//+------------------------------------------------------------------+
//| Update server time                                               |
//+------------------------------------------------------------------+
bool UpdateServerTime()
{
   g_time_server = TimeCurrent();
   return (g_time_server > 0);
}

//+------------------------------------------------------------------+
//| Update local time                                                |
//+------------------------------------------------------------------+
bool UpdateLocalTime()
{
   g_time_local = TimeLocal();
   return (g_time_local > 0);
}

//+------------------------------------------------------------------+
//| Update GMT time                                                  |
//+------------------------------------------------------------------+
bool UpdateGMTTime()
{
   g_time_gmt = TimeGMT();
   return (g_time_gmt > 0);
}

//+------------------------------------------------------------------+
//| Update bar time                                                  |
//+------------------------------------------------------------------+
bool UpdateBarTime()
{
   g_time_bar = g_candle_current_time;
   return (g_time_bar > 0);
}

//+------------------------------------------------------------------+
//| Update elapsed time since start                                  |
//+------------------------------------------------------------------+
bool UpdateElapsedTime()
{
   static datetime start_time = 0;
   
   if(start_time == 0)
      start_time = g_time_server;
   
   g_time_elapsed = g_time_server - start_time;
   return true;
}

//+------------------------------------------------------------------+
//| Validate time data                                               |
//+------------------------------------------------------------------+
bool ValidateTime()
{
   return (g_time_server > 0);
}

//+------------------------------------------------------------------+
//| Check if new bar has formed                                      |
//+------------------------------------------------------------------+
bool IsNewBar()
{
   return g_session_new_bar;
}

//+------------------------------------------------------------------+
//| Check if market is open                                          |
//+------------------------------------------------------------------+
bool MarketOpen()
{
   return g_session_is_open;
}

//+------------------------------------------------------------------+
//| Get current trading session                                      |
//+------------------------------------------------------------------+
string TradingSession()
{
   if(g_session_is_weekend)
      return "WEEKEND";
   if(g_session_is_holiday)
      return "HOLIDAY";
   if(!g_session_is_open)
      return "CLOSED";
   
   int hour = TimeHour(g_time_server);
   
   if(hour >= 0 && hour < 8)
      return "ASIA";
   if(hour >= 8 && hour < 16)
      return "EUROPE";
   if(hour >= 13 && hour < 22)
      return "US";
   
   return "OVERLAP";
}

//+------------------------------------------------------------------+
//| Check if current day is trading day                              |
//+------------------------------------------------------------------+
bool TradingDay()
{
   return g_session_is_trading_day;
}

//+------------------------------------------------------------------+
//| Get seconds since last bar                                       |
//+------------------------------------------------------------------+
long TimeSinceBar()
{
   if(g_candle_current_time == 0)
      return 0;
   
   return (g_time_server - g_candle_current_time);
}

//+------------------------------------------------------------------+
//| Get seconds since last trade                                     |
//+------------------------------------------------------------------+
long TimeSinceTrade()
{
   if(g_last_trade_time == 0)
      return LONG_MAX;
   
   return (g_time_server - g_last_trade_time);
}

//+------------------------------------------------------------------+
//| Get seconds until next bar                                       |
//+------------------------------------------------------------------+
long SecondsToNextBar()
{
   if(g_candle_current_time == 0)
      return 0;
   
   MqlDateTime dt;
   TimeToStruct(g_candle_current_time, dt);
   
   datetime next_bar = StructToTime(dt) + PeriodSeconds(_Period);
   
   return (next_bar - g_time_server);
}

//+------------------------------------------------------------------+
//| PRICE UTILITIES                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Normalize price to symbol digits                                 |
//+------------------------------------------------------------------+
double NormalizePrice(double price)
{
   if(price <= 0)
      return 0;
   
   return NormalizeDouble(price, (int)g_symbol_digits);
}

//+------------------------------------------------------------------+
//| Normalize volume to symbol step                                  |
//+------------------------------------------------------------------+
double NormalizeVolume(double volume)
{
   if(volume <= 0)
      return 0;
   
   return NormalizeDouble(volume, 2);
}

//+------------------------------------------------------------------+
//| Normalize lots to symbol constraints                             |
//+------------------------------------------------------------------+
double NormalizeLots(double lots)
{
   if(lots <= 0)
      return 0;
   
   double min_lot = g_symbol_volume_min > 0 ? g_symbol_volume_min : 0.01;
   double max_lot = g_symbol_volume_max > 0 ? g_symbol_volume_max : 100.0;
   double lot_step = g_symbol_volume_step > 0 ? g_symbol_volume_step : 0.01;
   
   lots = MathFloor(lots / lot_step) * lot_step;
   lots = MathMax(min_lot, MathMin(max_lot, lots));
   
   return NormalizeDouble(lots, 2);
}

//+------------------------------------------------------------------+
//| Normalize stop loss distance                                     |
//+------------------------------------------------------------------+
double NormalizeStopLoss(double sl_points)
{
   if(sl_points <= 0)
      return 0;
   
   double min_stop = g_symbol_stop_level > 0 ? g_symbol_stop_level : 0;
   
   return MathMax(sl_points, (double)min_stop);
}

//+------------------------------------------------------------------+
//| Normalize take profit distance                                   |
//+------------------------------------------------------------------+
double NormalizeTakeProfit(double tp_points)
{
   if(tp_points <= 0)
      return 0;
   
   double min_stop = g_symbol_stop_level > 0 ? g_symbol_stop_level : 0;
   
   return MathMax(tp_points, (double)min_stop);
}

//+------------------------------------------------------------------+
//| Round price to tick size                                         |
//+------------------------------------------------------------------+
double RoundPrice(double price)
{
   if(price <= 0 || g_symbol_tick_size <= 0)
      return price;
   
   return MathRound(price / g_symbol_tick_size) * g_symbol_tick_size;
}

//+------------------------------------------------------------------+
//| Round lots to lot step                                           |
//+------------------------------------------------------------------+
double RoundLots(double lots)
{
   if(lots <= 0 || g_symbol_volume_step <= 0)
      return lots;
   
   return MathRound(lots / g_symbol_volume_step) * g_symbol_volume_step;
}

//+------------------------------------------------------------------+
//| SPREAD UTILITIES                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get current spread in points                                     |
//+------------------------------------------------------------------+
double CurrentSpread()
{
   return g_price_spread_points;
}

//+------------------------------------------------------------------+
//| Get spread in points                                             |
//+------------------------------------------------------------------+
double SpreadPoints()
{
   return g_price_spread_points;
}

//+------------------------------------------------------------------+
//| Get spread in pips                                               |
//+------------------------------------------------------------------+
double SpreadPips()
{
   return g_price_spread_pips;
}

//+------------------------------------------------------------------+
//| Check if spread is acceptable                                    |
//+------------------------------------------------------------------+
bool SpreadAcceptable(double max_spread_pips)
{
   return (g_price_spread_pips <= max_spread_pips);
}

//+------------------------------------------------------------------+
//| CANDLE UTILITIES                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get candle body size                                             |
//+------------------------------------------------------------------+
double CandleBody(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return 0;
   
   return MathAbs(bar.close - bar.open);
}

//+------------------------------------------------------------------+
//| Get body as percentage of range                                  |
//+------------------------------------------------------------------+
double BodyPercent(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return 0;
   
   double range = bar.high - bar.low;
   if(range == 0)
      return 0;
   
   double body = MathAbs(bar.close - bar.open);
   return (body / range) * 100.0;
}

//+------------------------------------------------------------------+
//| Get candle range                                                 |
//+------------------------------------------------------------------+
double CandleRange(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return 0;
   
   return bar.high - bar.low;
}

//+------------------------------------------------------------------+
//| Get upper wick size                                              |
//+------------------------------------------------------------------+
double UpperWick(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return 0;
   
   double high = MathMax(bar.open, bar.close);
   return bar.high - high;
}

//+------------------------------------------------------------------+
//| Get lower wick size                                              |
//+------------------------------------------------------------------+
double LowerWick(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return 0;
   
   double low = MathMin(bar.open, bar.close);
   return low - bar.low;
}

//+------------------------------------------------------------------+
//| Get upper wick as percentage                                     |
//+------------------------------------------------------------------+
double UpperWickPercent(datetime bar_time, int timeframe = 0)
{
   double range = CandleRange(bar_time, timeframe);
   if(range == 0)
      return 0;
   
   return (UpperWick(bar_time, timeframe) / range) * 100.0;
}

//+------------------------------------------------------------------+
//| Get lower wick as percentage                                     |
//+------------------------------------------------------------------+
double LowerWickPercent(datetime bar_time, int timeframe = 0)
{
   double range = CandleRange(bar_time, timeframe);
   if(range == 0)
      return 0;
   
   return (LowerWick(bar_time, timeframe) / range) * 100.0;
}

//+------------------------------------------------------------------+
//| Check if candle is bullish                                       |
//+------------------------------------------------------------------+
bool BullishBody(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return false;
   
   return (bar.close > bar.open);
}

//+------------------------------------------------------------------+
//| Check if candle is bearish                                       |
//+------------------------------------------------------------------+
bool BearishBody(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return false;
   
   return (bar.close < bar.open);
}

//+------------------------------------------------------------------+
//| Check if candle is doji                                          |
//+------------------------------------------------------------------+
bool Doji(datetime bar_time, int timeframe = 0)
{
   double body_pct = BodyPercent(bar_time, timeframe);
   return (body_pct < 10.0); // Body less than 10% of range
}

//+------------------------------------------------------------------+
//| Check if candle is strong bullish                                |
//+------------------------------------------------------------------+
bool StrongBullish(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return false;
   
   double body_pct = BodyPercent(bar_time, timeframe);
   return (bar.close > bar.open && body_pct > 70.0);
}

//+------------------------------------------------------------------+
//| Check if candle is strong bearish                                |
//+------------------------------------------------------------------+
bool StrongBearish(datetime bar_time, int timeframe = 0)
{
   if(timeframe == 0)
      timeframe = _Period;
   
   MqlBar bar;
   if(CopyRates(g_symbol_name, timeframe, bar_time, 1, &bar) != 1)
      return false;
   
   double body_pct = BodyPercent(bar_time, timeframe);
   return (bar.close < bar.open && body_pct > 70.0);
}

//+------------------------------------------------------------------+
//| PRICE ACTION UTILITIES                                           |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if breakout occurred                                       |
//+------------------------------------------------------------------+
bool BreakoutOccurred(double level, int lookback = 20)
{
   double highest_high = 0;
   double lowest_low = DBL_MAX;
   
   for(int i = 1; i <= lookback; i++)
   {
      MqlBar bar;
      if(CopyRates(g_symbol_name, _Period, i, 1, &bar) == 1)
      {
         highest_high = MathMax(highest_high, bar.high);
         lowest_low = MathMin(lowest_low, bar.low);
      }
   }
   
   return (g_candle_current_high > highest_high || g_candle_current_low < lowest_low);
}

//+------------------------------------------------------------------+
//| Check if false breakout occurred                                 |
//+------------------------------------------------------------------+
bool FalseBreakout(double level, int lookback = 20)
{
   if(!BreakoutOccurred(level, lookback))
      return false;
   
   // Check if price closed back inside the range
   double highest_high = 0;
   double lowest_low = DBL_MAX;
   
   for(int i = 1; i <= lookback; i++)
   {
      MqlBar bar;
      if(CopyRates(g_symbol_name, _Period, i, 1, &bar) == 1)
      {
         highest_high = MathMax(highest_high, bar.high);
         lowest_low = MathMin(lowest_low, bar.low);
      }
   }
   
   bool broke_high = (g_candle_current_high > highest_high);
   bool broke_low = (g_candle_current_low < lowest_low);
   
   if(broke_high && g_candle_current_close <= highest_high)
      return true;
   if(broke_low && g_candle_current_close >= lowest_low)
      return true;
   
   return false;
}

//+------------------------------------------------------------------+
//| Check if gap detected                                            |
//+------------------------------------------------------------------+
bool GapDetected(double gap_threshold = 0)
{
   if(gap_threshold == 0)
      gap_threshold = g_symbol_point * 10; // Default 10 points
   
   double gap = MathAbs(g_candle_current_open - g_candle_prev_close);
   return (gap > gap_threshold);
}

//+------------------------------------------------------------------+
//| Check for higher high                                            |
//+------------------------------------------------------------------+
bool HigherHigh(int bars_back = 1)
{
   if(bars_back < 1)
      return false;
   
   MqlBar current_bar, prev_bar;
   
   if(CopyRates(g_symbol_name, _Period, 0, 1, &current_bar) != 1)
      return false;
   if(CopyRates(g_symbol_name, _Period, bars_back, 1, &prev_bar) != 1)
      return false;
   
   return (current_bar.high > prev_bar.high);
}

//+------------------------------------------------------------------+
//| Check for higher low                                             |
//+------------------------------------------------------------------+
bool HigherLow(int bars_back = 1)
{
   if(bars_back < 1)
      return false;
   
   MqlBar current_bar, prev_bar;
   
   if(CopyRates(g_symbol_name, _Period, 0, 1, &current_bar) != 1)
      return false;
   if(CopyRates(g_symbol_name, _Period, bars_back, 1, &prev_bar) != 1)
      return false;
   
   return (current_bar.low > prev_bar.low);
}

//+------------------------------------------------------------------+
//| Check for lower high                                             |
//+------------------------------------------------------------------+
bool LowerHigh(int bars_back = 1)
{
   if(bars_back < 1)
      return false;
   
   MqlBar current_bar, prev_bar;
   
   if(CopyRates(g_symbol_name, _Period, 0, 1, &current_bar) != 1)
      return false;
   if(CopyRates(g_symbol_name, _Period, bars_back, 1, &prev_bar) != 1)
      return false;
   
   return (current_bar.high < prev_bar.high);
}

//+------------------------------------------------------------------+
//| Check for lower low                                              |
//+------------------------------------------------------------------+
bool LowerLow(int bars_back = 1)
{
   if(bars_back < 1)
      return false;
   
   MqlBar current_bar, prev_bar;
   
   if(CopyRates(g_symbol_name, _Period, 0, 1, &current_bar) != 1)
      return false;
   if(CopyRates(g_symbol_name, _Period, bars_back, 1, &prev_bar) != 1)
      return false;
   
   return (current_bar.low < prev_bar.low);
}

//+------------------------------------------------------------------+
//| BROKER UTILITIES                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get broker stop level                                            |
//+------------------------------------------------------------------+
long BrokerStopLevel()
{
   return g_symbol_stop_level;
}

//+------------------------------------------------------------------+
//| Get freeze level                                                 |
//+------------------------------------------------------------------+
long FreezeLevel()
{
   return g_symbol_freeze_level;
}

//+------------------------------------------------------------------+
//| Get minimum lot size                                             |
//+------------------------------------------------------------------+
double MinimumLot()
{
   return g_symbol_volume_min;
}

//+------------------------------------------------------------------+
//| Get maximum lot size                                             |
//+------------------------------------------------------------------+
double MaximumLot()
{
   return g_symbol_volume_max;
}

//+------------------------------------------------------------------+
//| Get lot step                                                     |
//+------------------------------------------------------------------+
double LotStep()
{
   return g_symbol_volume_step;
}

//+------------------------------------------------------------------+
//| Get maximum orders allowed                                       |
//+------------------------------------------------------------------+
long MaximumOrders()
{
   return SymbolInfoInteger(g_symbol_name, SYMBOL_TRADE_ORDERS_TOTAL);
}

//+------------------------------------------------------------------+
//| Check if trading is allowed                                      |
//+------------------------------------------------------------------+
bool TradeAllowed()
{
   return (g_symbol_trade_allowed != 0 && MarketInfo(g_symbol_name, SYMBOL_TRADE_MODE) != SYMBOL_TRADE_MODE_DISABLED);
}

//+------------------------------------------------------------------+
//| ACCOUNT VALIDATION                                               |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if enough margin for trade                                 |
//+------------------------------------------------------------------+
bool EnoughMargin(double required_margin)
{
   return (g_account_free_margin >= required_margin);
}

//+------------------------------------------------------------------+
//| Check if enough free margin                                      |
//+------------------------------------------------------------------+
bool EnoughFreeMargin(double amount)
{
   return (g_account_free_margin >= amount);
}

//+------------------------------------------------------------------+
//| Check if enough balance                                          |
//+------------------------------------------------------------------+
bool EnoughBalance(double amount)
{
   return (g_account_balance >= amount);
}

//+------------------------------------------------------------------+
//| POSITION VALIDATION                                              |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check if open position exists                                    |
//+------------------------------------------------------------------+
bool HasOpenPosition()
{
   return g_position_exists;
}

//+------------------------------------------------------------------+
//| Check if buy position exists                                     |
//+------------------------------------------------------------------+
bool HasBuyPosition()
{
   return (g_position_exists && g_position_type == POSITION_TYPE_BUY);
}

//+------------------------------------------------------------------+
//| Check if sell position exists                                    |
//+------------------------------------------------------------------+
bool HasSellPosition()
{
   return (g_position_exists && g_position_type == POSITION_TYPE_SELL);
}

//+------------------------------------------------------------------+
//| Get current position profit                                      |
//+------------------------------------------------------------------+
double PositionProfit()
{
   return g_position_profit;
}

//+------------------------------------------------------------------+
//| Check if position is in loss                                     |
//+------------------------------------------------------------------+
bool PositionLoss()
{
   return (g_position_profit < 0);
}

//+------------------------------------------------------------------+
//| Get position age in seconds                                      |
//+------------------------------------------------------------------+
long PositionAge()
{
   if(g_position_open_time == 0)
      return 0;
   
   return (g_time_server - g_position_open_time);
}

//+------------------------------------------------------------------+
//| Get position volume                                              |
//+------------------------------------------------------------------+
double PositionVolume()
{
   return g_position_volume;
}

//+------------------------------------------------------------------+
//| SYMBOL UTILITIES                                                 |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get pip value                                                    |
//+------------------------------------------------------------------+
double PipValue()
{
   double pip_size = (g_symbol_digits == 5 || g_symbol_digits == 3) ? 10 : 1;
   return g_symbol_tick_value * pip_size;
}

//+------------------------------------------------------------------+
//| Get point value                                                  |
//+------------------------------------------------------------------+
double PointValue()
{
   return g_symbol_point;
}

//+------------------------------------------------------------------+
//| Get tick value                                                   |
//+------------------------------------------------------------------+
double TickValue()
{
   return g_symbol_tick_value;
}

//+------------------------------------------------------------------+
//| Get tick size                                                    |
//+------------------------------------------------------------------+
double TickSize()
{
   return g_symbol_tick_size;
}

//+------------------------------------------------------------------+
//| Get contract size                                                |
//+------------------------------------------------------------------+
double ContractSize()
{
   return g_symbol_contract_size;
}

//+------------------------------------------------------------------+
//| Get symbol digits                                                |
//+------------------------------------------------------------------+
long Digits()
{
   return g_symbol_digits;
}

//+------------------------------------------------------------------+
//| MATH UTILITIES                                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Clamp value between min and max                                  |
//+------------------------------------------------------------------+
double Clamp(double value, double min_val, double max_val)
{
   return MathMax(min_val, MathMin(max_val, value));
}

//+------------------------------------------------------------------+
//| Linear interpolation                                             |
//+------------------------------------------------------------------+
double Lerp(double start, double end, double t)
{
   return start + (end - start) * Clamp(t, 0.0, 1.0);
}

//+------------------------------------------------------------------+
//| Map value from one range to another                              |
//+------------------------------------------------------------------+
double MapRange(double value, double in_min, double in_max, double out_min, double out_max)
{
   return (value - in_min) * (out_max - out_min) / (in_max - in_min) + out_min;
}

//+------------------------------------------------------------------+
//| Get minimum value                                                |
//+------------------------------------------------------------------+
double MinValue(double a, double b)
{
   return MathMin(a, b);
}

//+------------------------------------------------------------------+
//| Get maximum value                                                |
//+------------------------------------------------------------------+
double MaxValue(double a, double b)
{
   return MathMax(a, b);
}

//+------------------------------------------------------------------+
//| Get absolute value                                               |
//+------------------------------------------------------------------+
double Absolute(double value)
{
   return MathAbs(value);
}

//+------------------------------------------------------------------+
//| Get average of two values                                        |
//+------------------------------------------------------------------+
double Average(double a, double b)
{
   return (a + b) / 2.0;
}

//+------------------------------------------------------------------+
//| ARRAY UTILITIES                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Get array average                                                |
//+------------------------------------------------------------------+
double ArrayAverage(const double &arr[], int start = 0, int count = WHOLE_ARRAY)
{
   if(ArraySize(arr) == 0)
      return 0;
   
   double sum = 0;
   int actual_count = 0;
   
   int end = (count == WHOLE_ARRAY) ? ArraySize(arr) : start + count;
   
   for(int i = start; i < end && i < ArraySize(arr); i++)
   {
      sum += arr[i];
      actual_count++;
   }
   
   return (actual_count > 0) ? sum / actual_count : 0;
}

//+------------------------------------------------------------------+
//| Get array maximum                                                |
//+------------------------------------------------------------------+
double ArrayMaximum(const double &arr[], int start = 0, int count = WHOLE_ARRAY)
{
   if(ArraySize(arr) == 0)
      return EMPTY_VALUE;
   
   double max_val = arr[start];
   
   int end = (count == WHOLE_ARRAY) ? ArraySize(arr) : start + count;
   
   for(int i = start + 1; i < end && i < ArraySize(arr); i++)
   {
      max_val = MathMax(max_val, arr[i]);
   }
   
   return max_val;
}

//+------------------------------------------------------------------+
//| Get array minimum                                                |
//+------------------------------------------------------------------+
double ArrayMinimum(const double &arr[], int start = 0, int count = WHOLE_ARRAY)
{
   if(ArraySize(arr) == 0)
      return EMPTY_VALUE;
   
   double min_val = arr[start];
   
   int end = (count == WHOLE_ARRAY) ? ArraySize(arr) : start + count;
   
   for(int i = start + 1; i < end && i < ArraySize(arr); i++)
   {
      min_val = MathMin(min_val, arr[i]);
   }
   
   return min_val;
}

//+------------------------------------------------------------------+
//| Get array sum                                                    |
//+------------------------------------------------------------------+
double ArraySum(const double &arr[], int start = 0, int count = WHOLE_ARRAY)
{
   if(ArraySize(arr) == 0)
      return 0;
   
   double sum = 0;
   
   int end = (count == WHOLE_ARRAY) ? ArraySize(arr) : start + count;
   
   for(int i = start; i < end && i < ArraySize(arr); i++)
   {
      sum += arr[i];
   }
   
   return sum;
}

//+------------------------------------------------------------------+
//| Calculate array slope                                            |
//+------------------------------------------------------------------+
double ArraySlope(const double &arr[], int period = 14)
{
   if(ArraySize(arr) < period)
      return 0;
   
   double sum_x = 0, sum_y = 0, sum_xy = 0, sum_xx = 0;
   
   for(int i = 0; i < period; i++)
   {
      double x = i;
      double y = arr[ArraySize(arr) - period + i];
      
      sum_x += x;
      sum_y += y;
      sum_xy += x * y;
      sum_xx += x * x;
   }
   
   double denominator = period * sum_xx - sum_x * sum_x;
   if(denominator == 0)
      return 0;
   
   return (period * sum_xy - sum_x * sum_y) / denominator;
}

//+------------------------------------------------------------------+
//| VALIDATION                                                       |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Validate price                                                   |
//+------------------------------------------------------------------+
bool ValidatePrice(double price)
{
   return (price > 0 && price < 1e10);
}

//+------------------------------------------------------------------+
//| Validate volume                                                  |
//+------------------------------------------------------------------+
bool ValidateVolume(double volume)
{
   return (volume > 0 && volume <= g_symbol_volume_max);
}

//+------------------------------------------------------------------+
//| Validate lot size                                                |
//+------------------------------------------------------------------+
bool ValidateLot(double lots)
{
   return (lots >= g_symbol_volume_min && lots <= g_symbol_volume_max);
}

//+------------------------------------------------------------------+
//| Validate stop levels                                             |
//+------------------------------------------------------------------+
bool ValidateStops(double sl, double tp, double entry_price)
{
   if(sl > 0 && tp > 0)
   {
      double sl_dist = MathAbs(entry_price - sl) / g_symbol_point;
      double tp_dist = MathAbs(tp - entry_price) / g_symbol_point;
      
      return (sl_dist >= g_symbol_stop_level && tp_dist >= g_symbol_stop_level);
   }
   
   return true;
}

//+------------------------------------------------------------------+
//| Validate spread                                                  |
//+------------------------------------------------------------------+
bool ValidateSpread()
{
   return (g_price_spread_points >= 0 && g_price_spread_points < 1000);
}

//+------------------------------------------------------------------+
//| HELPERS                                                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Copy price to buffer                                             |
//+------------------------------------------------------------------+
bool CopyPrice(double &buffer[], int mode = MODE_CLOSE, int count = 100)
{
   return (CopyRates(g_symbol_name, _Period, mode, count, buffer) > 0);
}

//+------------------------------------------------------------------+
//| Copy rates to buffer                                             |
//+------------------------------------------------------------------+
bool CopyRates(MqlBar &buffer[], int count = 100)
{
   return (CopyRates(g_symbol_name, _Period, 0, count, buffer) > 0);
}

//+------------------------------------------------------------------+
//| Safe division                                                    |
//+------------------------------------------------------------------+
double SafeDivide(double numerator, double denominator, double default_value = 0)
{
   if(denominator == 0)
      return default_value;
   
   return numerator / denominator;
}

//+------------------------------------------------------------------+
//| Convert boolean to string                                        |
//+------------------------------------------------------------------+
string BoolToString(bool value)
{
   return value ? "true" : "false";
}

//+------------------------------------------------------------------+
//| Format price for display                                         |
//+------------------------------------------------------------------+
string FormatPrice(double price)
{
   return DoubleToString(price, (int)g_symbol_digits);
}

//+------------------------------------------------------------------+
//| Format lots for display                                          |
//+------------------------------------------------------------------+
string FormatLots(double lots)
{
   return DoubleToString(lots, 2);
}

//+------------------------------------------------------------------+
//| Format percent for display                                       |
//+------------------------------------------------------------------+
string FormatPercent(double value)
{
   return DoubleToString(value, 2) + "%";
}

//+------------------------------------------------------------------+
//| Format time for display                                          |
//+------------------------------------------------------------------+
string FormatTime(datetime time)
{
   return TimeToString(time, TIME_DATE | TIME_SECONDS);
}

//+------------------------------------------------------------------+
//| DEBUG                                                            |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Self test for utilities                                          |
//+------------------------------------------------------------------+
bool SelfTestUtilities()
{
   Print("=== Utilities Self Test ===");
   
   bool all_passed = true;
   
   // Test initialization
   if(!InitializeUtilities())
   {
      Print("FAIL: InitializeUtilities");
      all_passed = false;
   }
   else
      Print("PASS: InitializeUtilities");
   
   // Test market update
   if(!UpdateMarket())
   {
      Print("FAIL: UpdateMarket");
      all_passed = false;
   }
   else
      Print("PASS: UpdateMarket");
   
   // Test account update
   if(!UpdateAccount())
   {
      Print("FAIL: UpdateAccount");
      all_passed = false;
   }
   else
      Print("PASS: UpdateAccount");
   
   // Run validation
   RunValidation();
   
   Print("=== Self Test Complete ===");
   
   return all_passed;
}

//+------------------------------------------------------------------+
//| Run validation checks                                            |
//+------------------------------------------------------------------+
void RunValidation()
{
   Print("Running validation...");
   
   if(!ValidateSymbol())
      Print("WARNING: Symbol validation failed");
   
   if(!ValidatePrices())
      Print("WARNING: Price validation failed");
   
   if(!ValidateTime())
      Print("WARNING: Time validation failed");
   
   if(!ValidateAccount())
      Print("WARNING: Account validation failed");
   
   Print("Validation complete");
}

//+------------------------------------------------------------------+
//| Dump utilities state for debugging                               |
//+------------------------------------------------------------------+
void DumpUtilities()
{
   Print("=== Utilities State Dump ===");
   Print("Symbol: ", g_symbol_name);
   Print("Digits: ", g_symbol_digits);
   Print("Point: ", g_symbol_point);
   Print("Bid: ", g_price_bid);
   Print("Ask: ", g_price_ask);
   Print("Spread: ", g_price_spread_points, " points");
   Print("Balance: ", g_account_balance);
   Print("Equity: ", g_account_equity);
   Print("Time: ", TimeToString(g_time_server));
   Print("Position: ", g_position_exists ? "YES" : "NO");
   Print("========================");
}

#endif // UTILITIES_MQH
