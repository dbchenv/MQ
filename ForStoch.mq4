//+------------------------------------------------------------------+
//|                                                     ForStoch.mq4 |
//|                      Copyright 2013, try_to_sleep Software Corp. |
//|                                              http://www.oiol.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2013, try_to_sleep Software Corp."
#property link      "http://www.oiol.net"

//--- input parameters
extern double    Lots = 0.5;  //下单手数
extern double    StopLoss=5.0;
extern double    TakeProfit=2.0;
//+------------------------------------------------------------------+
//| expert initialization function                                   |
//+------------------------------------------------------------------+
int init()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert deinitialization function                                 |
//+------------------------------------------------------------------+
int deinit()
  {
//----
   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+

datetime Onetime = 0;

int start()
{
//----

   double MaxP,MixP,MaxTemp,MixTemp=2000;
   double data[][6];
   bool PriceOk;
   ArrayCopyRates(data,"XAUUSD", PERIOD_M5);

   for(int i=0;i<=9;i++){
      if(data[i][3]>MaxTemp){
         MaxTemp = data[i][3];
      }
      if(data[i][2]<MixTemp){
         MixTemp = data[i][2];
      }
   }
   if((MaxTemp-MixTemp)>=3){
      PriceOk = true;
   }else{
      PriceOk = false;
   }

   Print("最高价："+MaxTemp,"---最低价："+MixTemp,"---差价："+(MaxTemp-MixTemp));

   int ticket;
   bool GoBuy,GoSell;
   double G = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_MAIN,0);
   double R = iStochastic(NULL,0,5,3,3,MODE_SMA,0,MODE_SIGNAL,0);
   Print("绿线："+G+"  红线："+R);

   if(OrdersTotal() <= 1)
   {
      if(OrdersTotal() == 1)
      {
         if(OrderSelect(0, SELECT_BY_POS)==true)
         {
            int CloseNum = OrderTicket();
            double CloseLots = OrderLots();
            
            if(OrderType()==1)
            {
               GoBuy = true; GoSell = false;              
            }else{
               GoBuy = false; GoSell = true;
            }
         }
      }else{
          GoBuy = true; GoSell = true;
      }
   
      if((G-R)>=4 && G <= 41 && GoBuy==true && PriceOk==true && Onetime != Time[0])
      {
         ticket=OrderSend(Symbol(),OP_BUY,Lots,Ask,1,Ask-StopLoss,Ask+15,"My order #2",16384,0,Green);
         if(ticket<0){
            Print("OrderSend 失败错误 #",GetLastError());
            return(0);
         }else{
            if(CloseNum != 0 && GoSell==false){
               if(OrderClose(CloseNum,CloseLots,Ask,0.5,White)==true){
                  Print("订单#"+CloseNum+" 已平仓! "+CloseLots);
               }else{
                  Print("订单#"+CloseNum+" 平仓失败! "+CloseLots,"  OrderClose 失败错误 #"+GetLastError());
               }
            }
         }
         Onetime = Time[0];
      }
      if((R-G)>=4 && R >= 59 && GoSell==true && PriceOk==true && Onetime != Time[0])
      {
         ticket=OrderSend(Symbol(),OP_SELL,Lots,Ask,1,Ask+StopLoss,Ask-15,"My order #2",16384,0,Red);
         if(ticket<0){
            Print("OrderSend 失败错误 #",GetLastError());
            return(0);
         }else{
            if(CloseNum !=0 && GoBuy==false){
               if(OrderClose(CloseNum,CloseLots,Ask,0.5,White)==true){
                  Print("订单#"+CloseNum+" 已平仓! "+CloseLots);
               }else{
                  Print("订单#"+CloseNum+" 平仓失败! "+CloseLots,"  OrderClose 失败错误 #"+GetLastError());
               }
            }
         }
         Onetime = Time[0];
      }
   }

//----
   return(0);
}
//+------------------------------------------------------------------+