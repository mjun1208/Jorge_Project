using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class LoadingSceneManager : MonoBehaviour
{
    public static string nextScene;

    [SerializeField]
    Image progressBar;

    private void Start()
    {
        StartCoroutine(LoadScene());
    }

    string nextSceneName;
    public static void LoadScene(string sceneName)
    {
        nextScene = sceneName;
        SceneManager.LoadScene("LoadingScene");
    }

    IEnumerator LoadScene()
    {
        yield return null;

        AsyncOperation op = SceneManager.LoadSceneAsync(nextScene);
        op.allowSceneActivation = false;

        float timer = 0.0f;
        while (!op.isDone)
        {
            yield return null;

            timer += Time.deltaTime;

            if (progressBar.fillAmount > 0)
            {
                Debug.Log("A");
                progressBar.fillAmount -= 0.005f;
            }
            else
            {
                progressBar.fillAmount = 0;
            }
            if (Input.GetKeyDown(KeyCode.Space))
            {
                Debug.Log("B");
                progressBar.fillAmount += 0.05f;
            }

            if (progressBar.fillAmount == 1.0f)
                    op.allowSceneActivation = true;

                //float random = Random.Range(0, 0.05f);
                //Debug.Log("Ang");
                //if (op.progress >= 0.9f)
                //{
                //    progressBar.fillAmount += random; //Mathf.Lerp(progressBar.fillAmount, 1f, timer);
                //
                //    if (progressBar.fillAmount == 1.0f)
                //        op.allowSceneActivation = true;
                //}
                //else
                //{
                //    progressBar.fillAmount += random; //Mathf.Lerp(progressBar.fillAmount, op.progress, timer);
                //    if (progressBar.fillAmount >= op.progress)
                //    {
                //        timer = 0f;
                //    }
                //}
        }
    }
}