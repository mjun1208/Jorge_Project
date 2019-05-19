using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class NotJorge : MonoBehaviour
{

    private GameObject Player;
    private NavMeshAgent nav;
    private Animator anime; 
    //private Transform Pos;  

    //NavMeshAgent Ang;

    // Start is called before the first frame update
    void Start()
    {
        Player = GameObject.FindGameObjectWithTag("Player");
        nav = GetComponent<NavMeshAgent>();
        anime = GetComponent<Animator>();
    }

    // Update is called once per frame
    void Update()
    {
       nav.SetDestination(Player.transform.position);
       AnimeUpdate();
    }

    void AnimeUpdate()
    {
        if (nav.destination != transform.position)
            anime.SetBool("Move", true);
        else
            anime.SetBool("Move", false);
    }
}
