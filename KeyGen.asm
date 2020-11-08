.386
.model	flat, stdcall
option	casemap :none

include	resID.inc

AllowSingleInstance MACRO lpTitle
        invoke FindWindow,NULL,lpTitle
        cmp eax, 0
        je @F
          push eax
          invoke ShowWindow,eax,SW_RESTORE
          pop eax
          invoke SetForegroundWindow,eax
          mov eax, 0
          ret
        @@:
      ENDM
      
.code
start:
	invoke	GetModuleHandle, NULL
	mov	hInstance, eax
	AllowSingleInstance addr WindowTitle
	invoke	DialogBoxParam, hInstance, IDD_MAIN, 0, offset DlgProc, 0
	invoke	ExitProcess, eax

DlgProc proc hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	
	.if	uMsg == WM_INITDIALOG
		invoke  InitProc, kgcolor
		invoke	LoadIcon,hInstance,200
		invoke	SendMessage, hWnd, WM_SETICON, 1, eax
		invoke  SetWindowText, hWnd, addr WindowTitle
		invoke  SetDlgItemText, hWnd, IDC_ENAME, addr DefaultName
		invoke  SetDlgItemText, hWnd, IDC_SNAME, addr Text1
		invoke  SetDlgItemText, hWnd, IDC_SCODE, addr Text2
		invoke  SetDlgItemText, hWnd, IDC_STATIC2, addr Text3
		invoke  MAGICV2MENGINE_DllMain,hInstance,DLL_PROCESS_ATTACH,0
		invoke 	V2mPlayStream, addr v2m_Data,TRUE
		m2m scr.scroll_hwnd,hWnd
		mov scr.scroll_text, offset ScrollerText
		mov scr.scroll_x,28
		mov scr.scroll_y,229
		mov scr.scroll_width,326
		mov scr.scroll_textcolor,00FFFFFFh
		invoke FindResource,NULL,ID_FONT,RT_RCDATA
		mov hFontRes,eax
		invoke LoadResource,NULL,eax
		.if eax
			invoke LockResource,eax
			mov ptrFont,eax
			invoke SizeofResource,NULL,hFontRes
			invoke AddFontMemResourceEx,ptrFont,eax,0,addr nFont
		.endif
		invoke CreateFontIndirect,addr lfFont
		mov scr.scroll_hFont,eax
		invoke CreateScroller,addr scr
		invoke Generate,hWnd
	.elseif uMsg == WM_PAINT
		invoke	PaintProc, hWnd, 1
	.elseif uMsg == WM_CTLCOLORSTATIC
		invoke	GetDlgCtrlID, lParam
		.if eax == IDC_ECODE
			invoke	StaticProc, hWnd, wParam, 1
		.elseif eax == IDC_SNAME||eax == IDC_SCODE||eax == IDC_STATIC2
			invoke	StaticProc, hWnd, wParam, 2
		.endif
    	ret
    .elseif uMsg == WM_CTLCOLOREDIT
    	invoke	EditProc, wParam
    	ret
    .elseif uMsg == WM_DRAWITEM
    	.if wParam == IDB_ABOUT||wParam == IDB_EXIT
    		invoke	DrawProc, hWnd, lParam, 0
    	.else
    		invoke	DrawProc, hWnd, lParam, 1
    	.endif
   	.elseif uMsg == WM_LBUTTONDOWN
		invoke	SendMessage, hWnd, WM_NCLBUTTONDOWN, 2, 0
	.elseif uMsg == WM_RBUTTONDOWN
		invoke  ShowWindow, hWnd, SW_MINIMIZE
	.elseif uMsg == WM_COMMAND
		mov	eax,wParam
		.if eax == IDB_GENERATE	
			invoke Generate,hWnd
		.elseif eax == IDB_ABOUT
			invoke GetModuleHandle,0
			invoke DialogBoxParam,eax,IDD_ABOUTBOX,hWnd,addr AboutProc,WM_INITDIALOG
		.elseif	eax == IDB_EXIT
			invoke	OutitProc
			invoke	SendMessage, hWnd, WM_CLOSE, 0, 0
		.endif
	.elseif	uMsg == WM_CLOSE
		invoke  V2mStop
  		invoke  MAGICV2MENGINE_DllMain,hInstance,DLL_PROCESS_DETACH,0
		invoke	OutitProc
		invoke	EndDialog, hWnd, 0
	.endif

	xor	eax,eax
	ret
