# Démarrage rapide — touche ² dans Unity → animation Videoshow

Marche à suivre la plus courte pour que ça fonctionne.

## 0. Préalable

- Videoshow tourne (le raccourci ouvre bien la régie, `http://localhost:8123` répond).
- Vous avez un projet Unity ouvert (n'importe lequel, Unity 2020 LTS ou +).

## 1. Trouver la vraie URL de Videoshow (5 min)

Sans cette info, le script Unity tape dans le vide.

1. Lancez Videoshow normalement via le raccourci.
2. Dans la fenêtre Chrome de la régie, **clic droit → Inspecter** (ou Ctrl+Shift+I).
   - Si ça ne marche pas en mode `--app`, fermez Videoshow et relancez Chrome à la main :
     ```
     chrome.exe --app=http://localhost:8123/?mode=controle --remote-debugging-port=9222
     ```
3. Onglet **Network** dans les DevTools.
4. Dans la régie, **cliquez sur le bouton qui déclenche l'animation** (ou appuyez sur ² si
   c'est ce qui marche déjà).
5. Une nouvelle ligne apparaît dans Network. Cliquez dessus et notez :
   - **Method** (GET ou POST)
   - **Request URL** (ex. `http://localhost:8123/api/trigger/intro`)
   - Onglet **Payload** ou **Request** : le corps JSON s'il y en a un.

**Si vous voyez `ws://` au lieu de `http://` :** Videoshow utilise des WebSockets,
prévenez-moi, le client HTTP ne suffira pas.

## 2. Importer les scripts dans votre projet Unity (1 min)

1. Téléchargez le dossier `Assets/Scripts/Videoshow/` depuis cette branche
   (`claude/enable-unity-animations-bIWFB`) ou faites un `git clone` du dépôt.
2. Dans Unity, glissez ce dossier `Videoshow/` dans `Assets/Scripts/` (créez `Scripts`
   s'il n'existe pas).
3. Attendez la compilation. La Console ne doit pas afficher d'erreur rouge.

## 3. Créer le GameObject pont (1 min)

1. Dans la Hierarchy : **clic droit → Create Empty**, renommez-le `VideoshowBridge`.
2. Sélectionnez-le, dans l'Inspector cliquez **Add Component → Videoshow Client**.
3. Configurez avec ce que vous avez trouvé à l'étape 1 :

   | Trouvé à l'étape 1 | À mettre dans `Videoshow Client` |
   |---|---|
   | `POST http://localhost:8123/api/trigger/intro` | Base Url : `http://localhost:8123`<br>Endpoint : `/api/trigger/{id}`<br>Method : `POST` |
   | `GET http://localhost:8123/anim?name=intro` | Base Url : `http://localhost:8123`<br>Endpoint : `/anim?name={id}`<br>Method : `GET` |
   | Body JSON : `{"name":"intro"}` | Json Body Template : `{"name":"{id}"}` |
   | Body JSON vide | Json Body Template : *(vide)* |

4. **Add Component → Videoshow Animation Trigger**.
   - `Animation Id` : l'ID utilisé par Videoshow (ex. `intro`)
   - `Trigger Key` : laissez `BackQuote` (= la touche ² sur AZERTY)

## 4. Tester (30 sec)

1. Lancez la scène (▶).
2. La fenêtre Game doit avoir le focus (clic dessus).
3. Appuyez sur **²**.
4. Dans la Console Unity vous devriez voir :
   ```
   [Videoshow] POST http://localhost:8123/api/trigger/intro → 200
   ```
5. Videoshow doit jouer l'animation.

### Si rien dans la Console

- La fenêtre Game n'a pas le focus → cliquez dans la Game view.
- La touche n'est pas reconnue : changez `Trigger Key` pour `Space` pour tester, puis si
  Space marche, le souci vient bien de la touche ². Essayez alors les codes virtuels
  via le composant `VideoshowGlobalHotkey` (voir plus bas).

### Si erreur HTTP dans la Console

- `Connection refused` → Videoshow n'est pas lancé, ou tourne sur un autre port.
- `404 Not Found` → l'endpoint configuré est faux, retournez à l'étape 1.
- `400 Bad Request` → l'API attend probablement un autre format de body.

## 5. Bonus : que ça marche même hors focus Unity

Remplacez `Videoshow Animation Trigger` par `Videoshow Global Hotkey` sur le même
GameObject. Ce composant écoute la touche au niveau du système Windows, donc ça
fonctionne même si vous êtes dans une autre app au moment d'appuyer sur ².

- `Virtual Key Code` : `222` (= 0xDE), c'est le code de la touche ² sur AZERTY.
- Si ça ne déclenche pas, essayez `192` (= 0xC0).
- Pensez à cocher **Player Settings → Run In Background**.

(Windows uniquement.)
