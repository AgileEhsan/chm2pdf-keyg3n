    format pe gui 6.0
    include 'win32ax.inc'
    entry initialize

;
;   +-----------------------------------------------------------------+
;   |                          AUTHOR                                 |
;   +-----------------------------------------------------------------+
;
;            _______            ____  ________          ________  ____ 
;    ___  ___\   _  \  _______ /_   |/   __   \___  ___/   __   \/_   |
;    \  \/  //  /_\  \ \_  __ \ |   |\____    /\  \/  /\____    / |   |
;     >    < \  \_/   \ |  | \/ |   |   /    /  >    <    /    /  |   |
;    /__/\_ \ \_____  / |__|    |___|  /____/  /__/\_ \  /____/   |___|
;          \/       \/                               \/                
;
;   +-----------------------------------------------------------------+
;   |                   KeyG3n for CHM2PDF                            |
;   +-----------------------------------------------------------------+
;   |               [*]  Writtem in pure x86 Assembly                 |
;   |               [*]  MSVCRT *NOT* Needed                          |
;   +-----------------------------------------------------------------+
;

macro init_dll dll_id, dll_name, [func_name]
{
    common
        label dll_id
        .size = 0
        .dll db dll_name, 0
        label .functions
    forward
        .size = .size + 1
    forward
        dd func_name, fn#func_name
    forward
        label func_name dword
        .str db `func_name, 0
    forward
        label fn#func_name dword
        dd  0
}

macro make_string_table [string]
{
    common
        .size = 0
    forward
        .size = .size + 1
    forward
        local name
        dd name
    forward
        name TCHAR string, 0
}

macro load_dll [dll_id]
{
    forward
    push ebx
    push esi
    push edx
    local ..next, ..load_loop
..next:
    mov eax, esp
    invoke fnLoadLibraryEx, dll_id#.dll, 0, 0
    mov esi, eax
    xor ebx, ebx
..load_loop:
    invoke fnGetProcAddress, esi, dword [dll_id#.functions+ebx*8]
    mov edx, [dll_id#.functions+ebx*8+4]
    mov [edx], eax
    inc ebx
    cmp ebx, dll_id#.size
    jl ..load_loop
    pop edx
    pop esi
    pop ebx
}

section '.data' data readable writeable

    fnGetProcAddress    dd  0
    fnLoadLibraryEx     dd  0
    handlers dd on_copy_click, on_generate_license_click, on_about_click
    index dd 0
    hInstance dd ?
    aboutDialog MSGBOXPARAMS aboutDialog.size, 0, 0, szAboutText, szAboutTitle, MB_USERICON, 1, 0, 0, 0
    aboutDialog.size = $-aboutDialog

    szAboutTitle db 'About', 0
    szAboutText db '  KeyG3n for CHM2PDF', 10, 10, '  [ ~ x0r19x91 ~ ]', 0
    init_dll user32, 'user32.dll',\
        DialogBoxParamA, LoadIconA, SendMessageA, SendDlgItemMessageA, OpenClipboard, CloseClipboard,\
        EmptyClipboard, SetClipboardData, MessageBoxIndirectA, PostMessageA

    init_dll kernel32, 'kernel32.dll',\
        GlobalAlloc, GlobalLock, GlobalUnlock, ExitProcess

section '.rsrc' data readable resource from 'main.res'

section '.code' code readable executable

    license_keys:
        make_string_table '03562-000002329-222486877', '04010-000082155-217197507',\
            '04460-000062030-211920276', '05360-000021928-201402162', '05811-000001952-196161247',\
            '06261-000082026-190932404', '06711-000062149-185715616', '07160-000042323-180510867',\
            '07608-000022548-175318141', '08055-000002823-170137420', '08500-000083149-164968687',\
            '08943-000063526-159811927', '09384-000043954-154667122', '09823-000024433-149534256',\
            '00693-000085547-139304274', '01122-000066182-134207125', '01549-000046868-129121847',\
            '01971-000027607-124048425', '02390-000008398-118986842', '02804-000089241-113937081',\
            '01013-000099990-607485025', '03213-000070137-108899125', '04410-000013142-093855923',\
            '04798-000094250-088865022', '05180-000075411-083885843', '05924-000037894-073962585',\
            '06286-000019216-069018471', '06641-000000591-064086013', '06988-000082021-059165194',\
            '07328-000063504-054255996', '07660-000045042-049358403', '07984-000026634-044472399',\
            '08300-000008280-039597967'

    GET_PROC_ADDRESS    =   0x8f900864
    LOAD_LIBRARY        =   0x00635164
    KERNEL32_HASH       =   0x29A1244C

jenkins_hash:
    push ebx
    xor eax, eax
@@:
    movzx ebx, byte [esi]
    or bl, bl
    jz @f
    add eax, ebx
    mov ebx, eax
    shl ebx, 10
    add eax, ebx
    mov ebx, eax
    shr ebx, 6
    xor eax, ebx
    inc esi
    jmp @b
@@:
    mov ebx, eax
    shl ebx, 3
    add eax, ebx
    mov ebx, eax
    shr ebx, 11
    xor eax, ebx
    mov ebx, eax
    shl ebx, 15
    add eax, ebx
    pop ebx
    ret

hash:
    push ebx
    xor eax, eax
    sub esi, 2
@@:
    inc esi
    inc esi
    movzx ebx, word [esi]
    or ebx, ebx
    jz .ret
    ror eax, 9
    xor eax, ebx
    cmp ebx, 0x61
    jl @b
    cmp ebx, 0x7b
    jge @b
    xor eax, ebx
    sub ebx, 0x20
    xor eax, ebx
    jmp @b
.ret:
    pop ebx
    ret

initialize:
    mov eax, [fs:0x30]
    mov eax, [eax+12]
    mov ebx, [eax+0x1c]

.find:
    mov esi, [ebx+0x20]
    call hash
    cmp eax, KERNEL32_HASH
    jz .found
    mov ebx, [ebx]
    jmp .find

.found:
    mov ebx, [ebx+8]
    mov eax, [ebx+0x3c]
    mov eax, [eax+ebx+24+96]
    add eax, ebx
    push eax
    mov ecx, [eax+24]
    mov ebp, [eax+32]   ; name table
    mov edx, [eax+36]   ; ordinal table
    add edx, ebx
    add ebp, ebx
    xor edi, edi

.search_loop:
    mov esi, [ebp]
    add esi, ebx
    call jenkins_hash
    cmp eax, LOAD_LIBRARY
    jnz .is_proc_addr
    inc edi
    movzx eax, word [edx]
    mov [fnLoadLibraryEx], eax
    jmp .next_func

.is_proc_addr:
    cmp eax, GET_PROC_ADDRESS
    jnz .next_func
    inc edi
    movzx eax, word [edx]
    mov [fnGetProcAddress], eax

.next_func:
    add edx, 2
    add ebp, 4
    cmp edi, 2
    jz @f
    dec ecx
    jnz .search_loop

@@:
    pop edi
    mov edx, [edi+28]
    add edx, ebx
    mov eax, [fnLoadLibraryEx]
    mov ecx, [edx+eax*4]
    add ecx, ebx
    mov [fnLoadLibraryEx], ecx
    mov eax, [fnGetProcAddress]
    mov ecx, [edx+eax*4]
    add ecx, ebx
    mov [fnGetProcAddress], ecx
    jmp main

on_initdialog:
    invoke fnLoadIconA, [hInstance], 1
    invoke fnSendMessageA, ebp, WM_SETICON, 0, eax
    jmp handled_message

on_copy_click:
    invoke fnSendDlgItemMessageA, ebp, 1, WM_GETTEXTLENGTH, 0, 0
    test eax, eax
    jz handled_message
    invoke fnOpenClipboard, ebp
    test eax, eax
    jz handled_message
    invoke fnEmptyClipboard
    invoke fnGlobalAlloc, GHND, 32
    mov esi, eax
    invoke fnGlobalLock, eax
    push eax
    invoke fnSendDlgItemMessageA, ebp, 1, WM_GETTEXT, 32, eax
    invoke fnGlobalUnlock
    invoke fnSetClipboardData, CF_TEXT, esi
    invoke fnCloseClipboard
    jmp handled_message

on_generate_license_click:
    mov eax, [index]
    invoke fnSendDlgItemMessageA, ebp, 1, WM_SETTEXT, 0, dword [eax*4+license_keys]
    mov eax, [index]
    inc eax
    xor edx, edx
    mov ecx, license_keys.size
    div ecx
    mov [index], edx
    jmp handled_message

on_about_click:
    mov [aboutDialog.hwndOwner], ebp
    mov eax, [hInstance]
    mov [aboutDialog.hInstance], eax
    invoke fnMessageBoxIndirectA, aboutDialog
    jmp handled_message

dialog_proc:
    mov eax, [esp+8]
    mov ebp, [esp+4]
    cmp eax, WM_CLOSE
    jz close_window
    sub eax, 0x110
    jz on_initdialog
    dec eax
    jz on_command

leave_message:
    xor eax, eax
    ret

on_command:
    mov eax, [esp+12]
    sub eax, 2
    cmp eax, 2
    ja leave_message
    jmp [handlers+eax*4]

close_window:
    invoke fnPostMessageA, ebp, WM_QUIT, 0, 0

handled_message:
    mov eax, 1
    ret

main:
    load_dll kernel32, user32
    mov eax, [fs:0x30]
    mov eax, [eax+8]
    mov [hInstance], eax
    invoke fnDialogBoxParamA, eax, 1, NULL, dialog_proc, NULL
    invoke fnExitProcess, 0