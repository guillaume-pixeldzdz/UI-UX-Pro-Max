; =============================================================================
;  videoshow-hotkey.ahk
;
;  Quand vous appuyez sur ² depuis n'importe quelle application,
;  ce script renvoie la touche ² à la fenêtre Videoshow.
;  Videoshow réagit alors comme si vous étiez sur sa fenêtre.
;
;  Aucune URL ni API à découvrir : on imite simplement un appui de touche.
;
;  AutoHotkey v2 requis : https://www.autohotkey.com/  ("Download v2.0")
;
;  Usage :
;    1. Installer AutoHotkey v2 (gratuit, 5 Mo).
;    2. S'assurer que Videoshow est lancé (le raccourci ouvre la régie Chrome).
;    3. Double-cliquer sur ce .ahk : icône H verte dans la barre des tâches.
;    4. Depuis n'importe quelle app, appuyer sur ² -> Videoshow joue l'animation.
;    5. Pour stopper : clic droit sur l'icône H -> Exit.
;
;  Démarrage automatique avec Windows :
;    Win+R -> shell:startup -> glissez un raccourci du .ahk dans ce dossier.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ---------------------------------------------------------------------------
;  CONFIGURATION
; ---------------------------------------------------------------------------

; Identifiant de la fenêtre Videoshow (sera cherché dans le titre).
; Si ça ne marche pas, mettez juste "Videoshow" ou "localhost:8123".
WINDOW_TITLE := "Videoshow"

; true  : on active brièvement la fenêtre Videoshow puis on rend la main
;         (méthode la plus fiable avec Chrome, mais on voit un flash).
; false : on envoie la touche sans changer de fenêtre (silencieux mais
;         Chrome ne le reçoit pas toujours — à tester chez vous).
USE_FOCUS_METHOD := true

; Délai (ms) pendant lequel Videoshow doit avoir le focus pour recevoir
; la touche. 30-80 ms est un bon compromis.
FOCUS_DELAY_MS := 50

; Afficher une notification à chaque déclenchement (false pour ne pas être pollué).
SHOW_NOTIFICATIONS := true

; Fichier de log ("" pour désactiver).
LOG_FILE := A_ScriptDir "\videoshow-hotkey.log"

; ---------------------------------------------------------------------------
;  Démarrage
; ---------------------------------------------------------------------------
TrayTip "Videoshow Hotkey", "Actif. Appuyez sur ² pour déclencher.", 0x1
LogLine("Script démarré. Cible fenêtre : " WINDOW_TITLE)

; ---------------------------------------------------------------------------
;  Raccourci
;  SC029 = scan code de la touche en haut à gauche (² sur AZERTY).
;  Indépendant de la disposition clavier.
; ---------------------------------------------------------------------------
SC029::TriggerVideoshow()

TriggerVideoshow()
{
    global WINDOW_TITLE, USE_FOCUS_METHOD, FOCUS_DELAY_MS, SHOW_NOTIFICATIONS

    targetHwnd := WinExist(WINDOW_TITLE)
    if (!targetHwnd)
    {
        LogLine("ERREUR : aucune fenêtre '" WINDOW_TITLE "' trouvée. Videoshow est-il lancé ?")
        if (SHOW_NOTIFICATIONS)
            TrayTip "Videoshow", "Fenêtre Videoshow introuvable.", 0x10
        return
    }

    if (USE_FOCUS_METHOD)
    {
        ; On mémorise la fenêtre courante, on bascule sur Videoshow, on tape ²,
        ; on revient sur la fenêtre d'origine.
        previousHwnd := WinGetID("A")

        WinActivate("ahk_id " targetHwnd)
        if (!WinWaitActive("ahk_id " targetHwnd, , 0.5))
        {
            LogLine("ERREUR : impossible d'activer Videoshow.")
            if (SHOW_NOTIFICATIONS)
                TrayTip "Videoshow", "Impossible d'activer la fenêtre.", 0x10
            return
        }

        SendInput("{SC029}")
        Sleep(FOCUS_DELAY_MS)

        if (previousHwnd && previousHwnd != targetHwnd)
            WinActivate("ahk_id " previousHwnd)
    }
    else
    {
        ; Méthode sans changement de focus. Peut ne pas marcher avec Chrome.
        ControlSend("{SC029}", , "ahk_id " targetHwnd)
    }

    LogLine("Touche ² envoyée à Videoshow.")
    if (SHOW_NOTIFICATIONS)
        TrayTip "Videoshow", "Animation déclenchée.", 0x1
}

LogLine(text)
{
    global LOG_FILE
    if (LOG_FILE = "")
        return
    try FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " " text "`n", LOG_FILE
}
