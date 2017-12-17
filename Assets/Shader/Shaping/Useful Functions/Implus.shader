Shader "Custom/Shaping/Useful Functions/Implus" 
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)

		_TotalLength ("Total Length", Range(0, 50)) = 1
		_K ("k", Range(0, 3)) = 1
	}


	SubShader 
	{
		Tags 
		{ 
			"RenderType"="Opaque" 
		}
		
		Pass 
		{
			CGPROGRAM

			#pragma vertex vert
			#pragma fragment frag 
			#include "UnityCG.cginc"

			fixed4 _LineColor;

			fixed _TotalLength;
			fixed _K;

			struct vertexOutput
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0; 
			};

			vertexOutput vert(appdata_base input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.texcoord.xy;

				return output;
			}


			// 一般用来表示一个数上升得很快，下降得很慢
			// x 代表横坐标, k 用于控制这个曲线的长度(不是等于曲线长度)
			// 返回值在 (0, 1) 之间
			// 最大值出现在 1/k 处
			// 具体见 : http://www.iquilezles.org/www/articles/functions/functions.htm
			float implus(float k, float x)
			{
				float h = k * x;
				return h * exp(1 - h); 
			}



			float plot(float2 pos, float dest)
			{
				return smoothstep(dest - 0.02, dest, pos.y) - smoothstep(dest, dest + 0.02, pos.y);
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float y = implus(_K, input.uv.x * _TotalLength) * 0.8 + 0.1;

				fixed3 color = (0, 0, 0);

				float factor = plot(input.uv, y);
				color = (1 - factor) * color + factor * _LineColor; 

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"	
}