DlgProc endp

Generate proc uses ebx edi esi, hWnd:DWORD

	invoke GetDlgItemText, hWnd, IDC_ENAME, ADDR Serialbuff, 30h
	mov buff1, eax
	cmp eax, 0
	je _NameNotEntered ;if the name isn't entered it will show the NoName message
	cmp eax, 3
	jbe _4CharzPls ;if the name is entered less than 4 chars it will show the TooShort message
	
		mov edi, offset Serialbuff
		MOV ESI, 05DFEE4A4h
		XOR EBX, EBX
	
	@pro_0042F893:
	
		TEST EDI, EDI
		JE @pro_0042F8A0
		invoke lstrlen, addr Serialbuff
		JMP @pro_0042F8A2
	
	@pro_0042F8A0:
	
		XOR EAX, EAX
	
	@pro_0042F8A2:
	
		ADD EAX, -4
		CMP EBX, EAX
		JNB @pro_0042F8B5
		XOR ESI, DWORD PTR DS:[EBX+EDI]
		TEST BL, 040h
		JE @pro_0042F8B2
		INC EBX
	
	@pro_0042F8B2:
	
		INC EBX
		JMP @pro_0042F893
	
	@pro_0042F8B5:
	
		MOV EAX, ESI
	
	invoke wsprintfA, addr Finalserial, addr Format, eax ;get the serial format 
	invoke SetDlgItemText, hWnd, IDC_ECODE, ADDR Finalserial ;show the gen'd serial
	
_ret:
	xor eax,eax
	ret
	
_NameNotEntered:
	invoke SetDlgItemText,hWnd,IDC_ECODE,addr NoName
	jmp _ret
	
_4CharzPls:
	invoke SetDlgItemText,hWnd,IDC_ECODE,addr TooShort
	jmp _ret
	
Generate endp

TopXY proc wDim:DWORD, sDim:DWORD

    shr sDim, 2      ; divide screen dimension by 2
    shr wDim, 2      ; divide window dimension by 2
    mov eax, sDim
    sub eax, wDim

    ret

TopXY endp

align 4
AboutProc proc uses ebx esi edi hWnd:DWORD,uMsg:DWORD,wParam:DWORD,lParam:DWORD
	local rect:RECT
	LOCAL x
	LOCAL y
	mov eax,uMsg
	.if eax==WM_INITDIALOG

		invoke GetParent,hWnd
		mov ecx,eax
		invoke GetWindowRect,ecx,addr rect
		
		invoke GetSystemMetrics, SM_CXSCREEN
		invoke TopXY, wx, eax
		mov x, eax
		
		invoke GetSystemMetrics, SM_CYSCREEN
		invoke TopXY, wy, eax
		mov y, eax
		
		invoke SetWindowPos, hWnd, 0, x, y, wx, wy, SWP_SHOWWINDOW
		xor esi,esi
		mov edi,20
		;invoke CreateRoundRectRgn,esi,esi,wx,wy,edi,edi
		;invoke SetWindowRgn,hWnd,eax,1
		RGB 0,0,0
		invoke CreateSolidBrush,eax
		mov mColor,eax
		invoke GlobalAlloc,GHND,19600
		mov MemFree,eax	
		invoke GlobalLock,eax
		mov MemLock,eax
		invoke SetTimer,hWnd,1,10,0
		xor eax,eax
		invoke CreateThread,0,0,offset UpdateScroller,0,0,eax
		mov ThreadID,eax
		invoke SetThreadPriority,eax,THREAD_PRIORITY_LOWEST

	.elseif eax == WM_TIMER
      		invoke  InvalidateRect, hWnd, 0, 0

	.elseif eax == WM_PAINT
		invoke CreateTVBox,hWnd

	.elseif eax == WM_RBUTTONDOWN
		invoke  SendMessage,hWnd,WM_CLOSE,0,0

	.elseif eax == WM_LBUTTONDOWN
		invoke PostMessage, hWnd,WM_NCLBUTTONDOWN, 2,lParam

	.elseif eax==WM_CLOSE
		invoke TerminateThread,ThreadID,0
		invoke GlobalUnlock,MemLock
		invoke GlobalFree,MemFree
		invoke EndDialog,hWnd,0

	.endif
	xor eax,eax

	ret 	                         
AboutProc endp


