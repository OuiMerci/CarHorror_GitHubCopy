using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class HelpScreen : MonoBehaviour
{
    public void OnHelpButton(InputAction.CallbackContext context)
    {
        if (context.started)
        {
            gameObject.SetActive(!gameObject.activeSelf);
        }
    }
}
