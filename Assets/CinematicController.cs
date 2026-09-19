using UnityEngine;
using System.Collections;

public class CinematicController : MonoBehaviour
{
    [Header("Audio")]
    public AudioClip cassetteClick;
    public AudioClip mainSong;
    public AudioClip engineSound;
    public AudioClip engineStop;
    public AudioClip rocketRadioSpeech; // Yeni: Rocket'ın "Dışarı çık" telsiz konuşması
    public AudioClip radioStatic;
    public AudioClip alarmSound;

    [Header("Lights")]
    public Light[] cockpitLights;

    [Header("Sun Lights")]
    public Light sunLightPink; // büyük pembe → max 1.2
    public Light sunLightPurple; // mor → max 0.4

    [Header("Ship Movement")]
    public GameObject planet;
    public GameObject asteroid;
    public float planetMoveSpeed = 3f;
    public Material skyboxMaterial;
    public float moveDuration = 20f;

    [Header("Walkman Emission")]
    public Renderer walkmanRenderer;
    public int materialIndex = 0; // hangi material emission açılacak

    [Header("Door")]
    public DoorInteraction door;

    [Header("Interaction")]
    public float interactDistance = 1f;
    public Transform walkmanTransform;
    public GameObject promptCanvas;

    private AudioSource audioSource;
    private AudioSource engineAudio;
    private OVRCameraRig cameraRig;
    private bool hasStarted = false;

    [Header("Alarm Settings")]
    public float alarmPulseSpeed = 4f; // Işıkların gradient geçiş hızı
    public float alarmMaxIntensity = 100f; // Alarm anındaki maksimum parlaklık
    private Color[] originalLightColors; // Lambaların ilk renklerini saklamak için
    private float[] originalLightIntensities; // Hata almamak için orijinal şiddetleri de saklıyoruz
    private bool isAlarmActive = false;  // Alarm loop'unu kontrol etmek için
    private Coroutine alarmCoroutine;    // Alarmı sonradan durdurabilmek için reference

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
        audioSource = gameObject.AddComponent<AudioSource>();
        engineAudio = gameObject.AddComponent<AudioSource>();

        if (skyboxMaterial != null)
            skyboxMaterial.SetFloat("_Rotation", 283f);

        if (walkmanRenderer != null)
        {
            // Direkt olarak emisyon özelliğini kapatır, renk ne olursa olsun parlamaz
            walkmanRenderer.materials[materialIndex].DisableKeyword("_EMISSION");
        }

        // --- YENİ: Lambaların orijinal renklerini hafızaya alıyoruz ---
        if (cockpitLights != null && cockpitLights.Length > 0)
        {
            originalLightColors = new Color[cockpitLights.Length];
            originalLightIntensities = new float[cockpitLights.Length];
            for (int i = 0; i < cockpitLights.Length; i++)
            {
                if (cockpitLights[i] != null)
                {
                    originalLightColors[i] = cockpitLights[i].color; // Orijinal rengi kaydet (Mavi/Neon vs.)
                    originalLightIntensities[i] = cockpitLights[i].intensity; // Şiddeti kaydet
                    cockpitLights[i].enabled = false; // Başlangıçta kapat
                }
            }
        }

