// enter these variables manually
string URL =  "https://rumorcity.000webhostapp.com/phptest.php";

string region = "a6226d40-7dc8-8db4-dd9a-395ee7c685a5";

//______________________________________________

string pass = "Rum0r_c!ty1"; //  A password to protect data in database so no outside scripts cannot read or modify data. Password must be the same in all authorized scripts that read or write data

key    http_request_new;
key    http_request_update; 
key    http_request_reset;
key    http_request_rolls;
string req; 

float range = 20.0;

integer sqlimit = 9; // limit of how many skill points can be spent per modifier

integer health = 6;
integer mod_points = 9;
integer atk_mod = 0;
integer evade_mod = 0;
integer stealth_mod = 0;
integer detect_mod = 0;
integer strength_mod = 0; 
integer rolls = 0;
integer finalize = FALSE;
string race = "";


list tgt_btns;


integer gRoll;
integer aRoll;

integer lchan;  // chan to hear other huds and admin hud
integer lhandle;

integer tchan;  // chan to target another hud
integer thandle;

integer rchan;    // chan to select race
integer rhandle;

integer modchan; // chan to set modifiers
integer modhandle;

integer rollchan; // chan to select roll type
integer rollhandle;

integer adminchan;
integer adminhandle;


integer finchan;
integer finhandle;

integer pause_chan;
integer pause_handle;
 


integer titlerchan;

integer pagechan = -72432346;
integer pagemenu;
integer pagehandle;

integer achan;

key target;
key owner;








// >>>> dice rolls <<<<<<<<

integer attack_roll;
integer evade_roll;
integer detect_roll;
integer stealth_roll;
integer astrength_roll;
integer tstrength_roll;

integer max_roll = 20;

//__________________________



 

list races  = ["Human", "Bio-Mech","Android","Replicant","Were","Neo-Vampire"];




string roll_type;

string lshealth;
integer lswrite;




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

Race()
{
  finalize = FALSE;  
  lswrite = Protect("lsfinalize",(string)finalize);
  llListenRemove(rhandle);
  rhandle =llListen(rchan,"",owner,"");
  llDialog(owner,"\nSelect your race:",races,rchan);
  Timer();  
    
}


ModMenu()
{
    
   
   llListenRemove(modhandle);
   modhandle = llListen(modchan,"",owner,"");
   llDialog(owner, "\n\nRace: "+race+"\n\nAttack:"+(string)atk_mod+"\nEvade:"+(string)evade_mod+"\nStealth:"+(string)stealth_mod+"\nDetect:"+(string)detect_mod+"\nStrength:"+(string)strength_mod+"\n\nYou have "+(string)mod_points+" points to spend.\n\nSelect a modifier to add a point to it.\n\nSelect Reset to reset your race and modifiers before finalizing.\n\nSelect Finalize to finalize your character.\n", order_buttons(["Attack", "Evade", "Stealth", "Detect","Strength","Reset","Finalize", "Close"]), modchan);
   Timer();
   
   
 
   
    
    
    
    
    
}


integer Roll()
{
    
  // integer r = llRound(llFrand(20.0));
  
  integer r = (integer)(llFrand(21.0));

   
   if(r == 0)
   {
      
       return Roll();
   }
   
   else
   { 
   return r; 
   }
}




Attacked(key id)
{
    evade_roll = (integer)pRead("lsevade_roll");
    rchan = ((integer)("0x"+llGetSubString((string)id,-8,-1)) - 7863) | 0x8000000;
    llRegionSay(rchan, "EVADE_ATTACK|"+(string)evade_roll);
  llOwnerSay("/me lost a health point."); 
                 health -= 1 ; 
                  lswrite = Protect("lshealth",(string)health);
                 LM("Set_Health","1"); 
                
                 Titler();
                 
                 llMessageLinked(LINK_SET,health,"set_health_timer","");
                 
                  RegionCheck();
                  
                  req = "update";
                  Web("UPDATE", "http_request_update");    
    
    
}

Detected(key id)
{
     llOwnerSay("You were detected by secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about");
    stealth_roll = (integer)pRead("lsstealth_roll");
     rchan = ((integer)("0x"+llGetSubString((string)llGetOwnerKey(id),-8,-1)) - 7863) | 0x8000000;

              llRegionSay(rchan, "STEALTH_ATTACK|"+(string)stealth_roll);
    
}


Strengthed(key id)
{
     llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about was stronger than you.");
    tstrength_roll = (integer)pRead("lststrength_roll");
     llRegionSay(rchan, "STRENGTH_ATTACK|"+(string)tstrength_roll);
    
}



