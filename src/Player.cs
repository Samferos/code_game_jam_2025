using System.Data;
using System.Linq;
using System.Net;
using System.Runtime.Serialization;
using Godot;

partial class Player : Character
{
    private AnimatedSprite2D SpriteSheet;

    [Signal]
    public delegate void BoostEventHandler();

    [Export]
    public CollisionShape2D StandingCollision;
    [Export]
    public CollisionShape2D CrouchingCollision;
    [Export]
    public RayCast2D CrouchHolder; // This sounds so wrong

    [ExportGroup("Abilities")]
    [Export]
    public PackedScene BaseAttack;

    private bool HasBoost;
    private bool IsCrouching;

    public override void _Ready()
    {
        SpriteSheet = (AnimatedSprite2D)GetChildren().First((Node node) => { return node is AnimatedSprite2D; });
        base._Ready();
    }

    public override void _Process(double delta)
    {
        // Animation Transitions !
        // Here we check when specific non-looping animations
        // end, and we switch the corresponding animation
        // looping section when it has reached its end.
        if (SpriteSheet.Animation == "start_falling" && !SpriteSheet.IsPlaying())
        {
            SpriteSheet.Play("falling");
        }
        else if (SpriteSheet.Animation == "start_crouching" && !SpriteSheet.IsPlaying())
        {
            SpriteSheet.Play("crouching");
        }
        // Otherwise we set the animations based on the current action and
        // the previous action.
        else
        {
            if (IsCrouching)
            {
                if (CurrentAction == Action.Idling && SpriteSheet.Animation != "crouching")
                {
                    if (SpriteSheet.Animation == "crouching_strafe")
                    {
                        SpriteSheet.Play("crouching");
                    }
                    else
                    {
                        SpriteSheet.Play("start_crouching");
                    }
                }
                else if (CurrentAction == Action.Moving)
                {
                    SpriteSheet.Play("crouching_strafe");
                }
            }
            else
            {
                if (CurrentAction == Action.Falling && SpriteSheet.Animation != "falling")
                {
                    SpriteSheet.Play("start_falling");
                }
                else
                {
                    SpriteSheet.Play(CurrentAction.Name);
                }
            }
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

        if (IsOnFloor())
        {
            HasBoost = true;
        }

        if (Input.IsActionJustPressed("attack"))
        {
            Attack attack = (Attack)BaseAttack.Instantiate().GetNode(".");
            var attackDirection = direction.Normalized() * 10.0f;
            if (attackDirection.IsZeroApprox())
            {
                attackDirection = (Facing == Direction.LEFT ? Vector2.Left : Vector2.Right) * 10.0f;
            }
            LaunchAttack(attack, attackDirection);
        }

        if (IsCrouching)
        {
            Move(horizontalDirection / 2.0f);
        }
        else
        {
            Move(horizontalDirection);
        }

        if (Input.IsActionPressed("move_down") && IsOnFloor())
        {
            StandingCollision.Disabled = true;
            CrouchingCollision.Disabled = false;
            IsCrouching = true;
        }
        else if (!CrouchHolder.IsColliding())
        {
            StandingCollision.Disabled = false;
            CrouchingCollision.Disabled = true;
            IsCrouching = false;
        }

        if (Input.IsActionJustPressed("jump") && !CrouchHolder.IsColliding())
        {
            Jump();
        }
        if (Input.IsActionJustReleased("jump"))
        {
            StopJumping();
        }

        if (Input.IsActionJustPressed("boost") && HasBoost && !direction.IsZeroApprox())
        {
            ApplyForce((direction + Vector2.Up * 0.3f).Normalized() * JumpImpulse * 2.0f, false);
            HasBoost = false;
            CurrentAction = Action.Jumping;
            EmitSignal(SignalName.Boost);
        }

        // Let character handle the movement.
        base._PhysicsProcess(delta);
    }
}