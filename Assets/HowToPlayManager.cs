using UnityEngine;

public class HowToPlayManager : MonoBehaviour
{
    public GameObject howToPlayCanvas;
    private bool isVisible = true;

    void Start()
    {
        if (howToPlayCanvas != null) howToPlayCanvas.SetActive(true);
    }

    void Update()
    {
        // A tuşuna basınca toggle
        if (OVRInput.GetDown(OVRInput.Button.One))
        {
            isVisible = !isVisible;
            if (howToPlayCanvas != null) howToPlayCanvas.SetActive(isVisible);
        }
    }
}