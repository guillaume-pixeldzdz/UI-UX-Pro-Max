# UI-UX-Pro-Max — Pont Unity ⇄ Videoshow

Scripts Unity pour déclencher les animations de l'application **Videoshow VRA — Audition Morand**
(qui tourne localement à `http://localhost:8123`) depuis un projet Unity, via des requêtes HTTP.

## Contenu

```
Assets/Scripts/Videoshow/
├── VideoshowClient.cs            ← client HTTP générique (configurable dans l'inspecteur)
├── VideoshowAnimationTrigger.cs  ← MonoBehaviour exemple : touche clavier → animation
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

## Prérequis Unity

- Aucun package externe : on utilise `UnityEngine.Networking.UnityWebRequest`, fourni en standard.
- Si votre build cible WebGL et que Videoshow tourne sur une autre machine, pensez à CORS.

## Et si Videoshow ne parle pas HTTP mais WebSocket ?

C'est probable pour ce type d'appli "régie temps réel". Si la procédure de découverte
révèle une connexion `ws://localhost:8123/…`, dites-le et j'ajouterai un client
WebSocket (basé sur `NativeWebSocket`).
