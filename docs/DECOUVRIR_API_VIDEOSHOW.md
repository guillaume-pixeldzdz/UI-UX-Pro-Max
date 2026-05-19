# Découvrir l'API de Videoshow

Le raccourci `Videoshow.lnk` lance Chrome en mode app sur `http://localhost:8123/?mode=controle`.
Ça veut dire qu'un **serveur HTTP local** tourne en arrière-plan et que le mode `controle`
est l'interface de régie. Notre but est de découvrir **quelles requêtes** cette régie envoie
quand vous cliquez sur "déclencher animation", pour pouvoir reproduire ces requêtes depuis Unity.

## Étape 1 — Repérer le processus

Sur la machine où Videoshow est installé, ouvrez PowerShell **en administrateur** et tapez :

```powershell
Get-NetTCPConnection -LocalPort 8123 | Select-Object OwningProcess
Get-Process -Id <PID_retourné>
```

Vous saurez alors quel exécutable héberge le serveur (probablement quelque chose dans
`C:\Users\guill\AppData\Local\AuditionMorand\Videoshow\`).

## Étape 2 — Lister les endpoints disponibles

Naviguez vers le dossier d'installation puis cherchez des fichiers indicatifs :

```powershell
cd "$env:LOCALAPPDATA\AuditionMorand\Videoshow"
dir
# repérez : server.js, app.exe, routes.json, public/, etc.
```

Si c'est une appli Node/Electron, les routes sont souvent dans un `server.js` ou un dossier
`routes/`. Ouvrez-les et notez les chemins (ex. `app.post('/api/trigger/:id', ...)`).

## Étape 3 — Espionner la régie via DevTools

C'est la méthode la plus fiable, qui ne demande pas le code source :

1. Lancez Videoshow normalement (via le raccourci).
2. Dans la fenêtre Chrome de la régie, appuyez sur **Ctrl+Shift+I** pour ouvrir les DevTools.
   - Si Ctrl+Shift+I est désactivé en mode `--app`, lancez Chrome manuellement avec :
     ```
     chrome.exe --app=http://localhost:8123/?mode=controle --remote-debugging-port=9222
     ```
     puis ouvrez `http://localhost:9222` dans un autre navigateur.
3. Allez dans l'onglet **Network**.
4. Cliquez sur le bouton "déclencher animation" dans la régie.
5. Repérez la nouvelle requête qui apparaît. Notez :
   - **Méthode** (GET / POST / WebSocket)
   - **URL** (ex. `http://localhost:8123/api/animation/intro`)
   - **Payload** (corps JSON si POST)

## Étape 4 — Sonder depuis Unity

Le script `VideoshowProbe.cs` essaie une dizaine de chemins courants et logge les codes
de réponse. Ajoutez-le sur un GameObject vide et lancez la scène : la console Unity
indiquera quels endpoints existent (code 200 ou 404).

## Étape 5 — Configurer `VideoshowClient`

Une fois la vraie URL connue, dans l'inspecteur Unity sur le `VideoshowClient` :

| Champ | Exemple si endpoint = `POST /api/animation/intro` |
|-------|---------------------------------------------------|
| `Base Url` | `http://localhost:8123` |
| `Animation Endpoint Template` | `/api/animation/{id}` |
| `Method` | `POST` |
| `Json Body Template` | `` (vide) ou `{"id":"{id}"}` selon l'API |

Puis appelez `client.TriggerAnimation("intro")` depuis vos scripts Unity.

## Cas particulier : la régie utilise des WebSockets

Si dans l'onglet Network vous voyez une connexion `ws://localhost:8123/...` et que cliquer
sur "déclencher" n'émet aucune requête HTTP, c'est que les commandes passent par WebSocket.
Dans ce cas le client HTTP fourni ici ne suffira pas — il faudra ajouter
`NativeWebSocket` (package Unity) et adapter le client. Dites-le moi et je l'ajoute.
