using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AntCave : MonoBehaviour
{
    private Vector3 AntSpawn;
    public GameObject AntPrefab;
    // Start is called before the first frame update
    void Start()
    {
        StartCoroutine(SpawnAnt());
    }

    // Update is called once per frame
    void Update()
    {
    }

    IEnumerator SpawnAnt()
    {
        AntSpawn = transform.position;
        Instantiate(AntPrefab, AntSpawn, transform.rotation);
        yield return new WaitForSeconds(2);
        StartCoroutine(SpawnAnt());
    }
}
