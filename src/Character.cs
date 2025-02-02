using System;
using System.ComponentModel;
using System.Linq.Expressions;
using System.Runtime.InteropServices;
using Godot;

/// <summary>
/// A Character that lives in the game world with stats and abilities
/// and movement.
/// To call movement functions, override the <c>_PhysicsProcess()</c>
/// function, and preferrably place your calls before <c>base._PhysicsProcess()</c>
/// </summary>
public partial class Character : CharacterBody2D
{
	// Constants
	private const float Ratio = 1_000; // px per m
	private const float RatioSquared = Ratio * Ratio;

	// Variables
	[Export]
	protected float Speed = 3.6f;
	[ExportGroup("Jump Control")]
	[Export]
	protected float JumpImpulse = 10.0f;
	[Export]
	private float JumpAccel = 2.6f;
	[Export]
	private float JumpAccelFalloff = 20.4f;
	[ExportGroup("Air Control")]
	[Export]
	private float AirControl = 0.3f;
	[Export]
	private float AirControlRecovery = 30.7f;
	[Export]
	private float MaxAirControl = 4.0f;
	[Export]
	private float MaxJumpTime = 0.4f;
	[ExportGroup("Movement Abilities")]
	[Export]
	private bool AllowWallJump = true;
	[Export]
	private bool AllowWallSlide = true;

	private bool Jumping = false;
	private float JumpTime;
	private float JumpDeccel;

	private bool WallSliding = false;

	private float CurrentAirControl;

	private Vector2 velocity;
	private float AirDrag = 0.42f;
	private float GroundResistance = 0.3f;

	protected Action CurrentAction;
	protected Direction Facing;

	/// <summary>
	/// The Direction the character is facing.
	/// </summary>
	protected enum Direction
	{
		LEFT,
		RIGHT,
	}

	public override void _Ready()
	{
		JumpTime = MaxJumpTime;
		CurrentAirControl = AirControl;
		JumpDeccel = 0;
		base._Ready();
	}

	/// <summary>
	/// Moves the character in a certain direction.
	/// Negative values move the character left.
	/// Positive values move the character right.
	/// </summary>
	/// <param name="direction">The direction in which to move the character.</param>
	protected void Move(float direction)
	{
		if (IsOnFloor() && !Jumping)
		{
			velocity.X += direction * Speed * Ratio;
			if (direction < 0)
			{
				Facing = Direction.LEFT;
			}
			else if (direction > 0)
			{
				Facing = Direction.RIGHT;
			}
			if (Mathf.IsZeroApprox(direction) || IsOnWall())
			{
				CurrentAction = Action.Idling;
			}
			else
			{
				CurrentAction = Action.Moving;
			}
		}
		else if (IsOnWallOnly() && AllowWallSlide && Mathf.Sign(-GetWallNormal().X) == Mathf.Sign(direction))
		{
			WallSliding = true;
			CurrentAction = Action.WallSliding;
			if (direction < 0)
			{
				Facing = Direction.RIGHT;
			}
			else if (direction > 0)
			{
				Facing = Direction.LEFT;
			}
		}
		else if (CurrentAirControl == AirControl) // Air Control
		{
			float desiredAirControl = direction * Speed * Ratio * CurrentAirControl;
			bool slowingDown = Mathf.Sign(velocity.X) != Mathf.Sign(direction);
			if (Mathf.Abs(velocity.X + desiredAirControl) < MaxAirControl * Ratio || slowingDown)
			{
				velocity.X += desiredAirControl;
			}
		}
	}

	/// <summary>
	/// Makes the character jump.
	/// If <c>StopJumping()</c> is not called, the
	/// character will jump to the max height, or until
	/// it reaches an obstacle (ceiling).
	/// </summary>
	protected void Jump()
	{
		if (Jumping)
		{
			velocity += Vector2.Up * MathF.Max(JumpAccel - JumpDeccel, 0.0f) * Ratio;
		}
		else if (IsOnFloor())
		{
			velocity.Y = -JumpImpulse * Ratio;
			Jumping = true;
			CurrentAction = Action.Jumping;
		}
		else if (AllowWallJump)
		{ // [TODO] Simplify this shit
			var leftCollision = MoveAndCollide(Vector2.Left * 3.0f, testOnly: true);
			var rightCollision = MoveAndCollide(Vector2.Right * 3.0f, testOnly: true);
			if (leftCollision != null)
			{
				velocity = (leftCollision.GetNormal() + Vector2.Up * 0.6f).Normalized() * JumpImpulse * 1.2f * Ratio;
				Jumping = true;
				CurrentAirControl = 0;
				WallSliding = false;
				CurrentAction = Action.Jumping;
				Facing = Direction.RIGHT;
			}
			if (rightCollision != null)
			{
				velocity = (rightCollision.GetNormal() + Vector2.Up * 0.6f).Normalized() * JumpImpulse * 1.2f * Ratio;
				Jumping = true;
				CurrentAirControl = 0;
				WallSliding = false;
				CurrentAction = Action.Jumping;
				Facing = Direction.LEFT;
			}
		}
	}

	/// <summary>
	/// Stops the current jump. The character will stop
	/// adding velocity to his jump.
	/// </summary>
	protected void StopJumping()
	{
		Jumping = false;
		JumpTime = MaxJumpTime;
		JumpDeccel = 0;
	}

	/// <summary>
	/// Applies an arbitrary force to this character.
	/// Can be useful for knockback or bumpers.
	/// If <c>add</c> is set to false, the velocity is
	/// set to the force, instead of adding it.
	/// </summary>
	/// <param name="force">The force to be applied.</param>
	/// <param name="add">If the force should override
	/// the current velocity.</param>
	public void ApplyForce(Vector2 force, bool add = true)
	{
		if (add)
		{
			velocity += force * Ratio;
		}
		else
		{
			velocity = force * Ratio;
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (!IsOnFloor())
		{
			velocity += GetGravity();
			if (WallSliding)
			{
				velocity -= velocity * GroundResistance; // Wall Friction
				CurrentAction = Action.WallSliding;
				WallSliding = false;
			}
			else
			{
				velocity -= velocity.Normalized() * 0.5f * (velocity.LengthSquared() / RatioSquared) * AirDrag; // Air Drag
				CurrentAirControl = Mathf.Lerp(CurrentAirControl, AirControl, (float)delta * AirControlRecovery);
				if (velocity.Y > 0)
				{
					CurrentAction = Action.Falling;
				}
			}
		}
		else
		{
			velocity -= velocity * GroundResistance; // Ground Friction
			CurrentAirControl = AirControl;
		}

		Velocity = velocity * (float)delta;
		MoveAndSlide();
		base._PhysicsProcess(delta);

		if (IsOnCeiling()) // Butt with the ceiling
		{
			StopJumping();
			velocity = velocity.Slide(GetLastSlideCollision().GetNormal());
		}
		if (IsOnWall()) // Butt with the walls
		{
			velocity.X = 0;
		}
		if (IsOnFloor() && Jumping)
		{
			StopJumping();
		}

		if (Jumping)
		{
			JumpTime -= (float)delta;
			JumpDeccel += JumpAccelFalloff * (float)delta;
			Jump();
			if (JumpTime <= 0) { StopJumping(); }
		}
	}
}