using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class PosOutline : MonoBehaviour {
    [ColorUsage(true, true)]
    public Color outlineColor;

    [FormerlySerializedAs("outline")] [Range(0.0f, 1.0f)]
    public float outlineWidth = 0.0f;

    private Material _mat;
    private static readonly int OutLineColor = Shader.PropertyToID("_OutLineColor");
    private static readonly int OutLineWidth = Shader.PropertyToID("_OutLineWidth");

    private void Awake() {
        _mat = GetComponent<MeshRenderer>().material;
    }


    private void Update() {
   
        _mat.SetColor(OutLineColor, outlineColor);
        _mat.SetFloat(OutLineWidth, outlineWidth);
    }
}