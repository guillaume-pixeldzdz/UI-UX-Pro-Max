; =============================================================================
;  videoshow-hotkey.ahk
;  Déclenche une animation Videoshow via la touche ² depuis n'importe quelle app.
;  AutoHotkey v2 requis : https://www.autohotkey.com/  (cliquer "Download")
;
;  Usage :
;    1. Installer AutoHotkey v2.
;    2. Double-cliquer sur ce fichier. Une icône H verte apparaît dans la barre
;       des tâches : le script est actif.
;    3. Appuyer sur ² (la touche en haut à gauche, au-dessus de Tab) depuis
;       n'importe quelle application -> Videoshow joue l'animation.
;    4. Pour stopper : clic droit sur l'icône H -> Exit.
;    5. Pour le lancer au démarrage de Windows : placer un raccourci de ce .ahk
;       dans  shell:startup  (à taper dans la barre Exécuter).
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
Persistent

; ---------------------------------------------------------------------------
;  CONFIGURATION — à adapter une fois que vous connaissez l'API de Videoshow
; ---------------------------------------------------------------------------

; URL appelée quand on appuie sur ². Trouvez-la avec Chrome DevTools (F12 -> Network)
; en cliquant sur le bouton "déclencher animation" dans la régie Videoshow.
ANIMATION_URL := "http://localhost:8123/api/trigger/intro"

; Méthode HTTP : "GET" ou "POST".
METHOD := "POST"

; Corps JSON envoyé en POST. Laisser "" si l'API n'attend rien.
; Exemples :   ""                       (corps vide)
;              '{"animation":"intro"}'  (JSON simple)
JSON_BODY := ""

; Afficher une notification système à chaque déclenchement (utile pour débugger,
; mettre à false en production pour ne pas être pollué).
SHOW_NOTIFICATIONS := true

; Fichier de log (mettre "" pour désactiver).
LOG_FILE := A_ScriptDir "\videoshow-hotkey.log"

; ---------------------------------------------------------------------------
;  Notification de démarrage
; ---------------------------------------------------------------------------
TrayTip "Videoshow Hotkey", "Actif. Appuyez sur ² pour déclencher.", 0x1
LogLine("Script démarré. Cible : " METHOD " " ANIMATION_URL)

; ---------------------------------------------------------------------------
;  Le raccourci
;  SC029 = scan code de la touche en haut à gauche du clavier (² sur AZERTY,
;  ` sur QWERTY). On utilise le scan code pour être indépendant de la
;  disposition clavier.
; ---------------------------------------------------------------------------
SC029::TriggerVideoshow()

TriggerVideoshow()
{
    global ANIMATION_URL, METHOD, JSON_BODY, SHOW_NOTIFICATIONS

    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open(METHOD, ANIMATION_URL, true)
        whr.SetRequestHeader("Content-Type", "application/json")
        whr.SetRequestHeader("Accept", "application/json")
        whr.Send(JSON_BODY)
        whr.WaitForResponse(3)  ; 3 secondes max

        status := whr.Status
        LogLine("Requête envoyée -> HTTP " status)

        if (SHOW_NOTIFICATIONS)
        {
            if (status >= 200 && status < 300)
                TrayTip "Videoshow", "Animation déclenchée (HTTP " status ")", 0x1
            else
                TrayTip "Videoshow", "Réponse inattendue : HTTP " status, 0x2
        }
    }
    catch as err
    {
        LogLine("ERREUR : " err.Message)
        if (SHOW_NOTIFICATIONS)
            TrayTip "Videoshow", "Erreur : " err.Message, 0x10
    }
}

; ---------------------------------------------------------------------------
;  Logging
; ---------------------------------------------------------------------------
LogLine(text)
{
    global LOG_FILE
    if (LOG_FILE = "")
        return
    try
    {
        FileAppend FormatTime(, "yyyy-MM-dd HH:mm:ss") " " text "`n", LOG_FILE
    }
}
