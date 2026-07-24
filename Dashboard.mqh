//+------------------------------------------------------------------+
//|                                              Dashboard.mqh       |
//|                                  Professional Trading Dashboard  |
//+------------------------------------------------------------------+
#property copyright "Trade Bot v1"
#property link      ""
#property version   "1.00"
#property description "Real-time trading dashboard with market, indicators, strategy, execution, and statistics panels"

#include "Structures.mqh"
#include "Utilities.mqh"
#include "Logger.mqh"

//+------------------------------------------------------------------+
//| Global Dashboard State                                            |
//+------------------------------------------------------------------+
static int g_dashboardHandle = -1;
static bool g_dashboardInitialized = false;
static datetime g_lastDashboardUpdate = 0;
static int g_panelX = 10;
static int g_panelY = 20;
static int g_panelWidth = 350;
static int g_rowHeight = 18;
static color g_colorBullish = clrGreen;
static color g_colorBearish = clrRed;
static color g_colorNeutral = clrGray;
static color g_colorText = clrWhite;
static color g_colorBackground = clrBlack;

//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+

// Initialize the dashboard system
bool InitializeDashboard()
{
    if (g_dashboardInitialized)
        return true;
    
    // Load dashboard inputs from global settings
    LoadDashboardInputs();
    
    // Create the dashboard panel
    if (!CreateDashboard())
    {
        LogError("Dashboard initialization failed", __FUNCTION__, __LINE__);
        return false;
    }
    
    // Reset dashboard to default state
    ResetDashboard();
    
    g_dashboardInitialized = true;
    LogInfo("Dashboard initialized successfully", __FUNCTION__);
    return true;
}

// Load dashboard configuration inputs
void LoadDashboardInputs()
{
    // Dashboard position and size can be customized via inputs
    g_panelX = 10;
    g_panelY = 20;
    g_panelWidth = 350;
    g_rowHeight = 18;
    
    // Color scheme
    g_colorBullish = clrGreen;
    g_colorBearish = clrRed;
    g_colorNeutral = clrGray;
    g_colorText = clrWhite;
    g_colorBackground = clrBlack;
}

// Create the main dashboard panel
bool CreateDashboard()
{
    // Create background rectangle for the entire dashboard
    int totalHeight = 450; // Approximate height for all panels
    
    if (!DrawRectangle("DashboardBG", g_panelX - 5, g_panelY - 5, 
                       g_panelX + g_panelWidth + 5, g_panelY + totalHeight + 5, 
                       g_colorBackground, 1, BORDER_FLAT))
    {
        return false;
    }
    
    // Create panel headers
    DrawLabel("Market Info", g_panelX, g_panelY, clrDodgerBlue, 10, true);
    DrawLabel("Indicators", g_panelX, g_panelY + 90, clrDodgerBlue, 10, true);
    DrawLabel("Strategy", g_panelX, g_panelY + 180, clrDodgerBlue, 10, true);
    DrawLabel("Execution", g_panelX, g_panelY + 270, clrDodgerBlue, 10, true);
    DrawLabel("Statistics", g_panelX, g_panelY + 360, clrDodgerBlue, 10, true);
    
    return true;
}

// Shutdown the dashboard system
void ShutdownDashboard()
{
    if (!g_dashboardInitialized)
        return;
    
    DestroyDashboard();
    g_dashboardInitialized = false;
    LogInfo("Dashboard shutdown complete", __FUNCTION__);
}

// Destroy all dashboard objects
void DestroyDashboard()
{
    // Delete all dashboard-related objects
    for (int i = ObjectsTotal(0, 0, OBJ_RECTANGLE_LABEL); i >= 0; i--)
    {
        string name = ObjectName(0, i, 0, OBJ_RECTANGLE_LABEL);
        if (StringFind(name, "Dashboard") >= 0 || StringFind(name, "Dash_") >= 0)
        {
            DeleteObject(name);
        }
    }
    
    for (int i = ObjectsTotal(0, 0, OBJ_LABEL); i >= 0; i--)
    {
        string name = ObjectName(0, i, 0, OBJ_LABEL);
        if (StringFind(name, "Dashboard") >= 0 || StringFind(name, "Dash_") >= 0)
        {
            DeleteObject(name);
        }
    }
}

//+------------------------------------------------------------------+
//| Main Engine                                                       |
//+------------------------------------------------------------------+

