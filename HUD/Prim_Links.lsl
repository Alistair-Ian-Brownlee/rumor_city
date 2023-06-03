string pass = "Rum0r_c!ty1";   //  A password to protect data in database so no outside scripts cannot read or modify data. Password must be the same in all authorized scripts that read or write data

//_________________________________

// >>>>> squares on HUD<<<<<<<<<<

list hp_btns;
list roll_btns;
list ev_btns;
list st_btns;
list dt_btns;
list str_btns;
//_________________________________

//_________________________________

// >>>>> buttons on HUD<<<<<<<<<<

integer roll_btn; 
integer mod_btn;
integer page_btn;
integer pause_btn;
//_________________________________

vector WHITE = <1.0, 1.0, 1.0>;
vector RED = <1.0, 0.0, 0.0>;

key hfull = "445137f7-4c42-8401-01f8-2781b511a898"; //UUID of full health icon.
key hempty = "66bdda5a-a593-23b3-5026-7f867ce231df"; //UUID of empty health icon.

key owner;

SetSquares(list tmp,integer h, key txt1,key txt2, vector col,  integer dir) // dir is direction to suptract square, 1 will subtract the first square, 0 will subtract the last square
{ 

    

    h = h - 1;
    integer i;
    integer tlength = llGetListLength(tmp);
  
  
  if(dir = 1) 
  {
  
     for(i = 0; i < tlength; ++ i)
     {
         
       if(i <= h)
       {
              // [ PRIM_COLOR, integer face, vector color, float alpha ]
           llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]);
            
            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]);

             llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]); 
           
        }
        
        else if(i > h)  
        {
             llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);

            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);

           llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);
            
            
        } 
         
      
     }
     
   }
   
   else if(dir = 0)
   {
        for(i = tlength; i > -1; -- i)
     {
         
       if(i <= h)
       {
              // [ PRIM_COLOR, integer face, vector color, float alpha ]
           llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]);
           
            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]);

            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt1,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,1.0]);
           
        }
        
        else if(i > h)  
        {
             llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);

            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);

            llSetLinkPrimitiveParamsFast(llList2Integer(tmp,i),[PRIM_TEXTURE,ALL_SIDES,txt2,<1.0, 1.0, 0.0>, <0.0, 0.0, 0.0>, 0.0,PRIM_COLOR,ALL_SIDES,col,0.0]);
            
            
        } 
         
      
     }
       
       
       
    } 
    
    
}

SetAlpha(list tmp)
{
  
  integer a;
  integer tlength = llGetListLength(tmp);
  
  
  for(a = 0; a < tlength; ++ a)
  {
    
      llSetLinkAlpha(llList2Integer(tmp,a), 0.0, ALL_SIDES);
      
  }  
    
}

list Sort(list tmp)
{
    
    
  tmp = llListSort(tmp, 2, TRUE);
  
  tmp = llList2ListStrided(llDeleteSubList(tmp, 0, 0),0,-1,2);
    
   return tmp;
}


LM(string msg, key id)
{
  
  llMessageLinked(LINK_SET,0,msg,id);  
    
}


