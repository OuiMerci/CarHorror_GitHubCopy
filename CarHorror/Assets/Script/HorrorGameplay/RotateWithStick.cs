using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

namespace CarHorror.Gameplay
{
    public class RotateWithStick : MonoBehaviour
    {
        [Header("Version 1")]
        [SerializeField] private float lerpSpeed;
        [SerializeField] private GameObject _logicV1;
        [SerializeField] private GameObject _gizmoV1;

        [Header("Version 2")]
        [SerializeField] private bool version2;
        [SerializeField] private float moveSpeed;
        [SerializeField] private float lowerX;
        [SerializeField] private float higherX;
        [SerializeField] private GameObject _logicV2;
        [SerializeField] private GameObject _gizmoV2;
        [SerializeField] private float retroDelay;

        private Vector2 lookInput;
        private bool lookingBack;
        private float lookingBackTime;

        private void Update()
        {
            if(lookingBack && lookingBackTime + retroDelay < Time.time)
            {
                lookingBack = false;
                transform.localEulerAngles = new Vector3(0, 180, 0);
            }
            if(version2)
            {
                Vector3 inputDiff = new Vector3(-lookInput.y, lookInput.x, 0) * Time.deltaTime * moveSpeed;
                transform.localEulerAngles += inputDiff;
                ClampYRotation(lookInput.y);
            }
            else
            {
                float finalY = StickInputToAngle(lookInput);
                float lerpedY = Mathf.LerpAngle(transform.localEulerAngles.y, finalY, lerpSpeed);
                transform.localEulerAngles = new Vector3(0, lerpedY, 0);
            }
        }

        public void UpdateRotation(InputAction.CallbackContext context)
        {
            lookInput = context.ReadValue<Vector2>();
            lookInput = lookInput.sqrMagnitude > 0.01f ? lookInput : Vector2.zero;
        }

        private float StickInputToAngle(Vector2 input)
        {
            return Mathf.Atan2(input.x, input.y) * Mathf.Rad2Deg;
        }

        private void ClampYRotation(float direction) // +1 = up / 1 = down
        {
            if (direction == 0) return;
            float newX = transform.localEulerAngles.x;
            if (newX < higherX && newX > lowerX)
            {
                newX = direction > 0 ? higherX : lowerX;
            }

            if (newX != transform.localEulerAngles.x)
                transform.localEulerAngles = new Vector3(newX, transform.localEulerAngles.y, transform.localEulerAngles.z);
        }

        public void SwapVersion(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                version2 = !version2;
                _logicV1.SetActive(!version2);
                _logicV2.SetActive(version2); 
            }
        }

        public void SwapGizmo(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                _gizmoV1.SetActive(!_gizmoV1.activeSelf);
                _gizmoV2.SetActive(!_gizmoV2.activeSelf); 
            }
        }

        public void LightUp(InputAction.CallbackContext context)
        {
            if(context.started)
            {
                RenderSettings.ambientIntensity += 1;
                RenderSettings.ambientIntensity = Mathf.Clamp(RenderSettings.ambientIntensity, 0, 15);
                Debug.Log("Light : " + RenderSettings.ambientIntensity);
            }
        }

        public void LightDown(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                RenderSettings.ambientIntensity -= 1;
                RenderSettings.ambientIntensity = Mathf.Clamp(RenderSettings.ambientIntensity, 0, 15);
                Debug.Log("Light : " + RenderSettings.ambientIntensity);
            }
        }

        public void LookBack(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                lookingBack = true;
                lookingBackTime = Time.time;
            }
            else if (context.canceled)
            {
                lookingBack = false;
                transform.localEulerAngles = new Vector3(0, 0, 0);
            }
        }
    }

}