# Outils

## `lancer-videoshow.bat`

Script Windows qui automatise le lancement complet de Videoshow :

1. Vérifie si le serveur tourne déjà sur le port 8123.
2. Sinon, va dans `%LOCALAPPDATA%\AuditionMorand` et cherche l'exécutable du serveur
   (essaye plusieurs noms probables, puis prend n'importe quel `.exe` non-Chrome).
3. Lance ce serveur.
4. Attend jusqu'à 15 secondes que le port réponde.
5. Ouvre la régie dans Chrome en mode app, comme le raccourci d'origine.

### Utilisation

Double-clic sur le fichier. Une fenêtre noire (console) s'ouvre quelques secondes,
puis Chrome lance la régie Videoshow.

### Si ça ne fonctionne pas

Le script écrit à l'écran ce qu'il fait. En cas d'échec il **ouvre automatiquement
l'Explorateur** sur `%LOCALAPPDATA%\AuditionMorand` pour que vous puissiez voir
ce qu'il contient. Faites une capture du dossier et envoyez-la, je vous dirai
quel fichier lancer.

### Démarrage automatique avec Windows

Pour ne plus jamais avoir à lancer Videoshow manuellement :

1. `Win + R` → `shell:startup` → Entrée.
2. Glisser un **raccourci** de `lancer-videoshow.bat` (clic droit → Créer un raccourci)
   dans le dossier qui s'ouvre.

À chaque démarrage de Windows, Videoshow sera lancé automatiquement.
