using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AudioControl : MonoBehaviour
{
    public AudioClip StartBGM;
    public AudioClip Explosion;
    public AudioClip EndBGM;

    AudioSource audio;
    // Start is called before the first frame update
    void Start()
    {

        audio = GetComponent<AudioSource>();
      //  SoundManager("StartBGM");
    }

   public  void SoundManager(string audioName)
    {

        if (audioName == "Explosion")
        {//explosion
            audio.PlayOneShot(Explosion);
        }

        if (audioName == "StartBGM")
        {//sparkexplosion
            audio.PlayOneShot(StartBGM);
        }

        if (audioName == "EndBGM")
        {
            audio.PlayOneShot(EndBGM);
        }
    }
}