integer ModCheck(integer mod)
{
    if(mod_points > 0)
    {
  
   if(mod < sqlimit)  
    {
      mod = mod + 1;  
      mod_points = mod_points - 1;
      
       if(mod_points <= 0) 
   { 
      
       llOwnerSay("You have no more modifier points to spend.");
       
    }
      return mod; 
     }
            
     else
     {
              
        llOwnerSay("Modifier maxed. You can not add more points to that modifier.");
        return mod;        
      }  
    }
    
    else
    {
        llOwnerSay("You have no more modifier points to spend.");
        return mod; 
        
    }
    
}

integer Modify(string roll, integer r, integer m)
{
    
  integer perc;
  
  perc = m * 5;
  
   
    
  integer mod = llRound((float)perc/100 * r) ;  
  
  llWhisper(0, roll + " secondlife:///app/agent/" +  (string)owner + "/about: ["+(string)r+"] +" + "[" + (string)mod + "] = " +"[" + (string)(mod + r) + "]");
  
    
  return mod + r;  
}











Timer()
{
  
  llSetTimerEvent(0.0); 
  llSetTimerEvent(120.0);   
    
}

string pRead(string kv)
{
    
  return llLinksetDataReadProtected(kv,pass);
    
}

Read()
{   
    health = (integer)pRead("lshealth");
    race = pRead("lsrace");
    atk_mod = (integer)pRead("lsatk_mod");
    evade_mod = (integer)pRead("lsevade_mod");
    stealth_mod = (integer)pRead("lsstealth_mod");
    detect_mod = (integer)pRead("lsdetect_mod");
    strength_mod = (integer)pRead("lsstrength_mod");
    mod_points = (integer)pRead("mod_points"); 
    rolls = (integer)pRead("lsrolls"); 
    string fin = pRead("lsfinalize"); 
    if( fin == "" || fin == "0" )
    {
      
      finalize = FALSE;  
        
    }
    
    else
    {
     
     finalize = TRUE;   
        
    }
    
     LM("set_squares","");
    
   
    req = "update";
    Web("UPDATE", "http_request_update");
}

integer Protect(string kv, string val)
{
  
   return llLinksetDataWriteProtected(kv,val,pass);
    
}

Write(integer dir)  // dir is direction to suptract square, 1 will subtract the first square, 0 will subtract the last square
{
     lswrite = Protect("lshealth",(string)health);
      lswrite = Protect("lsrace",race);
     lswrite = Protect("lsatk_mod",(string)atk_mod);
      lswrite = Protect("lsevade_mod",(string)evade_mod);
      lswrite = Protect("lsstealth_mod",(string)stealth_mod);
     lswrite = Protect("lsdetect_mod",(string)detect_mod);
      lswrite = Protect("lsstrength_mod",(string)strength_mod);
     lswrite = Protect("lsmod_points",(string)mod_points);
      lswrite = Protect("lsrolls",(string)rolls); 
      lswrite = Protect("lsfinalize",(string)finalize);
    
     LM("set_squares","1");
    
    req = "update"; 
    Web("UPDATE", "http_request_update");
}


Web(string cmd, string req_id)
{
//integer lsmod_points;
//integer lsatk_mod;
//integer lsevade_mod;
//integer lsstealth_mod;
//integer lsdetect_mod;
//integer lsstrength_mod;
//integer lsfinalize;
//integer lsrolls;

//integer mod_points = 9;
//integer atk_mod = 0;
//integer evade_mod = 0;
//integer stealth_mod = 0;
//integer detect_mod = 0;
//integer strength_mod = 0; 
//integer rolls = 0;
    
    
// llSay(0,"Sending...");

      

       rolls = (integer)pRead("lsrolls");
      
       
       if(race == "")
       {race = "none";}
       
       string j_obj = llList2Json( JSON_OBJECT,     
           [   
           "uuid", llGetOwner(),
           "name", llKey2Name(llGetOwner()),
           "rolls", rolls,
           "health", health,
           "race", race,
           "mod_points", mod_points,
           "attack_mod", atk_mod,
           "evade_mod", evade_mod,
           "stealth_mod", stealth_mod,
           "detect_mod", detect_mod,
           "strength_mod", strength_mod,
           "finalize", finalize,
           "cmd", llToUpper(cmd)
            
           
                 
           ]);
           
           
       list params = [ HTTP_METHOD, "POST", 
         HTTP_MIMETYPE,        "application/x-www-form-urlencoded", 
         HTTP_BODY_MAXLENGTH,  16384,
         HTTP_PRAGMA_NO_CACHE, TRUE
       ];    
           
           
     if(req_id == "http_request_new")
     {
       http_request_new = llHTTPRequest(URL ,
       params, j_obj );  
     }
       
     else if(req_id == "http_request_update")
     {
       http_request_update = llHTTPRequest(URL ,
       params, j_obj );  
     }
     
      else if(req_id == "http_request_rolls")
     {
       http_request_rolls = llHTTPRequest(URL ,
       params, j_obj );  
     }
     
      else if(req_id == "http_request_reset")
     {
       http_request_reset = llHTTPRequest(URL ,
       params, j_obj );  
     }
    
    if(race == "none")
       {race = "";}
}



