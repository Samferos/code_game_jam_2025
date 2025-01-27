using System;
using Godot;
using Godot.Collections;

// The Character's stats
public partial class Character : CharacterBody2D
{

	[ExportGroup("Abilities & Stats")]
	[Export(PropertyHint.Range, "0,100")]
	protected uint Health = 10;
	[Export(PropertyHint.Range, "0,100")]
	protected uint MaxHealth = 10;
	// uint Mana;
	// uint MaxMana;
	[Export]
	protected uint Attack = 3;
	[Export]
	protected uint Defence = 2;

	protected virtual void Damage(uint amount)
	{
		Health -= (uint)Mathf.Clamp(amount - Defence, 0, Health);
	}

	/// <summary>
	/// Deals damage to another character.
	/// </summary>
	public void DealDamageTo(Character other, float damageMult)
	{
		other.Damage((uint)(Attack * damageMult));
	}

	protected void LaunchAttack(Attack attack, Vector2 offset)
	{
		AddChild(attack);
		attack.owner = this;
		if (attack.Rotates)
		{
			attack.Rotation = offset.Angle();
		}
		if (attack.Flips)
		{
			if (offset.X < 0)
			{
				attack.Flip();
			}
		}
		attack.Translate(offset);
	}
}