integer reset_btn;
integer restore_btn;
integer lottery_btn;
key owner;
list tgt_btns;

integer tchan;
integer thandle;

integer reset_chan;
integer reset_handle;

integer restore_chan; 
integer restore_handle; 

integer rolls_chan;
integer rolls_handle;

integer admin_chan;
integer admin_handle;

integer page_chan = -72432346;
integer page_handle;

key target;

string health;
string rolls;



integer touched;


Scan()
{
    
           tgt_btns = [];
           list avis = llGetAgentList(AGENT_LIST_PARCEL,[]);
           
            integer x;
            
            integer tot = llGetListLength(avis);
            
            
             for(x = 0; x < tot; ++x)
            {
             
                key av = llList2Key(avis, x);
                
                
                
             
                  
                  tgt_btns += [llKey2Name(av)] + [av];  
                    
                
                
                
                
                
            }  // for
            
            
            
             if(tgt_btns != [])
            {
                
            llListenRemove(thandle);
            thandle = llListen(tchan, "",owner, "");    
            DialogPlus(owner, "\nSelect someone to manage their HUD:", llList2ListStrided(tgt_btns,0,-1,2), tchan, menuindex = 0);  
            
            
            }
            
            else
            {
              llListenRemove(thandle);
              llDialog(owner,"\nThere is no one in range.",[],-34);  
                
            }  
     Timer();
    
}



Timer()
{
  
  llSetTimerEvent(0.0); 
  llSetTimerEvent(120.0);   
    
}

list order_buttons(list buttons)
{
    return llList2List(buttons, -3, -1) + llList2List(buttons, -6, -4) +
        llList2List(buttons, -9, -7) + llList2List(buttons, -12, -10);
}

integer menuindex;

DialogPlus(key avatar, string message, list buttons, integer channel, integer CurMenu)
{
    if (12 < llGetListLength(buttons))
    {
        list lbut = buttons;
        list Nbuttons = [];
        if(CurMenu == -1)
        {
            CurMenu = 0;
            menuindex = 0;
        }

        if((Nbuttons = (llList2List(buttons, (CurMenu * 10), ((CurMenu * 10) + 9)) + ["Back", "Next"])) == ["Back", "Next"])
            DialogPlus(avatar, message, lbut, channel, menuindex = 0);
        else
            llDialog(avatar, message,  order_buttons(Nbuttons), channel);
    }
    else
        llDialog(avatar, message,  order_buttons(buttons), channel);
}

default
{
    
    on_rez(integer start_param)
    {
        
        
      llResetScript();  
        
    }
    
    state_entry()
    {
       owner = llGetOwner(); 
       
       tchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 735328) | 0x8000000;
       reset_chan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 73738) | 0x8000000;
       restore_chan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 73786) | 0x8000000;

