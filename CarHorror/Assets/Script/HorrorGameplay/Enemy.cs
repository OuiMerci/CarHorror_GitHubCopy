using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using Imported.Outline;

namespace CarHorror.Gameplay
{
    public class Enemy : MonoBehaviour, ITarget
    {
        Transform ITarget.HitLocation => transform;
        //private Outline _outline;

        private void Start()
        {
            //_outline = GetComponent<Outline>();
            //_outline.enabled = false;
        }

        public void ApplyHit()
        {
            Debug.Log(gameObject.name +  " -> I am being hit !!");
        }

        public void SetTargetted(bool targetted)
        {
            //_outline.enabled = targetted;
        }
    }

}