using UnityEngine;
using TMPro;
using System.Collections;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;

    [Header("Level Settings")]
    public int totalLeechesTarget = 5;
    private int destroyedLeechesCount = 0;

    [Header("UI")]
    public TextMeshProUGUI leechCounterText; // Inspector'dan bağla

    [Header("Door")]
    public DoorInteraction door;

    [Header("Rocket Speech")]
    public AudioClip rocketVictorySpeech;
    public AudioClip radioStatic;
    private AudioSource rocketAudio;

    void Awake()
    {
        if (Instance == null) Instance = this;
        else Destroy(gameObject);
    }

    void Start()
    {
        rocketAudio = gameObject.AddComponent<AudioSource>();
        UpdateUI();
    }

    public void LeechDestroyed()
    {
        destroyedLeechesCount++;
        UpdateUI();

        if (destroyedLeechesCount >= totalLeechesTarget)
            LevelCompleted();
    }

    void UpdateUI()
    {
        if (leechCounterText != null)
            leechCounterText.text = $"{destroyedLeechesCount}/{totalLeechesTarget}";
    }

    void LevelCompleted()
    {
        StartCoroutine(VictorySequence());
    }

    IEnumerator VictorySequence()
    {
        yield return new WaitForSeconds(2f);

        if (door != null) door.isLocked = false;

        // Radio static + konuşma
        if (radioStatic != null)
            rocketAudio.PlayOneShot(radioStatic, 2f);

        yield return new WaitForSeconds(1f);

        if (rocketVictorySpeech != null)
            rocketAudio.PlayOneShot(rocketVictorySpeech);
    }
}