using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Chaser : MonoBehaviour
{
    public Transform[] destinations;
    public int nextDest;
    public NavMeshAgent navAgent;
    public float nextDestDelay;
    public float nextDestTime = -200;

    // Update is called once per frame
    void Update()
    {
        if(nextDestTime + nextDestDelay < Time.time)
        {
            GoToNextDest();
        }
    }

    private void GoToNextDest()
    {
        navAgent.SetDestination(destinations[nextDest].position);
        nextDest = nextDest + 1 >= destinations.Length ? 0 : nextDest+1;
        nextDestTime = Time.time;
    }
}
