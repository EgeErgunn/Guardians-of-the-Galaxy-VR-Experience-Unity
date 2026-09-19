using UnityEngine;
using System.Collections;

public class GunController : MonoBehaviour
{
    public bool isRightHand = true;
    public float summonSpeedGravity = 10f;
    public float summonSpeedSpace = 100f;
    public Transform attachPoint;
    public Transform muzzlePoint;
    public GameObject bulletPrefab;
    public float maxDistanceFromSpawn = 15f;
    public bool useGravity = true;
    public bool limitRange = true;

    [Header("Sounds")]
    public AudioClip summonSound;
    public AudioClip pistolShot;
    public AudioClip heavyShot;

    private AudioSource audioSource;
    private OVRCameraRig cameraRig;
    private Transform handAnchor;
    private Rigidbody rb;
    private Collider gunCollider;

    private bool isSummoning = false;
    private bool isHeld = false;

    private Vector3 spawnPosition;
    private Quaternion spawnRotation;

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
        handAnchor = isRightHand ? cameraRig.rightHandAnchor : cameraRig.leftHandAnchor;
        rb = GetComponent<Rigidbody>();
        gunCollider = GetComponentInChildren<Collider>();
        audioSource = gameObject.AddComponent<AudioSource>();

        rb.useGravity = useGravity;
        if (!useGravity) rb.isKinematic = false;

        spawnPosition = transform.position;
        spawnRotation = transform.rotation;
    }

    void Update()
    {
        if (!isHeld && !isSummoning && limitRange)
        {
            float distFromSpawn = Vector3.Distance(transform.position, spawnPosition);
            if (distFromSpawn > maxDistanceFromSpawn)
            {
                ResetToSpawn();
            }
        }

        OVRInput.Controller controller = isRightHand ? OVRInput.Controller.RTouch : OVRInput.Controller.LTouch;
        OVRInput.Button summonButton = isRightHand ? OVRInput.Button.Two : OVRInput.Button.Four;

        // --- SUMMON BAŞLANGICI ---
        if (OVRInput.GetDown(summonButton) && !isHeld && !isSummoning)
        {
            isSummoning = true;
            isHeld = false; // Güvenlik önlemi

            // Fizik motorunu tamamen boşa çıkarıyoruz ki transform.position ile çakışmasın
            rb.isKinematic = true;
            rb.linearVelocity = Vector3.zero;
            rb.angularVelocity = Vector3.zero;

            if (gunCollider != null) gunCollider.enabled = false;
            if (summonSound != null) audioSource.PlayOneShot(summonSound);
        }

        bool gripHeld = isRightHand ? OVRInput.Get(OVRInput.RawButton.RHandTrigger) : OVRInput.Get(OVRInput.RawButton.LHandTrigger);
        float dist = Vector3.Distance(transform.position, handAnchor.position);
        float grabDistance = useGravity ? 0.3f : 1f;

        if (gripHeld && dist < grabDistance && !isHeld && !isSummoning)
        {
            GrabGun();
        }

        if (!gripHeld && isHeld)
        {
            DropGun();
        }

        // --- HAREKET VE EŞZAMANLAMA (SUMMON AKIŞI) ---
        if (isSummoning)
        {
            float speed = useGravity ? summonSpeedGravity : summonSpeedSpace;

            // Pozisyonu taşımadan önce hedefe ulaşıp ulaşmayacağımızı kontrol ediyoruz
            float step = speed * Time.deltaTime;

            if (dist <= step || dist < 0.05f)
            {
                // EĞER HIZ ÇOK YÜKSEKSE VE ELİN İÇİNE GİRDİYSE DOĞRUDAN KİLİTLE
                SnapToHand();
            }
            else
            {
                // Normal seyahat hali
                transform.position = Vector3.MoveTowards(transform.position, handAnchor.position, step);
                transform.rotation = Quaternion.Lerp(transform.rotation, handAnchor.rotation, Time.deltaTime * speed);
            }
        }

        // --- ELDE TUTMA VE ATEŞ ETME ---
        if (isHeld)
        {
            // Pozisyonu her frame elin pozisyonuyla çivi gibi çakıyoruz
            PositionOnHand();

            if (OVRInput.GetDown(OVRInput.Button.PrimaryIndexTrigger, controller))
                Shoot();
        }
    }

    void SnapToHand()
    {
        isSummoning = false;
        isHeld = true;

        rb.isKinematic = true;
        rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;

        if (gunCollider != null) gunCollider.enabled = false;

        PositionOnHand(); // Anında el pozisyonuna eşitle
    }

    void PositionOnHand()
    {
        if (attachPoint != null)
        {
            transform.position = handAnchor.position - (attachPoint.position - transform.position);
            transform.rotation = handAnchor.rotation * Quaternion.Inverse(attachPoint.localRotation);
        }
        else
        {
            transform.position = handAnchor.position;
            transform.rotation = handAnchor.rotation;
        }
    }

    void GrabGun()
    {
        rb.isKinematic = true;
        rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        isHeld = true;
        if (gunCollider != null) gunCollider.enabled = false;
    }

    void DropGun()
    {
        isHeld = false;
        rb.isKinematic = false;
        rb.useGravity = useGravity;
        if (gunCollider != null) gunCollider.enabled = true;
    }

    void ResetToSpawn()
    {
        transform.position = spawnPosition;
        transform.rotation = spawnRotation;
        rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        if (!useGravity) rb.isKinematic = false;
    }

    void Shoot()
    {
        AudioClip clip = Random.value < 0.7f ? pistolShot : heavyShot;
        if (clip != null) audioSource.PlayOneShot(clip, 2f);

        if (bulletPrefab != null && muzzlePoint != null)
            Instantiate(bulletPrefab, muzzlePoint.position, muzzlePoint.rotation);
    }
}