using Godot;
using System;

public partial class Enemy : Character
{
    protected override void Damage(uint amount)
    {
        base.Damage(amount);
        if (Health <= 0)
        {
            QueueFree();
        }
    }
}
