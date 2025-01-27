using System;
using Godot;
using Godot.Collections;

// The Character's stats
public partial class Character : CharacterBody2D
{
	uint Health = 10;
	uint MaxHealth = 10;
	// uint Mana;
	// uint MaxMana;
	uint Attack = 3;
	uint Defence = 2;

	[ExportCategory("Abilities & Stats")]
	[Export]
	public Array<Attack> Abilities;

	private void Damage(uint amount)
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
}