using Godot;

public partial class BotAI : CharacterBody3D
{
	[Export]
	public NodePath PlayerPath { get; set; }

	[Export]
	public float Speed { get; set; } = 4.5f;

	[Export]
	public float ChaseRadius { get; set; } = 40.0f;

	[Export]
	public float StoppingDistance { get; set; } = 2.0f;

	private Node3D player;

	public override void _Ready()
	{
		player = GetNodeOrNull<Node3D>(PlayerPath);
		if (player == null)
		{
			foreach (var node in GetTree().GetNodesInGroup("player"))
			{
				if (node is Node3D found)
				{
					player = found;
					break;
				}
			}
		}
	}

	public override void _PhysicsProcess(double delta)
	{
		if (player == null)
			return;

		var targetPos = player.GlobalTransform.Origin;
		var direction = targetPos - GlobalTransform.Origin;
		var distance = direction.Length();
		if (distance > ChaseRadius || distance <= StoppingDistance)
		{
			Velocity = Vector3.Zero;
			MoveAndSlide();
			return;
		}

		direction = direction.Normalized();
		Velocity = direction * Speed;
		MoveAndSlide();

		LookAt(targetPos, Vector3.Up);
	}
}
