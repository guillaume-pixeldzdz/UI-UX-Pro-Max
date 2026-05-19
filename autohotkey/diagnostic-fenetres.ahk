; =============================================================================
;  diagnostic-fenetres.ahk
;
;  Liste toutes les fenêtres visibles avec leur titre, leur processus, et leur
;  classe. Ouvre le résultat dans le Bloc-notes.
;
;  Utilisation :
;    1. Avoir Videoshow ouvert (régie + affichage si vous avez deux écrans).
;    2. Double-cliquer sur ce fichier.
;    3. Le Bloc-notes s'ouvre avec la liste. Repérez les lignes qui correspondent
;       à Videoshow (probablement avec "chrome.exe" comme processus) et envoyez-
;       les-moi.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

output := "=== FENÊTRES OUVERTES (visibles uniquement) ===`n"
output .= "Date : " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n`n"
output .= "Format : [processus]  TITRE  (classe)`n"
output .= "------------------------------------------------------------`n"

list := []
for hwnd in WinGetList()
{
    try
    {
        title := WinGetTitle("ahk_id " hwnd)
        if (title = "")
            continue
        proc := WinGetProcessName("ahk_id " hwnd)
        cls := WinGetClass("ahk_id " hwnd)
        list.Push(Format("[{1}]  {2}  ({3})", proc, title, cls))
    }
}

; Tri pour mettre Chrome en premier, c'est plus pratique à repérer
chromeLines := []
otherLines := []
for line in list
{
    if InStr(line, "chrome.exe", false)
        chromeLines.Push(line)
    else
        otherLines.Push(line)
}

output .= "`n--- Fenêtres Chrome (les plus susceptibles d'être Videoshow) ---`n"
for line in chromeLines
    output .= line "`n"

output .= "`n--- Autres fenêtres ---`n"
for line in otherLines
    output .= line "`n"

reportFile := A_ScriptDir "\fenetres.txt"
try FileDelete(reportFile)
FileAppend(output, reportFile)
Run('notepad.exe "' reportFile '"')
ExitApp
