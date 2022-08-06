Received: by Poppy (0.13/Amiga) id AA000042; Thu, 29 Jan 98 18:38:56 GMT
Return-Path: <birdland@luva.lb.bawue.de>
Received: from punt-2.mail.demon.net by mailstore for girv@girvnet.demon.co.uk
          id 886041860:15:01190:0; Thu, 29 Jan 98 02:44:20 GMT
Received: from luva.lb.bawue.de ([193.197.11.185]) by punt-2.mail.demon.net
           id aa0526440; 29 Jan 98 2:43 GMT
Received: (from root@localhost)
	by luva.lb.bawue.de (8.8.5/8.8.5) with UUCP id DAA04024
	for girvnet.demon.co.uk!girv; Thu, 29 Jan 1998 03:31:27 +0100 (CET)
From: magicsn@birdland.es.bawue.de (Steffen Haeuser)
To: girv@girvnet.demon.co.uk
Reply-To: magicsn@birdland.es.bawue.de
Message-ID: <96000406335739651897@BIRDLAND.es.bawue.de>
References: <yam7332.297.18712656@post.demon.co.uk>
X-Mailer: fastnet2rfc V3.0 - MagicSN@Birdland.es.bawue.de
Organization: Birdland BBS, Dettingen/Teck, South Germany, +49-7021-862428
Content-Type: text/plain; charset=ISO-8859-1
Subject: Re: Amiga Quake!
Date: 29 Jan 1998 00:46:05


 girv@girvnet.demon.co.uk wrote :


gi> Hi Steffen,

Hi!

gi> Well, here is the first of many questions that I promised you :)
gi> Is there a RtgMaster equivalent of "ObtainBestPen" - something to

Sure.

gi> map an RGB triplet to a pen number on a colourmapped screen?

Well, you don't do ObtainBestPen, when you access a screen... you directly set 
the color using LoadRGBRtg... starting with rtgmaster V32, there is also a 
"Workbench Window Mode", which of course cannot simply modify the Colors, as 
they might still be needed the way they are :) Because of that, LoadRGBRtg 
does something ObtainBestPen-ish, when accessing a Workbench Window instead of 
a Screen... to use a Workbench Window you provide rtg_Workbench,LUT8 to the 
Tags of OpenRtgScreen... starting with V33 (released somewhen next week) there 
will be a new tag for the Screenmode-Requester smr_Workbench. When this Tag is 
present, the user can choose with the Screenmode-Requester, if he wants to use 
a Screen or Workbench Window... this will work like this then...

struct TagItem tags1[]=
{smr_MinWidth,320,
 smr_MaxWidth,640,
 smr_MinHeight,200,
 smr_MaxHeight,480,
 smr_ChunkySupport,LUT8,
 smr_PlanarSupport,-1,
 smr_Workbench,1,
 smr_Buffers,2,
 TAG_DONE,0
};

struct TagItem tags2[]=
{
 rtg_Workbench,0,
 rtg_Buffers,2,
 TAG_DONE,0
};

sr=RtgScreenModeReq(tags1);
if (sr->Flags&sq_WORKBENCH) tags2[0].ti_Data=LUT8;
else tags2[0].ti_Data=0;

screen=OpenRtgScreen(sr,tags2);
LoadRGBRtg(screen,colors);

// LoadRGBRtg *changes* the color for Screens, and does ObtainBestPen-ish
// things for WINDOWS. The format of colors looks exactly like the format
// of LoadRGB32... freeing the Pens again is automatically done by
// CloseRtgScreen, if needed...

It is possible that i mailed you the V33 archive already, but not sure about 
it... with V32 the smr_Workbench did not yet exist, and you had to control the 
tags2[0].ti_Data by using a parameter for your game, still... this is why i 
added functionality to the Screenmode-Requester in V33 (smr_Workbench, 
sq_WORKBENCH)

I hope this helps for now :)

BTW: Some days ago my Doom compiled the first time... only the 68k version, 
though, the PPC version has still a problem... but hopefully solved soon :)

Steffen

