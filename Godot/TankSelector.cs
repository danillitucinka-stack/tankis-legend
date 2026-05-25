using Godot;
using System.Collections.Generic;
using Godot.Collections;

public partial class TankSelector : Node
{
    [Export]
    public string ConfigPath { get; set; } = "res://Godot/tank_list.json";

    [Export]
    public NodePath PreviewAnchorPath { get; set; }

    [Export]
    public string SaveKey { get; set; } = "selected_tank";

    private Array tankList = new Array();
    private int currentIndex = 0;
    private Node3D currentPreview;
    private string selectedId = string.Empty;
    private const string SaveFile = "user://selected_tank.cfg";

    [Signal]
    public delegate void SelectedTankChangedEventHandler(string selectedId);

    public override void _Ready()
    {
        LoadTankData();
        LoadSavedTank();
        UpdatePreview();
    }

    private void LoadTankData()
    {
        var file = FileAccess.Open(ConfigPath, FileAccess.ModeFlags.READ);
        if (file == null)
        {
            GD.PushError($"TankSelector: не удалось открыть {ConfigPath}");
            return;
        }

        var jsonText = file.GetAsText();
        file.Close();
        var result = JSON.ParseString(jsonText);
        if (result.Error != Error.Ok)
        {
            GD.PushError($"TankSelector: ошибка JSON {result.Error} в {ConfigPath}: {result.ErrorString}");
            return;
        }

        if (result.Result is Array array)
            tankList = array;
    }

    private void LoadSavedTank()
    {
        var cfg = new ConfigFile();
        var err = cfg.Load(SaveFile);
        if (err == Error.Ok)
        {
            selectedId = cfg.GetValue("tank", SaveKey, string.Empty) as string;
            if (!string.IsNullOrEmpty(selectedId))
            {
                currentIndex = 0;
                for (var i = 0; i < tankList.Count; i++)
                {
                    if (tankList[i] is Dictionary item &&
                        item.Get("id", string.Empty) as string == selectedId)
                    {
                        currentIndex = i;
                        break;
                    }
                }
            }
        }
        else
        {
            currentIndex = 0;
        }
    }

    private void SaveSelectedTank()
    {
        if (currentIndex < 0 || currentIndex >= tankList.Count)
            return;

        var item = tankList[currentIndex] as Dictionary;
        if (item == null)
            return;

        selectedId = item.Get("id", string.Empty) as string;
        var cfg = new ConfigFile();
        cfg.Load(SaveFile);
        cfg.SetValue("tank", SaveKey, selectedId);
        cfg.Save(SaveFile);
        EmitSignal(nameof(SelectedTankChanged), selectedId);
    }

    private void UpdatePreview()
    {
        if (currentPreview != null)
        {
            currentPreview.QueueFree();
            currentPreview = null;
        }

        if (tankList.Count == 0)
            return;

        currentIndex = Mathf.Clamp(currentIndex, 0, tankList.Count - 1);
        var item = tankList[currentIndex] as Dictionary;
        if (item == null)
            return;

        var scenePath = item.Get("scene", string.Empty) as string;
        if (string.IsNullOrEmpty(scenePath))
            return;

        var anchor = GetNodeOrNull<Node3D>(PreviewAnchorPath);
        if (anchor == null)
        {
            GD.PushError("TankSelector: preview_anchor_path не задан или не Node3D");
            return;
        }

        var packed = ResourceLoader.Load<PackedScene>(scenePath);
        if (packed == null)
        {
            GD.PushError($"TankSelector: не удалось загрузить сцену танка: {scenePath}");
            return;
        }

        currentPreview = packed.Instantiate() as Node3D;
        if (currentPreview == null)
        {
            GD.PushError($"TankSelector: загруженная сцена не Node3D: {scenePath}");
            return;
        }

        anchor.AddChild(currentPreview);
        currentPreview.Transform = Transform3D.Identity;
        currentPreview.Scale = Vector3.One;
    }

    public void NextTank()
    {
        if (tankList.Count == 0)
            return;

        currentIndex = (currentIndex + 1) % tankList.Count;
        UpdatePreview();
    }

    public void PreviousTank()
    {
        if (tankList.Count == 0)
            return;

        currentIndex = (currentIndex - 1 + tankList.Count) % tankList.Count;
        UpdatePreview();
    }

    public void SelectCurrentTank()
    {
        SaveSelectedTank();
    }

    public string GetSelectedTankScenePath()
    {
        if (currentIndex >= 0 && currentIndex < tankList.Count)
        {
            var item = tankList[currentIndex] as Dictionary;
            return item?.Get("scene", string.Empty) as string ?? string.Empty;
        }

        return string.Empty;
    }
}
