using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace CarHorror.Gameplay
{
    public interface ITarget
    {
        Transform HitLocation { get;}
        void ApplyHit();
        void SetTargetted(bool targetted);
    }

}