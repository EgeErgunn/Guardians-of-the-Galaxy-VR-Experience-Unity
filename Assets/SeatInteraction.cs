using UnityEngine;

public class SeatInteraction : MonoBehaviour
{
    public Transform sitPoint;
    public float interactDistance = 3f;
    public GameObject locomotorObject;
    public GameObject promptCanvas;
    public GameObject leverObject;

    [Header("Özellikler")]
    public bool lockOnSit = false;
    public bool emissionPulse = false;

    [Header("Emission")]
    public Renderer[] seatRenderers;
    public int[] materialIndexes;
    public float pulseSpeed = 2f;

    private OVRCameraRig cameraRig;
    private bool isOccupied = false;

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
        if (promptCanvas != null)
            promptCanvas.SetActive(false);
    }

    void Update()
    {
        if (cameraRig == null) return;

        if (emissionPulse && !isOccupied && seatRenderers != null)
        {
            float raw = Mathf.PingPong(Time.time * pulseSpeed, 1f);
            float t = Mathf.Pow(raw, 3f); // eğriyi sonuna doğru hızlandırır, çoğu zaman sönük kalır
            Color emissionColor = Color.white * Mathf.Lerp(0f, 0.4f, t); // 2f yerine 0.8f, daha az beyaz

            for (int i = 0; i < seatRenderers.Length; i++)
            {
                if (seatRenderers[i] == null) continue;
                int matIdx = i < materialIndexes.Length ? materialIndexes[i] : 0;
                seatRenderers[i].materials[matIdx].EnableKeyword("_EMISSION");
                seatRenderers[i].materials[matIdx].SetColor("_EmissionColor", emissionColor);
            }
        }

        float dist = Vector3.Distance(cameraRig.transform.position, transform.position);
        bool nearby = (dist < interactDistance && !isOccupied) || isOccupied;

        if (promptCanvas != null)
            promptCanvas.SetActive(nearby && !isOccupied);

        if (nearby && OVRInput.GetDown(OVRInput.Button.Three))
        {
            if (!isOccupied) Sit();
            else if (!lockOnSit) StandUp();
        }
    }

    void Sit()
    {
        isOccupied = true;

        if (locomotorObject != null) locomotorObject.SetActive(false);
        if (leverObject != null) leverObject.GetComponent<LeverInteraction>()?.SetSeated(true);

        cameraRig.transform.position = sitPoint.position;
        cameraRig.transform.rotation = sitPoint.rotation;

        if (promptCanvas != null) promptCanvas.SetActive(false);

        if (emissionPulse && seatRenderers != null)
            for (int i = 0; i < seatRenderers.Length; i++)
            {
                if (seatRenderers[i] == null) continue;
                int matIdx = i < materialIndexes.Length ? materialIndexes[i] : 0;
                seatRenderers[i].materials[matIdx].SetColor("_EmissionColor", Color.black);
                seatRenderers[i].materials[matIdx].DisableKeyword("_EMISSION");
            }
    }

    void StandUp()
    {
        isOccupied = false;

        if (locomotorObject != null) locomotorObject.SetActive(true);
        if (leverObject != null) leverObject.GetComponent<LeverInteraction>()?.SetSeated(false);

        cameraRig.transform.position = sitPoint.position + Vector3.right * 1f;

        if (emissionPulse && seatRenderers != null)
            for (int i = 0; i < seatRenderers.Length; i++)
            {
                if (seatRenderers[i] == null) continue;
                int matIdx = i < materialIndexes.Length ? materialIndexes[i] : 0;
                seatRenderers[i].materials[matIdx].EnableKeyword("_EMISSION");
            }
    }
}