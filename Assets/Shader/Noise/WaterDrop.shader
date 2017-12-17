Shader "Custom/Noise/WaterDrop" 
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

			// Get a random gradient
			float2 random2(in float2 pos)
			{
				// Get a random pos
				pos = float2(dot(pos, float2(127.1, 311.7)), dot(pos, float2(269.5, 183.3)));
			
				return -1 + 2 * frac(sin(pos) * 43758.5453123);
			}

			// Return a value between [-1, 1]
			float noise(in float2 pos)
			{
				float2 i = floor(pos);
				float2 f = frac(pos);

				// Four corner 
				float2 a = random2(i);
				float2 b = random2(i + float2(1, 0));
				float2 c = random2(i + float2(0, 1));
				float2 d = random2(i + float2(1, 1));

				// Smooth interpolation
				float2 u = smoothstep(0, 1, f);

				return lerp(lerp(dot(a, f - float2(0, 0)), dot(b, f - float2(1, 0)), u.x), 
							lerp(dot(c, f - float2(0, 1)), dot(d, f - float2(1, 1)), u.x), u.y);
			}

		
			float4 frag(vertexOutput input) : SV_Target
			{
				float3 color = 0;

				float t = fmod(_Time.y, 50);
				if(t > 25)
				{
					t = 50 - t;
				}

				input.uv += noise(input.uv * 2) * t;

				// Big black drops
				color = smoothstep(0.15, 0.2, noise(input.uv));
				// Black splatter
				color += smoothstep(0.15, 0.2, noise(input.uv * 10));
				// Holes on splatter
				color -= smoothstep(0.38, 0.4, noise(input.uv * 10));

				return float4(1 - color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
