using Godot;
using Godot.NativeInterop;
using System;

public partial class Platform : TileMapLayer
{
    private float FixedPosition;

    public override void _Ready()
    {
        FixedPosition = Position.Y;
        var area = GetNode<Area2D>("StepOnArea");
        area.BodyEntered += (body) =>
        {
            if (body is Character)
            {
                var tween = CreateTween();
                tween.SetEase(Tween.EaseType.Out);
                tween.SetTrans(Tween.TransitionType.Sine);
                tween.TweenProperty(this, "position:y", FixedPosition + 5.0f, 0.2f);
                tween.Play();
            }
        };
        area.BodyExited += (body) =>
        {
            if (body is Character)
            {
                var tween = CreateTween();
                tween.SetEase(Tween.EaseType.In);
                tween.SetTrans(Tween.TransitionType.Sine);
                tween.TweenProperty(this, "position:y", FixedPosition, 0.2f);
                tween.Play();
            }
        };
        base._Ready();
    }
}