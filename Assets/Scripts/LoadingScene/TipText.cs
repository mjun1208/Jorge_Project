using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class TipText : MonoBehaviour
{
    string[] tiptext = new string[20];
    // Start is called before the first frame update
    void Start()
    {
        tiptext[0] = "조지는 사실 모두 다 죽일 수 있습니다.";
        tiptext[1] = "조지는 와칸다에 가본적이 있습니다.";
        tiptext[2] = "사실 여러분이 가지 못하는 구역들도 구현이 되어있습니다. 때론 그런 구역들도 가보실 수 있죠.";
        tiptext[3] = "여러분이 아직 탐방하지 '못한' 구역들이 많습니다.";
        tiptext[4] = "조지의 주 무기는 'SMG-11'입니다.";
        tiptext[5] = "앙기모씨";
        tiptext[6] = "숨겨진 커멘드를 입력하면 새로운 효과가 생길지도..?";
        tiptext[7] = "여러분들은 지금 가본 지역보다 못찾은 지역이 더 많습니다.";
        tiptext[8] = "You made me a, you made me a believer, believer.";
        tiptext[9] = "조지는 게임이 완성되기까지 많은 변확가 있었습니다. 예를 들어.. 지금 달리기 처럼요.";

        tiptext[10] = "태양만세";
        tiptext[11] = "지금도 몇몇프로그래머들은 조지 유니버스를 위해 작업중입니다.";
        tiptext[12] = "맘마미아";
        tiptext[13] = "만약 당신이 생성하지 않은 조지가 당신을 바라보고 있다면 당장 게임을 종료하세요.";
        tiptext[14] = "사실.. 아직 게임이 불안정하여 많은 오류가 있습니다. 생성하지 않은 조지처럼요.";
        tiptext[15] = "조지의 여자친구 조르지아와는 메이플스토리에서 만난 사이입니다.";
        tiptext[16] = "5코스트 3/5 조지, 전투의 함성: 춤을 춥니다.";
        tiptext[17] = "0100100001100101011011000110110001101111";
        tiptext[18] = "여러분이 게임을 즐기고 계실때도 제작자는 게임을 만들고 있는 중입니다.";
        tiptext[19] = "조지 한판 했습니다.... 게임이 안되도 좋지못합니다.";

        int rand = Random.Range(0, 19);
        gameObject.GetComponent<Text>().text = tiptext[rand];

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