integer Region_Paused = FALSE;
integer Hud_Paused = FALSE;

RegionCheck()
{
     list details = llGetParcelDetails(llGetPos(), [PARCEL_DETAILS_ID]);
        if (llList2String(details ,0) != region)
        {
          Region_Paused = TRUE;
          
           lswrite = Protect("lsregion",(string)Region_Paused);
          
           llMessageLinked(LINK_SET, 0 ,"pause_health_timer",""); 
          
           llOwnerSay("User detected off sim. Healing suspended."); 
            
            
        }
        
        else
        {
            
            if(health < 6)
            {
             llOwnerSay("User detected on sim. Healing allowed."); 
            Region_Paused = FALSE;
             lswrite = Protect("lsregion",(string)Region_Paused);
            
            Hud_Paused = (integer)pRead("lshudpaused");
            
           
            
            if(Hud_Paused == FALSE)
            {
           llMessageLinked(LINK_SET, health ,"resume_health_timer",""); 
LM("set_health","1");
                Titler();
             }
             }
             
             else
             {
                 
                 llMessageLinked(LINK_SET,health,"pause_health_timer",""); 
            llOwnerSay("Healing inactive. You are currently at full health.");  
                 
                 
              }
            
            
         }
    
   Titler(); 
    
}

Titler()
{
   Hud_Paused = (integer)pRead("lshudpaused");
   Region_Paused = (integer)pRead("lsregion");
   
   if(Hud_Paused == TRUE || Region_Paused == TRUE)
   {
        llSay(titlerchan,"health_paused|" + (string)health);
       
    }
    
    else
    {
        
        llSay(titlerchan,"health_resumed|" + (string)health);
    }
    
    
    
}

LM(string msg, key id)
{
  
  llMessageLinked(LINK_SET,0,msg,id);  
    
}




