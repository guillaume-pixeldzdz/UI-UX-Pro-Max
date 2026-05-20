# Hotkey global Videoshow

Faire que la touche **²** déclenche l'animation Videoshow **depuis n'importe quelle
application**, sans rien modifier dans Videoshow.

## Principe

Vous avez confirmé que la touche ² marche déjà quand Videoshow a le focus.
Ce script :

1. Détecte que vous appuyez sur ² (peu importe l'application active).
2. Bascule très brièvement sur la fenêtre Videoshow.
3. Lui renvoie la touche ².
4. Revient sur votre application précédente.

Aucune URL ni API à découvrir : on imite un appui clavier.

## Installation (3 min)

1. **Installer AutoHotkey v2** : https://www.autohotkey.com/ → *Download v2.0*.
   (Gratuit, 5 Mo, options d'installation par défaut.)

2. **Récupérer le script** : téléchargez `videoshow-hotkey.ahk` depuis ce dépôt
   (branche `claude/enable-unity-animations-bIWFB`). Placez-le où vous voulez,
   par exemple sur le Bureau.

3. **S'assurer que Videoshow tourne.** Le script cherche une fenêtre dont le
   titre contient "Videoshow". Vérifiez le titre exact de la fenêtre Chrome
   de la régie ; si c'est différent (ex. "Audition Morand"), ouvrez le `.ahk`
   avec le Bloc-notes et changez la ligne :
   ```ahk
   WINDOW_TITLE := "Videoshow"
   ```

4. **Double-cliquer sur `videoshow-hotkey.ahk`.** Une icône **H** verte apparaît
   dans la barre des tâches. Le script est actif.

5. **Tester** : depuis n'importe quelle application, appuyez sur **²**.
   - Vous devriez voir un bref clignotement (Videoshow passe au premier plan
     1/20e de seconde) puis Videoshow joue l'animation.
   - Une notification "Animation déclenchée" apparaît.

## Démarrer automatiquement avec Windows

1. `Win + R` → taper `shell:startup` → Entrée.
2. Glissez un **raccourci** (clic droit → Créer un raccourci) du fichier
   `videoshow-hotkey.ahk` dans le dossier qui s'ouvre.

## Réglages dans le script

Tout est en haut de `videoshow-hotkey.ahk`, modifiable avec le Bloc-notes :

| Réglage | À quoi ça sert |
|---|---|
| `WINDOW_TITLE` | Bout du titre de la fenêtre Videoshow à cibler. |
| `USE_FOCUS_METHOD` | `true` (recommandé) : flash bref sur Videoshow.<br>`false` : tente d'envoyer la touche sans changer de fenêtre. Chrome ne l'accepte pas toujours, donc à utiliser seulement si la méthode `true` ne convient pas. |
| `FOCUS_DELAY_MS` | Temps pendant lequel Videoshow garde le focus. Si l'animation ne se déclenche pas, monter à `100` ou `150`. |
| `SHOW_NOTIFICATIONS` | `false` pour supprimer les bulles de notification. |

## Dépannage

Tout est loggé dans `videoshow-hotkey.log` (à côté du script).

| Symptôme | Cause / solution |
|---|---|
| "Fenêtre Videoshow introuvable" | Videoshow n'est pas lancé, ou son titre ne contient pas "Videoshow". Vérifiez le titre réel (en haut de la fenêtre) et adaptez `WINDOW_TITLE`. |
| Le focus flashe mais l'animation ne se déclenche pas | Le délai est trop court. Mettez `FOCUS_DELAY_MS := 150`. |
| Tape `²` dans mon document au lieu de déclencher | Le script n'est pas chargé. Vérifiez l'icône H dans la barre des tâches. |
| Ça marche mais le clignotement me dérange | Essayez `USE_FOCUS_METHOD := false`. Si Chrome ignore, il n'y a pas de solution silencieuse simple sans toucher au code de Videoshow. |

## Trouver le titre exact de la fenêtre Videoshow

AutoHotkey installe un outil : **Window Spy** (clic droit sur l'icône H d'un
script en cours → *Window Spy*). Survolez la fenêtre Videoshow avec la souris,
Window Spy affiche son titre exact et sa classe. Copiez le titre dans
`WINDOW_TITLE`.
