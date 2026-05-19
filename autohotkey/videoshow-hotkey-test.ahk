; =============================================================================
;  videoshow-hotkey-test.ahk
;
;  Mode TEST : ce script ne mappe pas ² globalement. À la place, il mappe
;  F1, F2, F3, F4, F5 à 5 façons différentes d'envoyer ² à Videoshow.
;  Lancez Videoshow, lancez ce script, puis depuis n'importe quelle autre
;  application appuyez sur F1, F2, ... F5.
;  Celle qui déclenche l'animation est la "bonne". Dites-moi laquelle, et
;  je l'écris dans le script principal.
;
;  AutoHotkey v2 requis.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

SetTitleMatchMode 2

WINDOW_PATTERNS := ["Audition Morand", "Vidéoshow", "Videoshow"]
FOCUS_DELAY_MS := 80
LOG_FILE := A_ScriptDir "\videoshow-hotkey-test.log"

TrayTip "Videoshow TEST", "F1..F5 = 5 méthodes différentes. Dites-moi laquelle marche.", 0x1
LogLine("===== TEST démarré =====")

F1::TryMethod(1, "SendInput {SC029}")
F2::TryMethod(2, "Send {SC029} (event mode)")
F3::TryMethod(3, "Send mot ²")
F4::TryMethod(4, "ControlSend (sans changer focus)")
F5::TryMethod(5, "PostMessage WM_KEYDOWN/KEYUP")

TryMethod(num, label)
{
    global WINDOW_PATTERNS, FOCUS_DELAY_MS

    LogLine("--- Méthode " num " : " label " ---")
    previousHwnd := WinGetID("A")
    targetHwnd := FindFirstVideoshow()

    if (!targetHwnd)
    {
        TrayTip "TEST", "Fenêtre Videoshow introuvable.", 0x10
        LogLine("Pas de fenêtre trouvée.")
        return
    }

    title := WinGetTitle("ahk_id " targetHwnd)
    LogLine("Cible : " title)

    switch num
    {
        case 1:
            WinActivate("ahk_id " targetHwnd)
            WinWaitActive("ahk_id " targetHwnd, , 0.4)
            SendInput("{SC029}")
            Sleep(FOCUS_DELAY_MS)

        case 2:
            WinActivate("ahk_id " targetHwnd)
            WinWaitActive("ahk_id " targetHwnd, , 0.4)
            previousMode := A_SendMode
            SendMode "Event"
            SetKeyDelay 30, 30
            Send("{SC029}")
            SendMode previousMode
            Sleep(FOCUS_DELAY_MS)

        case 3:
            WinActivate("ahk_id " targetHwnd)
            WinWaitActive("ahk_id " targetHwnd, , 0.4)
            SendText("²")
            Sleep(FOCUS_DELAY_MS)

        case 4:
            ; Sans changement de focus, vise le contrôle Chrome interne
            try
            {
                ControlSend("{SC029}", "Chrome_RenderWidgetHostHWND1", "ahk_id " targetHwnd)
            }
            catch
            {
                ControlSend("{SC029}", , "ahk_id " targetHwnd)
            }

        case 5:
            ; Envoi bas niveau via PostMessage : WM_KEYDOWN=0x100, WM_KEYUP=0x101
            ; lParam : scan code dans les bits 16-23, donc 0x29 << 16 = 0x290000
            ; VK utilisé : 0xC0 (VK_OEM_3) = touche `/~/² selon layout
            PostMessage(0x100, 0xC0, 0x00290001, , "ahk_id " targetHwnd)
            Sleep(20)
            PostMessage(0x101, 0xC0, 0xC0290001, , "ahk_id " targetHwnd)
    }

    if (previousHwnd && previousHwnd != targetHwnd)
        try WinActivate("ahk_id " previousHwnd)

    TrayTip "TEST", "Méthode " num " envoyée. Animation déclenchée ?", 0x1
    LogLine("Méthode " num " : envoyée à " title)
}

FindFirstVideoshow()
{
    global WINDOW_PATTERNS
    for pattern in WINDOW_PATTERNS
    {
        list := WinGetList(pattern)
        if (list.Length > 0)
            return list[1]
    }
    return 0
}

LogLine(text)
{
    global LOG_FILE
    try FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " " text "`n", LOG_FILE
}
