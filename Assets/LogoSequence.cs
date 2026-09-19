using System.Collections;
using UnityEngine;
using UnityEngine.UI;

public class LogoSequence : MonoBehaviour
{
    [Header("Panels")]
    public Image blackPanel;
    public Image gogLogo;
    public Image vrExperience;

    [Header("Timing")]
    public float blackDuration = 1f;      // siyahta bekleme
    public float logoFadeIn = 2f;         // logo belirme süresi
    public float logoHoldDuration = 2f;   // logo ekranda kalma süresi
    public float textFadeIn = 2f;         // yazı belirme süresi

    private bool hasStarted = false;

    void Start()
    {
        SetAlpha(blackPanel, 0f);
        SetAlpha(gogLogo, 0f);
        SetAlpha(vrExperience, 0f);
    }

    public void StartLogoSequence()
    {
        if (!hasStarted)
        {
            hasStarted = true;
            StartCoroutine(PlaySequence());
        }
    }

    IEnumerator PlaySequence()
    {
        // Başta her şey gizli, panel siyah
        SetAlpha(blackPanel, 1f);
        SetAlpha(gogLogo, 0f);
        SetAlpha(vrExperience, 0f);

        // Siyahta bekle
        yield return new WaitForSeconds(blackDuration);

        // GOG Logo fade in
        yield return StartCoroutine(FadeIn(gogLogo, logoFadeIn));

        // Logo ekranda bekle
        yield return new WaitForSeconds(logoHoldDuration);

        // VR Experience yazısı fade in
        yield return StartCoroutine(FadeIn(vrExperience, textFadeIn));
    }

    IEnumerator FadeIn(Image image, float duration)
    {
        float elapsed = 0f;
        while (elapsed < duration)
        {
            SetAlpha(image, elapsed / duration);
            elapsed += Time.deltaTime;
            yield return null;
        }
        SetAlpha(image, 1f);
    }

    void SetAlpha(Image image, float alpha)
    {
        if (image == null) return;
        Color c = image.color;
        c.a = alpha;
        image.color = c;
    }
}