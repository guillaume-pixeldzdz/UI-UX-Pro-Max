using UnityEngine;

namespace AuditionMorand.Videoshow.Demo
{
    public class VideoshowDemo : MonoBehaviour
    {
        public VideoshowClient client;

        [Tooltip("Liste d'IDs d'animations à proposer dans l'UI de debug.")]
        public string[] animationIds = { "intro", "applause", "fin" };

        private string lastResponse = "";
        private string lastError = "";

        private void Reset()
        {
            client = GetComponent<VideoshowClient>();
        }

        private void Awake()
        {
            if (client == null) client = GetComponent<VideoshowClient>();
            if (client != null)
            {
                client.onSuccess.AddListener(r => lastResponse = string.IsNullOrEmpty(r) ? "(vide)" : r);
                client.onError.AddListener(e => lastError = e);
            }
        }

        private void OnGUI()
        {
            const int width = 320;
            GUILayout.BeginArea(new Rect(10, 10, width, Screen.height - 20), GUI.skin.box);
            GUILayout.Label("Videoshow – panneau de test");

            if (client == null)
            {
                GUILayout.Label("Aucun VideoshowClient assigné.");
                GUILayout.EndArea();
                return;
            }

            GUILayout.Label($"Base URL : {client.baseUrl}");
            GUILayout.Label($"Endpoint : {client.method} {client.animationEndpointTemplate}");

            GUILayout.Space(8);
            GUILayout.Label("Déclencher :");
            foreach (string id in animationIds)
            {
                if (GUILayout.Button(id))
                {
                    client.TriggerAnimation(id);
                }
            }

            GUILayout.Space(8);
            GUILayout.Label("Dernière réponse :");
            GUILayout.TextArea(lastResponse, GUILayout.Height(60));
            GUILayout.Label("Dernière erreur :");
            GUILayout.TextArea(lastError, GUILayout.Height(60));

            GUILayout.EndArea();
        }
    }
}
