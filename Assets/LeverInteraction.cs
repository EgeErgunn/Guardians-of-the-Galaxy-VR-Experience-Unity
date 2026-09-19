using System.Collections;
using UnityEngine;

public class LeverInteraction : MonoBehaviour
{
    [Header("Lever")]
    public Transform leverPivot;
    public float maxAngle = 120f;
    public GameObject leverPromptCanvas;

    [Header("Sound")]
    public AudioClip engineClip;
    public float minVolume = 0f;
    public float maxVolume = 1f;

    [Header("Logo")]
    public LogoSequence logoSequence;

    [Header("Sequence")]
    public GameObject[] asteroids;
    public Material skyboxMaterial;
    public GameObject incomingShip;
    public float startSkyboxRotation = 167f;
    public float endSkyboxRotation = 120f;
    public float sequenceDuration = 6f;

    [Header("Sequence Audio")]
    public AudioClip shipArrivalSound;
    public AudioClip mainSong;

    private bool sequenceStarted = false;
    private AudioSource audioSource;
    private AudioSource sequenceAudioSource;
    private bool isSeated = false;
    private bool isHolding = false;
    public bool isLocked = true;
    private float currentAngle = 0f;
    private float startAngle = 0f;
    private OVRCameraRig cameraRig;
    private Vector3 lastHandPos;

    private Vector3 shipStartPos = new Vector3(-3.5f, 30.2f, -950f);
    private Vector3 shipEndPos = new Vector3(-3.5f, 30.2f, -134f);

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();

        audioSource = gameObject.AddComponent<AudioSource>();
        audioSource.clip = engineClip;
        audioSource.loop = true;
        audioSource.playOnAwake = false;
        audioSource.volume = 0f;

        sequenceAudioSource = gameObject.AddComponent<AudioSource>();
        sequenceAudioSource.loop = false;
        sequenceAudioSource.playOnAwake = false;

        startAngle = leverPivot.localEulerAngles.x;
        currentAngle = startAngle;

        if (leverPromptCanvas != null) leverPromptCanvas.SetActive(false);

        if (skyboxMaterial != null)
            skyboxMaterial.SetFloat("_Rotation", startSkyboxRotation);

        if (incomingShip != null)
        {
            incomingShip.transform.position = shipStartPos;
            incomingShip.SetActive(false);
        }
    }

    public void SetSeated(bool seated)
    {
        isSeated = seated;
        if (!seated)
        {
            isHolding = false;
            SetLeverValue(0f);
            if (leverPromptCanvas != null) leverPromptCanvas.SetActive(false);
        }
        else
        {
            if (leverPromptCanvas != null) leverPromptCanvas.SetActive(true);
        }
    }

    void Update()
    {
        if (!isSeated || cameraRig == null || isLocked) return;

        Transform rightHand = cameraRig.rightHandAnchor;
        bool gripHeld = OVRInput.Get(OVRInput.Button.SecondaryHandTrigger);

        if (gripHeld && !isHolding)
        {
            isHolding = true;
            lastHandPos = rightHand.position;
        }
        else if (!gripHeld)
        {
            isHolding = false;
        }

        if (isHolding)
        {
            float deltaZ = rightHand.position.z - lastHandPos.z;
            float deltaY = rightHand.position.y - lastHandPos.y;
            float totalDelta = deltaZ + deltaY;
            lastHandPos = rightHand.position;

            currentAngle = Mathf.Clamp(currentAngle - totalDelta * 90f, startAngle - maxAngle, startAngle);
            leverPivot.localRotation = Quaternion.Euler(currentAngle, 0f, 0f);

            float t = Mathf.InverseLerp(startAngle, startAngle - maxAngle, currentAngle);
            SetLeverValue(t);

            if (t >= 1f && !sequenceStarted)
            {
                isLocked = true;
                sequenceStarted = true;
                StartCoroutine(StartSequence());
            }
        }
    }

    void SetLeverValue(float t)
    {
        if (engineClip == null) return;

        if (t > 0.01f)
        {
            if (!audioSource.isPlaying) audioSource.Play();
            audioSource.volume = Mathf.Lerp(minVolume, maxVolume, t);
            audioSource.pitch = Mathf.Lerp(0.5f, 2f, t);
        }
        else
        {
            audioSource.volume = Mathf.Lerp(audioSource.volume, 0f, Time.deltaTime * 2f);
            if (audioSource.volume < 0.01f) audioSource.Stop();
        }
    }

    IEnumerator StartSequence()
    {
        // Engine anında kes, şarkı başlat
        audioSource.Stop();
        audioSource.volume = 0f;

        if (mainSong != null)
        {
            sequenceAudioSource.clip = mainSong;
            sequenceAudioSource.loop = false;
            sequenceAudioSource.Play();
        }

        float elapsed = 0f;

        while (elapsed < sequenceDuration)
        {
            float t = elapsed / sequenceDuration;

            if (skyboxMaterial != null)
                skyboxMaterial.SetFloat("_Rotation", Mathf.Lerp(startSkyboxRotation, endSkyboxRotation, t));

            foreach (var asteroid in asteroids)
                if (asteroid != null)
                    asteroid.transform.Translate(Vector3.forward * 5f * Time.deltaTime);

            elapsed += Time.deltaTime;
            yield return null;
        }

        yield return StartCoroutine(ShipHyperspaceEntry());
    }

    IEnumerator ShipHyperspaceEntry()
    {
        if (incomingShip == null) yield break;

        incomingShip.transform.position = shipStartPos;
        incomingShip.SetActive(true);

        if (shipArrivalSound != null)
            sequenceAudioSource.PlayOneShot(shipArrivalSound);

        float elapsed = 0f;
        float duration = 1f;

        while (elapsed < duration)
        {
            float t = Mathf.Pow(elapsed / duration, 0.4f);
            incomingShip.transform.position = Vector3.Lerp(shipStartPos, shipEndPos, t);
            elapsed += Time.deltaTime;
            yield return null;
        }

        incomingShip.transform.position = shipEndPos;

        yield return new WaitForSeconds(2f);

        if (logoSequence != null)
            logoSequence.StartLogoSequence();
    }
}