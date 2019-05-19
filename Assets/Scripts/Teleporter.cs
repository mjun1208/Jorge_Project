using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class Teleporter : MonoBehaviour
{

    public string NextScene;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        transform.Rotate(0, 4, 0);
    }

    private void OnTriggerEnter(Collider other)
    {
        LoadingSceneManager.LoadScene(NextScene);
    }
}