align 4
CreateTVBox proc hWnd:DWORD
	local ps:PAINTSTRUCT, rect:RECT, bm:BITMAP;
	local hdcx:DWORD, srcdc:DWORD, hbitmap:DWORD, mbitmap:DWORD;
	local hdc:DWORD, hfont:DWORD;

	invoke BeginPaint,hWnd,addr ps
	mov hdcx,eax
	invoke CreateCompatibleDC, hdcx
	mov srcdc, eax
	invoke CreateCompatibleBitmap,hdcx,wx,wy
	mov hbitmap,eax
	invoke  SelectObject,srcdc,hbitmap
	invoke SetRect,addr rect, 0,0, wx, wy
	invoke FillRect, srcdc, addr rect,mColor
	invoke CreateCompatibleDC, 0
	mov hdc,eax
	invoke  SelectObject,hdc, mbitmap
	invoke GetObject,mbitmap,sizeof BITMAP,addr bm
	invoke  SetBkMode, srcdc, TRANSPARENT
	invoke CreateFontIndirect,addr AboutFont
	mov hfont,eax
	invoke  SelectObject, srcdc,hfont

	invoke SetRect,addr rect, 70,57, wx, wy
	invoke  SetTextColor, srcdc, Fade
	invoke DrawText,srcdc,mText,TxtLength,addr rect,DT_TOP

	invoke BitBlt,srcdc,7,10,wx,wy,hdc,0,0,SRCCOPY

	invoke BitBlt,hdcx,0,0,wx,wy,srcdc,0,0,SRCCOPY

	invoke DeleteObject,hbitmap
	invoke DeleteObject,mbitmap
	invoke DeleteObject,hfont
	invoke DeleteDC,srcdc
	invoke DeleteDC,hdc
	invoke EndPaint,hWnd,addr ps

	ret
CreateTVBox endp

align 4
UpdateScroller proc
	local black:DWORD, white:DWORD, time:DWORD



	RGB 255,255,255
	mov white,eax

	RGB 0,0,0
	mov black,eax
	mov Fade,eax

	@@:

	mov esi,offset szAboutText           

	.while byte ptr [esi] != 11

	invoke lstrlen,esi
	mov TxtLength,eax

	mov mText,esi
	.while eax != white

	invoke Sleep,15
	push Fade
	push white
	call FadeIn_Out
	mov Fade,eax

	.endw

	.while eax != 150

	invoke Sleep,25
	; Small mod for fading text by Mr.ROSE
	; Remove the "invoke Sleep,20" above and And remove the ";"
	; 
	;invoke Sleep,3
	;push Fade
	;push Yellow		;white
	;call FadeIn_Out
	;mov Fade,eax
	
	inc time
	mov eax,time

	.endw

	mov time,0

	.while eax != black

	invoke Sleep,15
	push Fade
	push black
	call FadeIn_Out
	mov Fade,eax

	.endw

	add esi,TxtLength
	inc esi
	.endw

	jmp @B
	ret

UpdateScroller endp


align 4
FadeIn_Out proc uses ebx edi esi fade_in:DWORD,fade_out:DWORD

	mov esi,fade_in
	mov edi,fade_out
	mov eax,esi
	shr eax,16
	mov bl,al
	mov eax,edi
	shr eax,16
	call FadeIn_Out_Update
	shl ebx,8
	mov eax,esi
	shr eax,8
	mov bl,al
	mov eax,edi
	shr eax,8
	call FadeIn_Out_Update
	shl ebx,8
	mov eax,esi
	mov bl,al
	mov eax,edi
	call FadeIn_Out_Update
	shr ebx,8
	mov eax,ebx
	ret

FadeIn_Out endp

align 4
FadeIn_Out_Update proc

	.if al == bl
	mov bh,al
	jmp @F
	.endif

	mov cl,al
	mov dl,bl

	.if al > bl

	mov ah,al
	sub ah,bl

	.if ah >= 128
	sub cl,10
	.endif

	sub cl,5
	add dl,15

	.if al  > dl && cl  > dl
	mov bh,cl
	jmp @F
	.endif

	mov bh,bl
	jmp @F

	.endif

	mov ah,bl
	sub ah,al

	.if ah >= 128
	add cl,10
	.endif

	add cl,5
	sub dl,15

	.if al  <= dl && cl  <= dl
	mov bh,cl
	jmp @F
	.endif

	mov bh,bl

	@@:

	ret
FadeIn_Out_Update endp

end start