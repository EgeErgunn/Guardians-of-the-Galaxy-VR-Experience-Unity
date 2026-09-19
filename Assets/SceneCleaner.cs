using UnityEngine;

public class SceneCleanup : MonoBehaviour
{
    void Awake()
    {
        Physics.gravity = new Vector3(0, -9.81f, 0);


        // Duplicate CameraRig varsa temizle
        OVRCameraRig[] rigs = FindObjectsOfType<OVRCameraRig>();
        if (rigs.Length > 1)
        {
            Debug.Log("Duplicate CameraRig bulundu, temizleniyor");
            for (int i = 1; i < rigs.Length; i++)
                Destroy(rigs[i].gameObject);
        }

        // Duplicate OVRManager varsa temizle
        OVRManager[] managers = FindObjectsOfType<OVRManager>();
        if (managers.Length > 1)
        {
            Debug.Log("Duplicate OVRManager bulundu, temizleniyor");
            for (int i = 1; i < managers.Length; i++)
                Destroy(managers[i].gameObject);
        }
    }
}