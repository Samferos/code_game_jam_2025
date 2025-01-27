using System;
using Godot;

public partial class Attack : Area2D
{
	[Export]
	public bool SelfDamage = false;
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
				}
				else
				{
					owner.DealDamageTo(body as Character, AttackMult);
				}
				MaxHits--;
			}
			if (MaxHits <= 0)
			{
				EmitSignal(SignalName.LastHit);
				QueueFree();
			}
		};
	}

	public override void _PhysicsProcess(double delta)
	{
		Translate(Velocity);
		Velocity += Acceleration;
		base._PhysicsProcess(delta);
	}
}
