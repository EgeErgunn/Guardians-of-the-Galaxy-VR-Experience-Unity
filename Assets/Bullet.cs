using UnityEngine;

public class Bullet : MonoBehaviour
{
    public float speed = 20f;
    public GameObject hitEffect;
    public AudioClip hitSound;

    void Start()
    {
        Destroy(gameObject, 7f);
    }

    void Update()
    {
        float moveDistance = speed * Time.deltaTime;

        if (Physics.Raycast(transform.position, transform.forward, out RaycastHit hit, moveDistance))
        {
            if (hitSound != null)
                AudioSource.PlayClipAtPoint(hitSound, transform.position);

            if (hitEffect != null)
            {   
                Instantiate(hitEffect, hit.point, Quaternion.identity);
            }
                

            // Sülüğe çarptıysa LeechHealth'i tetikle
            LeechHealth leech = hit.collider.GetComponentInParent<LeechHealth>();
            if (leech != null)
                leech.TakeDamage();

            Destroy(gameObject);
            return;
        }

        transform.Translate(Vector3.forward * moveDistance);
    }
}