using UnityEngine;

namespace AuditionMorand.Videoshow
{
    [RequireComponent(typeof(VideoshowClient))]
    public class VideoshowAnimationTrigger : MonoBehaviour
    {
        [Tooltip("Identifiant de l'animation à déclencher côté Videoshow.")]
        public string animationId = "intro";

        [Tooltip("Si vrai, déclenche l'animation au démarrage de la scène.")]
        public bool triggerOnStart = false;

        [Tooltip("Touche clavier qui déclenche l'animation. None pour désactiver.\n" +
                 "BackQuote = la touche ² sur AZERTY français (même position physique " +
                 "que ` sur QWERTY).")]
        public KeyCode triggerKey = KeyCode.BackQuote;

        private VideoshowClient client;

        private void Awake()
        {
            client = GetComponent<VideoshowClient>();
        }

        private void Start()
        {
            if (triggerOnStart)
            {
                Trigger();
            }
        }

        private void Update()
        {
            if (triggerKey != KeyCode.None && Input.GetKeyDown(triggerKey))
            {
                Trigger();
            }
        }

        public void Trigger()
        {
            client.TriggerAnimation(animationId);
        }

        public void Trigger(string overrideId)
        {
            client.TriggerAnimation(overrideId);
        }
    }
}
