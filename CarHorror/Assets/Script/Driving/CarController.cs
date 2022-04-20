// Still experimental - Refactor properly once playability is statisfying

using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using DG.Tweening;

namespace PM.ArcadeDriving
{
    public class CarController : MonoBehaviour
    {
        public HorrorCarInputs carInputs;
        public bool limitFPS;

        [SerializeField] private Rigidbody sphereRB;
        [SerializeField] private Rigidbody carRB;
        [SerializeField] private GameObject carModel;
        [SerializeField] private LayerMask GroundLayer;
        [SerializeField] private bool isOnGravityZone;
        [SerializeField] private float fwdSpeed;
        [SerializeField] private float reverseSpeed;
        [SerializeField] private float turnSpeed;
        [SerializeField] private float reverseTurnSpeed;
        [SerializeField] private float noMoveInputTurnSpeed;
        [SerializeField] private float startMovingThreshold;
        [SerializeField] private float velocityToForwardLerpSpeed;
        [SerializeField] private float airborneExtraGravity;
        [SerializeField] private float airDrag;
        [SerializeField] private float groundAlignSpeed;
        [SerializeField] private float modelSteering;
        [SerializeField] private float modelSteeringTime;
        [SerializeField] private float driftSteeringRatio;

        private bool isMov;
        private bool isDrifting;
        private int driftDirection;
        private bool isJumping;
        private float accelerateInput;
        private float brakeInput;
        private float moveInput;
        private float turnInput;
        private bool isGrounded;
        private float groundDrag;

        public float MovementMagnitude => new Vector2(sphereRB.velocity.x, sphereRB.velocity.z).magnitude;
        public bool IsMoving => MovementMagnitude > startMovingThreshold;

        void Start()
        {
            if (limitFPS)
                Application.targetFrameRate = 60;

            sphereRB.transform.parent = null;
            carRB.transform.parent = null;
            groundDrag = sphereRB.drag;
        }

        void Update()
        {
            var vAxis = moveInput = (accelerateInput - brakeInput);

            // Set speeds
            var moveSpeed = moveInput > 0 ? fwdSpeed : reverseSpeed;
            var tmpTurnSpeed = moveInput == 0 ? noMoveInputTurnSpeed : moveInput > 0 ? turnSpeed : reverseTurnSpeed;

            //apply speed
            moveInput *= moveSpeed;

            // Car postion follows the sphere's
            transform.position = sphereRB.transform.position;

            // Check velocity
            var rbMagnitude = new Vector2(sphereRB.velocity.x, sphereRB.velocity.z).normalized.magnitude;
            var dotProduct = Vector3.Dot(transform.forward.normalized, sphereRB.velocity.normalized);
            rbMagnitude *= dotProduct > 0 ? 1 : -1;

            // Adjust Rotation
            if (IsMoving)
            {
                var finalTurnInput = isDrifting ? GetRemappedDriftControl() : turnInput;

                var rotationVector = new Vector3(0, finalTurnInput * tmpTurnSpeed * rbMagnitude * Time.deltaTime, 0);
                transform.rotation = Quaternion.Euler(transform.rotation.eulerAngles + rotationVector);
            }

            // Ground check Raycast
            isGrounded = Physics.Raycast(transform.position, -transform.up, out RaycastHit hit, maxDistance: 1, GroundLayer);

            // Rotate car according to ground
            var rotationTarget = Quaternion.FromToRotation(transform.up, hit.normal) * transform.rotation;
            transform.rotation = Quaternion.Slerp(transform.rotation, rotationTarget, groundAlignSpeed * Time.deltaTime);

            // Check Ground Type
            isOnGravityZone = isGrounded && hit.collider.gameObject.tag == "GravityGround";

            // Update drag
            sphereRB.drag = isGrounded ? groundDrag : airDrag;

            RotateModel();
        }

        private void FixedUpdate()
        {
            if (isGrounded)
            {
                if (moveInput != 0)
                {
                    Vector3 accDirection = isDrifting ? driftDirection * -carModel.transform.forward : -carModel.transform.right;

                    // apply input force
                    sphereRB.AddForce(accDirection * moveInput, ForceMode.Acceleration);
                }
                else if (IsMoving)
                {
                    ApplyNoAccelerationRotation();
                }
            }
            else
            {
                // add extra gravity
                ApplyAirborneGravity();
            }

            carRB.MoveRotation(transform.rotation);
            
        }

        private void ApplyAirborneGravity()
        {
            if (isOnGravityZone)
                sphereRB.AddForce(transform.up * -airborneExtraGravity);
            else
                sphereRB.AddForce(Vector3.up * -airborneExtraGravity);
        }

        private void ApplyNoAccelerationRotation()
        {
            //get tmp vector between forward and velovity
            var tmpVector3 = Vector3.Lerp(sphereRB.velocity.normalized, transform.forward.normalized, velocityToForwardLerpSpeed);

            // no input, but redirect the remaining velocity to transform.forward
            var mag = sphereRB.velocity.magnitude;
            sphereRB.velocity = tmpVector3 * mag;
        }

        private void CheckStartDrift()
        {
            if (isGrounded && !isJumping) // Mettre un cooldown sur le saut
            {
                // Jump movement
                isJumping = true;
                carModel.transform.DOComplete();
                var jumpTween = carModel.transform.DOPunchPosition(transform.up * .2f, .3f, 5, 1);
                jumpTween.onComplete += StartDrifting;
            }
        }
        
        private void CheckEndDrift()
        {
            if (isDrifting)
            {
                isDrifting = false;
            }
        }

        private void StartDrifting()
        {
            isJumping = false;

            if(turnInput != 0 && moveInput != 0)
            {
                isDrifting = true;
                driftDirection = turnInput > 0 ? 1 : -1;
                Debug.Log("start drifting");
            }
        }

        private float GetRemappedDriftControl() // change stick input from -1/1 to 0/2 or -2/0
        {
            var result = driftDirection > 0 ? turnInput + 1 : turnInput - 1;
            Debug.Log("result = " + result);
            return result * driftSteeringRatio;
        }

        // The car model has been rotated 90d to the left to avoid a gimbal lock issue
        private void RotateModel()
        {
            if (!isDrifting)
            {
                carModel.transform.localEulerAngles = Vector3.Lerp(carModel.transform.localEulerAngles, new Vector3(0, 90 + (turnInput * modelSteering), carModel.transform.localEulerAngles.z), modelSteeringTime);
            }
            else
            {
                float control = GetRemappedDriftControl();
                carModel.transform.localEulerAngles = Vector3.Lerp(carModel.transform.localEulerAngles, new Vector3(0, 90 + (GetRemappedDriftControl() * modelSteering), carModel.transform.localEulerAngles.z), modelSteeringTime);
            }
        }

        #region Input Events
        public void UpdateAcceleration(InputAction.CallbackContext context)
        {
            accelerateInput = context.ReadValue<float>();
        }

        public void UpdateBrake(InputAction.CallbackContext context)
        {
            brakeInput = context.ReadValue<float>();
        }

        public void UpdateSteer(InputAction.CallbackContext context)
        {
            turnInput = context.ReadValue<Vector2>().x;
        }

        public void OnDriftInput(InputAction.CallbackContext context)
        {
            if (context.started)
            {
                CheckStartDrift();
            }
            else if (context.canceled)
            {
                CheckEndDrift();
            }
        } 
        #endregion

        [ContextMenu("reset Car")]
        public void ResetCar()
        {
            transform.eulerAngles = Vector3.zero;
            sphereRB.velocity = Vector3.zero;
        }
    }
}