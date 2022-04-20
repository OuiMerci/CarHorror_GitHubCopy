using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using PMExtensions;

namespace CarHorror.Gameplay
{
    public class WaterShooter : MonoBehaviour
    {

        [SerializeField] private WaterBullet bullet;
        [SerializeField] private Transform waterParent;
        [SerializeField] private ParticleSystem waterFX;
        [SerializeField] private float impulse;
        [SerializeField] private float spawnDelay;
        [SerializeField] private bool permaShoot;
        [SerializeField] private Rigidbody _carRb;

        private float lastSpawn;
        private bool _isShooting;
        private PMOPool<WaterBullet> bulletPool;
        private bool debugCollider;

        private void Start()
        {
            bulletPool = new PMOPool<WaterBullet>(bullet, 200, 1000, transform);
        }

        // Update is called once per frame
        void Update()
        {
            Debug.DrawRay(transform.position, transform.forward, Color.green);

            if (_isShooting || permaShoot)
            {
                if (lastSpawn + spawnDelay < Time.time)
                {
                    SpawnBullet();
                }
            }
        }

        void SpawnBullet()
        {
            var water = bulletPool.GetFromQueue();
            water.Initialize(transform, impulse, _carRb.velocity, bulletPool.AddToPool, debugCollider);
            water.transform.parent = waterParent;
            lastSpawn = Time.time;
        }

        public void OnShootButton(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                _isShooting = true;
                waterFX.Play();
            }
            else if (context.canceled)
            {
                _isShooting = false;
                waterFX.Stop();
            }
        }

        public void OnColliderDebugButton(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                debugCollider = !debugCollider;
            }
        }
    }
}
