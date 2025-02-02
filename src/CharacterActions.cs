using Godot;

public partial class Character : CharacterBody2D
{
	/// <summary>
	/// Represents the current action the character is doing.
	/// (on the ground, air, moving, wallsliding etc.)
	/// </summary>
	protected class Action
	{
		/// <summary>
		/// The name of the action.
		/// Can be used in correspondance with the animation name.
		/// </summary>
		public string Name;

		/// <summary>
		/// Part of default action sets. 
		/// Idling action.
		/// </summary>
		public readonly static Action Idling = new("idling");
		public readonly static Action Moving = new("moving");
		public readonly static Action Jumping = new("jumping");
		public readonly static Action Falling = new("falling");
		public readonly static Action WallSliding = new("wall_sliding");

		public Action(string name)
		{
			Name = name;
		}
	}
}