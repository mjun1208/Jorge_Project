using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NotJorge : MonoBehaviour
{

    private GameObject Player;
    private NavMeshAgent nav;
    private Animator anime;
    private Vector3 OldPos;

    private SphereCollider Trigger;
    //private Transform Pos;  

    //NavMeshAgent Ang;

    // Start is called before the first frame update
    void Start()
    {
        Player = GameObject.FindGameObjectWithTag("Player");
        nav = GetComponent<NavMeshAgent>();
        anime = GetComponent<Animator>();

        anime.SetBool("Move", false);
    }

    // Update is called once per frame
    void Update()
    {
        AnimeUpdate();
    }


    void AnimeUpdate()
    {
        if (nav.enabled)
            anime.SetBool("Move", true);
        else
            anime.SetBool("Move", false);
    }

    void NavUpdate()
    {
        nav.enabled = true;
        nav.SetDestination(Player.transform.position);
      
    }


    private void OnTriggerStay(Collider other)
    {
        if (other.gameObject.tag == "Player")
            NavUpdate();
        else
            return;
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Player")
            nav.enabled = false;
        else
            return;
    }
}
