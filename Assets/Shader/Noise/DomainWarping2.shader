Shader "Custom/Noise/DomainWarping2" 
{
	Properties
	{
		_ColorA ("Tint Color A", Color) = (1, 1, 1, 1)
		_ColorB ("Tint Color B", Color) = (1, 1, 1, 1)
		_ColorC ("Tint Color C", Color) = (1, 1, 1, 1)		
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

			struct vertexOutput
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0; 
			};

			float4 _ColorA;
			float4 _ColorB;
			float4 _ColorC;

			vertexOutput vert(appdata_base input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.texcoord.xy;

				return output;
			}

			// Get a random vector between [-1, 1]
			float2 random2(in float2 pos)
			{			
				return frac(sin(dot(pos, float2(12.9898, 78.233))) * 43758.5453123);
			}

			// Return a value between [0, 1]
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

				return lerp(a, b, u.x) + (c - a) * u.y * (1 - u.x) + (d - b) * u.x * u.y;
			}

			// 2D fractal brownian motion
			float fbm(in float2 pos)
			{
				const int OCTAVES = 4;
				const float lacunarity = 2.0;
				const float gain = 0.5;

				float value = 0;
				float amptitude = 0.5;
				

				for(int i = 0; i < OCTAVES; i++)
				{
					value += amptitude * noise(pos);
					amptitude *= gain;
					pos *= lacunarity;
				}

				return value;
			}


			float pattern(in float2 p, out float2 q, out float2 r)
			{
				q = float2(fbm(p + float2(0, 0)), 
						   fbm(p + float2(5.2, 1.3)));

				r = float2(fbm(p + 4.0 * q + float2(1.7, 9.2) + 0.37 * _Time.y), 
						   fbm(p + 4.0 * q + float2(8.3, 2.8) + 0.423 * _Time.y));

				return fbm(p + 4 * r);
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				input.uv *= 10;
				input.uv.x *= 2;

				float2 q, r;
				float v = pattern(input.uv, q, r);	

				float3 color = lerp(v * _ColorA, lerp(_ColorB, _ColorC, q.x), r.x);

			    return float4(color, 1);
			}
			
			ENDCG
		}
	}
	FallBack "Diffuse"
}
