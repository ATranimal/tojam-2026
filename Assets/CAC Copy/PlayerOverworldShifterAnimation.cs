using System.Collections;
using System.Collections.Generic;
using StarterAssets;
using UnityEngine;
using UnityEngine.InputSystem;
using DG.Tweening;
using Yarn.Unity;

public class PlayerOverworldShifterAnimation : MonoBehaviour
{
    public static PlayerOverworldShifterAnimation s;


    [SerializeField]
    ThirdPersonController thirdPersonController;

    [SerializeField]
    public bool isFrozen = false;

    [Header("Directional Animation")]
    [SerializeField]
    Animator spriteAnimator;

    [SerializeField]
    Animator spriteShadowAnimator;

    StarterAssetsInputs _input;

    // Animator parameter hashes
    static readonly int AnimMoveX = Animator.StringToHash("MoveX");
    static readonly int AnimMoveY = Animator.StringToHash("MoveY");
    static readonly int AnimSpeed = Animator.StringToHash("Speed");

    void Awake()
    {
        s = this;
    }

    // Start is called before the first frame update
    void Start()
    {
        // SetShifterSprite(playerInfoSO.shifterAvatar);
        _input = GetComponent<StarterAssetsInputs>();
        // Player position restoration is handled by RouteManagerv2.RestorePlayerPosition()
        // to avoid race conditions with BazaarManager initialization
    }

    void Update()
    {
        thirdPersonController.enabled = !isFrozen;
        UpdateDirectionalAnimation();
    }

    void UpdateDirectionalAnimation()
    {
        if (spriteAnimator == null || _input == null) return;

        Vector2 move = _input.move;
        float speed = move.magnitude;

        if (move.x < 0f)
        {
            spriteAnimator.GetComponent<SpriteRenderer>().flipX = true;
            if (spriteShadowAnimator != null)
                spriteShadowAnimator.GetComponent<SpriteRenderer>().flipX = true;
        }
        else if (move.x > 0f)
        {
            spriteAnimator.GetComponent<SpriteRenderer>().flipX = false;
            if (spriteShadowAnimator != null)
                spriteShadowAnimator.GetComponent<SpriteRenderer>().flipX = false;
        }

        spriteAnimator.SetFloat(AnimSpeed, speed);
        if (spriteShadowAnimator != null)
            spriteShadowAnimator.SetFloat(AnimSpeed, speed);

        if (speed > 0.01f)
        {
            spriteAnimator.SetFloat(AnimMoveX, move.x);
            spriteAnimator.SetFloat(AnimMoveY, move.y);
            if (spriteShadowAnimator != null)
            {
                spriteShadowAnimator.SetFloat(AnimMoveX, move.x);
                spriteShadowAnimator.SetFloat(AnimMoveY, move.y);
            }
        }
    }

    void OnTriggerEnter(Collider collider)
    {
    }

    void OnTriggerExit(Collider collider)
    {
    }


    public void Fire(InputAction.CallbackContext context)
    {
        if (!context.started)
        {
            return;
        }
    }

    [YarnCommand("freeze")]
    public void ToggleFreeze(bool frozen = true)
    {
        isFrozen = frozen;
    }
}
