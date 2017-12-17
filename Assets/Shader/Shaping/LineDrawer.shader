Shader "Custom/Shaping/LineDrawer" 
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
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
				// y = x line 
				//float y = input.uv.x;

				// y = x ^ ? line
				float y = pow(input.uv.x, 2);

				//float y = cos(sin(input.uv.x) * 100) * 0.5 + 0.5;

				fixed3 color = input.uv.x;

				float factor = plot(input.uv, y);
				color = (1 - factor) * color + factor * _LineColor; 

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
