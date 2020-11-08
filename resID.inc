include		windows.inc 
include		kernel32.inc 
include		user32.inc 
include     gdi32.inc  
include 	shell32.inc
include		winmm.inc
include		masm32.inc
include		oleaut32.inc
include		ole32.inc
include		msvcrt.inc
include		comctl32.inc
include		comdlg32.inc
include 	\masm32\macros\macros.asm
include		Kolor.inc
include	TextScroller.inc
include MagicV2mEngine.inc

includelib	kernel32.lib
includelib	user32.lib 
includelib 	gdi32.lib
includelib 	shell32.lib
includelib	winmm.lib
includelib 	masm32.lib
includelib  oleaut32.lib
includelib  ole32.lib
includelib	msvcrt.lib
includelib	comctl32.lib
includelib	comdlg32.lib
includelib	Kolor.lib
includelib	TextScroller.lib
includelib  MagicV2mEngine.lib

DlgProc		PROTO	:DWORD,:DWORD,:DWORD,:DWORD
Generate	PROTO	:DWORD
AboutProc 			PROTO :DWORD,:DWORD,:DWORD,:DWORD
UpdateScroller			PROTO
CreateTVBox 			PROTO :DWORD
UpdateTVBox 			PROTO

.const
IDD_MAIN	equ	1000
IDD_ABOUTBOX	equ	2000
IDC_SNAME	equ	1002
IDC_ENAME	equ	1003
IDC_SCODE	equ	1004
IDC_ECODE	equ	1005
IDB_ABOUT	equ	1006
IDB_GENERATE	equ	1007
IDB_EXIT	equ	1008
IDC_STATIC2	equ	1010
ID_FONT		equ	1337

.data
include queen.inc
kgcolor			KOLOR	<00000000h, 00FFFFFFh, 00000000h, 00FFFFFFh, 00808080h, 00FFFFFFh>
WindowTitle	db	"Teleport Pro 1.62 KeyGen",0
DefaultName db	"r0ger^PRF",0
Text1		db	"Name :",0
Text2		db	"Code :",0
Text3		db	"flw on my ig @r0gerica",0
ScrollerText TCHAR ".:: Keygen for Teleport Pro 1.62 ::. -- keygenned by r0ger | gfx : r0ger | v2m cover : Quickyman | kolor GUI : profdracula                  ",
				"big gr33tz to all PRF memberz incl r0bica, Al0hA, ShTEFY, B@TRyNU, GRUiA, MaryNello, DaViD, pHane, bDM10, OviSpider & others ,",
				"and to all tuts4you memberz !                         (C) 2o2o  ,  PERYFERiAH tEAM .             ",0
lfFont  LOGFONT	<12,8,0,0,FW_NORMAL,0,0,0,DEFAULT_CHARSET,OUT_DEFAULT_PRECIS,CLIP_DEFAULT_PRECIS,\
									DEFAULT_QUALITY	,DEFAULT_PITCH or FF_DONTCARE,'Courier'>
nFont		dd	1

;kg data
Format		db	"%u",0
NoName		db	"No name entered.",0
TooShort	db	"Enter at least 4 chars pls.",0

;aboutbox data
wx	equ 400
wy	equ 200

AboutFont			LOGFONT <12, 8, 0, 0, FW_NORMAL, FALSE, FALSE, FALSE, DEFAULT_CHARSET, OUT_CHARACTER_PRECIS, 										CLIP_DEFAULT_PRECIS,PROOF_QUALITY,DEFAULT_PITCH,"Courier">

szAboutText 		db "  P E R Y F E R i A H  t E A M",13
					db "PRESENTS U ANOTHER FINE RELEASE :",0
					
					db "    tARGEt : Teleport Pro v1.62",13
					db "   CracKeR : r0ger",13
					db "pr0tecti0n : S/N",13
					db "  rls date : o 5 . 1 1 . 2 o 2 o",13
					db "  v2m name : queen - who wants to",13
					db "live forever (cover by Quickyman)",0
					
					db " gr33tz fly out to r0bica, Al0hA,",13
					db "  B@TRyNU, ShTEFY, DaViD, r0cky,",13
					db "    r1ckyTiTAN,sabYn,s0r3l, SiD",13
					db "   mYu,Gyahnni,MaryNello,GRUiA,",13
					db "  aMaliaVerSace,st3fan(C)ADR!AN,",13
					db "NoNNy,QueenAntonia,bDM10,OviSpider,",0

					db	" ",13
					db  " ",13
					db  " and other PrF memberz out there !",0

			db	" and gr33tz 2 all tuts4you memberz",13
			db  " including Teddy Rogers, Xylitol,",13
			db  "   kao, udg, Ufo-Pu55y, atom0s, ",13
			db  "  CodeExplorer,Loki,GioTiN^UST, ",13
			db  "     X-88 and other memberz ;) ",0

			db  " 10x go 2 :",13
			db  "   s3rh47 for the keygen tutorial",13
			db  "   Quickyman for this nice music",13
			db  "   profdracula for the KOLOR GUI",0
			
			db	"        GFX created by me",13
			db	"      aboutbox created by me",0

			db  "             contact : ",13
			db  " ",13
			db  "       youtube :  MC Roger ",13
			db  "       fezbuc  :  Darius Dan",13
			db  "     instagram :  @r0gerica",13
			db  "        @peryferiah.artpack",0

			db  "     deviantart : r0gerica",13
			db  "    furaffinity : r0gerica",13
			db  "        discord : r0gerica#2649",13
			db	"         github : r0gerica",0
			
			db  " ",13
			db  "'the lord of hosts is with us. ",13
			db  " the god of Jacob is our fortress.'",13
			db  " ",13
			db  "       P S A L M   4 6 : 7 ",0
			db 11

			
			
.data?
hInstance	dd	?
scr				SCROLLER_STRUCT <>
hFontRes				dd			?
ptrFont					dd			?

;kg variables
Serialbuff dd  50 dup(?)
buff1		 dd	 50 dup(?)
Finalserial	 db	 50 dup(?)

;aboutbox  variables
mColor	dd ?
ThreadID	dd ?
Counter	dd ?
MemLock	dd ?
MemFree	dd ?
mText	dd ?
Fade	dd ?
TxtLength	dd ?
