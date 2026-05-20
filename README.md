# UI-UX-Pro-Max — Hotkey Videoshow

Déclencher les animations de **Videoshow VRA — Audition Morand** (serveur local
`http://localhost:8123`) avec la touche **²** depuis n'importe quelle application.

## Deux approches

### 🔑 Approche recommandée : AutoHotkey (`autohotkey/`)

Un petit script qui tourne dans la barre des tâches, écoute la touche ² au
niveau Windows, et envoie une requête HTTP à Videoshow. Aucune dépendance à
Unity. **→ Voir `autohotkey/README.md`.**

### 🎮 Approche Unity (`Assets/`)

Scripts Unity pour déclencher la même chose depuis votre projet Unity, soit
quand Unity a le focus, soit globalement via un hotkey système.

## Contenu

```
Assets/Scripts/Videoshow/
├── VideoshowClient.cs            ← client HTTP générique (configurable dans l'inspecteur)
├── VideoshowAnimationTrigger.cs  ← touche clavier → animation (focus Unity requis)
├── VideoshowGlobalHotkey.cs      ← touche clavier GLOBALE (marche même hors focus Unity, Windows)
├── VideoshowProbe.cs             ← sonde une liste de chemins pour découvrir l'API
└── Demo/
    └── VideoshowDemo.cs          ← panneau OnGUI avec boutons de test

docs/
└── DECOUVRIR_API_VIDEOSHOW.md    ← procédure pour trouver les vrais endpoints
```

## Démarrage rapide

1. **Découvrir l'API de Videoshow** — suivez `docs/DECOUVRIR_API_VIDEOSHOW.md`.
   Tant que vous ne connaissez pas l'URL exacte qu'utilise la régie pour déclencher
   une animation, le client ne peut que deviner.

2. **Copier les scripts** dans votre projet Unity (n'importe quel projet Unity 2020+
   fait l'affaire) en glissant le dossier `Assets/Scripts/Videoshow/` dans la fenêtre
   Project.

3. **Créer un GameObject** `VideoshowBridge`, lui ajouter :
   - `VideoshowClient` — réglez `Base Url`, `Animation Endpoint Template`, `Method`,
     `Json Body Template` selon ce que vous avez trouvé à l'étape 1.
   - `VideoshowAnimationTrigger` — choisissez un `Animation Id` et une `Trigger Key`.

4. **Lancer la scène**. Appuyer sur la touche déclenche l'animation côté Videoshow.

## Déclencher depuis votre propre code

```csharp
using AuditionMorand.Videoshow;

public class MonScript : MonoBehaviour
{
    public VideoshowClient videoshow;

    public void OnPersonnageEntreEnScene()
    {
        videoshow.TriggerAnimation("entree-personnage");
    }
}
```

## Touche globale (² même hors focus Unity)

`VideoshowAnimationTrigger` utilise `Input.GetKeyDown` : ça ne fonctionne **que** quand
la fenêtre Unity a le focus. Si vous voulez que la touche `²` déclenche l'animation
même quand vous êtes dans une autre application :

1. Sur le `GameObject` `VideoshowBridge`, **retirez** `VideoshowAnimationTrigger` et
   **ajoutez** `VideoshowGlobalHotkey`.
2. `Virtual Key Code` : laissez `0xDE` (= 222). C'est le code de la touche `²` sur
   AZERTY français standard. Si ça ne marche pas, essayez `0xC0` (192).
3. `Animation Id` : l'ID à déclencher.
4. Dans **Edit → Project Settings → Player → Resolution and Presentation**,
   cochez **Run In Background**. (Le script le force aussi par code, mais autant
   l'activer aussi dans les settings pour le build.)

Le composant lance un thread léger qui surveille la touche via l'API Windows
`GetAsyncKeyState`. Windows uniquement (le hotkey global est désactivé sur Mac/Linux).

## Prérequis Unity

- Aucun package externe : on utilise `UnityEngine.Networking.UnityWebRequest`, fourni en standard.
- Si votre build cible WebGL et que Videoshow tourne sur une autre machine, pensez à CORS.

## Et si Videoshow ne parle pas HTTP mais WebSocket ?

C'est probable pour ce type d'appli "régie temps réel". Si la procédure de découverte
révèle une connexion `ws://localhost:8123/…`, dites-le et j'ajouterai un client
WebSocket (basé sur `NativeWebSocket`).
