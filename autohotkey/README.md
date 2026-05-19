# Hotkey global Videoshow (AutoHotkey)

Solution légère pour que la touche **²** déclenche une animation Videoshow
**depuis n'importe quelle application**, sans Unity ni rien d'autre.

## Installation (3 min)

1. **Installer AutoHotkey v2** : https://www.autohotkey.com/ → bouton *Download* → *Download v2.0*.
   Installer avec les options par défaut.

2. **Trouver l'URL exacte que Videoshow utilise pour déclencher une animation.**
   Deux méthodes :

   ### Méthode A : DevTools (recommandée)

   1. Lancer Videoshow normalement.
   2. Dans la fenêtre Chrome de la régie : `Ctrl+Shift+I` → onglet **Network**.
   3. Cliquer sur le bouton "déclencher animation" dans la régie.
   4. Une nouvelle ligne apparaît. Clic dessus :
      - Notez la **méthode** (GET/POST)
      - Notez l'**URL complète** (ex. `http://localhost:8123/api/trigger/intro`)
      - Onglet *Payload* : copiez le corps JSON s'il y en a un.

   Si Ctrl+Shift+I ne marche pas (Chrome en mode `--app`), relancez Chrome à la main :
   ```
   chrome.exe --app=http://localhost:8123/?mode=controle --remote-debugging-port=9222
   ```
   puis ouvrez `http://localhost:9222` dans un autre navigateur.

   ### Méthode B : sondage automatique

   Double-cliquez sur `videoshow-probe.ahk`. Il teste une dizaine de chemins
   courants et ouvre un rapport texte avec les codes de réponse. Les chemins
   qui répondent `200` méritent d'être inspectés ensuite avec DevTools.

3. **Adapter `videoshow-hotkey.ahk`** :
   - Ouvrir le fichier avec le Bloc-notes.
   - Modifier les 3 variables en haut :
     ```ahk
     ANIMATION_URL := "http://localhost:8123/api/trigger/intro"  ; <- votre URL
     METHOD := "POST"                                            ; <- GET ou POST
     JSON_BODY := ""                                             ; <- vide ou JSON
     ```
   - Enregistrer.

4. **Lancer le script** : double-clic sur `videoshow-hotkey.ahk`.
   Une icône **H** verte apparaît dans la barre des tâches.

5. **Tester** : depuis n'importe quelle application, appuyer sur **²**.
   - Une notification "Animation déclenchée" doit apparaître.
   - Videoshow doit jouer l'animation.

## Démarrer automatiquement avec Windows

1. `Win + R` → taper `shell:startup` → Entrée.
2. Glisser le **raccourci** (pas le fichier lui-même) de `videoshow-hotkey.ahk`
   dans ce dossier.

## Dépannage

Tout est loggé dans `videoshow-hotkey.log` (à côté du script).

| Symptôme | Cause probable |
|---|---|
| Notification "Erreur : ..." | Videoshow n'est pas lancé, ou mauvaise URL. |
| "Animation déclenchée HTTP 404" | URL invalide, vérifier dans DevTools. |
| "Animation déclenchée HTTP 200" mais Videoshow inerte | L'API attend un autre format (vérifier le payload dans DevTools). |
| Aucune notification, rien ne se passe | Le script n'est pas lancé (icône H absente de la barre des tâches), ou autre app intercepte la touche. |
| La touche ² fait apparaître `²` à l'écran au lieu de déclencher | Le script n'est pas chargé, ou il y a une erreur de syntaxe : clic droit sur l'icône H → *Open*, puis vérifier la console. |

## Ajouter d'autres raccourcis

Dans `videoshow-hotkey.ahk`, dupliquez le bloc `SC029::` :

```ahk
; ² -> intro
SC029::TriggerUrl("http://localhost:8123/api/trigger/intro")

; F1 -> applause
F1::TriggerUrl("http://localhost:8123/api/trigger/applause")

; F2 -> fin
F2::TriggerUrl("http://localhost:8123/api/trigger/fin")
```

(il faudra adapter légèrement la fonction pour qu'elle prenne l'URL en paramètre,
dites-le moi si vous voulez cette version).
