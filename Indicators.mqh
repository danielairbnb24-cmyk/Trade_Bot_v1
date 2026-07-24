//+------------------------------------------------------------------+
//|                                               Indicators.mqh     |
//|                        Complete Indicator Engine with Slopes     |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Trade Bot v1"
#property version   "1.00"

#include "Structures.mqh"
#include "Utilities.mqh"

//+------------------------------------------------------------------+
//| Global Indicator State                                           |
//+------------------------------------------------------------------+
struct SIndicatorState
{
   // Handles
   int handle_ema_fast;
   int handle_ema_medium;
   int handle_ema_slow;
   int handle_rsi;
   int handle_adx;
   int handle_atr;
   int handle_wpr;
   
   // Buffers
   double ema_fast[];
   double ema_medium[];
   double ema_slow[];
   double rsi[];
   double adx[];
   double plus_di[];
   double minus_di[]
   double atr[];
   double wpr[];
   
   // Previous values for velocity/acceleration
   double prev_rsi;
   double prev_rsi_velocity;
   double prev_adx;
   double prev_adx_velocity;
   double prev_atr;
   double prev_wpr;
   
   // Filtered RSI (smoothed)
   double filtered_rsi;
   double smooth_rsi;  // Average of last 3 RSI points
   
   // EMA slopes and velocities
   double fast_ema_slope;
   double medium_ema_slope;
   double slow_ema_slope;
   double fast_ema_velocity;
   double medium_ema_velocity;
   double slow_ema_velocity;
   
   // RSI metrics
   double rsi_velocity;
   double rsi_acceleration;
   
   // ADX metrics
   double adx_slope;
   double adx_velocity;
   double adx_acceleration;
   
   // ATR metrics
   double atr_normalized;
   double atr_points;
   double atr_velocity;
   double atr_acceleration;
   
   // WPR metrics
   double wpr_velocity;
   
   // Candle analysis
   double candle_body;
   double candle_body_percent;
   double candle_range;
   double candle_upper_wick;
   double candle_lower_wick;
   double candle_upper_wick_percent;
   double candle_lower_wick_percent;
   int candle_direction;
   double candle_strength;
   bool is_doji;
   
   // Derived strengths
   double momentum_strength;
   double trend_strength;
   double volatility_strength;
   double average_range;
   
   // Price data
   double current_bid;
   double current_ask;
   double current_spread;
   double current_mid;
   double candle_open;
   double candle_high;
   double candle_low;
   double candle_close;
   
   // Status
   bool initialized;
   bool data_valid;
};

static SIndicatorState g_ind;

//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool InitializeIndicators()
{
   ZeroMemory(g_ind);
   
   if(!CreateIndicatorHandles())
      return false;
      
   if(!VerifyIndicatorHandles())
      return false;
      
   if(!InitializeBuffers())
      return false;
      
   if(!WarmupIndicators())
      return false;
      
   ResetIndicators();
   g_ind.initialized = true;
   
   Print("Indicators initialized successfully");
   return true;
}

//+------------------------------------------------------------------+
bool CreateIndicatorHandles()
{
   string symbol = _Symbol;
   
   // Create EMA handles
   if(!CreateEMAHandles(symbol))
      return false;
      
   // Create RSI handle
   if(!CreateRSIHandle(symbol))
      return false;
      
   // Create ADX handle
   if(!CreateADXHandle(symbol))
      return false;
      
   // Create ATR handle
   if(!CreateATRHandle(symbol))
      return false;
      
   // Create WPR handle
   if(!CreateWPRHandle(symbol))
      return false;
      
   return true;
}

//+------------------------------------------------------------------+
bool CreateEMAHandles(const string &symbol)
{
   g_ind.handle_ema_fast = iMA(symbol, PERIOD_CURRENT, 9, 0, MODE_EMA, PRICE_CLOSE);
   g_ind.handle_ema_medium = iMA(symbol, PERIOD_CURRENT, 21, 0, MODE_EMA, PRICE_CLOSE);
   g_ind.handle_ema_slow = iMA(symbol, PERIOD_CURRENT, 50, 0, MODE_EMA, PRICE_CLOSE);
   
   if(g_ind.handle_ema_fast == INVALID_HANDLE || 
      g_ind.handle_ema_medium == INVALID_HANDLE || 
      g_ind.handle_ema_slow == INVALID_HANDLE)
      return false;
      
   return true;
}

