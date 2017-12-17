Shader "Custom/Color/SimpleChannelMix" 
{
	Properties
	{
		_ColorA ("Color A", Color) = (1, 1, 1, 1)
		_ColorB ("Color B", Color) = (0, 0, 0, 0)

		_LineColor ("LineColor", Color) = (1, 1, 1, 1)
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

			fixed4 _ColorA;
			fixed4 _ColorB;

			fixed4 _LineColor;

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


			float plot(float2 pos, float dest)
			{
				return smoothstep(dest - 0.02, dest, pos.y) - smoothstep(dest, dest + 0.02, pos.y);
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				// fixed3 destY = smoothstep(0, 1, input.uv.x).xxx;
				// fixed3 destY = smoothstep(0, 1, input.uv.x).xxx;
				fixed destY = pow(input.uv.x, 2);

				// 渐变
				fixed3 color = lerp(_ColorA, _ColorB, destY);

				// 画出 destY 曲线
				fixed factor = plot(input.uv, destY);
				color = (1 - factor) * color + factor * _LineColor;

				return fixed4(color, 1.0);	
			}

			ENDCG
		}
	}
	FallBack "Diffuse"	
}
