using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class AnteaterMovement : MonoBehaviour
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
        //StartCoroutine("Movement");

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

        if(state == "Walk")
        {
            if(nav.remainingDistance <= nav.stoppingDistance && !nav.pathPending)
            {
                state = "Idle";
            }
        }
    }

    //IEnumerable 이건 코루틴이 아니였다 IEnumerator 이걸 써야함ㅎㅎ
    
    IEnumerator Movement()
    {


        float dir_X = Random.Range(0f, 18f);
        transform.Rotate(new Vector3(0, 100, 0));

        

        yield return new WaitForSeconds(.5f);
        //코루틴은 다시 시작해줘야함ㅋㅋ;;
        StartCoroutine("Movement");
    }
}
