//+------------------------------------------------------------------+
//|                                               equity_monitor.mq4 |
//|                                                           zenott |
//|                                    https://www.github.com/zenott |
//+------------------------------------------------------------------+
#property copyright "zenott"
#property link      "https://www.github.com/zenott"
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

#include <stdlib.mqh>
#include <stderror.mqh>

extern int interval=1;

datetime time_bill=0;
int count=0;

int OnInit()
  {
//--- indicator buffers mapping
   ObjectCreate("line_1",OBJ_LABEL,0,0,0);
//---
   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason)
  {
//---
   ObjectDelete("line_1");
   
  }
  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  
  bool pos_open=false;
  for(int i=OrdersTotal() - 1;i>=0; i--) 
               {
                  bool os14=OrderSelect(i,SELECT_BY_POS);
                  if(OrderType()==OP_SELL || OrderType()==OP_BUY) 
                     {
                        pos_open=true;
                     } 
               }

   if (time_bill != iTime(NULL,PERIOD_M1,0))
            {
               if(pos_open==true && MathMod(count,interval)==0)
                  { 
                     int filehandle;  
                     filehandle=FileOpen("equity.csv",FILE_READ|FILE_WRITE|FILE_CSV);
                     if(filehandle!=INVALID_HANDLE)
                       {
                        FileSeek(filehandle,0,SEEK_END);
                        FileWrite(filehandle,TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES),DoubleToStr(AccountEquity(),2),DoubleToStr(AccountProfit(),2));
                        FileClose(filehandle);
                        Print("File updated.");
                       }
                     else Print("Operation FileOpen failed, error ",GetLastError());
                  }
            
               count=count+1;
            }
   time_bill = iTime(NULL,PERIOD_M1,0);   
   
   string text_append="";
   if (pos_open==true) text_append=" - Active";
   
   ObjectSet("line_1",OBJPROP_CORNER,2);
   ObjectSet("line_1",OBJPROP_XDISTANCE,14);
   ObjectSet("line_1",OBJPROP_YDISTANCE,14);
   ObjectSet("line_1",OBJPROP_COLOR,Brown);
   ObjectSet("line_1",OBJPROP_WIDTH,3);
   ObjectSet("line_1",OBJPROP_BACK,false);
   ObjectSet("line_1",OBJPROP_FONTSIZE,10);
   ObjectSetText("line_1","Equity Monitor"+text_append,10,"Times New Roman");

   

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