        if (sunLightPink != null) { sunLightPink.intensity = 0f; sunLightPink.transform.rotation = Quaternion.Euler(8f, 180f, 90f); }
        if (sunLightPurple != null) { sunLightPurple.intensity = 0f; sunLightPurple.transform.rotation = Quaternion.Euler(-170f, -90f, 0f); }
    }

    void Update()
    {
        if (hasStarted)
        {
            if (promptCanvas != null) promptCanvas.SetActive(false);
            return;
        }

        if (cameraRig == null || walkmanTransform == null) return;

        float dist = Vector3.Distance(
            cameraRig.transform.position,
            walkmanTransform.position
        );
        bool nearby = dist < interactDistance;
        if (promptCanvas != null) promptCanvas.SetActive(nearby);

        if (nearby && OVRInput.GetDown(OVRInput.RawButton.RHandTrigger))
            StartCoroutine(PlaySequence());
    }

    IEnumerator PlaySequence()
    {
        hasStarted = true;

        if (promptCanvas != null) promptCanvas.SetActive(false);

        if (walkmanRenderer != null)
        {
            walkmanRenderer.materials[materialIndex].EnableKeyword("_EMISSION");
        }

        // 1. Kaset click sesi
        if (cassetteClick != null)
            audioSource.PlayOneShot(cassetteClick);

        yield return new WaitForSeconds(0.8f);

        // 2. Şarkı başlar
        audioSource.clip = mainSong;
        audioSource.loop = false;
        audioSource.Play();

        // 3. Işıklar sırayla açılır (5 saniyede)
        StartCoroutine(LightSequence());

        // 4. 1 saniye sonra gemi harekete geçer
        yield return new WaitForSeconds(1f);
        StartCoroutine(MoveShip());

        // 5. moveDuration sonra sekans biter
        yield return new WaitForSeconds(moveDuration);
        StopSequence();
    }

    IEnumerator LightSequence()
    {
        if (cockpitLights.Length == 0) yield break;

        float interval = 5f / cockpitLights.Length;

        foreach (var light in cockpitLights)
        {
            if (light != null)
            {
                // Alarm aktif değilse orijinal renginde açıldığından emin ol
                if (!isAlarmActive) light.color = originalLightColors[System.Array.IndexOf(cockpitLights, light)];
                light.enabled = true;
            }
            yield return new WaitForSeconds(interval);
        }
    }

    IEnumerator MoveShip()
    {
        float elapsed = 0f;
        float startRotation = 283f;
        float endRotation = 167f;

        // Engine sesi başlar
        if (engineSound != null)
        {
            engineAudio.clip = engineSound;
            engineAudio.loop = true;
            engineAudio.Play();
        }

        while (elapsed < moveDuration)
        {
            float t = elapsed / moveDuration;

            // Skybox yavaşça döner
            if (skyboxMaterial != null)
            {
                float currentRot = Mathf.Lerp(startRotation, endRotation, t);
                skyboxMaterial.SetFloat("_Rotation", currentRot);
            }

            // Sunlight yavaşça artar ve döner
            if (sunLightPink != null)
            {
                sunLightPink.intensity = Mathf.Lerp(0f, 1.2f, t);
                float yRot = Mathf.Lerp(180f, 90f, t);
                sunLightPink.transform.rotation = Quaternion.Euler(8f, yRot, 90f);
            }
            if (sunLightPurple != null)
            {
                sunLightPurple.intensity = Mathf.Lerp(0f, 0.4f, t);
                float yRot = Mathf.Lerp(-90f, 0f, t);
                sunLightPurple.transform.rotation = Quaternion.Euler(-170f, yRot, 0f);
            }

            // Gezegen bize doğru gelip geçer
            if (planet != null)
                planet.transform.Translate(Vector3.forward * planetMoveSpeed * Time.deltaTime);

            if (asteroid != null)
                asteroid.transform.Translate(Vector3.forward * planetMoveSpeed * Time.deltaTime);

            elapsed += Time.deltaTime;
            yield return null;
        }

        // Engine durur
        engineAudio.Stop();
        if (engineStop != null)
            engineAudio.PlayOneShot(engineStop, 3f);

    }

    void StopSequence()
    {
        // Şarkı durur
        audioSource.Stop();

        // Alarm sesi - loop, kısık
        if (alarmSound != null)
        {
            engineAudio.clip = alarmSound;
            engineAudio.loop = true;
            engineAudio.volume = 0.3f; // kısık
            engineAudio.Play();
        }

        // --- YENİ: ALARM MODUNU BAŞLAT ---
        isAlarmActive = true;
        alarmCoroutine = StartCoroutine(AlarmLightLoop());

        // --- YENİ: Rocket Telsizden Konuşur ---
        StartCoroutine(RocketSequence());

        // Lever açılır (Part 3 için)
        // if (lever != null) lever.isLocked = false;
    }

    IEnumerator RocketSequence()
    {
        yield return new WaitForSeconds(6f);

        AudioSource rocketAudio = gameObject.AddComponent<AudioSource>();
        rocketAudio.volume = 1f;

        if (radioStatic != null)
            audioSource.PlayOneShot(radioStatic, 6f);

        yield return new WaitForSeconds(1f); // static bittikten 1 sn sonra konuşsun

        if (rocketRadioSpeech != null)
            audioSource.PlayOneShot(rocketRadioSpeech, 5f);

        yield return new WaitForSeconds(30f);

        // Kapıyı aç
        if (door != null) door.isLocked = false;
    }

    // --- YENİ COROUTINE: Kırmızı Yanıp Sönen Alarm Sistemi ---
    IEnumerator AlarmLightLoop()
    {
        // Tüm ışıkları hemen kırmızıya boya
        foreach (var light in cockpitLights)
        {
            if (light != null)
            {
                light.color = Color.red;
                light.enabled = true;
            }
        }

        // Sonsuz loop (Oyuncu dışarı çıkana veya sen durdurana kadar)
        while (isAlarmActive)
        {
            float wave = Mathf.Sin(Time.time * alarmPulseSpeed);
            float normalizedWave = (wave + 1f) / 2f;

            // Tüm ışıkların şiddetini bu dalgaya göre pürüzsüzce (gradient) değiştir
            foreach (var light in cockpitLights)
            {
                if (light != null)
                {
                    light.intensity = normalizedWave*500f;
                }
            }

            // Yarım saniyede bir yanıp sönsün (Hızı buradan ayarlayabilirsin)
            yield return null;
        }
    }

    // --- YENİ FONKSİYON: Dışarı çıktığında alarmı kapatmak istersen çağırabilirsin ---
    public void StopAlarm()
    {
        isAlarmActive = false;
        if (alarmCoroutine != null) StopCoroutine(alarmCoroutine);

        // Işıkları eski renklerine geri döndür
        for (int i = 0; i < cockpitLights.Length; i++)
        {
            if (cockpitLights[i] != null)
            {
                cockpitLights[i].color = originalLightColors[i];
                cockpitLights[i].intensity = originalLightIntensities[i]; // Eski parlaklığına döndür
                cockpitLights[i].enabled = true; // İstersen açık kalsınlar
            }
        }
    }
}