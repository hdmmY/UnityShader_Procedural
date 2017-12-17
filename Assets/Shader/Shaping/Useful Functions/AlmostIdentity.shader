Shader "Custom/Shaping/Useful Functions/AlmostIdentity" 
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)

		_M ("m", Range(0, 1)) = 0.5
		_N ("n", Range(0, 1)) = 0.2
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

			fixed _M;
			fixed _N;

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


			// 0 < n < m, x > 0
			// 当 x > m 的时候, return x.
			// 当 0 < x < m 的时候, return 平滑过渡到 n.
			// 具体见 : http://www.iquilezles.org/www/articles/functions/functions.htm
			float almostIdentity(float x, float m, float n)
			{
				if(x > m)	return x;

				const float a = 2 * n - m;
				const float b = 2 * m - 3 * n;
				const float t = x / m;

				return (a * t + b) * t * t + n;
			}



			float plot(float2 pos, float dest)
			{
				return smoothstep(dest - 0.02, dest, pos.y) - smoothstep(dest, dest + 0.02, pos.y);
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float y = almostIdentity(input.uv.x, _M, _N);

				fixed3 color = fixed3(0, 0, 0);

				float factor = plot(input.uv, y);
				color = (1 - factor) * color + factor * _LineColor; 

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"	
}
