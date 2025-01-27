using System.Data;
using System.Linq;
using System.Runtime.Serialization;
using Godot;

partial class Player : Character
{
    private AnimatedSprite2D SpriteSheet;

    private bool HasBoost;

    public override void _Ready()
    {
        SpriteSheet = (AnimatedSprite2D)GetChildren().First((Node node) => { return node is AnimatedSprite2D; });
        base._Ready();
    }

    public override void _Process(double delta)
    {
        switch (CurrentAction)
        {
            default:
            case Action.IDLING:
                SpriteSheet.Play("idle");
                break;
            case Action.WALKING:
                SpriteSheet.Play("walking");
                break;
            case Action.WALL_SLIDING:
                SpriteSheet.Play("wall_sliding");
                break;
            case Action.FALLING:
                // Kinda messy
                // [TODO] Simplify this shit
                if ((SpriteSheet.Animation == "start_falling" && !SpriteSheet.IsPlaying()) || SpriteSheet.Animation == "falling")
                {
                    SpriteSheet.Play("falling");
                }
                else
                {
                    SpriteSheet.Play("start_falling");
                }
                break;
            case Action.JUMPING:
                SpriteSheet.Play("jumping");
                break;
        }

        switch (Facing)
        {
            default:
            case Direction.RIGHT:
                SpriteSheet.FlipH = false;
                break;
            case Direction.LEFT:
                SpriteSheet.FlipH = true;
                break;
        }

        base._Process(delta);
    }

    public override void _PhysicsProcess(double delta)
    {
        Vector2 direction = Input.GetVector("move_left", "move_right", "move_up", "move_down");
        float horizontalDirection = Input.GetAxis("move_left", "move_right");

        Move(horizontalDirection);

        if (IsOnFloor())
        {
            HasBoost = true;
        }

        if (Input.IsActionJustPressed("jump"))
        {
            Jump();
        }
        if (Input.IsActionJustReleased("jump"))
        {
            StopJumping();
        }
        if (Input.IsActionJustPressed("boost") && HasBoost && !direction.IsZeroApprox())
        {
            ApplyForce(direction * JumpImpulse * 2.0f, false);
            HasBoost = false;
        }

        // Let character handle the movement.
        base._PhysicsProcess(delta);
    }
}