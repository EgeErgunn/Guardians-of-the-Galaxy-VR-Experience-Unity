using UnityEngine;

public class LeechHealth : MonoBehaviour
{
    [Header("Death Effects")]
    public ParticleSystem bloodEffect;
    public AudioClip deathSound;

    [Header("3D Sound Settings")]
    public float soundMaxDistance = 50f;
    [Range(0f, 1f)] public float soundVolume = 1.0f;

    private bool isDead = false;

    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Bullet") && !isDead)
        {
            Die();
            Destroy(collision.gameObject);
        }
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Bullet") && !isDead)
        {
            Die();
            Destroy(other.gameObject);
        }
    }

    public void TakeDamage()
    {
        if (!isDead) Die();
    }

    void Die()
    {
        isDead = true;

        if (bloodEffect != null)
        {
            bloodEffect.transform.SetParent(null); // Sülükten kopar
            bloodEffect.transform.position = transform.position;
            bloodEffect.Play();
            Destroy(bloodEffect.gameObject, 2f);
        }

        if (deathSound != null)
            Spawn3DDeathSound();

        if (GameManager.Instance != null)
            GameManager.Instance.LeechDestroyed();

        Destroy(gameObject);
    }

    void Spawn3DDeathSound()
    {
        GameObject audioObj = new GameObject("Temporary_Leech_Death_Sound");
        audioObj.transform.position = transform.position;

        AudioSource aSource = audioObj.AddComponent<AudioSource>();
        aSource.clip = deathSound;
        aSource.spatialBlend = 1.0f;
        aSource.volume = soundVolume;
        aSource.rolloffMode = AudioRolloffMode.Linear;
        aSource.minDistance = 2f;
        aSource.maxDistance = soundMaxDistance;
        aSource.Play();

        Destroy(audioObj, deathSound.length + 0.1f);
    }
}