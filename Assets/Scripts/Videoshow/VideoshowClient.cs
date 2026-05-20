using System;
using System.Collections;
using System.Text;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.Networking;

namespace AuditionMorand.Videoshow
{
    public enum VideoshowHttpMethod
    {
        GET,
        POST
    }

    [Serializable]
    public class VideoshowResponseEvent : UnityEvent<string> { }

    [Serializable]
    public class VideoshowErrorEvent : UnityEvent<string> { }

    public class VideoshowClient : MonoBehaviour
    {
        [Header("Serveur Videoshow")]
        [Tooltip("URL de base du serveur Videoshow local.")]
        public string baseUrl = "http://localhost:8123";

        [Tooltip("Timeout des requêtes en secondes.")]
        [Range(1f, 30f)]
        public float requestTimeoutSeconds = 5f;

        [Header("Endpoint d'animation")]
        [Tooltip("Chemin relatif appelé pour déclencher une animation. " +
                 "Utilisez {id} comme placeholder pour l'identifiant. " +
                 "Exemple : /api/animation/{id} ou /trigger?anim={id}")]
        public string animationEndpointTemplate = "/api/animation/{id}";

        [Tooltip("Méthode HTTP utilisée pour déclencher l'animation.")]
        public VideoshowHttpMethod method = VideoshowHttpMethod.POST;

        [Tooltip("Corps JSON envoyé en POST. Utilisez {id} comme placeholder. " +
                 "Laissez vide pour envoyer un corps vide.")]
        [TextArea(2, 5)]
        public string jsonBodyTemplate = "{\"animation\":\"{id}\"}";

        [Header("Événements")]
        public VideoshowResponseEvent onSuccess;
        public VideoshowErrorEvent onError;

        public void TriggerAnimation(string animationId)
        {
            if (string.IsNullOrWhiteSpace(animationId))
            {
                ReportError("ID d'animation vide.");
                return;
            }

            StartCoroutine(SendAnimationRequest(animationId));
        }

        public void TriggerRawPath(string relativePath)
        {
            if (string.IsNullOrWhiteSpace(relativePath))
            {
                ReportError("Chemin vide.");
                return;
            }

            StartCoroutine(SendRawRequest(relativePath, null));
        }

        private IEnumerator SendAnimationRequest(string animationId)
        {
            string path = animationEndpointTemplate.Replace("{id}", UnityWebRequest.EscapeURL(animationId));
            string body = method == VideoshowHttpMethod.POST && !string.IsNullOrEmpty(jsonBodyTemplate)
                ? jsonBodyTemplate.Replace("{id}", animationId)
                : null;

            yield return SendRawRequest(path, body);
        }

        private IEnumerator SendRawRequest(string relativePath, string jsonBody)
        {
            string url = CombineUrl(baseUrl, relativePath);

            using (UnityWebRequest request = BuildRequest(url, jsonBody))
            {
                request.timeout = Mathf.CeilToInt(requestTimeoutSeconds);
                yield return request.SendWebRequest();

                if (request.result == UnityWebRequest.Result.Success)
                {
                    string response = request.downloadHandler != null ? request.downloadHandler.text : string.Empty;
                    Debug.Log($"[Videoshow] {method} {url} → {(int)request.responseCode}");
                    onSuccess?.Invoke(response);
                }
                else
                {
                    string message = $"{method} {url} → {request.error} (code {(int)request.responseCode})";
                    ReportError(message);
                }
            }
        }

        private UnityWebRequest BuildRequest(string url, string jsonBody)
        {
            if (method == VideoshowHttpMethod.GET)
            {
                return UnityWebRequest.Get(url);
            }

            UnityWebRequest request = new UnityWebRequest(url, UnityWebRequest.kHttpVerbPOST);
            byte[] bodyBytes = string.IsNullOrEmpty(jsonBody)
                ? Array.Empty<byte>()
                : Encoding.UTF8.GetBytes(jsonBody);

            request.uploadHandler = new UploadHandlerRaw(bodyBytes);
            request.downloadHandler = new DownloadHandlerBuffer();
            request.SetRequestHeader("Content-Type", "application/json");
            request.SetRequestHeader("Accept", "application/json");
            return request;
        }

        private static string CombineUrl(string root, string path)
        {
            if (string.IsNullOrEmpty(root)) return path;
            if (string.IsNullOrEmpty(path)) return root;

            bool rootEndsWithSlash = root.EndsWith("/");
            bool pathStartsWithSlash = path.StartsWith("/");

            if (rootEndsWithSlash && pathStartsWithSlash) return root + path.Substring(1);
            if (!rootEndsWithSlash && !pathStartsWithSlash) return root + "/" + path;
            return root + path;
        }

        private void ReportError(string message)
        {
            Debug.LogError($"[Videoshow] {message}");
            onError?.Invoke(message);
        }
    }
}
