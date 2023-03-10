Shader "Custom/BloomOutLine"
{

    Properties
    {
        _OutlineColor ("Outline Color", color) = (1.0, 0, 0, 1.0)
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize ("Blur Size", float) = 1.0
    }
    SubShader
    {
        Tags
        {
            "RenderType" = "Opaque"
        }

        CGINCLUDE
        #include "UnityCG.cginc"

        fixed4 _OutlineColor;
        sampler2D _MainTex;
        half4 _MainTex_TexelSize;
        float _BlurSize;

        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };

        v2f vertBlurVertical(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[2] = uv - float2(0.0, _MainTex_TexelSize.y * 1.0) * _BlurSize;
            o.uv[3] = uv + float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;
            o.uv[4] = uv - float2(0.0, _MainTex_TexelSize.y * 2.0) * _BlurSize;

            return o;
        }

        v2f vertBlurHorizontal(appdata_img v)
        {
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);

            half2 uv = v.texcoord;

            o.uv[0] = uv;
            o.uv[1] = uv + float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[2] = uv - float2(_MainTex_TexelSize.x * 1.0, 0.0) * _BlurSize;
            o.uv[3] = uv + float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;
            o.uv[4] = uv - float2(_MainTex_TexelSize.x * 2.0, 0.0) * _BlurSize;

            return o;
        }

        fixed4 fragBlur(v2f i) : SV_Target
        {
            float weight[3] = {0.4026, 0.2442, 0.0545};
            fixed3 sum = tex2D(_MainTex, i.uv[0]).rgb * weight[0];

            for (int it = 1; it < 3; it++)
            {
              sum += tex2D(_MainTex, i.uv[it * 2 - 1]).rgb * weight[it];
                sum += tex2D(_MainTex, i.uv[it * 2]).rgb * weight[it];
        
            }

            return fixed4(sum, 1.0);
        }
        ENDCG

        ZTest Always
        Cull Off
        ZWrite Off

        pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            v2f_img vert(appdata_img v)
            {
                v2f_img o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 frag(v2f_img i) : SV_Target
            {
                return fixed4(1, 1, 1, 1);
            }
            ENDCG
        }

        pass
        {
            NAME "GAUSSIAN_BLUR_VERTICAL"

            CGPROGRAM
            #pragma vertex vertBlurVertical
            #pragma fragment fragBlur
            ENDCG
        }

        pass
        {
            NAME "GAUSSIAN_BLUR_HORIZONTAL"

            CGPROGRAM
            #pragma vertex vertBlurHorizontal
            #pragma fragment fragBlur
            ENDCG
        }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragOutline

            sampler2D _BlurTex, _OutlineColorTex;
            half4 _BlurTex_TexelSize, _OutlineColorTex_TexelSize;

            v2f_img vert(appdata_img v)
            {
                v2f_img o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            fixed4 fragOutline(v2f_img i) : SV_Target
            {
                fixed4 scene = tex2D(_MainTex, i.uv);
                fixed4 blur = tex2D(_BlurTex, i.uv);
                fixed4 outlineColor = tex2D(_OutlineColorTex, i.uv);
                fixed lerp = saturate( blur.r-outlineColor.r);


                fixed4 final = scene * (1 - lerp) + _OutlineColor * lerp;
                return final;
            }
            ENDCG
        }
    }
    FallBack off

}