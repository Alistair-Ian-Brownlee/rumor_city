key owner;
integer reroll_chan;
integer reroll_handle;

string type;
key attacker;

string pass = "Rum0r_c!ty1"; //  A password to protect data in database so no outside scripts cannot read or modify data. Password must be the same in all authorized scripts that read or write data

Timer()
{ 
  
  llSetTimerEvent(0.0); 
  llSetTimerEvent(60.0);   
    
} 

string pRead(string kv)
{
    
  return llLinksetDataReadProtected(kv,pass); 
    
}

integer rolls;

ReRoll(key atker, integer at, integer ev) 
{ 
    type = pRead("lsroll_type");
    rolls = (integer)pRead("lsrolls"); 
   
    
    llListenRemove(reroll_chan);
    reroll_handle = llListen(reroll_chan,"","","");
    
   if(type == "attack")
   { 
    llDialog(owner,"\nsecondlife:///app/agent/" +  (string)atker + "/about+ is attacking you.\n\nsecondlife:///app/agent/" +  (string)atker + "/about"+ "rolled: " + (string)at+"\nYou rolled: " + (string)ev+"\n\nYou have "+(string)rolls+"\n\nWould you like to try re-roll for a better roll?",["Yes","No"],reroll_chan);
   }
   
   else if(type == "detect")
   { 
    llDialog(owner,"\nsecondlife:///app/agent/" +  (string)atker + "/about+ is detecting you.\n\nsecondlife:///app/agent/" +  (string)attacker + "/about"+ "rolled: " + (string)at+"\nYou rolled: " + (string)ev+"\n\nYou have "+(string)rolls+"\n\nWould you like to try re-roll for a better roll?",["Yes","No"],reroll_chan);
   }
   
    if(type == "strength")
   { 
    llDialog(owner,"\nsecondlife:///app/agent/" +  (string)atker + "/about+ is using strength against you.\n\nsecondlife:///app/agent/" +  (string)attacker + "/about"+ "rolled: " + (string)at+"\nYou rolled: " + (string)ev+"\n\nYou have "+(string)rolls+"\n\nWould you like to try re-roll for a better roll?",["Yes","No"],reroll_chan);
   }
    
   
    Timer();
    

    
    
}


LM(string msg, key id)
{
  
  llMessageLinked(LINK_SET,0,msg,id);  
    
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
     reroll_chan = ((integer)("0x"+llGetSubString((string)llGetKey(),-8,-1)) - 737655) | 0x8000000;;
        
    }


   link_message(integer sender, integer num, string msg, key id)
    {
      msg = llToLower(msg);  
      attacker = id;
      
      if(msg == "reroll_attack")
      {
          
        //   ReRoll(key attacker, integer at, integer ev, string type)  

         integer attack_roll = (integer)pRead("lsattack_roll");
          integer evade_roll = (integer)pRead("lsevade_roll");
         ReRoll(id, attack_roll, evade_roll); 
          
      }
      
      else if(msg == "reroll_detect")
      {
          
        //   ReRoll(key attacker, integer at, integer ev, string type)  

         integer detect_roll = (integer)pRead("lsdetect_roll");
          integer stealth_roll = (integer)pRead("lsstealth_roll");
         ReRoll(id, detect_roll, stealth_roll); 
          
      }
      
      else if(msg == "reroll_strength")
      {
          
        //   ReRoll(key attacker, integer at, integer ev, string type)  

         integer astrength_roll = (integer)pRead("lsdetect_roll");
          integer tstrength_roll = (integer)pRead("lststrength_roll");
         ReRoll(id, astrength_roll, tstrength_roll); 
          
      }
      
      
     
     }
     
     
     listen(integer chan, string name, key id, string msg)
     {
         
         if(chan == reroll_chan)
         {
             llSetTimerEvent(0.0);
             msg= llToLower(msg);
             if(msg == "yes")
             {
                 LM("reroll_accepted",attacker);
                 
             }
             
             else if(msg == "no")
             {
                 
                 LM("reroll_declined",attacker);
                 
             }
             
             
         }
         
         
     }
     
     
     timer()
    {
        llSetTimerEvent(0.0);
         llListenRemove(reroll_handle); 
     
    string type = pRead("lsroll_type");
    
   if(type == "attack")
   { 
      LM("attacked",attacker);
   }
   
   else if(type == "detect")
   { 
       LM("detected",attacker);
   }
   
    if(type == "strength")
   { 
      
       LM("strengthened",attacker);
      
   }
    
    
       
       
        
    }  // timer
}
