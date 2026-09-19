using UnityEngine;
using UnityEngine.SceneManagement;

public class DoorInteraction : MonoBehaviour
{
    public float interactDistance = 1.5f;
    public AudioClip doorSound;
    public GameObject promptCanvas;
    public bool isLocked = true;

    [Header("Scene Settings")]
    public bool isPart1Door = true; // Part1 kapısıysa işaretle, Part2 kapısıysa kaldır

    private OVRCameraRig cameraRig;
    private AudioSource audioSource;

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
        audioSource = gameObject.AddComponent<AudioSource>();
        if (promptCanvas != null) promptCanvas.SetActive(false);
    }

    void Update()
    {
        if (isLocked) return;

        float dist = Vector3.Distance(
            cameraRig.transform.position,
            transform.position
        );

        bool nearby = dist < interactDistance;
        if (promptCanvas != null) promptCanvas.SetActive(nearby);

        if (nearby && OVRInput.GetDown(OVRInput.RawButton.RHandTrigger))
            StartCoroutine(OpenDoor());
    }

    System.Collections.IEnumerator OpenDoor()
    {
        if (promptCanvas != null) promptCanvas.SetActive(false);
        if (doorSound != null) audioSource.PlayOneShot(doorSound);

        yield return new WaitForSeconds(2f);

        SceneManager.LoadScene(isPart1Door ? "GuardiansCockpitPart2" : "GuardiansCockpitPart3");
    }
}