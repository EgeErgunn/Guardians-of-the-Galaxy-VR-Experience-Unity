using UnityEngine;

public class BillboardCanvas : MonoBehaviour
{
    private OVRCameraRig cameraRig;

    void Start()
    {
        cameraRig = FindObjectOfType<OVRCameraRig>();
    }

    void Update()
    {
        if (cameraRig == null) return;

        Vector3 direction = transform.position - cameraRig.centerEyeAnchor.position;
        transform.rotation = Quaternion.LookRotation(direction);
    }
}