default
{
    
    on_rez(integer start_param)
    {
       if(llGetOwner() != owner)
       { 
        
        llLinksetDataReset();
        llResetScript();
       
       }
       
       else
       {
          llResetScript();  
           
       }
        
    }
    
    state_entry()
    {
     
     //  llLinksetDataReset();
       integer at = llGetAttached();  
      
      if(at != 0) 
      {  
    
       llSleep(2.0);
        
       owner = llGetOwner(); 
       
       finalize = FALSE;

     
       
        tchan = ((integer)("0x"+llGetSubString((string)llGetKey(),-8,-1)) - 6368) | 0x8000000;
        lchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 7863) | 0x8000000;
        rchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 8421) | 0x8000000;
        modchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 3257) | 0x8000000;
        rollchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 1257) | 0x8000000;
        adminchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 23646) | 0x8000000;
        pagemenu = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 7243) | 0x8000000;
        titlerchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 848537) | 0x8000000;
        pause_chan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 72873) | 0x8000000;;
         
         
        
       
         llListenRemove(lhandle);
            lhandle = llListen(lchan, "","", "");   
       
          llListenRemove(adminhandle);
          adminhandle = llListen(adminchan, "","", ""); 
       
     
       
       
       lshealth = pRead("lshealth");
       
       
       
      
       
       
       
       if(lshealth == "")
       {
         
         health =   6;
        lswrite = Protect("lshealth",(string)health);
         
         //potential place to contact web server
           
       }
       
       else 
       {
       
         health = (integer)lshealth;
       //potential place to contact web server
        
       
       }
       
       
       
      // llSay(titlerchan,(string)health);
       
       RegionCheck();
        
    
     
     
     // place web server here move checking race
     
    
    
      
      race = pRead("lsrace");
      
      if(race == "")
      {
          
          Web("POST", "http_request_new");
          
         
          
      }
      
      else
      {
        
        Read();  
       
             
      } 
     }
     
     else
     {
       
       llOwnerSay("HUD not attached. Please attach to continue."); 

   // llDie(); 
         
     }
     
     
    }
    
      http_request(key id, string method, string body)
    { 
        integer responseStatus = 200;
        string responseBody    = "my method"; 
       
        if (method == "GET")
        {  responseStatus = 200;
           responseBody   = "ok";
        }
        // else if (method == "POST") ...;
        // else if (method == "PUT") ...;
        // else if (method == "DELETE") { responseStatus = 403; responseBody = "forbidden"; } 
        llHTTPResponse(id, responseStatus, responseBody);
    }
    http_response(key request_id, integer status, list metadata, string body) 
    { 
   
    
    list tmp = llParseString2List(body,["|"],[]);
    
    string cmd = llToLower(llList2String(tmp,0));
    string ref = llList2String(tmp,1);
     list json = llJson2List(ref);   
  
    
     
     
   if(request_id == http_request_new)
   { 
    if(body != "")
    {
    if(cmd == "found")
    {
      
     if(llJsonGetValue((string)json,["race"]) == "none")
     {
        
        Race(); 
         
     } 
     
     else
     {
     rolls = (integer)llJsonGetValue((string)json,["wins"]);
     
     health = (integer)llJsonGetValue((string)json,["health"]);

     race = llJsonGetValue((string)json,["race"]);
     
     mod_points = (integer)llJsonGetValue((string)json,["mod_points"]);

     atk_mod = (integer)llJsonGetValue((string)json,["attack_mod"]);


     evade_mod = (integer)llJsonGetValue((string)json,["evade_mod"]);


    stealth_mod = (integer)llJsonGetValue((string)json,["stealth_mod"]);

    detect_mod = (integer)llJsonGetValue((string)json,["detect_mod"]);

    strength_mod = (integer)llJsonGetValue((string)json,["strength_mod"]);

   finalize = (integer)llJsonGetValue((string)json,["finalize"]);
     
    Write(1);
    }
     
      
    } // found
    
    else if(cmd == "not found")
    {
        
        
         Race();
        
    }
    } // body !=""
    
    else
    {
        Web("POST", "http_request_new");
        
     }
    
    
    } //http_request_new


   else if(request_id == http_request_update)
   {
   
    
    if(body != "")
    {
    
    if(cmd == "updated")
    {
        rolls = (integer)pRead("lsrolls");
        
         integer wins = (integer)llJsonGetValue((string)json,["wins"]);
      
         if(rolls > wins)
         {
          req = "rolls_update"; 
          Web("Rolls_Update", "http_request_rolls");
             
         }


        else if(wins > rolls)
         {
           
           llOwnerSay("You have been awarded " + (string)(wins - rolls) + " re-rolls!");
           
           rolls = wins;  
           
          lswrite = Protect("lsrolls",(string)rolls);
           
          
         }
        
    }
    
    }// if body != ""
   
   else 
    {
        
        if(req == "update")
        {
        
          Web("Update", "http_request_update");
                 
        }
        
        else if(req == "rolls_update")
        {
            
         Web("Rolls_Update", "http_request_rolls");
  
            
        }

        }
    
    } // http_request_update 
    
   else if(request_id == http_request_rolls)
   {
      
       
       if(body == "")
       {
         
         req = "rolls_update"; 
         Web("Rolls_Update", "http_request_rolls");  
           
       }
       
   }
    
    else if(request_id == http_request_reset)
   {
    
   
    
    if(body != "")
    {
    
    if(cmd == "database_reset")
    {
     llOwnerSay("Database has been reset. You can respec your character now.");
     llResetScript();   
        
    }
    
    }  // bpdy != ""
    
    else
    {
        Web("Reset", "http_request_reset");
        
    }
    
   } // http_request_reset 
    
    
    }
    

    touch_end(integer total_number)
    {
        
       llOwnerSay("Memory: " + (string)llGetFreeMemory()); 
       
    } // touch_end
    
    
     link_message(integer sender, integer num, string msg, key id) 
    {
        msg = llToLower(msg);
        
        if(msg == "restore_health")
        {
          
        
           
          if(health < 6)
          { 
          
           health += 1; 
          lswrite = Protect("lshealth",(string)health);
           LM("Set_Health","0");
           Titler();
           Write(1);
         if(health < 6)
         { 
          llMessageLinked(LINK_SET,health,"set_health_timer","");
         }
         
         else
         {
             
             llMessageLinked(LINK_SET,health,"pause_health_timer",""); 
            llOwnerSay("Healing inactive. You are currently at full health.");  
         }
         
         
          }
          
          else
          {
             llMessageLinked(LINK_SET,health,"pause_health_timer",""); 
            llOwnerSay("Healing inactive. You are currently at full health.");  
              
          }
            
        }
        
        
        else if(msg == "reroll_accepted")
        {
           roll_type = llToLower(pRead("lsroll_type")); 

            rolls = rolls - 1;
            
            lswrite = Protect("lsrolls",(string)rolls);
            
            req = "rolls_update";
             Web("Rolls_Update", "http_request_rolls");
            
            
             if(roll_type == "attack")
           {
               llRegionSay(rchan, "REROLL_ATTACK");
               
           } 
           
           
            else if(roll_type == "detect")
           {
               llRegionSay(rchan, "REROLL_DETECT|"+(string)owner);
               
           } 
           
            else if(roll_type == "strength")
           {
               llRegionSay(rchan, "REROLL_STRENGTH|"+(string)owner);
               
           } 
            
            
        }
        
         else if(msg == "reroll_declined")
        {
           roll_type = llToLower(pRead("lsroll_type")); 
           
           if(roll_type == "attack")
           {
               
               Attacked(id);
           } 
           
            else if(roll_type == "detect")
           {
               
               Detected(id);
           } 
           
            else if(roll_type == "strength")
           {
               
               Strengthed(id);
           } 
            
        }
        
        
        
        else if(msg == "race_menu")
        {
         
          llListenRemove(rhandle);
          rhandle =llListen(rchan,"",owner,"");
          
          llDialog(owner,"\nSelect your race:",races,rchan);
           Timer();   
            
        }
        
        else if(msg == "touch_roll")
        {
           
            
            if(finalize == TRUE)
           {
           llListenRemove(rollhandle);
           rollhandle = llListen(rollchan,"",owner,"");
           Timer();
           llDialog(owner,"\nSelect to roll for Attack, Detect or Strength.\n",["Attack", "Detect", "Strength"],rollchan);
          }
          
          else
          {
              llOwnerSay("You must finalize your character before rolling. Select the \"Modifiers\" button and select Finalize to finalize your character.");

              llDialog(owner, "\nYou must finalize your character before rolling.\n\nSelect the \"Modifiers\" button and select Finalize to finalize your character.\n", ["Ok"], -39);
              
          }           
            
        }
        
        
         else if(msg == "touch_mod")
        {
            if(finalize == FALSE)
          { 
          
          ModMenu();
          
          }
          
          else
          {
             
             llOwnerSay("You can not make changes to your character after finalizing. To reset you HUD contact an admin."); 
              
          }
            
        }
        
        else if(msg == "touch_page")
        {
           llListenRemove(pagehandle);
          pagehandle = llListen(pagemenu,"",owner,"");
          Timer();
          llDialog(owner, "\nWould you like to page nearby admins?",["Yes","No"],pagemenu);
            
        }
        
         else if(msg == "touch_pause")
        {
            llDialog(owner,"\nSelect to pause or resume the health timer", ["Pause", "Resume"],lchan);
            
        }
        
        else if(msg == "read_squares")
        {
            Read();
            
        }
        
         else if(msg == "attacked")
        {
            Attacked(id);
            
        }
        
        else if(msg == "detected")
        {
            Detected(id);
            
        }
        
         else if(msg == "strengthened")
        {
            Strengthed(id);
            
        }
        
        
        else if(msg == "request_unpause")
      {
          llListenRemove(pause_handle);
          pause_handle = llListen(pause_chan,"","","");
          llDialog(owner,"\"Healing is currently paused. Do you want to resume healing?", ["Yes","No"],pause_chan);
          Timer();
          
          
      }
        
        
     }
    
    
    
      listen(integer chan, string name, key id, string msg)
    {
       
       
       
     if(chan == lchan)
       {
           
         list tmp = llParseString2List(msg, ["|"],[""]); 
          
           
         string cmd  = llToLower(llList2String(tmp,0));
         string ref =   llList2String(tmp,1);
         
         rchan = ((integer)("0x"+llGetSubString((string)llGetOwnerKey(id),-8,-1)) - 7863) | 0x8000000;

        
         
         if(cmd == "health_check") 
         {
             
              
              
              llRegionSay(rchan, "SEND_HEALTH|"+(string)health);
             
             
             
         }
         
         else if(cmd == "send_health")
         {
             
            if((integer)ref > 0)
            { 
              gRoll = Modify("Attacker", Roll(),atk_mod);
            
            attack_roll = gRoll;
            
            llOwnerSay("/me rolled a "+(string)gRoll);
             
             
            llRegionSay(rchan, "ATTACK_TARGET|" +(string)gRoll);
            }
            
            else
            {
              llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " does not have health right now."); 
                    
            }
             
         }
         
         else if(cmd == "attack_target")
          {

              
              lswrite = Protect("lsroll_type","attack");
              
              attack_roll = (integer)ref;
              
              llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)attack_roll);
              
              gRoll = Modify("Evader", Roll(),evade_mod);
              
             llOwnerSay("/me rolled a "+(string)gRoll);
              
              evade_roll = gRoll;
              
                 
              
              
              
              /// do health check here
              
              if(attack_roll > evade_roll) // attacker wins
              {
                
                if(rolls > 0) 
                {
                    llRegionSay(rchan, "Rerolling");
                  lswrite = Protect("lsattack_roll",(string)attack_roll);
                
                   lswrite = Protect("lsevade_roll",(string)evade_roll);
                   
                  LM("reroll_attack",llGetOwnerKey(id));
                    
                    
                }
                
                else
                {
                   
                   Attacked(llGetOwnerKey(id));
                    
                }
                  
              }
              
              else // attacker loses
              {
                  // do or say smething something to attacker
                   llWhisper(0," secondlife:///app/agent/" +  (string)owner + "/about evaded the attack.");
              }
              
              
              
           
              
          }  //if cmd == attack_target
          
          
          
           else if(cmd == "reroll_attack")
          {
            
              llRegionSay(achan, "HEALTH_CHECK");

              
          }
          
          
           else if(cmd == "detect_target")
          {
              lswrite = Protect("lsroll_type","detect");
              detect_roll = (integer)ref;
              
              llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)detect_roll);
              
              gRoll = Modify("Stealther",Roll(),stealth_mod);
               
             llOwnerSay("/me rolled a "+(string)gRoll);
              
              stealth_roll = gRoll;
              
              
              
              /// do health check here
              
              if(detect_roll > stealth_roll)
              {
                  
                  if(rolls > 0) 
                {
                    llRegionSay(rchan, "Rerolling");
                  lswrite = Protect("lsdetect_roll",(string)detect_roll);
                
                   lswrite = Protect("lsstealth_roll",(string)stealth_roll);
                    
                  LM("reroll_detect",llGetOwnerKey(id));
                    
                    
                }
                
                else
                {
                   
                   Detected(id);
                    
                }
                  
                  
                  
                  
                  
                  
               
                  
              }
              
              else
              {
                  llWhisper(0," secondlife:///app/agent/" +  (string)owner + "/about avoided detection."); 
                  
              }
              
              
              
           
              
          } 
          
          
           else if(cmd == "reroll_detect")
          {
            
              gRoll = Modify("Detector",Roll(),detect_mod);
            
            detect_roll = gRoll;
            
            llOwnerSay("/me rolled a "+(string)gRoll);
             
           
            llRegionSay(achan, "DETECT_TARGET|" +(string)gRoll);

              
          }
          
          
          else if(cmd == "strength_target")
          {
              lswrite = Protect("lsroll_type","strength");
              astrength_roll = (integer)ref;
              
              llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)astrength_roll);
              
              gRoll = Modify("Strength",Roll(),stealth_mod);
              
             llOwnerSay("/me rolled a "+(string)gRoll);
              
              tstrength_roll = gRoll;
              
                 rchan = ((integer)("0x"+llGetSubString((string)llGetOwnerKey(id),-8,-1)) - 7863) | 0x8000000;
              
             // 
              
              /// do health check here
              
              if(astrength_roll > tstrength_roll)
              {
                  
                   if(rolls > 0) 
                {
                    llRegionSay(rchan, "Rerolling");
                  lswrite = Protect("lsastrength_roll",(string)astrength_roll);
                
                   lswrite = Protect("lststrength_roll",(string)tstrength_roll);
                   
                  LM("reroll_strength",llGetOwnerKey(id));
                    
                    
                }
                
                else
                {
                   Strengthed(id); 
                    
                 }
                  
               
                  
              }  // attacker strength > target strength
              
             
              
              
              else
              {
                  llWhisper(0," secondlife:///app/agent/" +  (string)owner + "/about was stronger than secondlife:///app/agent/" +  (string)llGetOwnerKey(id)+ "/about .");   
                  
              }
              
              
              
           
              
          } 
          
          
          
           else if(cmd == "reroll_strength")
              {
                 
                 gRoll = Modify("Strength",Roll(),strength_mod);
            
            astrength_roll = gRoll;
            
            llOwnerSay("/me rolled a "+(string)gRoll);
             
             
            llRegionSay(achan, "STRENGTH_TARGET|" +(string)gRoll); 
                   
                  
              }
              
              
          
          else if(cmd == "evade_attack")
          {
              
              evade_roll = (integer)ref;
              
              // notify attacker their of victory or loss
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)evade_roll);  

             if(attack_roll > evade_roll)
             {
                 
                llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+" lost a health point.");   
                 
             }
              
          }
          
          
           else if(cmd == "stealth_attack")
          {
              
              stealth_roll = (integer)ref;
              
              // notify attacker their of victory or loss
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)stealth_roll);  

             if(detect_roll > stealth_roll)
             {
                 
                llOwnerSay("/me detected secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+".");   
                 
             }
              
          }
          
          else if(cmd == "strength_attack")
          {
              
              tstrength_roll = (integer)ref;
              
              // notify attacker their of victory or loss
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+ " rolled a "+(string)tstrength_roll);  

             if(astrength_roll > tstrength_roll)
             {
                 
                llOwnerSay("You were stronger than secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about"+".");   
                 
             }
              
          }
          
          else if(cmd == "pause")
          {
             if(health < 6)
              {  
              
              lswrite = Protect("lshudpaused",(string)TRUE); 
             llMessageLinked(LINK_SET, 0 ,"pause_health_timer",""); 
             Titler();
              }
              
              else
              {
                
                llOwnerSay("You are at full health.");
                  
              }
          }
          
          else if(cmd == "resume")
          {
              if(health < 6)
              {
                lswrite = Protect("lshudpaused",(string)FALSE);   
                 
              RegionCheck();
              }
              
          } 
          
          else if(cmd == "get_health")
          {
            
             Titler();
              
          }
          
          else if(cmd == "rerolling")
          {
              
            llOwnerSay("Asking secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about for a reroll");  
              
          }

           
           
        } // = lchan
        
        else if(chan == rchan)
        {
          // races  = ["Human", "Bio-Mech","Android","Replicant","Were","Neo-Vampire"]; 
          msg = llToLower(msg);
          if(msg == "human")
          {
            mod_points = 9;  
              
          }
          
          
          else if(msg == "bio-mech")
          {
            
             strength_mod = evade_mod + 3;
             mod_points = mod_points - 3;
              
          }
          
           else if(msg == "android")
          {
              
             detect_mod = detect_mod + 3;
             mod_points = mod_points - 3;
              
          }
          
           else if(msg == "replicant")
          {
              
             evade_mod = evade_mod + 3;
             mod_points = mod_points - 3;
              
          }
          
           else if(msg == "were")
          {
              //SetSquares(list tmp,integer h, key txt1,key txt2, vector col,  integer dir)
            
             atk_mod = atk_mod + 2;
             detect_mod = detect_mod+2;
             mod_points = mod_points - 4;
              
          }
          
           else if(msg == "neo-vampire")
          {
             
             evade_mod = evade_mod + 2;
             
             stealth_mod = stealth_mod+2;
             mod_points = mod_points - 4;
              
          }
          
           Protect("lshealth",(string)health);
          race = msg;
         lswrite = Protect("lsrace",race);
          Write(1);
          ModMenu();
            
        }  //else if(chan == rchan)
        
      else if(chan == modchan)
      {
          msg = llToLower(msg);
          
          if(msg == "attack")
          {
            
           atk_mod = ModCheck(atk_mod);   
           Write(1);
           ModMenu();
              
          }
          
          else if(msg == "evade")
          { 
             evade_mod = ModCheck(evade_mod);  
             Write(1);
             ModMenu();
          }
          
          else if(msg == "stealth")
          {
               
            stealth_mod = ModCheck(stealth_mod);  
            Write(1);
             ModMenu();
              
          }
          
          else if(msg == "detect")
          { 
            
             detect_mod = ModCheck(detect_mod);  
             Write(1);
             ModMenu();
              
          }
          
          else if(msg == "strength")
          {
              
             strength_mod = ModCheck(strength_mod);  
             Write(1);
             ModMenu();
              
          }
          
          else if(msg == "reset")
          {
              
            llLinksetDataReset();
            
            lswrite = Protect("lsrolls",(string)rolls);
            
            llOwnerSay("Resetting database. Please wait..."); 
           
            Web("RESET", "http_request_reset");
            
             
              
          }
          
          else if (msg == "finalize")
          {
              finchan = ((integer)("0x"+llGetSubString((string)llGetKey(),-8,-1)) - 34682) | 0x8000000;
              finhandle = llListen(finchan,"",owner,"");
              
              llDialog(owner,"\nYou are about to finalize you character. You will not be able to change your race or modifiers after finalizing. \n\nDo you want to finalize your character?",["Yes","No"],finchan);
              Timer();
              
          }
          
         
          
         
         
          
       } 
       
       
       else if(chan == rollchan)
       {
           
          roll_type = llToLower(msg); 
           
         
            tgt_btns = [];
            list avis = llGetAgentList(AGENT_LIST_PARCEL,[]);
            
            vector obj_pos = llGetPos();
            
            integer x;
            
            integer tot = llGetListLength(avis);
            
            
            
            for(x = 0; x < tot; ++x)
            {
             
                key av = llList2Key(avis, x);
                
                if(av != owner)
                {
                
                list tmp = llGetObjectDetails(av,[OBJECT_POS]);
                
                vector avi_pos = llList2Vector(tmp, 0);
                
                float dist = llVecDist(avi_pos,obj_pos);
                
                if(dist < range)
                {
                  
                  tgt_btns += [llKey2Name(av)] + [av];  
                    
                }
                
                }
                
                
            }  // for
            
            if(tgt_btns != [])
            {
                
            llListenRemove(thandle);
            thandle = llListen(tchan, "",owner, "");    
            DialogPlus(owner, "\nSelect someone to attack:", llList2ListStrided(tgt_btns,0,-1,2), tchan, menuindex = 0);  
             Timer();
            
            }
            
            else
            {
              llListenRemove(thandle);
              llDialog(owner,"\nThere is no one in range.",[],-34);  
                
            }  
            
         
           
           
       }  // rollchan
       
       
       else if(chan == tchan)
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
            
         achan = ((integer)("0x"+llGetSubString((string)target,-8,-1)) - 7863) | 0x8000000;
            
           if(roll_type == "attack")
           {  
            
            llRegionSay(achan, "HEALTH_CHECK");
            
            }
            
             else if(roll_type == "detect")
           { 
            gRoll = Modify("Detector",Roll(),detect_mod);
            
            detect_roll = gRoll;
            
            llOwnerSay("/me rolled a "+(string)gRoll);
             
           
            llRegionSay(achan, "DETECT_TARGET|" +(string)gRoll);
            
            }
            
            
             else if(roll_type == "strength")
           {  
            gRoll = Modify("Strength",Roll(),strength_mod);
            
            astrength_roll = gRoll;
            
            llOwnerSay("/me rolled a "+(string)gRoll);
             
             
            llRegionSay(achan, "STRENGTH_TARGET|" +(string)gRoll);
            
            }
            
            
           
            
            
            
           
        }
        
        
       } // if(chan == tchan)
       
       
       else if(chan == adminchan)
       {
         msg = llToLower(msg);
         
         if(msg == "reset_hud")
         {
            llLinksetDataReset(); 
            
           lswrite = Protect("lsrolls",(string)rolls);
            
             llOwnerSay("Resetting database. Please wait..."); 
            LM("reset_squares","");
            Web("Reset", "http_request_reset");   
             
         } 
         
         else if(msg == "get_health")
         { 
            
            llRegionSay(adminchan,"send_health|" + (string)health); 
             
         }
          
         else if(msg == "add_health_point")
         {
             
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about (Admin) restored one of your health points.");
             
              health += 1; 
            lswrite = Protect("lshealth",(string)health);
            LM("set_health","0");
           Titler();
            Write(1);
           
           
          if(health < 6)
          { 
          llMessageLinked(LINK_SET,health,"set_health_timer","");
          }
          
          else
          {
               llMessageLinked(LINK_SET,health,"pause_health_timer","");
            llOwnerSay("Healing stopped. You are currently at full health.");  
              
          }
             
             
             
         }
         
          else if(msg == "take_health_point")
         {
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about (Admin) took away one of your health points.");
              health -= 1; 
            lswrite = Protect("lshealth",(string)health);
            LM("set_health","1");
           Titler();
            Write(1);
            req = "update";
                  Web("UPDATE", "http_request_update"); 
           
          if(health < 6)
          { 
          llMessageLinked(LINK_SET,health,"set_health_timer","");

          RegionCheck();



          }
          
          else
          {
               llMessageLinked(LINK_SET,health,"pause_health_timer","");
            llOwnerSay("Healing stopped. You are currently at full health.");  
              
          }
             
             
             
         }
         
          else if(msg == "get_rolls")
         { 
            
            llRegionSay(adminchan,"send_rolls|" + (string)rolls); 
             
         }
         
         
          else if(msg == "add_reroll_point")
         {
             
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about (Admin) awarded you a reroll.");
             
              rolls = rolls + 1;
            
            lswrite = Protect("lsrolls",(string)rolls);
            
            req = "rolls_update";
             Web("Rolls_Update", "http_request_rolls");
             
             
             
         }
         
          else if(msg == "take_reroll_point")
         {
             llOwnerSay("secondlife:///app/agent/" +  (string)llGetOwnerKey(id) + "/about (Admin) took away one of your rerolls.");
              rolls = rolls - 1;
            
            lswrite = Protect("lsrolls",(string)rolls);
            
            req = "rolls_update";
             Web("Rolls_Update", "http_request_rolls");
             
             
             
         }
         
    
       } // else if(chan == adminchan)
       
       else if(chan == pagemenu)
       {
           
           if(msg == "Yes")
           {
               
              llOwnerSay("Paging nearby admins!");
              llRegionSay(pagechan,"Paging all admins!"); 
               
           }
           
       }
       
       else if(chan == finchan)
       {
           
          if(msg == "Yes")
          {
            finalize = TRUE;  
            lswrite = Protect("lsfinalize",(string)finalize);
            Write(1);
            llOwnerSay("Character finalized. You can now roll.");  
              
          } 
           
           
       }
       
       
       else if(chan == pause_chan)
       {
           
         if(msg == "Yes")
         {
             
              lswrite = Protect("lshudpaused",(string)FALSE);

    RegionCheck();
             
         }  
           
       }
        
    } // listen 
    
    
    changed(integer change)
    {
        
      if(change & CHANGED_LINK)
      {
          
        llResetScript();  
          
      }  
      
      else  if(change & CHANGED_OWNER)
      {
          
         
        llLinksetDataReset(); 
        llResetScript();  
          
      } 
      
      else if(change & (CHANGED_REGION | CHANGED_TELEPORT | CHANGED_REGION_START ))
      {
          
       RegionCheck();
          
      } 
        
    }
    
    timer()
    {
         
     llSetTimerEvent(0.0);
        llListenRemove(thandle); 
        llListenRemove(rhandle); 
        llListenRemove(modhandle);
        llListenRemove(rollhandle);
        llListenRemove(pagehandle);
        llListenRemove(finhandle);
        llListenRemove(pause_handle); 
        
        
        
    } 
    

    
    
}
