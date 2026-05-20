using System.Collections;
using UnityEngine;
using UnityEngine.Networking;

namespace AuditionMorand.Videoshow
{
    public class VideoshowProbe : MonoBehaviour
    {
        public string baseUrl = "http://localhost:8123";

        public string[] candidatePaths =
        {
            "/",
            "/api",
            "/api/animations",
            "/api/animation",
            "/api/trigger",
            "/animations",
            "/trigger",
            "/control",
            "/controle",
            "/status",
            "/health"
        };

        [ContextMenu("Probe")]
        public void Probe()
        {
            StartCoroutine(RunProbe());
        }

        private IEnumerator RunProbe()
        {
            Debug.Log($"[VideoshowProbe] Sondage de {baseUrl} sur {candidatePaths.Length} chemins…");
            foreach (string path in candidatePaths)
            {
                string url = baseUrl.TrimEnd('/') + (path.StartsWith("/") ? path : "/" + path);
                using (UnityWebRequest req = UnityWebRequest.Get(url))
                {
                    req.timeout = 3;
                    yield return req.SendWebRequest();

                    long code = req.responseCode;
                    string status = req.result == UnityWebRequest.Result.Success ? "OK" : req.error;
                    Debug.Log($"[VideoshowProbe] {url} → {code} ({status})");
                }
            }
            Debug.Log("[VideoshowProbe] Terminé.");
        }
    }
}
