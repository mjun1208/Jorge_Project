using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class JorgeTrigger : MonoBehaviour
{
    public GameObject NotJorge;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    private void OnTriggerExit(Collider other)
    {
        GameObject.Destroy(NotJorge);
        GameObject.Destroy(gameObject);
    }
}
