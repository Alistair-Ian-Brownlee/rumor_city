string pass = "Rum0r_c!ty1";   //  A password to protect data in database so no outside scripts cannot read or modify data. Password must be the same in all authorized scripts that read or write data


string pRead(string kv)
{
    
  return llLinksetDataReadProtected(kv,pass);
    
}

integer Protect(string kv, string val)
{
  
   return llLinksetDataWriteProtected(kv,val,pass);
    
}

integer lswrite;

Timer()
{
    
    llSetTimerEvent(0.0);
     llSetTimerEvent(10.0);
}

integer tnum;
integer tlimit;
integer health;
integer Hud_Paused = FALSE;
integer Region_Paused = FALSE;

Active(integer hp, integer timeleft)
{
  llOwnerSay("Healing active. Health is currently " + (string)hp + ". Next point in " + (string)timeleft + " minutes.");  
    
}

integer setLimit(integer num)
{
     if(num == 5)
           {
              
              return 1800; 
               
           }
           
            else if(num == 4)
           {
              
              return 3600; 
               
           }
           
            else
           {
              
              return 7200; 
               
           }
    
}

default
{
    
    on_rez(integer start_param)
    {
        
      llResetScript();  
        
    }
    
    state_entry()
    {
         integer at = llGetAttached();  
      
      if(at != 0) 
      {  
        
        Hud_Paused = (integer)pRead("lshudpaused");
        
      
        
        Region_Paused = (integer)pRead("lsregion");
        
        
        
        tlimit = (integer)pRead("lstlimit");
        tnum = (integer)pRead("lstnum");
        health = (integer)pRead("lshealth");  
        
        
        
        if(Hud_Paused == TRUE)
        {
            
            if(health < 6)
            {
           llMessageLinked(LINK_SET,0,"REQUEST_UNPAUSE",""); 
            }
            
        }
        
        else if(Hud_Paused == FALSE && Region_Paused == FALSE)
        {
           
           if(health < 6)
            { 
         // Active(num,(tlimit-tnum)/60);  
          Timer(); 
            }
            
        }
       
       
        }
     
      else
     {
       
      llSetTimerEvent(0.0);

   // llDie(); 
         
     }   
        
    }
    
    
    link_message(integer sender, integer num, string msg, key id)
    {
       
     
        
        msg = llToLower(msg);
        
        if(msg == "set_health_timer")
        {
          tnum = 0;  
            
          tlimit = setLimit(num);
          lswrite = Protect("lstlimit",(string)tlimit);
           
          if(Hud_Paused == FALSE && Region_Paused == FALSE)
          { 
         
           Active(num,(tlimit/60));
            Timer();
          }
            
        }
        
        else if(msg == "pause_health_timer")
        {
           
           llSetTimerEvent(0.0); 
          
           
          
            
        }
        
         else if(msg == "resume_health_timer")
        {
            
          Hud_Paused = FALSE;
          lswrite = Protect("lshudpaused",(string)Hud_Paused);
          Region_Paused = (integer)pRead("lsregion");
          
          tlimit = setLimit(num);
          lswrite = Protect("lstlimit",(string)tlimit);
          Active(num,(tlimit-tnum)/60);  
          Timer();
            
        }
        
        else if(msg == "reset_squares")
    {
        
      llResetScript();  
        
    }
       
    }

    timer()
    {
        
       
        
        tnum = tnum + 10;
        lswrite = Protect("lstnum",(string)tnum);
        
        if(tnum >= tlimit)
         {
         llSetTimerEvent(0.0);
         llMessageLinked(LINK_SET,0,"RESTORE_HEALTH","");
         }
       
    }
}
