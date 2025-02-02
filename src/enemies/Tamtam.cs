using System.Linq;
using Godot;

public partial class Tamtam : Enemy
{
    AnimatedSprite2D SpriteSheet;

    float Alternate = 2.0f;
    int direction = -1;

    public override void _Ready()
    {
        SpriteSheet = (AnimatedSprite2D)GetChildren().FirstOrDefault((child) => { return child is AnimatedSprite2D; });
        SpriteSheet?.Play("walking");
        var Bumper = (Area2D)GetChildren().FirstOrDefault((child) => { return child is Area2D; });
        Bumper.BodyEntered += (body) =>
        {
            if (body is Player)
            {
                (body as Player).ApplyForce((body.Position - Position) * 2.5f, false);
            }
        };
        base._Ready();
    }

    public override void _PhysicsProcess(double delta)
    {
        Alternate -= (float)delta;
        if (Alternate <= 0)
        {
            Alternate = 2.0f;
            direction *= -1;
            SpriteSheet.FlipH = !SpriteSheet.FlipH;
        }
        Move(direction);
        base._PhysicsProcess(delta);
    }
}