using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarHorror.Gameplay
{
    public class WaterHoseTargetFinder : MonoBehaviour
    {
        public ITarget ActiveTarget { get; private set; }
        private PlayerController _player;
        private List<ITarget> Targets = new List<ITarget>();

        public event Action<ITarget> OnActiveTargetChanged;

        private void Start()
        {
            _player = GetComponentInParent<PlayerController>();
        }

        private void OnTriggerEnter(Collider other)
        {
            var t = other.GetComponent<ITarget>();
            if(t != null)
            {
                Targets.Add(t);
                RefreshActiveTarget();
                Debug.Log("Add T " + other.gameObject.name);
            }
        }

        private void OnTriggerExit(Collider other)
        {
            var t = other.GetComponent<ITarget>();
            if (t != null)
            {
                Targets.Remove(t);
                RefreshActiveTarget();
                Debug.Log("Remove T " + other.gameObject.name);
            }
        }

        private void RefreshActiveTarget()
        {
            ITarget closest = GetClosestTarget();
            
            if(ActiveTarget != closest)
            {
                ActiveTarget?.SetTargetted(false); // set previous untargetted
                ActiveTarget = closest;
                OnActiveTargetChanged?.Invoke(ActiveTarget);
                ActiveTarget?.SetTargetted(true); // set current targetted
            }
        }

        private ITarget GetClosestTarget()
        {
            float minDist = float.MaxValue;
            ITarget closest = null;

            foreach(ITarget t in Targets)
            {
                float dist = Vector3.Distance(t.HitLocation.position, _player.transform.position); //use collider extents or hardcoded offset to handle big targets, or maybe just always give prio to the main boss
                if (dist < minDist)
                {
                    closest = t;
                    minDist = dist;
                }
            }

            return closest;
        }
    }

}