using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class BloomOutLine : MonoBehaviour
{
     
[SerializeField] public Renderer[] outlineObjects;

            [SerializeField] public Color outlineColor = Color.red;

            [Range(1, 8)] public int downSampleScale = 2; // 降采样比例
            [Range(0, 4)] public int blurIterations = 1; // 高斯模糊迭代次数
            [Range(0.2f, 3.0f)] public float blurSpread = 0.6f; // 高斯模糊
            private Material _outlineMaterial;
            private CommandBuffer _renderCommand;
   
            private const string OutlineShader = "Custom/BloomOutLine";


            private void Awake() {
                _renderCommand = new CommandBuffer {
                    name = "Render Outline"
                };

                _outlineMaterial = new Material(Shader.Find(OutlineShader));
            }

            void OnEnable() {
                // 顺序将渲染任务加入RenderCommand中
                _renderCommand.ClearRenderTarget(true, true, Color.clear);
                for (int i = 0; i < outlineObjects.Length; ++i) {
                    _renderCommand.DrawRenderer(outlineObjects[i], _outlineMaterial, 0, 0);
                }
            }

            void OnDisable() {
                _renderCommand.Clear();
            }

            void OnDestroy() {
                _renderCommand.Clear();
            }

            private void OnRenderImage(RenderTexture source, RenderTexture destination) {
                //1. 绘制颜色
                _outlineMaterial.SetColor("_OutlineColor", outlineColor);
                RenderTexture outlineColorRt = RenderTexture.GetTemporary(Screen.width, Screen.height);
                Graphics.SetRenderTarget(outlineColorRt);
                Graphics.ExecuteCommandBuffer(_renderCommand);
                // 用于测试
                //Graphics.Blit(outlineColorRt, destination);
                //RenderTexture.ReleaseTemporary(outlineColorRt);

                //2. 降采样
                int rtW = Screen.width >> downSampleScale;
                int rtH = Screen.height >> downSampleScale;
                RenderTexture blurRt = RenderTexture.GetTemporary(rtW, rtH);
                blurRt.filterMode = FilterMode.Bilinear;
                Graphics.Blit(outlineColorRt, blurRt);

                //3. 高斯模糊
                RenderTexture blurTemp = RenderTexture.GetTemporary(rtW, rtH);
                for (int i = 0; i < blurIterations; ++i) {
                    _outlineMaterial.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                    // 水平模糊
                    Graphics.Blit(blurRt, blurTemp, _outlineMaterial, 1);
                    // 垂直模糊
                    Graphics.Blit(blurTemp, blurRt, _outlineMaterial, 2);
                }

                // 用于测试
                //Graphics.Blit(blurRt, destination);

                //4. 叠加
                _outlineMaterial.SetTexture("_OutlineColorTex", outlineColorRt);
                _outlineMaterial.SetTexture("_BlurTex", blurRt);
                Graphics.Blit(source, destination, _outlineMaterial, 3);

                RenderTexture.ReleaseTemporary(outlineColorRt);
                RenderTexture.ReleaseTemporary(blurRt);
                RenderTexture.ReleaseTemporary(blurTemp);
            }
        

}
