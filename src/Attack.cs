using System.Data;
using System.Linq;
using System.Threading.Tasks;
using Godot;

public partial class Attack : Area2D
{
	[Export]
	public bool SelfDamage = false;
	[Export]
	public bool CancelOnOtherBody = true;
	[Export]
	public bool Rotates = true;
	[Export]
	public bool Flips = true;
	[Export]
	public int MaxHits = 1;
	[Export]
	public float AttackMult = 1f;
	[Export]
	public bool SpawnGlobal = false; // Decides whether to spawn the attack under the character or world.
	[Export]
	public Vector2 Velocity = Vector2.Zero;
	[Export]
	public Vector2 Acceleration = Vector2.Zero;
	[Export]
	public Vector2 Knockback = Vector2.Zero;
	[Export]
	public Vector2 SelfKnockback = Vector2.Zero; // Will not be applied in the case of self damage.
	/// <summary>
	/// Avoids the attack from disappearing before the
	/// animation ends.
	/// </summary>
	[Export]
	public bool AwaitAnimation = false;
	public Character owner;

	/// <summary>
	/// Sent went the attack hits for the last time
	/// before getting freed.
	/// </summary>
	[Signal]
	public delegate void LastHitEventHandler();

	public override void _Ready()
	{
		BodyEntered += (body) =>
		{
			if (body is Character)
			{
				if (SelfDamage && body == owner)
				{
					owner.DealDamageTo(owner, AttackMult);
					owner.ApplyForce(Knockback.Rotated(Rotation));
					MaxHits--;
				}
				else if (body != owner)
				{
					owner.DealDamageTo(body as Character, AttackMult);
					(body as Character).ApplyForce(Knockback.Rotated(Rotation));
					owner.ApplyForce(SelfKnockback.Rotated(Rotation));
					MaxHits--;
				}
			}
			else if (CancelOnOtherBody)
			{
				MaxHits = 0;
			}
			if (MaxHits <= 0)
			{
				EmitSignal(SignalName.LastHit);
				QueueFree();
			}
		};
	}

	public void Flip()
	{
		var SpriteSheet = GetChildren().FirstOrDefault((child) => { return child is Sprite2D || child is AnimatedSprite2D; });
		SpriteSheet?.Set("flip_v", true);
	}

	public override void _PhysicsProcess(double delta)
	{
		Translate(Velocity.Rotated(Rotation));
		Velocity += Acceleration;
		base._PhysicsProcess(delta);
	}

	public void Cancel()
	{
		if (AwaitAnimation)
		{
			var SpriteSheet = (AnimatedSprite2D)GetChildren().FirstOrDefault((child) => { return child is AnimatedSprite2D; });
			if (SpriteSheet.IsPlaying())
			{
				//await ToSignal(SpriteSheet, AnimatedSprite2D.SignalName.AnimationFinished);
			}
		}
		EmitSignal(SignalName.LastHit);
		QueueFree();
	}
}
