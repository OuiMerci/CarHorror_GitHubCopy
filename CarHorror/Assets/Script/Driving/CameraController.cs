using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PM.ArcadeDriving
{
    public class CameraController : MonoBehaviour
    {
        public Vector3 lookOffset;
        public GameObject Car;
        public CarController CarRef;
        public GameObject Attach;
        public float smoothSpeed;

        private Vector3 prevLook;

        private void Start()
        {
            prevLook = Car.transform.position + lookOffset;
            UpdateCamera();
        }

        void LateUpdate()
        {
            UpdateCamera();
        }

        private void UpdateCamera()
        {
            transform.position = Attach.transform.position;
            var nextLook = Vector3.Lerp(prevLook, Car.transform.position + lookOffset, smoothSpeed * Time.deltaTime);
            transform.LookAt(Car.transform.position + lookOffset);
            prevLook = nextLook;
        }
    }
}