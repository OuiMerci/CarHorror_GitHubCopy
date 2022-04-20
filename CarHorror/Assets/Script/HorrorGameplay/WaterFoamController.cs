using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarHorror.Gameplay
{
    public class WaterFoamController : MonoBehaviour
    {
        public Transform StartPoint;
        public Transform FoamReference;
        public float FoamMaxDist;

        private int allExceptCarLayer = ~(1 << 7); // All layers but Car

        // Update is called once per frame
        void Update()
        {
            if(Physics.Raycast(StartPoint.position, StartPoint.forward, out RaycastHit hit, FoamMaxDist, allExceptCarLayer, queryTriggerInteraction:QueryTriggerInteraction.Ignore))
            {
                FoamReference.position = hit.point;
                FoamReference.gameObject.SetActive(true);
            }
            else
            {
                FoamReference.gameObject.SetActive(false);
            }
        }

        private void OnDisable()
        {
            FoamReference.gameObject.SetActive(false);
        }
    }

}