//+------------------------------------------------------------------+
bool CreateRSIHandle(const string &symbol)
{
   g_ind.handle_rsi = iRSI(symbol, PERIOD_CURRENT, 14, PRICE_CLOSE);
   return (g_ind.handle_rsi != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
bool CreateADXHandle(const string &symbol)
{
   g_ind.handle_adx = iADX(symbol, PERIOD_CURRENT, 14);
   return (g_ind.handle_adx != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
bool CreateATRHandle(const string &symbol)
{
   g_ind.handle_atr = iATR(symbol, PERIOD_CURRENT, 14);
   return (g_ind.handle_atr != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
bool CreateWPRHandle(const string &symbol)
{
   g_ind.handle_wpr = iWPR(symbol, PERIOD_CURRENT, 14);
   return (g_ind.handle_wpr != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
bool VerifyIndicatorHandles()
{
   if(!HandleValid(g_ind.handle_ema_fast)) return false;
   if(!HandleValid(g_ind.handle_ema_medium)) return false;
   if(!HandleValid(g_ind.handle_ema_slow)) return false;
   if(!HandleValid(g_ind.handle_rsi)) return false;
   if(!HandleValid(g_ind.handle_adx)) return false;
   if(!HandleValid(g_ind.handle_atr)) return false;
   if(!HandleValid(g_ind.handle_wpr)) return false;
   
   return true;
}

//+------------------------------------------------------------------+
bool InitializeBuffers()
{
   ArraySetAsSeries(g_ind.ema_fast, true);
   ArraySetAsSeries(g_ind.ema_medium, true);
   ArraySetAsSeries(g_ind.ema_slow, true);
   ArraySetAsSeries(g_ind.rsi, true);
   ArraySetAsSeries(g_ind.adx, true);
   ArraySetAsSeries(g_ind.plus_di, true);
   ArraySetAsSeries(g_ind.minus_di, true);
   ArraySetAsSeries(g_ind.atr, true);
   ArraySetAsSeries(g_ind.wpr, true);
   
   return true;
}

//+------------------------------------------------------------------+
bool WarmupIndicators()
{
   MqlRates rates[];
   int copied = CopyRates(_Symbol, PERIOD_CURRENT, 0, 100, rates);
   
   if(copied < 100)
      return false;
      
   Sleep(100);  // Allow indicators to calculate
   
   return UpdateIndicators();
}

//+------------------------------------------------------------------+
void ResetIndicators()
{
   g_ind.prev_rsi = 50.0;
   g_ind.prev_rsi_velocity = 0.0;
   g_ind.prev_adx = 25.0;
   g_ind.prev_adx_velocity = 0.0;
   g_ind.prev_atr = 0.0;
   g_ind.prev_wpr = -50.0;
   g_ind.filtered_rsi = 50.0;
   g_ind.smooth_rsi = 50.0;
   g_ind.fast_ema_slope = 0.0;
   g_ind.medium_ema_slope = 0.0;
   g_ind.slow_ema_slope = 0.0;
   g_ind.data_valid = false;
}

//+------------------------------------------------------------------+
void ShutdownIndicators()
{
   ReleaseEMAHandles();
   ReleaseRSIHandle();
   ReleaseADXHandle();
   ReleaseATRHandle();
   ReleaseWPRHandle();
   
   g_ind.initialized = false;
   Print("Indicators shutdown complete");
}

//+------------------------------------------------------------------+
void ReleaseEMAHandles()
{
   if(g_ind.handle_ema_fast != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_ema_fast);
   if(g_ind.handle_ema_medium != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_ema_medium);
   if(g_ind.handle_ema_slow != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_ema_slow);
      
   g_ind.handle_ema_fast = INVALID_HANDLE;
   g_ind.handle_ema_medium = INVALID_HANDLE;
   g_ind.handle_ema_slow = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
void ReleaseRSIHandle()
{
   if(g_ind.handle_rsi != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_rsi);
   g_ind.handle_rsi = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
void ReleaseADXHandle()
{
   if(g_ind.handle_adx != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_adx);
   g_ind.handle_adx = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
void ReleaseATRHandle()
{
   if(g_ind.handle_atr != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_atr);
   g_ind.handle_atr = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
void ReleaseWPRHandle()
{
   if(g_ind.handle_wpr != INVALID_HANDLE)
      IndicatorRelease(g_ind.handle_wpr);
   g_ind.handle_wpr = INVALID_HANDLE;
}

//+------------------------------------------------------------------+
//| Main Update Engine                                                |
//+------------------------------------------------------------------+
bool UpdateIndicators()
{
   if(!g_ind.initialized)
      return false;
      
   ConsumeMarketData();
   
   if(!UpdateEMA())
      return false;
   if(!UpdateRSI())
      return false;
   if(!UpdateADX())
      return false;
   if(!UpdateATR())
      return false;
   if(!UpdateWPR())
      return false;
      
   UpdateCandleAnalysis();
   UpdateDerivedData();
   
   if(!ValidateIndicators())
      return false;
      
   PublishIndicators();
   g_ind.data_valid = true;
   
   return true;
}

//+------------------------------------------------------------------+
//| Price Consumption                                                  |
//+------------------------------------------------------------------+
void ConsumeMarketData()
{
   ReadPriceSnapshot();
   ReadCandleSnapshot();
}

//+------------------------------------------------------------------+
void ReadPriceSnapshot()
{
   MqlTick tick;
   if(SymbolInfoTick(_Symbol, tick))
   {
      g_ind.current_bid = tick.bid;
      g_ind.current_ask = tick.ask;
      g_ind.current_spread = tick.ask - tick.bid;
      g_ind.current_mid = (tick.bid + tick.ask) / 2.0;
   }
}

//+------------------------------------------------------------------+
void ReadCandleSnapshot()
{
   MqlRates rates[1];
   if(CopyRates(_Symbol, PERIOD_CURRENT, 0, 1, rates) > 0)
   {
      g_ind.candle_open = rates[0].open;
      g_ind.candle_high = rates[0].high;
      g_ind.candle_low = rates[0].low;
      g_ind.candle_close = rates[0].close;
      ValidateCandleIntegrity();
   }
}

//+------------------------------------------------------------------+
void ValidateCandleIntegrity()
{
   if(g_ind.candle_high < g_ind.candle_low)
   {
      double temp = g_ind.candle_high;
      g_ind.candle_high = g_ind.candle_low;
      g_ind.candle_low = temp;
   }
}

//+------------------------------------------------------------------+
//| EMA Updates                                                        |
//+------------------------------------------------------------------+
bool UpdateEMA()
{
   if(CopyBuffer(g_ind.handle_ema_fast, 0, 0, 5, g_ind.ema_fast) <= 0)
      return false;
   if(CopyBuffer(g_ind.handle_ema_medium, 0, 0, 5, g_ind.ema_medium) <= 0)
      return false;
   if(CopyBuffer(g_ind.handle_ema_slow, 0, 0, 5, g_ind.ema_slow) <= 0)
      return false;
      
   CalculateEMASlopes();
   CalculateEMAAlignments();
   CalculateEMASpreads();
   CalculateEMAVelocities();
   
   return true;
}

//+------------------------------------------------------------------+
void CalculateEMASlopes()
{
   g_ind.fast_ema_slope = CalculateSlope(g_ind.ema_fast, 3);
   g_ind.medium_ema_slope = CalculateSlope(g_ind.ema_medium, 3);
   g_ind.slow_ema_slope = CalculateSlope(g_ind.ema_slow, 3);
}

//+------------------------------------------------------------------+
void CalculateEMAAlignments()
{
   // Alignment logic can be added here
}

//+------------------------------------------------------------------+
void CalculateEMASpreads()
{
   // Spread calculations between EMAs
}

//+------------------------------------------------------------------+
void CalculateEMAVelocities()
{
   g_ind.fast_ema_velocity = CalculateVelocity(g_ind.ema_fast);
   g_ind.medium_ema_velocity = CalculateVelocity(g_ind.ema_medium);
   g_ind.slow_ema_velocity = CalculateVelocity(g_ind.ema_slow);
}

//+------------------------------------------------------------------+
//| RSI Updates                                                        |
//+------------------------------------------------------------------+
bool UpdateRSI()
{
   if(CopyBuffer(g_ind.handle_rsi, 0, 0, 5, g_ind.rsi) <= 0)
      return false;
      
   StorePreviousRSI();
   CalculateRSIVelocity();
   CalculateRSIAcceleration();
   CalculateFilteredRSI();
   CalculateSmoothRSI();  // Average of last 3 RSI points
   UpdateRSIDirection();
   
   return true;
}

//+------------------------------------------------------------------+
void StorePreviousRSI()
{
   g_ind.prev_rsi = g_ind.rsi[1];
}

//+------------------------------------------------------------------+
void CalculateRSIVelocity()
{
   g_ind.rsi_velocity = Difference(g_ind.rsi[0], g_ind.rsi[1]);
}

//+------------------------------------------------------------------+
void CalculateRSIAcceleration()
{
   double current_velocity = g_ind.rsi_velocity;
   g_ind.rsi_acceleration = Difference(current_velocity, g_ind.prev_rsi_velocity);
   g_ind.prev_rsi_velocity = current_velocity;
}

//+------------------------------------------------------------------+
void CalculateFilteredRSI()
{
   double current = g_ind.rsi[0];
   double prev1 = g_ind.rsi[1];
   double prev2 = g_ind.rsi[2];
   
   // Remove single bar noise
   if(MathAbs(current - prev1) > MathAbs(prev1 - prev2) * 2.0)
   {
      g_ind.filtered_rsi = prev1;
      return;
   }
   
   // Remove double bar noise
   if(MathAbs(current - prev1) < 0.5 && MathAbs(prev1 - prev2) > 3.0)
   {
      g_ind.filtered_rsi = prev1;
      return;
   }
   
   // Ignore minor oscillation
   if(MathAbs(current - prev1) < 1.0 && MathAbs(prev1 - prev2) < 1.0)
   {
      g_ind.filtered_rsi = prev1;
      return;
   }
   
   // Confirm persistence
   if((current > prev1 && prev1 > prev2) || (current < prev1 && prev1 < prev2))
      g_ind.filtered_rsi = current;
   else
      g_ind.filtered_rsi = prev1;
}

//+------------------------------------------------------------------+
void CalculateSmoothRSI()
{
   // Smooth RSI: Average of last 3 RSI data points
   if(ArraySize(g_ind.rsi) >= 3)
   {
      g_ind.smooth_rsi = (g_ind.rsi[0] + g_ind.rsi[1] + g_ind.rsi[2]) / 3.0;
   }
   else if(ArraySize(g_ind.rsi) >= 1)
   {
      g_ind.smooth_rsi = g_ind.rsi[0];
   }
}

//+------------------------------------------------------------------+
void UpdateRSIDirection()
{
   // Direction update logic
}

//+------------------------------------------------------------------+
//| ADX Updates                                                        |
//+------------------------------------------------------------------+
bool UpdateADX()
{
   if(CopyBuffer(g_ind.handle_adx, 0, 0, 5, g_ind.adx) <= 0)
      return false;
   if(CopyBuffer(g_ind.handle_adx, 1, 0, 5, g_ind.plus_di) <= 0)
      return false;
   if(CopyBuffer(g_ind.handle_adx, 2, 0, 5, g_ind.minus_di) <= 0)
      return false;
      
   StorePreviousADX();
   CalculateADXSlope();
   CalculateADXVelocity();
   CalculateADXAcceleration();
   UpdateADXDirection();
   
   return true;
}

//+------------------------------------------------------------------+
void StorePreviousADX()
{
   g_ind.prev_adx = g_ind.adx[1];
}

//+------------------------------------------------------------------+
void CalculateADXSlope()
{
   g_ind.adx_slope = CalculateSlope(g_ind.adx, 3);
}

//+------------------------------------------------------------------+
void CalculateADXVelocity()
{
   g_ind.adx_velocity = Difference(g_ind.adx[0], g_ind.adx[1]);
}

//+------------------------------------------------------------------+
void CalculateADXAcceleration()
{
   double current_velocity = g_ind.adx_velocity;
   g_ind.adx_acceleration = Difference(current_velocity, g_ind.prev_adx_velocity);
   g_ind.prev_adx_velocity = current_velocity;
}

//+------------------------------------------------------------------+
void UpdateADXDirection()
{
   // Direction update logic
}

//+------------------------------------------------------------------+
//| ATR Updates                                                        |
//+------------------------------------------------------------------+
bool UpdateATR()
{
   if(CopyBuffer(g_ind.handle_atr, 0, 0, 5, g_ind.atr) <= 0)
      return false;
      
   NormalizeATR();
   ConvertATRToPoints();
   CalculateATRVelocity();
   CalculateATRAcceleration();
   
   return true;
}

//+------------------------------------------------------------------+
void NormalizeATR()
{
   if(g_ind.candle_close > 0)
      g_ind.atr_normalized = (g_ind.atr[0] / g_ind.candle_close) * 100.0;
   else
      g_ind.atr_normalized = 0.0;
}

//+------------------------------------------------------------------+
void ConvertATRToPoints()
{
   g_ind.atr_points = g_ind.atr[0] / _Point;
}

//+------------------------------------------------------------------+
void CalculateATRVelocity()
{
   g_ind.atr_velocity = Difference(g_ind.atr[0], g_ind.atr[1]);
}

//+------------------------------------------------------------------+
void CalculateATRAcceleration()
{
   double current_velocity = g_ind.atr_velocity;
   g_ind.atr_acceleration = Difference(current_velocity, g_ind.prev_atr);
   g_ind.prev_atr = current_velocity;
}

//+------------------------------------------------------------------+
//| WPR Updates                                                        |
//+------------------------------------------------------------------+
bool UpdateWPR()
{
   if(CopyBuffer(g_ind.handle_wpr, 0, 0, 5, g_ind.wpr) <= 0)
      return false;
      
   StorePreviousWPR();
   CalculateWPRVelocity();
   UpdateWPRDirection();
   
   return true;
}

//+------------------------------------------------------------------+
void StorePreviousWPR()
{
   g_ind.prev_wpr = g_ind.wpr[1];
}

//+------------------------------------------------------------------+
void CalculateWPRVelocity()
{
   g_ind.wpr_velocity = Difference(g_ind.wpr[0], g_ind.wpr[1]);
}

//+------------------------------------------------------------------+
void UpdateWPRDirection()
{
   // Direction update logic
}

//+------------------------------------------------------------------+
//| Candle Analysis                                                    |
//+------------------------------------------------------------------+
void UpdateCandleAnalysis()
{
   CalculateBody();
   CalculateBodyPercent();
   CalculateRange();
   CalculateUpperWick();
   CalculateLowerWick();
   CalculateUpperWickPercent();
   CalculateLowerWickPercent();
   DetermineDirection();
   DetermineStrength();
   DetectDoji();
}

//+------------------------------------------------------------------+
void CalculateBody()
{
   g_ind.candle_body = MathAbs(g_ind.candle_close - g_ind.candle_open);
}

//+------------------------------------------------------------------+
void CalculateBodyPercent()
{
   double range = g_ind.candle_high - g_ind.candle_low;
   if(range > 0)
      g_ind.candle_body_percent = (g_ind.candle_body / range) * 100.0;
   else
      g_ind.candle_body_percent = 0.0;
}

//+------------------------------------------------------------------+
void CalculateRange()
{
   g_ind.candle_range = g_ind.candle_high - g_ind.candle_low;
}

//+------------------------------------------------------------------+
void CalculateUpperWick()
{
   double top = MathMax(g_ind.candle_open, g_ind.candle_close);
   g_ind.candle_upper_wick = g_ind.candle_high - top;
}

//+------------------------------------------------------------------+
void CalculateLowerWick()
{
   double bottom = MathMin(g_ind.candle_open, g_ind.candle_close);
   g_ind.candle_lower_wick = bottom - g_ind.candle_low;
}

//+------------------------------------------------------------------+
void CalculateUpperWickPercent()
{
   if(g_ind.candle_range > 0)
      g_ind.candle_upper_wick_percent = (g_ind.candle_upper_wick / g_ind.candle_range) * 100.0;
   else
      g_ind.candle_upper_wick_percent = 0.0;
}

//+------------------------------------------------------------------+
void CalculateLowerWickPercent()
{
   if(g_ind.candle_range > 0)
      g_ind.candle_lower_wick_percent = (g_ind.candle_lower_wick / g_ind.candle_range) * 100.0;
   else
      g_ind.candle_lower_wick_percent = 0.0;
}

//+------------------------------------------------------------------+
void DetermineDirection()
{
   if(g_ind.candle_close > g_ind.candle_open)
      g_ind.candle_direction = 1;  // Bullish
   else if(g_ind.candle_close < g_ind.candle_open)
      g_ind.candle_direction = -1; // Bearish
   else
      g_ind.candle_direction = 0;  // Neutral
}

//+------------------------------------------------------------------+
void DetermineStrength()
{
   g_ind.candle_strength = g_ind.candle_body_percent / 100.0;
}

//+------------------------------------------------------------------+
void DetectDoji()
{
   g_ind.is_doji = (g_ind.candle_body_percent < 10.0);
}

//+------------------------------------------------------------------+
//| Derived Values                                                     |
//+------------------------------------------------------------------+
void UpdateDerivedData()
{
   CalculateMomentumStrength();
   CalculateTrendStrength();
   CalculateVolatilityStrength();
   CalculateAverageRange();
}

//+------------------------------------------------------------------+
void CalculateMomentumStrength()
{
   double rsi_score = MathAbs(g_ind.rsi[0] - 50.0) / 50.0;
   double wpr_score = MathAbs(g_ind.wpr[0] + 50.0) / 50.0;
   g_ind.momentum_strength = (rsi_score + wpr_score) / 2.0;
}

//+------------------------------------------------------------------+
void CalculateTrendStrength()
{
   g_ind.trend_strength = g_ind.adx[0] / 100.0;
}

//+------------------------------------------------------------------+
void CalculateVolatilityStrength()
{
   g_ind.volatility_strength = MathMin(g_ind.atr_normalized / 2.0, 1.0);
}

//+------------------------------------------------------------------+
void CalculateAverageRange()
{
   g_ind.average_range = g_ind.atr[0];
}

//+------------------------------------------------------------------+
//| Validation                                                         |
//+------------------------------------------------------------------+
bool ValidateIndicators()
{
   if(!ValidateEMA()) return false;
   if(!ValidateRSI()) return false;
   if(!ValidateADX()) return false;
   if(!ValidateATR()) return false;
   if(!ValidateWPR()) return false;
   if(!ValidatePriceData()) return false;
   if(!ValidateBuffers()) return false;
   
   return true;
}

//+------------------------------------------------------------------+
bool ValidateEMA()
{
   if(ArraySize(g_ind.ema_fast) < 3) return false;
   if(ArraySize(g_ind.ema_medium) < 3) return false;
   if(ArraySize(g_ind.ema_slow) < 3) return false;
   if(g_ind.ema_fast[0] <= 0 || g_ind.ema_medium[0] <= 0 || g_ind.ema_slow[0] <= 0) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidateRSI()
{
   if(ArraySize(g_ind.rsi) < 3) return false;
   if(g_ind.rsi[0] < 0 || g_ind.rsi[0] > 100) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidateADX()
{
   if(ArraySize(g_ind.adx) < 3) return false;
   if(g_ind.adx[0] < 0 || g_ind.adx[0] > 100) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidateATR()
{
   if(ArraySize(g_ind.atr) < 3) return false;
   if(g_ind.atr[0] <= 0) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidateWPR()
{
   if(ArraySize(g_ind.wpr) < 3) return false;
   if(g_ind.wpr[0] < -100 || g_ind.wpr[0] > 0) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidatePriceData()
{
   if(g_ind.candle_high <= 0 || g_ind.candle_low <= 0) return false;
   if(g_ind.candle_high < g_ind.candle_low) return false;
   return true;
}

//+------------------------------------------------------------------+
bool ValidateBuffers()
{
   return true;
}

//+------------------------------------------------------------------+
//| Publish Data                                                       |
//+------------------------------------------------------------------+
void PublishIndicators()
{
   PublishEMA();
   PublishRSI();
   PublishFilteredRSI();
   PublishSmoothRSI();  // Publish smoothed RSI
   PublishADX();
   PublishATR();
   PublishWPR();
   PublishCandleData();
   PublishPriceData();
}

//+------------------------------------------------------------------+
void PublishEMA()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishRSI()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishFilteredRSI()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishSmoothRSI()
{
   // Publishing smoothed RSI (average of last 3 points)
}

//+------------------------------------------------------------------+
void PublishADX()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishATR()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishWPR()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishCandleData()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
void PublishPriceData()
{
   // Publishing logic
}

//+------------------------------------------------------------------+
//| Mathematical Helpers                                               |
//+------------------------------------------------------------------+
double CalculateSlope(const double &buffer[], int lookback)
{
   if(ArraySize(buffer) < lookback)
      return 0.0;
      
   double sum_x = 0.0;
   double sum_y = 0.0;
   double sum_xy = 0.0;
   double sum_xx = 0.0;
   
   for(int i = 0; i < lookback; i++)
   {
      sum_x += i;
      sum_y += buffer[i];
      sum_xy += i * buffer[i];
      sum_xx += i * i;
   }
   
   double denominator = (lookback * sum_xx - sum_x * sum_x);
   if(denominator == 0)
      return 0.0;
      
   double slope = (lookback * sum_xy - sum_x * sum_y) / denominator;
   return slope;
}

//+------------------------------------------------------------------+
double CalculateVelocity(const double &buffer[])
{
   if(ArraySize(buffer) < 2)
      return 0.0;
   return buffer[0] - buffer[1];
}

//+------------------------------------------------------------------+
double CalculateAcceleration(const double &buffer[])
{
   if(ArraySize(buffer) < 3)
      return 0.0;
      
   double vel1 = buffer[0] - buffer[1];
   double vel2 = buffer[1] - buffer[2];
   return vel1 - vel2;
}

//+------------------------------------------------------------------+
double Difference(double current, double previous)
{
   return current - previous;
}

//+------------------------------------------------------------------+
double AbsoluteDifference(double a, double b)
{
   return MathAbs(a - b);
}

//+------------------------------------------------------------------+
double PercentageChange(double current, double previous)
{
   if(previous == 0)
      return 0.0;
   return ((current - previous) / previous) * 100.0;
}

//+------------------------------------------------------------------+
double NormalizeValue(double value, double min_val, double max_val)
{
   if(max_val == min_val)
      return 0.5;
   return (value - min_val) / (max_val - min_val);
}

//+------------------------------------------------------------------+
double ClampValue(double value, double min_val, double max_val)
{
   return MathMax(min_val, MathMin(max_val, value));
}

//+------------------------------------------------------------------+
//| Buffer Helpers                                                     |
//+------------------------------------------------------------------+
int CopySingleBuffer(int handle, int buffer_num, int start_pos, int count, double &buffer[])
{
   return CopyBuffer(handle, buffer_num, start_pos, count, buffer);
}

//+------------------------------------------------------------------+
int CopyMultipleBuffer(int handle, int start_pos, int count, double &buffer[])
{
   return CopyBuffer(handle, 0, start_pos, count, buffer);
}

//+------------------------------------------------------------------+
bool IndicatorReady(int handle)
{
   return (handle != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
bool HandleValid(int handle)
{
   return (handle != INVALID_HANDLE);
}

//+------------------------------------------------------------------+
//| Getters                                                            |
//+------------------------------------------------------------------+
double GetFastEMA() { return ArraySize(g_ind.ema_fast) > 0 ? g_ind.ema_fast[0] : 0.0; }
double GetMediumEMA() { return ArraySize(g_ind.ema_medium) > 0 ? g_ind.ema_medium[0] : 0.0; }
double GetSlowEMA() { return ArraySize(g_ind.ema_slow) > 0 ? g_ind.ema_slow[0] : 0.0; }
double GetRSI() { return ArraySize(g_ind.rsi) > 0 ? g_ind.rsi[0] : 50.0; }
double GetFilteredRSI() { return g_ind.filtered_rsi; }
double GetSmoothRSI() { return g_ind.smooth_rsi; }  // Average of last 3 RSI points
double GetADX() { return ArraySize(g_ind.adx) > 0 ? g_ind.adx[0] : 0.0; }
double GetPlusDI() { return ArraySize(g_ind.plus_di) > 0 ? g_ind.plus_di[0] : 0.0; }
double GetMinusDI() { return ArraySize(g_ind.minus_di) > 0 ? g_ind.minus_di[0] : 0.0; }
double GetATR() { return ArraySize(g_ind.atr) > 0 ? g_ind.atr[0] : 0.0; }
double GetATRNormalized() { return g_ind.atr_normalized; }
double GetATRPoints() { return g_ind.atr_points; }
double GetWPR() { return ArraySize(g_ind.wpr) > 0 ? g_ind.wpr[0] : -50.0; }

// EMA Slopes
double GetFastEMASlope() { return g_ind.fast_ema_slope; }
double GetMediumEMASlope() { return g_ind.medium_ema_slope; }
double GetSlowEMASlope() { return g_ind.slow_ema_slope; }

// RSI Metrics
double GetRSIVelocity() { return g_ind.rsi_velocity; }
double GetRSIAcceleration() { return g_ind.rsi_acceleration; }

// ADX Metrics
double GetADXSlope() { return g_ind.adx_slope; }
double GetADXVelocity() { return g_ind.adx_velocity; }
double GetADXAcceleration() { return g_ind.adx_acceleration; }

// ATR Metrics
double GetATRVelocity() { return g_ind.atr_velocity; }
double GetATRAcceleration() { return g_ind.atr_acceleration; }

// WPR Metrics
double GetWPRVelocity() { return g_ind.wpr_velocity; }

// Candle Data
double GetCandleBody() { return g_ind.candle_body; }
double GetCandleBodyPercent() { return g_ind.candle_body_percent; }
double GetCandleRange() { return g_ind.candle_range; }
double GetCandleUpperWick() { return g_ind.candle_upper_wick; }
double GetCandleLowerWick() { return g_ind.candle_lower_wick; }
int GetCandleDirection() { return g_ind.candle_direction; }
double GetCandleStrength() { return g_ind.candle_strength; }
bool IsDoji() { return g_ind.is_doji; }

// Derived Strengths
double GetMomentumStrength() { return g_ind.momentum_strength; }
double GetTrendStrength() { return g_ind.trend_strength; }
double GetVolatilityStrength() { return g_ind.volatility_strength; }
double GetAverageRange() { return g_ind.average_range; }

// Price Data
double GetCurrentBid() { return g_ind.current_bid; }
double GetCurrentAsk() { return g_ind.current_ask; }
double GetCurrentSpread() { return g_ind.current_spread; }
double GetCurrentMid() { return g_ind.current_mid; }

// Status
bool IsIndicatorDataValid() { return g_ind.data_valid; }
bool IsIndicatorsInitialized() { return g_ind.initialized; }
//+------------------------------------------------------------------+
