using UnityEngine;
using System.Collections;
using UnityEngine.SceneManagement;

public class CharacterMove : MonoBehaviour
{
    public GameObject BallPrefab;
    public GameObject NotJorgePrefab;

    public float speed = 6.0F;
    public float jumpSpeed = 8.0F;
    public float gravity = 20.0F;
    private Vector3 moveDirection = Vector3.zero;

    private Animator animator;

    //여기부턴 마우스관련 선언
    public float upDownRange = 90;
    public float mouseSensitivity = 2f;
    private float rotLeftRight;
    private float rotUpDown;
    private float verticalRotation = 0f;
    private float verticalVelocity = 0f;
    Vector3 PlayerSpawn;

    private void Start()
    {
        Cursor.lockState = CursorLockMode.Locked;//커서를 중앙으로 잠금
        animator = this.GetComponentInChildren<Animator>();
        animator.SetBool("Move", false);

    }
    void Update()
    {
        //PlayerSpawn = new Vector3(0, 0, transform.position.z + 2);

        //캐릭터 버튼 조작
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            Application.Quit();
        }

        if (Input.GetKeyDown(KeyCode.R))
        {
            if(SceneManager.GetActiveScene().name != "JustBlock")//현재씬이 이거가 아닐때
            Application.LoadLevel(Application.loadedLevel);//R키 씬 재시작
        }

        if (Input.GetMouseButtonDown(0))
        {
            //if (SceneManager.GetActiveScene().name != "JustBlock")//현재씬이 이거가 아닐때
            //    Application.OpenURL("https://www.youtube.com/watch?v=HeOkJplUAAs");

            PlayerSpawn = new Vector3(transform.position.x, transform.position.y + 2, transform.position.z + 3);
            Instantiate(NotJorgePrefab, PlayerSpawn, transform.rotation);
        }

        //if (Input.GetKeyDown(KeyCode.LeftControl))
        //{
        //    if (SceneManager.GetActiveScene().name != "JustBlock")//현재씬이 이거가 아닐때
        //        SceneManager.LoadScene("JustBlock");
        //} 


        FPRotate();//마우스회전

        CharacterController controller = GetComponent<CharacterController>();
        if (controller.isGrounded)
        {

            moveDirection = new Vector3(Input.GetAxis("Horizontal"), 0, Input.GetAxis("Vertical"));
            moveDirection = transform.TransformDirection(moveDirection);


            if (moveDirection != new Vector3(0,0,0))
                animator.SetBool("Move", true);
            else
                animator.SetBool("Move", false);



            if (Input.GetButton("Sprint"))
                moveDirection *= speed * 3f;//스프린트
            else
                moveDirection *= speed;//걍 달리기

            if (Input.GetButton("Jump"))
            {
                moveDirection.y = jumpSpeed;
                Debug.Log("Jumped");
            }

        }
        moveDirection.y -= gravity * Time.deltaTime;
        controller.Move(moveDirection * Time.deltaTime);
    }

    void FPRotate()
    {
        //좌우 회전
        rotLeftRight = Input.GetAxis("Mouse X") * mouseSensitivity;
        transform.Rotate(0f, rotLeftRight, 0f);

        //상하 회전
        verticalRotation -= Input.GetAxis("Mouse Y") * mouseSensitivity;
        verticalRotation = Mathf.Clamp(verticalRotation, -upDownRange, upDownRange);
        Camera.main.transform.localRotation = Quaternion.Euler(verticalRotation, 0f, 0f);
    }
}