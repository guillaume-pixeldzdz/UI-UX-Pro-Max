; =============================================================================
;  videoshow-hotkey.ahk  (version multi-écrans / multi-fenêtres)
;
;  Quand vous appuyez sur ² depuis n'importe quelle application,
;  ce script renvoie la touche ² à TOUTES les fenêtres Videoshow ouvertes
;  (régie + affichage). La régie réagit, l'affichage ignore.
;
;  AutoHotkey v2 requis : https://www.autohotkey.com/
;
;  Usage :
;    1. Videoshow doit être ouvert (régie + affichage).
;    2. Double-cliquer ce fichier : icône H verte dans la barre des tâches.
;    3. Depuis n'importe quelle app : ² -> Videoshow joue l'animation.
;    4. Pour arrêter : clic droit sur l'icône H -> Exit.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

SetTitleMatchMode 2  ; "contient" partout dans le titre, pas seulement au début

; ---------------------------------------------------------------------------
;  CONFIGURATION
; ---------------------------------------------------------------------------

; Liste de motifs cherchés dans le titre des fenêtres ouvertes.
; Le script envoie la touche à toute fenêtre dont le titre contient un de ces motifs.
; Ajoutez/retirez à votre convenance.
WINDOW_PATTERNS := [
    "Videoshow",
    "Audition Morand",
    "VRA",
    "localhost:8123"
]

; Délai (ms) pendant lequel chaque fenêtre garde le focus pour recevoir la touche.
; 50-100 ms = bon compromis. Monter à 150 si l'animation ne se déclenche pas.
FOCUS_DELAY_MS := 60

; Afficher une notification à chaque déclenchement (true/false).
SHOW_NOTIFICATIONS := true

; Fichier de log ("" pour désactiver).
LOG_FILE := A_ScriptDir "\videoshow-hotkey.log"

; ---------------------------------------------------------------------------
TrayTip "Videoshow Hotkey", "Actif. Appuyez sur ² depuis n'importe où.", 0x1
LogLine("===== Démarrage =====")

; SC029 = touche en haut à gauche du clavier (² sur AZERTY, ` sur QWERTY)
SC029::TriggerVideoshow()

TriggerVideoshow()
{
    global WINDOW_PATTERNS, FOCUS_DELAY_MS, SHOW_NOTIFICATIONS

    previousHwnd := WinGetID("A")
    foundHwnds := []

    ; Récupérer toutes les fenêtres dont le titre contient un des motifs
    for pattern in WINDOW_PATTERNS
    {
        for hwnd in WinGetList(pattern)
        {
            ; Éviter les doublons
            found := false
            for existing in foundHwnds
                if (existing = hwnd)
                    found := true
            if (!found)
                foundHwnds.Push(hwnd)
        }
    }

    if (foundHwnds.Length = 0)
    {
        LogLine("Aucune fenêtre Videoshow trouvée.")
        if (SHOW_NOTIFICATIONS)
            TrayTip "Videoshow", "Aucune fenêtre Videoshow ouverte.", 0x10
        return
    }

    ; Envoyer ² à chaque fenêtre trouvée
    for hwnd in foundHwnds
    {
        title := WinGetTitle("ahk_id " hwnd)
        try
        {
            WinActivate("ahk_id " hwnd)
            if (WinWaitActive("ahk_id " hwnd, , 0.3))
            {
                SendInput("{SC029}")
                Sleep(FOCUS_DELAY_MS)
                LogLine("Envoyé ² à : " title)
            }
            else
            {
                LogLine("Impossible d'activer : " title)
            }
        }
        catch as e
        {
            LogLine("Erreur sur '" title "' : " e.Message)
        }
    }

    ; Revenir sur la fenêtre d'origine
    if (previousHwnd)
    {
        try WinActivate("ahk_id " previousHwnd)
    }

    if (SHOW_NOTIFICATIONS)
        TrayTip "Videoshow", foundHwnds.Length " fenêtre(s) ciblée(s).", 0x1
}

LogLine(text)
{
    global LOG_FILE
    if (LOG_FILE = "")
        return
    try FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " " text "`n", LOG_FILE
}
