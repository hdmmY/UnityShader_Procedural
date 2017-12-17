Shader "Custom/Noise/ValueNoise2D" 
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

			float random(in float2 pos)
			{
				return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453);
			}

			
			float noise(in float2 pos)
			{
				float2 i = floor(pos);
				float2 f = frac(pos);

				// Four corner 
				float a = random(i);
				float b = random(i + float2(1, 0));
				float c = random(i + float2(0, 1));
				float d = random(i + float2(1, 1));

				// Smooth interpolation
				//f = smoothstep(0, 1, f);

				return lerp(a, b, f.x) + (c - a) * f.y * (1 - f.x) + (d - b) * f.x * f.y;
			}

		
			fixed4 frag(vertexOutput input) : SV_Target
			{
				input.uv *= 10;

				float3 color = noise(input.uv).xxx;

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
