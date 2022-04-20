using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarHorror.Gameplay
{
    public class PimpomLights : MonoBehaviour
    {
        public bool IsOn;// { get; set;}
        [SerializeField] private GameObject _leftLight;
        [SerializeField] private GameObject _rightLight;
        [SerializeField] private float _switchDelay;

        private float _lastSwitch;

        // Update is called once per frame
        void Update()
        {
            if(IsOn && _lastSwitch + _switchDelay < Time.time)
            {
                SwitchLights();
            }
        }

        private void SwitchLights()
        {
            _lastSwitch = Time.time;
            _leftLight.SetActive(!_leftLight.activeSelf);
            _rightLight.SetActive(!_leftLight.activeSelf);
        }
    }

}