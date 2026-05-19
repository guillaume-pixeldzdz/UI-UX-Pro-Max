; =============================================================================
;  videoshow-hotkey.ahk
;
;  Quand vous appuyez sur ² depuis n'importe quelle application, ce script
;  trouve la fenêtre "Vidéoshow — Audition Morand" et lui renvoie la touche ².
;
;  AutoHotkey v2 requis : https://www.autohotkey.com/
;
;  Usage :
;    1. Videoshow doit être ouvert.
;    2. Double-cliquer ce fichier : icône H verte dans la barre des tâches.
;    3. Depuis n'importe quelle app : ² -> Videoshow joue l'animation.
;    4. Pour vérifier que le script fait son travail, regardez les
;       notifications (bulle en bas à droite) ET le log à côté du script.
;    5. Pour arrêter : clic droit sur l'icône H -> Exit.
;
;  Si ça ne marche pas, appuyez sur F12 : ça force un déclenchement en mode
;  "debug" très verbeux. Ouvrez ensuite le fichier videoshow-hotkey.log
;  pour voir ce qui s'est réellement passé.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

SetTitleMatchMode 2  ; "contient" partout dans le titre

; ---------------------------------------------------------------------------
;  CONFIGURATION
; ---------------------------------------------------------------------------

; Motifs cherchés dans le titre. Toute fenêtre dont le titre contient un de
; ces motifs sera ciblée. La diagnostic a confirmé "Audition Morand".
WINDOW_PATTERNS := [
    "Audition Morand",
    "Vidéoshow",
    "Videoshow",
    "VRA",
    "localhost:8123"
]

; Délai (ms) entre activation de la fenêtre et envoi de la touche.
FOCUS_DELAY_MS := 80

; Notifications dans la barre des tâches.
SHOW_NOTIFICATIONS := true

; Log détaillé (utile en cas de problème).
LOG_FILE := A_ScriptDir "\videoshow-hotkey.log"

; ---------------------------------------------------------------------------
TrayTip "Videoshow Hotkey", "Actif. Appuyez sur ² depuis n'importe où.`n(F12 = mode debug)", 0x1
LogLine("===== Démarrage =====")

; ² (scan code 0x29) en hotkey global
SC029::TriggerVideoshow(false)

; F12 en hotkey debug pour tester sans la touche ²
F12::TriggerVideoshow(true)

TriggerVideoshow(debug)
{
    global WINDOW_PATTERNS, FOCUS_DELAY_MS, SHOW_NOTIFICATIONS

    LogLine(debug ? "--- F12 (debug) ---" : "--- ² pressé ---")

    previousHwnd := WinGetID("A")
    LogLine("Fenêtre active avant : " (previousHwnd ? WinGetTitle("ahk_id " previousHwnd) : "(aucune)"))

    foundHwnds := FindVideoshowWindows()
    LogLine("Fenêtres trouvées : " foundHwnds.Length)

    if (foundHwnds.Length = 0)
    {
        LogLine("AUCUNE fenêtre Videoshow détectée. Patterns testés : " JoinArr(WINDOW_PATTERNS))
        if (SHOW_NOTIFICATIONS)
            TrayTip "Videoshow", "Aucune fenêtre Videoshow trouvée.`n(Le titre a-t-il changé ?)", 0x10
        return
    }

    sent := 0
    for hwnd in foundHwnds
    {
        title := WinGetTitle("ahk_id " hwnd)
        LogLine("  -> Cible : " title)
        try
        {
            WinActivate("ahk_id " hwnd)
            if (WinWaitActive("ahk_id " hwnd, , 0.4))
            {
                SendInput("{SC029}")
                Sleep(FOCUS_DELAY_MS)
                if (debug)
                {
                    ; En debug on envoie aussi le caractère brut, au cas où
                    ; Chrome filtre les keydown synthétiques.
                    SendText("²")
                    Sleep(FOCUS_DELAY_MS)
                }
                sent++
                LogLine("     Touche envoyée OK")
            }
            else
            {
                LogLine("     ÉCHEC : WinActivate n'a pas pris.")
            }
        }
        catch as e
        {
            LogLine("     ERREUR : " e.Message)
        }
    }

    ; Revenir sur la fenêtre d'origine
    if (previousHwnd)
    {
        try WinActivate("ahk_id " previousHwnd)
    }

    if (SHOW_NOTIFICATIONS)
    {
        if (sent > 0)
            TrayTip "Videoshow", sent " fenêtre(s) ciblée(s).", 0x1
        else
            TrayTip "Videoshow", "Trouvée mais impossible d'activer.", 0x10
    }
}

FindVideoshowWindows()
{
    global WINDOW_PATTERNS
    result := []
    seen := Map()
    for pattern in WINDOW_PATTERNS
    {
        for hwnd in WinGetList(pattern)
        {
            if (!seen.Has(hwnd))
            {
                seen[hwnd] := true
                result.Push(hwnd)
            }
        }
    }
    return result
}

JoinArr(arr)
{
    s := ""
    for v in arr
        s .= (s = "" ? "" : ", ") v
    return s
}

LogLine(text)
{
    global LOG_FILE
    if (LOG_FILE = "")
        return
    try FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " " text "`n", LOG_FILE
}