// Update the entire dashboard
void UpdateDashboard()
{
    if (!g_dashboardInitialized)
        return;
    
    // Limit update frequency to avoid performance issues
    datetime currentTime = TimeCurrent();
    if (currentTime - g_lastDashboardUpdate < 1) // Update max once per second
        return;
    
    g_lastDashboardUpdate = currentTime;
    
    // Update all panels
    UpdateMarketPanel();
    UpdateIndicatorPanel();
    UpdateStrategyPanel();
    UpdateExecutionPanel();
    UpdateStatisticsPanel();
    UpdateLoggerPanel();
    
    // Refresh the display
    RefreshDashboard();
}

//+------------------------------------------------------------------+
//| Market Panel                                                      |
//+------------------------------------------------------------------+

void UpdateMarketPanel()
{
    int startY = g_panelY + 20;
    int row = 0;
    
    // Show symbol
    ShowSymbol(g_panelX, startY + row * g_rowHeight, _Symbol);
    row++;
    
    // Show timeframe
    ShowTimeframe(g_panelX, startY + row * g_rowHeight, EnumToString((ENUM_TIMEFRAMES)_Period));
    row++;
    
    // Show spread
    double spread = CurrentSpread(_Symbol);
    ShowSpread(g_panelX, startY + row * g_rowHeight, spread);
    row++;
    
    // Show session
    string session = TradingSession();
    ShowSession(g_panelX, startY + row * g_rowHeight, session);
    row++;
    
    // Show bid/ask
    double bid = SymbolInfoDouble(_Symbol, SYMBOL_BID);
    double ask = SymbolInfoDouble(_Symbol, SYMBOL_ASK);
    ShowBidAsk(g_panelX, startY + row * g_rowHeight, bid, ask);
    row++;
    
    // Show current candle info
    ShowCurrentCandle(g_panelX, startY + row * g_rowHeight);
}

void ShowSymbol(int x, int y, string symbol)
{
    DrawLabel("Symbol:", x, y, g_colorText, 8);
    DrawValue("Dash_Symbol_Value", x + 80, y, symbol, clrYellow, 8);
}

void ShowTimeframe(int x, int y, string timeframe)
{
    DrawLabel("Timeframe:", x, y, g_colorText, 8);
    DrawValue("Dash_TF_Value", x + 80, y, timeframe, clrYellow, 8);
}

void ShowSpread(int x, int y, double spread)
{
    DrawLabel("Spread:", x, y, g_colorText, 8);
    color spreadColor = (spread <= 20) ? g_colorBullish : (spread <= 40) ? g_colorNeutral : g_colorBearish;
    DrawValue("Dash_Spread_Value", x + 80, y, DoubleToString(spread, 1), spreadColor, 8);
}

void ShowSession(int x, int y, string session)
{
    DrawLabel("Session:", x, y, g_colorText, 8);
    color sessionColor = (session == "London" || session == "New York") ? g_colorBullish : g_colorNeutral;
    DrawValue("Dash_Session_Value", x + 80, y, session, sessionColor, 8);
}

void ShowBidAsk(int x, int y, double bid, double ask)
{
    DrawLabel("Bid/Ask:", x, y, g_colorText, 8);
    string baText = DoubleToString(bid, _Digits) + "/" + DoubleToString(ask, _Digits);
    DrawValue("Dash_BA_Value", x + 80, y, baText, clrCyan, 8);
}

void ShowCurrentCandle(int x, int y)
{
    DrawLabel("Candle:", x, y, g_colorText, 8);
    
    double open = iOpen(_Symbol, _Period, 0);
    double close = iClose(_Symbol, _Period, 0);
    double high = iHigh(_Symbol, _Period, 0);
    double low = iLow(_Symbol, _Period, 0);
    
    color candleColor = (close > open) ? g_colorBullish : (close < open) ? g_colorBearish : g_colorNeutral;
    string candleText = (close > open) ? "Bull" : (close < open) ? "Bear" : "Doji";
    
    DrawValue("Dash_Candle_Value", x + 80, y, candleText, candleColor, 8);
}

//+------------------------------------------------------------------+
//| Indicator Panel                                                   |
//+------------------------------------------------------------------+