rolls_chan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 5688379) | 0x8000000;
       
        llListenRemove(page_handle); 
        page_handle = llListen(page_chan,"","","");
       
       
       integer total_prims = llGetNumberOfPrims()+1;
       integer p;
      
        for(p = 0; p < total_prims; ++p)
       {
          
          string lnk = llToLower(llGetLinkName(p)); 
          
          if(lnk == "reset_button")
          {
              reset_btn = p;
          }
          
          else if(lnk == "health_button")
          {
              restore_btn = p;
          }
          
           else if(lnk == "reroll_button")
          {
              lottery_btn = p;
          }
        }
    }

    touch_end(integer total_number)
    {
        
         key Toucher = llDetectedKey(0);
        
       if(Toucher == owner)
       {
         touched = llDetectedLinkNumber(0);
       
       if(touched == reset_btn || touched == restore_btn || touched == lottery_btn)
       {
           Scan();
            
         
           
       }
           
           
       }  // toucher == owner
       
    }
    
     listen(integer chan, string name, key id, string msg)
    {

 if(chan == tchan)
        {

        // If they clicked Next it will go to the next dialog window
        if(msg == "Next")
        {
            // ++menuindex will turn menuindex plus 1, making it give the next page.
            DialogPlus(owner, "Select a target:", llList2ListStrided(tgt_btns,0,-1,2), chan, ++menuindex);
        }

        //if they clicked back it will go to the last dialog window.
        else if(msg == "Back")
        {
            // --menuindex will turn menuindex minus 1, making it give the previous page.
            DialogPlus(owner, "Select a target", llList2ListStrided(tgt_btns,0,-1,2), chan, --menuindex);
        }

        // If they choose anything besides Back/Next it will be in this section
        else
        {
            //Be Safe
            llListenRemove(thandle);
            //Example used, change to whatever you wish.
           
            
           
            
            integer idx = llListFindList(tgt_btns, [msg]);
            
            target = llList2Key(tgt_btns, idx+1);
            
            admin_chan = ((integer)("0x"+llGetSubString((string)target,-8,-1)) - 23646) | 0x8000000;
            
            if(touched == reset_btn)
            {
               
                llListenRemove(reset_handle); 
                reset_handle = llListen(reset_chan,"",owner,"");
                
                llDialog(owner,"\nResetting secondlife:///app/agent/" +  (string)target + "/about's HUD will wipe their stats and race. Are you sure you want to reset their HUD?\n",["Yes","No"],reset_chan);
                 Timer();
                
            }
            
            
            else if(touched == restore_btn)
            {
                
                
                
                 llListenRemove(admin_handle); 
                 admin_handle = llListen(admin_chan,"","","");
                
                 llRegionSay(admin_chan,"get_health"); 
                
             //   llDialog(owner,"\nResetting secondlife:///app/agent/" +  (string)target + "/about's HUD will wipe their stats and race. Are you sure you want to reset their HUD?\n",["Yes","No"],restore_chan);
                 Timer();
                
            }
            
            else if(touched == lottery_btn)
            {
                llListenRemove(admin_handle); 
                 admin_handle = llListen(admin_chan,"","","");
                
                 llRegionSay(admin_chan,"get_rolls"); 
                
             //   llDialog(owner,"\nResetting secondlife:///app/agent/" +  (string)target + "/about's HUD will wipe their stats and race. Are you sure you want to reset their HUD?\n",["Yes","No"],restore_chan);
                 Timer();
                
                
                
            }
           

         }

       }
       
       
       else if(chan == reset_chan)
       {
           
          
          if(msg == "Yes")
          {
             llListenRemove(reset_handle);  
             llRegionSay(admin_chan,"reset_hud"); 
             llOwnerSay("secondlife:///app/agent/" +  (string)target + "/about's HUD was reset.");
             touched = reset_btn;
             Scan();
              
          } 
           
           
       }
       
       else if(chan == admin_chan)
       {
        
      
        
        list tmp = llParseString2List(msg, ["|"],[""]);   
         string cmd  = llToLower(llList2String(tmp,0));
         string ref =   llList2String(tmp,1);
         
         
         if(cmd == "send_health")
         {
             health = ref;
             
            llListenRemove(restore_handle);  
            restore_handle = llListen(restore_chan,"",owner,"");
             
             Timer();
             
             if((integer)health < 6)
             {
                
                    
                
                 
                 llDialog(owner,"\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has "+(health)+" health points. Would you like to restore or take away one of their health points?",order_buttons(["Add Health", "Take Health","Back","Close"]),restore_chan);
                 
             }
             
             else
             {
                 
                 llOwnerSay("\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has full health.");
                 llDialog(owner,"\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has full health.",[ "Take Health","Back","Close"],restore_chan);
                 
                 
             }
             
         }
         
         
         
          if(cmd == "send_rolls")
         {
             rolls = ref;
             
            llListenRemove(rolls_handle);  
            rolls_handle = llListen(rolls_chan,"",owner,"");
             
             Timer();
             
             if((integer)rolls > 0)
             {
                
                 if((integer)rolls < 3)   
                {
                 
                 llDialog(owner,"\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has "+(rolls)+" rerolls. Would you like to award them another reroll or take away a reroll?",order_buttons(["Add Reroll", "Take Reroll","Back","Close"]),rolls_chan);
                }
                
                else
                {
                    
                    llDialog(owner,"\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has "+(rolls)+" rerolls. Would you like to take away a reroll?",order_buttons([ "Take Reroll","Back","Close"]),rolls_chan);
                    
                    
                }
                
                 
             }
             
             else
             {
                 
                 llDialog(owner,"\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about has "+(rolls)+" rerolls. Would you like to award them a reroll?",order_buttons(["Add Reroll","Back","Close"]),rolls_chan);
                 
                 
             }
             
         }
         
           
           
       } //admin_chan
       
       
       else if(chan == restore_chan)
       {
           if(msg == "Add Health")
           {
               
                llRegionSay(admin_chan,"add_health_point"); 
                llSleep(1.0);
                llRegionSay(admin_chan,"get_health"); 
                
           }
           
           else if(msg == "Take Health")
           {
               
                llRegionSay(admin_chan,"take_health_point"); 
                llSleep(1.0);
                llRegionSay(admin_chan,"get_health"); 
                
           }
           
           else if(msg == "Back")
           {
               
             touched = restore_btn;  
             
             Scan();
               
           }
           
        }  //  else if(chan == restore_chan)
           
           
            else if(chan == rolls_chan)
       {
           if(msg == "Add Reroll")
           {
               
                llRegionSay(admin_chan,"add_reroll_point"); 
                llSleep(1.0);
                llRegionSay(admin_chan,"get_rolls"); 
                
           }
           
           else if(msg == "Take Reroll")
           {
               
                llRegionSay(admin_chan,"take_reroll_point"); 
                llSleep(1.0);
                llRegionSay(admin_chan,"get_rolls"); 
                
           }
           
           else if(msg == "Back")
           {
               
             touched = lottery_btn;  
             
             Scan();
               
           }
           
          
            
           
       } //  else if(chan == rolls_chan)
       
       else if(chan == page_chan)
       {
           
           llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about paged you!");
           llDialog(owner, "\nsecondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about paged you!", ["Ok"], -890);
           
           
       }
       
    } // listen
    
    changed(integer change)
    {
        
       if(change & CHANGED_OWNER)
       {
           
          llResetScript(); 
           
       } 
        
        
        
    }
    
    timer()
    {
        llListenRemove(thandle);
       llListenRemove(reset_handle); 
       llListenRemove(restore_handle); 
        llListenRemove(admin_handle); 
       
        
    }
    
}
