Shader "Custom/Pattern/Diamond" 
{
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


			fixed2 rotate2D(fixed2 pos, fixed angle)
			{
				angle = angle / 180 * UNITY_PI;
				pos -= 0.5;
				pos = mul(fixed2x2(cos(angle), -sin(angle), sin(angle), cos(angle)), pos);
				pos += 0.5;
				return pos;
			}

			fixed2 tile(fixed2 pos, fixed2 zoom)
			{
				return frac(pos * zoom);
			}

			fixed box(fixed2 pos, fixed2 size)
			{
				size = fixed2(0.5, 0.5) - size * 0.5;

				fixed2 uv = smoothstep(size, size + fixed2(0.02, 0.02), pos);
				uv *= smoothstep(size, size + fixed2(0.02, 0.02), 1 - pos);

				return uv.x * uv.y;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				input.uv = tile(input.uv, 10);
				input.uv = rotate2D(input.uv, sin(_Time.y) * 360 * 0.2);

				fixed3 color = box(input.uv, fixed2(0.5, 0.5));
				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
