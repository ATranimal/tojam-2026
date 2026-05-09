using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TestBillboard : MonoBehaviour
{
    Transform cam;

    void Start()
    {
        cam = Camera.main.transform;
    }

    void Update()
    {
        UpdateLookAtCamera();
    }

    void UpdateLookAtCamera()
    {
        Camera mainCamera = Camera.main;
        if (mainCamera == null)
            return;

        Transform camTransform = mainCamera.transform;
        transform.LookAt(transform.position + camTransform.forward);
    }
}
