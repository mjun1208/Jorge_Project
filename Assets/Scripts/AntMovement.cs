using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AntMovement : MonoBehaviour
{

    private Vector3 movedir;
    private Rigidbody rigid;
    private NavMeshAgent nav;

    private string state = "Idle";


    // Start is called before the first frame update
    void Start()
    {
        rigid = GetComponent<Rigidbody>();
        nav = GetComponentInChildren<NavMeshAgent>();

    }

    // Update is called once per frame
    void Update()
    {
        if (state == "Idle")
        {

            Vector3 randomPos = Random.insideUnitSphere * 100f;
            NavMeshHit navHit;
            NavMesh.SamplePosition(transform.position + randomPos, out navHit, 20f, NavMesh.AllAreas);
            nav.SetDestination(navHit.position);

            state = "Walk";
        }

        if (state == "Walk")
        {
            if (nav.remainingDistance <= nav.stoppingDistance && !nav.pathPending)
            {
                state = "Idle";
            }
        }
    }
}
