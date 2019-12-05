using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FindObj : MonoBehaviour
{
    RaycastHit hit;

    float Max = 15;
    // Start is called before the first frame update
    void Start()
    {

    }

    // Update is called once per frame
    void Update()
    {
        Debug.DrawRay(transform.position, transform.forward * Max, Color.red, 0.3f);
        if (Physics.Raycast(transform.position, transform.forward, out hit, Max))
        {
            if (hit.transform.tag.Equals("Rock"))
            {
                Debug.Log(hit.transform.tag);
            }
        }

    }
}
