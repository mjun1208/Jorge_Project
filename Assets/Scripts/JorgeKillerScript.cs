using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JorgeKillerScript : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        GameObject Ang = GameObject.FindGameObjectWithTag("NotJorge");

        if (Ang != null && Ang.transform.position.y < -500)
        {
            Destroy(Ang);
        }
    }
}
