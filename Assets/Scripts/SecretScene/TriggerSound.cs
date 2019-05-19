using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TriggerSound : MonoBehaviour
{
    public GameObject JorgeDuple;
    // Start is called before the first frame update
    void Start()
    {
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        Destroy(JorgeDuple);
        GameObject.Find("SoundManager").GetComponent<AudioControl>().SoundManager("Explosion");
        GameObject.Find("SoundManager").GetComponent<AudioControl>().SoundManager("EndBGM");
        Destroy(gameObject);
    }
}
