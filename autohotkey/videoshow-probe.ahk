; =============================================================================
;  videoshow-probe.ahk
;  Petit utilitaire pour découvrir quels endpoints HTTP Videoshow expose.
;  Lance des requêtes GET sur plusieurs chemins candidats et affiche le résultat.
;
;  Usage : double-clic. Un rapport texte s'ouvre avec les codes de réponse.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

BASE_URL := "http://localhost:8123"

paths := [
    "/",
    "/api",
    "/api/animations",
    "/api/animation",
    "/api/trigger",
    "/api/play",
    "/animations",
    "/trigger",
    "/control",
    "/controle",
    "/cue",
    "/status",
    "/health",
    "/ws"
]

report := "Sondage de " BASE_URL "`n"
report .= "=================================================`n`n"

for path in paths
{
    url := BASE_URL path
    try
    {
        whr := ComObject("WinHttp.WinHttpRequest.5.1")
        whr.Open("GET", url, true)
        whr.Send()
        whr.WaitForResponse(2)
        report .= Format("{:-4} {}`n", whr.Status, url)
    }
    catch as err
    {
        report .= Format("ERR  {} ({})`n", url, err.Message)
    }
}

report .= "`n=================================================`n"
report .= "Codes : 200 = OK, 404 = inexistant, ERR = pas de serveur sur ce port.`n"
report .= "Notez les chemins qui répondent 200 et explorez-les avec DevTools.`n"

reportFile := A_ScriptDir "\videoshow-probe-result.txt"
FileDelete(reportFile)
FileAppend(report, reportFile)
Run("notepad.exe " Chr(34) reportFile Chr(34))
