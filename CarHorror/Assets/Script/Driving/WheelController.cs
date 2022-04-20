using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PM.ArcadeDriving
{
    public class WheelController : MonoBehaviour
    {
        public GameObject[] Wheels;
        public float RotationSpeed;

        private Animator anim;
        private int goingLeftHash = Animator.StringToHash("GoingLeft");
        private int goingRightHash = Animator.StringToHash("GoingRight");

        // Start is called before the first frame update
        void Start()
        {
            anim = GetComponent<Animator>();
        }

        // Update is called once per frame
        void Update()
        {
            float vAxis = Input.GetAxisRaw("Vertical");
            float hAxis = Input.GetAxisRaw("Horizontal");

            foreach (GameObject w in Wheels)
            {
                w.transform.Rotate(vAxis * RotationSpeed * Time.deltaTime, 0, 0, relativeTo: Space.Self);
            }

            if (hAxis > 0)
            {
                anim.SetBool(goingLeftHash, false);
                anim.SetBool(goingRightHash, true);
            }
            else if (hAxis < 0)
            {
                anim.SetBool(goingLeftHash, true);
                anim.SetBool(goingRightHash, false);
            }
            else
            {
                anim.SetBool(goingLeftHash, false);
                anim.SetBool(goingRightHash, false);
            }
        }
    }

}