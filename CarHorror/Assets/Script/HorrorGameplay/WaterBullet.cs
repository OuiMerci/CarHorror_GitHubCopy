using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarHorror.Gameplay
{
    public class WaterBullet : MonoBehaviour
    {
        [SerializeField] private float _lifetime;
        [SerializeField] private float _gravityUp;
        [SerializeField] private GameObject _model;
        [SerializeField] private Rigidbody _rb;
        [SerializeField] private System.Action<WaterBullet> _destroyCallback;

        float spawnTime;

        void Update()
        {
            if (_lifetime + spawnTime < Time.time)
            {
                _destroyCallback.Invoke(this);
            }
        }

        public void Initialize(Transform p, float impulse, Vector3 baseVelocity, System.Action<WaterBullet> destroyCB, bool showModel = false)
        {
            // Reset
            _rb.velocity = baseVelocity;
            _rb.angularVelocity = Vector3.zero;
            spawnTime = Time.time;
            
            // Copy parent transform 
            transform.position = p.position;
            transform.rotation = p.rotation;
            
            // Set callback
            _destroyCallback = destroyCB;

            // Add impulse
            _rb.AddForce(transform.forward * impulse, ForceMode.Impulse);

            // Debug
            _model.SetActive(showModel);
        }

        private void FixedUpdate()
        {
            _rb.AddForce(Vector3.up * _gravityUp, ForceMode.Acceleration);
        }

        private void OnCollisionEnter(Collision collision)
        {
            _destroyCallback.Invoke(this);
        }
    }
}
