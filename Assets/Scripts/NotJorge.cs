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

       AnimeUpdate();


        if (Vector2.Distance(this.transform.position, Player.transform.position) < 20f)
        {
            nav.enabled = true;
            nav.SetDestination(Player.transform.position);
        }
        else
            nav.enabled = false;

        OldPos = transform.position;
        //Debug.Log(Vector2.Distance(this.transform.position, Player.transform.position));

    }

    void AnimeUpdate()
    {
        if (nav.enabled)
            anime.SetBool("Move", true);
        else
            anime.SetBool("Move", false);
    }

}
