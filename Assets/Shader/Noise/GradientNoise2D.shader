Shader "Custom/Noise/GradientNoise2D" 
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

		
			fixed4 frag(vertexOutput input) : SV_Target
			{
				input.uv *= 10;

				float3 color = noise(input.uv) * 0.5 + 0.5;

				//color = frac(sin(dot(color, color) * UNITY_PI)) ;

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
