using UnityEngine;

public class DayNightCycle : MonoBehaviour
{
    [Header("Lights")]
    public Light dayLight;
    public Light nightLight;

    [Header("Light Rotation")]
    // Pitch (X) angle for the sun at noon (day) and the moon at midnight (night).
    // Yaw (Y) stays fixed — point your lights in the editor, only pitch is animated.
    public float dayLightNoonPitch = 60f;    // sun high in the sky
    public float dayLightHorizonPitch = 5f;  // sun near horizon at dusk/dawn
    public float nightLightNoonPitch = 50f;  // moon high at midnight
    public float nightLightHorizonPitch = 5f; // moon near horizon at dusk/dawn

    [Header("Skyboxes")]
    // Assign your Daytime.mat and Nighttime.mat here.
    // Both use the same Astral Fjord Skybox shader, so Material.Lerp works perfectly.
    public Material daySkybox;
    public Material nightSkybox;

    [Header("Ambient Light")]
    public Color dayAmbient = new Color(0.5f, 0.55f, 0.6f);
    public Color nightAmbient = new Color(0.05f, 0.05f, 0.15f);

    [Header("Cycle Settings")]
    public float transitionDuration = 30f; // seconds to tween day→night or night→day
    public float holdDuration = 60f;       // seconds to hold at each extreme before transitioning
    public bool autoAdvance = true;

    [Range(0f, 1f)]
    public float timeOfDay = 0f; // 0 = full day, 1 = full night (read-only at runtime)

    // Runtime copy so we never modify the original assets
    private Material _blendedSkybox;

    private enum CycleState { HoldingDay, TransitionToNight, HoldingNight, TransitionToDay }
    private CycleState _state = CycleState.HoldingDay;
    private float _stateTimer = 0f;

    void Start()
    {
        if (daySkybox != null)
        {
            _blendedSkybox = new Material(daySkybox);
            RenderSettings.skybox = _blendedSkybox;
        }
        ApplyTimeOfDay(timeOfDay);
    }

    void OnDestroy()
    {
        if (_blendedSkybox != null)
            Destroy(_blendedSkybox);
    }

    void Update()
    {
        if (autoAdvance)
            AdvanceCycle(Time.deltaTime);

        ApplyTimeOfDay(timeOfDay);
    }

    private void AdvanceCycle(float dt)
    {
        _stateTimer += dt;

        switch (_state)
        {
            case CycleState.HoldingDay:
                timeOfDay = 0f;
                if (_stateTimer >= holdDuration)
                    TransitionTo(CycleState.TransitionToNight);
                break;

            case CycleState.TransitionToNight:
                timeOfDay = Mathf.Clamp01(_stateTimer / transitionDuration);
                if (_stateTimer >= transitionDuration)
                    TransitionTo(CycleState.HoldingNight);
                break;

            case CycleState.HoldingNight:
                timeOfDay = 1f;
                if (_stateTimer >= holdDuration)
                    TransitionTo(CycleState.TransitionToDay);
                break;

            case CycleState.TransitionToDay:
                timeOfDay = Mathf.Clamp01(1f - _stateTimer / transitionDuration);
                if (_stateTimer >= transitionDuration)
                    TransitionTo(CycleState.HoldingDay);
                break;
        }
    }

    private void TransitionTo(CycleState next)
    {
        _state = next;
        _stateTimer = 0f;
    }

    public void ApplyTimeOfDay(float t)
    {
        // Smooth curve so the transition eases in/out
        float nightBlend = Mathf.SmoothStep(0f, 1f, t);

        // Tween light intensities
        if (dayLight != null)
            dayLight.intensity = Mathf.Lerp(1f, 0f, nightBlend);
        if (nightLight != null)
            nightLight.intensity = Mathf.Lerp(0f, 1f, nightBlend);

        // Rotate lights to simulate sun/moon arc across the sky.
        // nightBlend 0 = full day (sun high), 1 = full night (moon high).
        // Each light arcs from its horizon pitch (0 or 1) to its noon pitch (0.5).
        if (dayLight != null)
        {
            // Day light: rises at nightBlend=1 (dawn), peaks at 0, sets at nightBlend=1
            // Map nightBlend 0→1 as day going from noon toward dusk: pitch noon→horizon
            float dayPitch = Mathf.Lerp(dayLightNoonPitch, dayLightHorizonPitch, nightBlend);
            dayLight.transform.localEulerAngles = new Vector3(dayPitch, dayLight.transform.localEulerAngles.y, 0f);
        }
        if (nightLight != null)
        {
            // Night light: rises at nightBlend=0.5 (dusk), peaks at 1, sets at nightBlend=0.5
            float nightPitch = Mathf.Lerp(nightLightHorizonPitch, nightLightNoonPitch, nightBlend);
            nightLight.transform.localEulerAngles = new Vector3(nightPitch, nightLight.transform.localEulerAngles.y, 0f);
        }

        // Tween ambient light color
        RenderSettings.ambientLight = Color.Lerp(dayAmbient, nightAmbient, nightBlend);

        // Lerp all shader float and color properties between the two materials.
        // Material.Lerp requires both materials to use the same shader — confirmed.
        if (_blendedSkybox != null && daySkybox != null && nightSkybox != null)
        {
            _blendedSkybox.Lerp(daySkybox, nightSkybox, nightBlend);
            DynamicGI.UpdateEnvironment();
        }
    }

    // Call this from other scripts to jump to a specific time (0=day, 1=night)
    public void SetTime(float t)
    {
        timeOfDay = Mathf.Clamp01(t);
        ApplyTimeOfDay(timeOfDay);
    }
}
