using System.Threading;
using UnityEngine;

#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
using System.Runtime.InteropServices;
#endif

namespace AuditionMorand.Videoshow
{
    [RequireComponent(typeof(VideoshowClient))]
    public class VideoshowGlobalHotkey : MonoBehaviour
    {
        [Tooltip("Code virtuel de la touche à écouter globalement.\n" +
                 "0xDE = touche ² sur la plupart des claviers AZERTY français.\n" +
                 "0xC0 = même touche si configuration différente.\n" +
                 "Liste complète : docs.microsoft.com/windows/win32/inputdev/virtual-key-codes")]
        public int virtualKeyCode = 0xDE;

        [Tooltip("Identifiant de l'animation à déclencher côté Videoshow.")]
        public string animationId = "intro";

        [Tooltip("Délai minimum entre deux déclenchements (anti-rebond, en secondes).")]
        [Range(0f, 2f)]
        public float minIntervalSeconds = 0.2f;

        [Tooltip("Période de polling du clavier en millisecondes.")]
        [Range(5, 100)]
        public int pollingIntervalMs = 20;

        private VideoshowClient client;
        private Thread pollingThread;
        private volatile bool keepRunning;
        private int triggerCount;
        private float lastTriggerTime;

#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
        [DllImport("user32.dll")]
        private static extern short GetAsyncKeyState(int vKey);
#endif

        private void Awake()
        {
            Application.runInBackground = true;
            client = GetComponent<VideoshowClient>();
        }

        private void OnEnable()
        {
#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
            keepRunning = true;
            pollingThread = new Thread(PollLoop)
            {
                IsBackground = true,
                Name = "VideoshowGlobalHotkey"
            };
            pollingThread.Start();
#else
            Debug.LogWarning("[VideoshowGlobalHotkey] Plateforme non Windows : le hotkey global est désactivé.");
#endif
        }

        private void OnDisable()
        {
            keepRunning = false;
            if (pollingThread != null && pollingThread.IsAlive)
            {
                pollingThread.Join(200);
            }
            pollingThread = null;
        }

#if UNITY_STANDALONE_WIN || UNITY_EDITOR_WIN
        private void PollLoop()
        {
            bool wasDown = false;
            while (keepRunning)
            {
                bool isDown = (GetAsyncKeyState(virtualKeyCode) & 0x8000) != 0;
                if (isDown && !wasDown)
                {
                    Interlocked.Increment(ref triggerCount);
                }
                wasDown = isDown;
                Thread.Sleep(pollingIntervalMs);
            }
        }
#endif

        private void Update()
        {
            int pending = Interlocked.Exchange(ref triggerCount, 0);
            if (pending == 0) return;

            if (Time.unscaledTime - lastTriggerTime < minIntervalSeconds) return;

            lastTriggerTime = Time.unscaledTime;
            client.TriggerAnimation(animationId);
        }
    }
}
