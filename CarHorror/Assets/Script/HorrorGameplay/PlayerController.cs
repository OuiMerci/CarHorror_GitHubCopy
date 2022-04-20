using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using Sirenix.OdinInspector;

namespace CarHorror.Gameplay
{
    public class PlayerController : MonoBehaviour
    {
        [SerializeField] private WaterHoseTargetFinder targetFinder;
        [SerializeField] private GameObject waterEffect;
        //[SerializeField] private float maxWaterScale;
        //[SerializeField] private float scaleSpeed;
        //[SerializeField] private WaterFoamController foamController;

        [ShowInInspector][ReadOnly] ITarget _currentTarget;
        private bool _isShooting;

        private void OnEnable()
        {
            targetFinder.OnActiveTargetChanged += OnActiveTargetChanged;
        }

        private void OnDisable()
        {
            targetFinder.OnActiveTargetChanged -= OnActiveTargetChanged;
        }

        private void Update()
        {
            //CheckShooting();
        }

        private void OnActiveTargetChanged(ITarget target)
        {
            _currentTarget = target;

            if (target == null)
            {
                //StopShooting();
            }
        }


        // OLD : test for displaying water as an animated sprite --->
        //private void CheckShooting()
        //{
        //    if(_isShooting)
        //    {
        //        waterEffect.SetActive(true);
        //        ScaleWaterUp();
        //        if(waterEffect.transform.localScale.y <= maxWaterScale)
        //            ApplyShoot();
        //    }
        //    else
        //    {
        //        ScaleWaterDown();
        //    }
        //}

        //private void ApplyShoot()
        //{
        //    //update FX rotation / position
        //    _currentTarget?.ApplyHit();
        //}

        //private void StopShooting()
        //{
        //    // end FX
        //    _currentTarget = null;
        //    //waterEffect.SetActive(false);
        //}


        //public void OnShootButton(InputAction.CallbackContext context)
        //{
        //    if (context.started)
        //    {
        //        _isShooting = true;
        //    }
        //    if(context.canceled)
        //    {
        //        _isShooting = false;
        //        StopShooting();
        //    }
        //}

        //private void ScaleWaterUp()
        //{
        //    if(waterEffect.transform.localScale.y > maxWaterScale)
        //    {
        //        float newY = waterEffect.transform.localScale.y - scaleSpeed * Time.deltaTime;
        //        newY = newY < maxWaterScale ? maxWaterScale : newY;
        //        waterEffect.transform.localScale = new Vector3(waterEffect.transform.localScale.x, newY, waterEffect.transform.localScale.z);
        //    }
        //    else
        //    {
        //        foamController.enabled = true;
        //    }
        //}

        //private void ScaleWaterDown()
        //{
        //    foamController.enabled = false;
        //    if (waterEffect.transform.localScale.y < 0)
        //    {
        //        float newY = waterEffect.transform.localScale.y + scaleSpeed * Time.deltaTime;
        //        newY = newY > 0 ? 0 : newY;
        //        waterEffect.transform.localScale = new Vector3(waterEffect.transform.localScale.x, newY, waterEffect.transform.localScale.z);
        //    }
        //    else
        //    {
        //        waterEffect.SetActive(false);
        //    }
        //}
    }
}