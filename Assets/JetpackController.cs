using UnityEngine;
using System.Collections;

public class JetpackController : MonoBehaviour
{
    [Header("Sürükle Bırakılacak Eller / Silahlar")]
    public Transform leftHandOrGun;  // Sol elini veya sol silahını buraya at
    public Transform rightHandOrGun; // Sağ elini veya sağ silahını buraya at

    [Header("Movement")]
    public float acceleration = 8f;
    public float maxSpeed = 15f;
    public float drag = 0.99f;

    [Header("Vertical")]
    public float verticalSpeed = 13f;

    [Header("Rotation")]
    public float turnSpeed = 120f;

    [Header("Collision")]
    public float capsuleRadius = 0.25f;
    public float capsuleHeight = 1.4f;
    public LayerMask collisionMask = ~0;

    [Header("Jetpack Audio")]
    public AudioClip hoverLoopSound;
    [Range(0f, 1f)] public float minVolume = 0.15f;
    [Range(0f, 1f)] public float maxVolume = 0.85f;
    public float soundFadeSpeed = 5f;

    private OVRCameraRig cameraRig;
    private Transform centerEye;
    private Vector3 velocity = Vector3.zero;
    private AudioSource jetpackAudioSource;

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
        if (cameraRig != null) centerEye = cameraRig.centerEyeAnchor;
        Physics.gravity = Vector3.zero;
        SetupJetpackAudio();
    }

    void SetupJetpackAudio()
    {
        jetpackAudioSource = gameObject.AddComponent<AudioSource>();
        jetpackAudioSource.clip = hoverLoopSound;
        jetpackAudioSource.loop = true;
        jetpackAudioSource.playOnAwake = true;
        jetpackAudioSource.volume = minVolume;
        jetpackAudioSource.spatialBlend = 0.0f; // 2D Ses

        if (hoverLoopSound != null) jetpackAudioSource.Play();
    }

    void Update()
    {
        if (cameraRig == null) return;

        // 1. Dönme (Sağ Stick)
        Vector2 rightStick = OVRInput.Get(OVRInput.Axis2D.SecondaryThumbstick);
        if (Mathf.Abs(rightStick.x) > 0.1f)
            cameraRig.transform.Rotate(0f, rightStick.x * turnSpeed * Time.deltaTime, 0f);

        // 2. Yön (Sol Stick)
        Vector2 leftStick = OVRInput.Get(OVRInput.Axis2D.PrimaryThumbstick);
        Vector3 forward = Vector3.forward;
        Vector3 right = Vector3.right;

        if (centerEye != null)
        {
            forward = centerEye.forward;
            right = centerEye.right;
            forward.y = 0f;
            forward.Normalize();
            right.Normalize();
        }

        velocity += (forward * leftStick.y + right * leftStick.x) * acceleration * Time.deltaTime;

        // 3. Dikey Hareket
        if (OVRInput.Get(OVRInput.Button.One)) velocity.y += verticalSpeed * Time.deltaTime;
        if (OVRInput.Get(OVRInput.Button.Three)) velocity.y -= verticalSpeed * Time.deltaTime;

        if (velocity.magnitude > maxSpeed) velocity = velocity.normalized * maxSpeed;
        velocity *= drag;

        UpdateJetpackAudioVolume();

        // --- COLLISION DETECTION KISMI ---
        Vector3 currentPos = cameraRig.transform.position;
        Vector3 bottom = currentPos + Vector3.up * capsuleRadius;
        Vector3 top = currentPos + Vector3.up * (capsuleHeight - capsuleRadius);
        Vector3 frameMovement = velocity * Time.deltaTime;

        RaycastHit hit;
        if (Physics.CapsuleCast(bottom, top, capsuleRadius, frameMovement.normalized, out hit, frameMovement.magnitude, collisionMask))
        {
            // OYUNCU KENDİ ELLERİNE ÇARPTIYSA DUVAR MUAMELESİ YAPMA, GEÇ GİT!
            if ((leftHandOrGun != null && hit.transform.IsChildOf(leftHandOrGun)) ||
                (rightHandOrGun != null && hit.transform.IsChildOf(rightHandOrGun)))
            {
                cameraRig.transform.position += frameMovement; // Elleri boşver, normal yola devam
            }
            else
            {
                // Gerçek bir duvara çarptıysak kaydır
                Vector3 slideMovement = Vector3.ProjectOnPlane(frameMovement, hit.normal);
                cameraRig.transform.position += slideMovement;
                velocity = Vector3.ProjectOnPlane(velocity, hit.normal) * drag;
            }
        }
        else
        {
            cameraRig.transform.position += frameMovement;
        }
    }

    void UpdateJetpackAudioVolume()
    {
        if (jetpackAudioSource == null || hoverLoopSound == null) return;
        float currentSpeedRatio = velocity.magnitude / maxSpeed;
        float targetVolume = Mathf.Lerp(minVolume, maxVolume, currentSpeedRatio);
        jetpackAudioSource.volume = Mathf.MoveTowards(jetpackAudioSource.volume, targetVolume, soundFadeSpeed * Time.deltaTime);
        jetpackAudioSource.pitch = Mathf.Lerp(1.0f, 1.25f, currentSpeedRatio);
    }
}