Shader "Custom/Noise/DomainWarping" 
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

		
			float fbm(in float2 pos)
			{
				const int OCTAVES = 4;

				float value = 0;
				float amptitude = 0.5;

				float2 shift = float2(100, 0);
				float2x2 rotMat = float2x2(cos(0.5), -sin(0.5), sin(0.5), cos(0.5));

				for(int i = 0; i < OCTAVES; i++)
				{
					value += amptitude * noise(pos);
					pos += mul(rotMat, pos) * 2 + shift;
					amptitude *= 0.5;
				}

				return value;
			}


			float4 frag(vertexOutput input) : SV_Target
			{
				float3 color = 0;

				float2 q = 0;
				q.x = fbm(input.uv + 0 * _Time.y);
				q.y = fbm(input.uv + float2(1, 1));

				float2 r = 0;
				r.x = fbm(input.uv + 1 * q + float2(1.7, 9.2) + 0.15 * _Time.y);
				r.y = fbm(input.uv + 1 * q + float2(8.3, 2.8) + 0.126 * _Time.y);

				float f = fbm(input.uv + r);

				color = lerp(float3(0.101961, 0.619608, 0.666667),
			                float3(0.666667, 0.666667, 0.498039),
			                clamp((f*f)*4.0,0.0,1.0));

			    color = lerp(color,
			                float3(0.000, 0.000, 0.995),
			                clamp(length(q),0.0,1.0));

			    color = lerp(color,
			                float3(0.525, 1.000, 0.933),
			                clamp(length(r.x),0.0,1.0));

				f = f * 2;
			    return float4(f * color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
