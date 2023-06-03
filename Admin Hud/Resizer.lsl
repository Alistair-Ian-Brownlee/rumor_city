// Linkset Resizer with Menu
// version 1.50 (2015-07-08)
// by: Brilliant Scientist and Sei Lisa
// © Copyright 2015 Sei Lisa
// --
// This script resizes all prims in a linkset, or a single prim.
// The process is controlled via a menu.
// The script works on arbitrary objects and requires no configuration.
// The script is based on "Linkset Resizer" script by Maestro Linden.
// http://wiki.secondlife.com/wiki/Linkset_resizer
// Special thanks to:
// Ann Otoole

float DialogTimeout = 180; // how many seconds before removing the listener

float max_scale;
float min_scale;

float   cur_scale = 1.0;
integer handle = 0;
integer menuChan;

list link_scales = [];
list link_positions = [];

makeMenu()
{
    if (!handle)
    {
        menuChan = 500000 + (integer)llFrand(500000);
        handle = llListen(menuChan, "", llGetOwner(), "");
    }
    llSetTimerEvent(DialogTimeout);

    //the button values can be changed i.e. you can set a value like "-1.00" or "+2.00"
    //and it will work without changing anything else in the script
    llDialog(llGetOwner(), "Max scale: " + (string)max_scale + "\nMin scale: " + (string)min_scale
        + "\n\nCurrent scale: "+ (string)cur_scale,
        ["-0.05", "-0.10", "-0.25", "+0.05", "+0.10", "+0.25", /*"MIN SIZE",*/ "RESTORE", /*"MAX SIZE",*/ "CLOSE", "DELETE..."],
        menuChan);
}

scanLinkset()
{
    integer link_qty = llGetNumberOfPrims();
    integer link_idx;
    integer link_ofs = (link_qty != 1); // add 1 if more than one prim (as linksets start numbering with 1)
    list params;

    for (link_idx = 0; link_idx < link_qty; ++link_idx)
    {
        params = llGetLinkPrimitiveParams(link_idx + link_ofs, [PRIM_POS_LOCAL, PRIM_SIZE]);

        link_positions += llList2Vector(params, 0);
        link_scales    += llList2Vector(params, 1);
    }

    max_scale = llGetMaxScaleFactor() * 0.999999;
    min_scale = llGetMinScaleFactor() * 0.000001;
}

resizeObject(float scale)
{
    integer link_qty = llGetNumberOfPrims();
    integer link_idx;
    integer link_ofs = (link_qty != 1);

    // scale the root
    llSetLinkPrimitiveParamsFast(link_ofs, [PRIM_SIZE, scale * llList2Vector(link_scales, 0)]);
    // scale all but the root
    for (link_idx = 1; link_idx < link_qty; link_idx++)
    {
        llSetLinkPrimitiveParamsFast(link_idx + link_ofs,
            [PRIM_SIZE,      scale * llList2Vector(link_scales, link_idx),
             PRIM_POS_LOCAL, scale * llList2Vector(link_positions, link_idx)]);
    }
}

default
{
    state_entry()
    {
        scanLinkset();
    }

    touch_start(integer total)
    {
        if (llDetectedKey(0) == llGetOwner())
            makeMenu();
    }

    timer()
    {
        llListenRemove(handle);
        handle = 0;
        llSetTimerEvent(0);
    }

    listen(integer channel, string name, key id, string msg)
    {
        if (msg == "RESTORE")
        {
            cur_scale = 1.0;
        }
        else if (msg == "MIN SIZE")
        {
            cur_scale = min_scale;
        }
        else if (msg == "MAX SIZE")
        {
            cur_scale = max_scale;
        }
        else if (msg == "DELETE...")
        {
            llDialog(llGetOwner(),"Are you sure you want to delete the resizer script?",
                ["DELETE","CANCEL"],menuChan);
            llSetTimerEvent(DialogTimeout);
            return;
        }
        else if (msg == "DELETE")
        {
            llOwnerSay("Deleting resizer script...");
            llRemoveInventory(llGetScriptName());
            return; // prevents the menu from showing - llRemoveInventory is not instant
        }
        else if (msg == "CANCEL")
        {
            // ignore but it will re-show the menu as it falls through
        }
        else if (msg == "CLOSE")
        {
            llListenRemove(handle);
            handle = 0;
            llSetTimerEvent(0);
            return; // prevents the menu from showing
        }
        else
        {
            cur_scale += (float)msg;
        }

        //check that the scale doesn't go beyond the bounds
        if (cur_scale > max_scale) { cur_scale = max_scale; }
        if (cur_scale < min_scale) { cur_scale = min_scale; }

        resizeObject(cur_scale);
        makeMenu();
    }
}