void UpdateIndicatorPanel()
{
    int startY = g_panelY + 110;
    int row = 0;
    
    // Show EMA values
    ShowEMA(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show RSI
    ShowRSI(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show Filtered RSI
    ShowFilteredRSI(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show ADX
    ShowADX(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show ATR
    ShowATR(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show WPR
    ShowWPR(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show indicator status
    ShowIndicatorStatus(g_panelX, startY + row * g_rowHeight);
}

void ShowEMA(int x, int y)
{
    // Placeholder - actual EMA values would come from indicator module
    DrawLabel("EMA(20):", x, y, g_colorText, 8);
    DrawValue("Dash_EMA_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowRSI(int x, int y)
{
    // Placeholder - actual RSI values would come from indicator module
    DrawLabel("RSI(14):", x, y, g_colorText, 8);
    DrawValue("Dash_RSI_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowFilteredRSI(int x, int y)
{
    DrawLabel("F-RSI:", x, y, g_colorText, 8);
    DrawValue("Dash_FRSI_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowADX(int x, int y)
{
    DrawLabel("ADX(14):", x, y, g_colorText, 8);
    DrawValue("Dash_ADX_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowATR(int x, int y)
{
    DrawLabel("ATR(14):", x, y, g_colorText, 8);
    DrawValue("Dash_ATR_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowWPR(int x, int y)
{
    DrawLabel("WPR(14):", x, y, g_colorText, 8);
    DrawValue("Dash_WPR_Value", x + 80, y, "N/A", clrYellow, 8);
}

void ShowIndicatorStatus(int x, int y)
{
    DrawLabel("Status:", x, y, g_colorText, 8);
    DrawValue("Dash_Ind_Status", x + 80, y, "Active", g_colorBullish, 8);
}

//+------------------------------------------------------------------+
//| Strategy Panel                                                    |
//+------------------------------------------------------------------+

void UpdateStrategyPanel()
{
    int startY = g_panelY + 200;
    int row = 0;
    
    // Show market regime
    ShowMarketRegime(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show buy score
    ShowBuyScore(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show sell score
    ShowSellScore(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show signal weights
    ShowSignalWeights(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show decision
    ShowDecision(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show decision reason
    ShowDecisionReason(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show signal states
    ShowSignalStates(g_panelX, startY + row * g_rowHeight);
}

void ShowMarketRegime(int x, int y)
{
    DrawLabel("Regime:", x, y, g_colorText, 8);
    DrawValue("Dash_Regime_Value", x + 80, y, "Trending", clrMagenta, 8);
}

void ShowBuyScore(int x, int y)
{
    DrawLabel("Buy Score:", x, y, g_colorText, 8);
    DrawValue("Dash_BuyScore", x + 80, y, "0.00", clrYellow, 8);
}

void ShowSellScore(int x, int y)
{
    DrawLabel("Sell Score:", x, y, g_colorText, 8);
    DrawValue("Dash_SellScore", x + 80, y, "0.00", clrYellow, 8);
}

void ShowSignalWeights(int x, int y)
{
    DrawLabel("Weights:", x, y, g_colorText, 8);
    DrawValue("Dash_Weights", x + 80, y, "Balanced", clrYellow, 8);
}

void ShowDecision(int x, int y)
{
    DrawLabel("Decision:", x, y, g_colorText, 8);
    DrawValue("Dash_Decision", x + 80, y, "WAIT", clrOrange, 8);
}

void ShowDecisionReason(int x, int y)
{
    DrawLabel("Reason:", x, y, g_colorText, 8);
    DrawValue("Dash_Reason", x + 80, y, "No signal", clrGray, 8);
}

void ShowSignalStates(int x, int y)
{
    DrawLabel("Signals:", x, y, g_colorText, 8);
    DrawValue("Dash_Signals", x + 80, y, "Inactive", clrGray, 8);
}

//+------------------------------------------------------------------+
//| Execution Panel                                                   |
//+------------------------------------------------------------------+

void UpdateExecutionPanel()
{
    int startY = g_panelY + 290;
    int row = 0;
    
    // Show position
    ShowPosition(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show entry
    ShowEntry(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show SL
    ShowSL(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show TP
    ShowTP(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show break even
    ShowBreakEven(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show trailing
    ShowTrailing(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show adaptive mode
    ShowAdaptiveMode(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show floating profit
    ShowFloatingProfit(g_panelX, startY + row * g_rowHeight);
}

void ShowPosition(int x, int y)
{
    DrawLabel("Position:", x, y, g_colorText, 8);
    DrawValue("Dash_Position", x + 80, y, "Flat", clrGray, 8);
}

void ShowEntry(int x, int y)
{
    DrawLabel("Entry:", x, y, g_colorText, 8);
    DrawValue("Dash_Entry", x + 80, y, "---", clrYellow, 8);
}

void ShowSL(int x, int y)
{
    DrawLabel("Stop Loss:", x, y, g_colorText, 8);
    DrawValue("Dash_SL", x + 80, y, "---", clrRed, 8);
}

void ShowTP(int x, int y)
{
    DrawLabel("Take Profit:", x, y, g_colorText, 8);
    DrawValue("Dash_TP", x + 80, y, "---", clrGreen, 8);
}

void ShowBreakEven(int x, int y)
{
    DrawLabel("Break Even:", x, y, g_colorText, 8);
    DrawValue("Dash_BE", x + 80, y, "Off", clrGray, 8);
}

void ShowTrailing(int x, int y)
{
    DrawLabel("Trailing:", x, y, g_colorText, 8);
    DrawValue("Dash_Trailing", x + 80, y, "Off", clrGray, 8);
}

void ShowAdaptiveMode(int x, int y)
{
    DrawLabel("Adaptive:", x, y, g_colorText, 8);
    DrawValue("Dash_Adaptive", x + 80, y, "Normal", clrYellow, 8);
}

void ShowFloatingProfit(int x, int y)
{
    DrawLabel("Float P/L:", x, y, g_colorText, 8);
    DrawValue("Dash_FloatPL", x + 80, y, "0.00", clrWhite, 8);
}

//+------------------------------------------------------------------+
//| Statistics Panel                                                  |
//+------------------------------------------------------------------+

void UpdateStatisticsPanel()
{
    int startY = g_panelY + 380;
    int row = 0;
    
    // Show daily stats
    ShowDailyStats(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show current trade
    ShowCurrentTrade(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show win rate
    ShowWinRate(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show profit
    ShowProfit(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show drawdown
    ShowDrawdown(g_panelX, startY + row * g_rowHeight);
    row++;
    
    // Show trade count
    ShowTradeCount(g_panelX, startY + row * g_rowHeight);
}

void ShowDailyStats(int x, int y)
{
    DrawLabel("Today:", x, y, g_colorText, 8);
    DrawValue("Dash_Daily", x + 80, y, "0 trades", clrYellow, 8);
}

void ShowCurrentTrade(int x, int y)
{
    DrawLabel("Current:", x, y, g_colorText, 8);
    DrawValue("Dash_CurrentTrade", x + 80, y, "None", clrGray, 8);
}

void ShowWinRate(int x, int y)
{
    DrawLabel("Win Rate:", x, y, g_colorText, 8);
    DrawValue("Dash_WinRate", x + 80, y, "0.0%", clrYellow, 8);
}

void ShowProfit(int x, int y)
{
    DrawLabel("Profit:", x, y, g_colorText, 8);
    DrawValue("Dash_Profit", x + 80, y, "$0.00", clrGreen, 8);
}

void ShowDrawdown(int x, int y)
{
    DrawLabel("Drawdown:", x, y, g_colorText, 8);
    DrawValue("Dash_DD", x + 80, y, "0.0%", clrRed, 8);
}

void ShowTradeCount(int x, int y)
{
    DrawLabel("Trades:", x, y, g_colorText, 8);
    DrawValue("Dash_TradeCount", x + 80, y, "0", clrYellow, 8);
}

//+------------------------------------------------------------------+
//| Logger Panel                                                      |
//+------------------------------------------------------------------+

void UpdateLoggerPanel()
{
    int startY = g_panelY + 450;
    
    // Update last message
    UpdateLastMessage(g_panelX, startY);
    
    // Update last error
    UpdateLastError(g_panelX, startY + g_rowHeight);
    
    // Update system state
    UpdateSystemState(g_panelX, startY + 2 * g_rowHeight);
}

void UpdateLastMessage(int x, int y)
{
    DrawLabel("Last Msg:", x, y, g_colorText, 8);
    DrawValue("Dash_LastMsg", x + 80, y, "System ready", clrWhite, 8);
}

void UpdateLastError(int x, int y)
{
    DrawLabel("Last Error:", x, y, g_colorText, 8);
    DrawValue("Dash_LastErr", x + 80, y, "None", clrGreen, 8);
}

void UpdateSystemState(int x, int y)
{
    DrawLabel("System:", x, y, g_colorText, 8);
    DrawValue("Dash_SysState", x + 80, y, "Running", g_colorBullish, 8);
}

//+------------------------------------------------------------------+
//| Drawing Functions                                                 |
//+------------------------------------------------------------------+

bool DrawText(string name, int x, int y, string text, color clr, int fontSize)
{
    if (ObjectFind(0, name) < 0)
    {
        if (!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
            return false;
        
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetString(0, name, OBJPROP_FONT, "Arial");
    }
    else
    {
        ObjectSetString(0, name, OBJPROP_TEXT, text);
    }
    
    return true;
}

bool DrawValue(string name, int x, int y, string value, color clr, int fontSize)
{
    return DrawText(name, x, y, value, clr, fontSize);
}

bool DrawLabel(string text, int x, int y, color clr, int fontSize, bool bold = false)
{
    string name = "Dash_Label_" + IntegerToString(x) + "_" + IntegerToString(y);
    
    if (ObjectFind(0, name) < 0)
    {
        if (!ObjectCreate(0, name, OBJ_LABEL, 0, 0, 0))
            return false;
        
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y);
        ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
        ObjectSetInteger(0, name, OBJPROP_FONTSIZE, fontSize);
        ObjectSetString(0, name, OBJPROP_TEXT, text);
        ObjectSetString(0, name, OBJPROP_FONT, bold ? "Arial Bold" : "Arial");
    }
    else
    {
        ObjectSetString(0, name, OBJPROP_TEXT, text);
    }
    
    return true;
}

bool DrawRectangle(string name, int x1, int y1, int x2, int y2, color clr, int width, ENUM_BORDER_TYPE border)
{
    if (ObjectFind(0, name) < 0)
    {
        if (!ObjectCreate(0, name, OBJ_RECTANGLE_LABEL, 0, 0, 0))
            return false;
        
        ObjectSetInteger(0, name, OBJPROP_XDISTANCE, x1);
        ObjectSetInteger(0, name, OBJPROP_YDISTANCE, y1);
        ObjectSetInteger(0, name, OBJPROP_XSIZE, x2 - x1);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, y2 - y1);
        ObjectSetInteger(0, name, OBJPROP_BGCOLOR, clr);
        ObjectSetInteger(0, name, OBJPROP_BORDER_TYPE, border);
        ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
    }
    else
    {
        ObjectSetInteger(0, name, OBJPROP_XSIZE, x2 - x1);
        ObjectSetInteger(0, name, OBJPROP_YSIZE, y2 - y1);
    }
    
    return true;
}

bool UpdateObject(string name, string property, string value)
{
    if (ObjectFind(0, name) >= 0)
    {
        ObjectSetString(0, name, property, value);
        return true;
    }
    return false;
}

bool DeleteObject(string name)
{
    return ObjectDelete(0, name);
}

//+------------------------------------------------------------------+
//| Helper Functions                                                  |
//+------------------------------------------------------------------+

void RefreshDashboard()
{
    ChartRedraw();
}

void ResetDashboard()
{
    // Reset all dashboard values to defaults
    g_lastDashboardUpdate = 0;
    
    // Clear all dynamic values
    for (int i = ObjectsTotal(0, 0, OBJ_LABEL) - 1; i >= 0; i--)
    {
        string name = ObjectName(0, i, 0, OBJ_LABEL);
        if (StringFind(name, "Dash_") >= 0 && StringFind(name, "Label") < 0)
        {
            DeleteObject(name);
        }
    }
}

string FormatNumber(double value, int digits)
{
    return DoubleToString(value, digits);
}

string FormatPrice(double price)
{
    return DoubleToString(price, _Digits);
}

string FormatPercent(double value)
{
    return DoubleToString(value * 100, 2) + "%";
}

color ColorByState(bool bullish, bool bearish)
{
    if (bullish)
        return g_colorBullish;
    if (bearish)
        return g_colorBearish;
    return g_colorNeutral;
}

//+------------------------------------------------------------------+
//| End of Dashboard.mqh                                              |
//+------------------------------------------------------------------+
