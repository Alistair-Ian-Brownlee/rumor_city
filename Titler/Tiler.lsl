key owner;
integer lchan;
integer lhandle;
string name;
string health;

vector WHITE = <1.0,1.0,1.0>;
vector RED = <1.0,0.0,0.0>;

Text(integer num)
{
 
  llSetText("\n"+ getName() +"\n \n"+(string)num+ " hitpoints", WHITE,1.0);   
    
}

string getName()
{
    
  string username  = llKey2Name(owner);
         integer found = llSubStringIndex(username, " Resident");
         if (found != -1)
         {
         integer i = llSubStringIndex(username, " Resident");
         username = llDeleteSubString(username, i, -1); 
         }
         
         
        return name = llGetDisplayName(owner)+"("+username+")";   
    
}

default
{
    
    attach(key id)
    {
        
      if(id)
      {
          
        llResetScript();  
          
      }  
        
        
    }
    
    on_rez(integer start_param)
    {
       
       llResetScript(); 
        
    }
    
    changed(integer change)
    {
        if (change & CHANGED_OWNER) llResetScript();
    }
    state_entry()
    {
         llSetText("", WHITE,1.0);  
       
        owner = llGetOwner();
        lchan = ((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 848537) | 0x8000000;
        llListen(lchan,"","","");
        
        
         
         llSay(((integer)("0x"+llGetSubString((string)owner,-8,-1)) - 7863) | 0x8000000, "get_health");
        
        
        
        
    }
    
    
    listen(integer chan, string name, key id, string msg)
    {
       
    
       
       if(chan == lchan)
       {
           
          list tmp = llParseString2List(msg,["|"],[""]); 
          
          string cmd = llList2String(tmp,0);
           string ref = llList2String(tmp,1);
           
           health = ref;
          if(cmd == "health_paused")
          {
              
              llSetText("\n"+ getName() +"\n \n"+health+ " hitpoints\nPaused", RED,1.0);  
          } 
          
          else if(cmd == "health_resumed")
          {
               llSetText("\n"+ getName() +"\n \n"+health+ " hitpoints", WHITE,1.0); 
              
          } 
          
          else{
              
              health = msg;
        Text((integer)msg);   }
           
        }
       
        
    }
}