string pRead(string kv)
{
    
  return llLinksetDataReadProtected(kv,pass);
    
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
        integer total_prims = llGetNumberOfPrims()+1;
       integer p;
       
       
       hp_btns = [];
       roll_btns = [];
       ev_btns = [];
       st_btns = [];
       dt_btns = [];
       str_btns = [];
       
       
       for(p = 0; p < total_prims; ++p)
       {
          
          string lnk = llToLower(llGetLinkName(p)); 
          
          if(lnk == "roll_button")
          {
              roll_btn = p;
          }
          
          else if(lnk == "modifier_button")
          {
              mod_btn = p;
          }
          
          else if(lnk == "page_button")
          {
              page_btn = p;
          }
          
           else if(lnk == "pause_button")
          {
              pause_btn = p;
          }
          
          else if(lnk == "hp1"|lnk == "hp2"|lnk == "hp3"|lnk == "hp4"|lnk == "hp5"|lnk == "hp6"|lnk == "hp7"|lnk == "hp8"|lnk == "hp9")
          {
              
              hp_btns += [lnk,p]; 
          }
          
          
           else if(lnk == "atk1"|lnk == "atk2"|lnk == "atk3"|lnk == "atk4"|lnk == "atk5"|lnk == "atk6"|lnk == "atk7"|lnk == "atk8"|lnk == "atk9")
          {
              roll_btns += [lnk, p]; 
          }
          
           else if(lnk == "ev1"|lnk == "ev2"|lnk == "ev3"|lnk == "ev4"|lnk == "ev5"|lnk == "ev6"|lnk == "ev7"|lnk == "ev8"|lnk == "ev9")
          {
              ev_btns += [lnk, p]; 
          }
         
          
           else if(lnk == "st1"|lnk == "st2"|lnk == "st3"|lnk == "st4"|lnk == "st5"|lnk == "st6"|lnk == "st7"|lnk == "st8"|lnk == "st9")
          {
              st_btns += [lnk, p]; 
          }
          
            else if(lnk == "dt1"|lnk == "dt2"|lnk == "dt3"|lnk == "dt4"|lnk == "dt5"|lnk == "dt6"|lnk == "dt7"|lnk == "dt8"|lnk == "dt9")
          {
              dt_btns += [lnk, p]; 
          }  
          
           else if(lnk == "str1"|lnk == "str2"|lnk == "str3"|lnk == "str4"|lnk == "str5"|lnk == "str6"|lnk == "str7"|lnk == "str8"|lnk == "str9")
          {
              str_btns += [lnk, p]; 
          }      
           
       }
       
       hp_btns = Sort(hp_btns);
       roll_btns = Sort(roll_btns);
       ev_btns = Sort(ev_btns);
       st_btns = Sort(st_btns);
       dt_btns = Sort(dt_btns);
       str_btns = Sort(str_btns);
    
       
       SetAlpha( hp_btns); 
      
       SetAlpha(roll_btns);
       
       SetAlpha(ev_btns);
      
       SetAlpha(st_btns);
       
       SetAlpha(dt_btns);
       
       SetAlpha(str_btns);
       
       
       llSleep(2.0);
       
        //  SetSquare(list tmp,integer h, key txt1,key txt2, vector col, integer dir) 
     
     SetSquares(hp_btns,6, hfull,hempty, WHITE, 1);
    }

    touch_end(integer num)
    {
     integer at = llGetAttached();  
      
      if(at != 0) 
      {  
       key Toucher = llDetectedKey(0);
        
       if(Toucher == owner)
       {
           
       string race = pRead("lsrace");
      
      if(race == "")
      {
         LM("race_menu","");
      }
       
       
       else
       {    
           
        integer touched = llDetectedLinkNumber(0);
       
       if(touched == roll_btn)
       {
          
           LM("touch_roll","");
                 
           
       }  // if(touched == roll_btn)
       
       
       else if(touched == mod_btn)
       {
           
          LM("touch_mod",""); 
           
         
           
           
       }
       
       else if(touched == page_btn)
       {
          LM("touch_page","");
          
           
           
       }
       
        else if(touched == pause_btn)
       {
          LM("touch_pause",""); 
           
          
            
           
       }
       
       
       }// if race is not empty
       
       }  // toucher == owner
       
       }
     
      else
     {
       
       llOwnerSay("HUD not attached. Please attach to continue."); 

   // llDie(); 
         
     }  
       
    }
    
    
    linkset_data( integer action, string name, string value )
 {
    
   // llOwnerSay("linksetdata: "+(string)action + ", " + name + ", " + value); 
     
  }
  
  
  link_message(integer sender, integer num, string msg, key id)
 
 {
    msg = llToLower(msg); 
     
    if(msg == "set_squares")
    { 
    
    integer atk_mod = (integer)pRead("lsatk_mod");
     integer evade_mod = (integer)pRead("lsevade_mod");
      integer stealth_mod = (integer)pRead("lsstealth_mod");
       integer detect_mod = (integer)pRead("lsdetect_mod");
        integer strength_mod = (integer)pRead("lsstrength_mod");
        
   // SetSquares(list tmp,integer h, key txt1,key txt2, vector col,  integer dir)
   integer dir = (integer)((string)id);

 SetSquares(roll_btns,atk_mod, TEXTURE_BLANK, TEXTURE_BLANK, RED,  dir);
     SetSquares(ev_btns,evade_mod, TEXTURE_BLANK, TEXTURE_BLANK, RED,  dir); 
     SetSquares(st_btns,stealth_mod, TEXTURE_BLANK, TEXTURE_BLANK, RED,  dir);
     SetSquares(dt_btns,detect_mod, TEXTURE_BLANK, TEXTURE_BLANK, RED,  dir);
      SetSquares(str_btns,strength_mod, TEXTURE_BLANK, TEXTURE_BLANK, RED,  1);
    }
    
    else if(msg == "set_health")
    {
        integer health = (integer)pRead("lshealth");
        
  //     SetSquares(list tmp,integer h, key txt1,key txt2, vector col,  integer dir)
     
        
         SetSquares(hp_btns,health, hfull,hempty, WHITE, (integer)((string)id));
    }
    
    
     else if(msg == "race_were")
    {
  SetSquares(dt_btns,2,  TEXTURE_BLANK, TEXTURE_BLANK, RED,  1);
    }
    
     else if(msg == "neo_vampire")
    {
  SetSquares(st_btns,2,  TEXTURE_BLANK, TEXTURE_BLANK, RED,  1);
    }
    
    else if(msg == "reset_squares")
    {
        
      llResetScript();  
        
    }
     
  }
 
 
  
  
  
}
