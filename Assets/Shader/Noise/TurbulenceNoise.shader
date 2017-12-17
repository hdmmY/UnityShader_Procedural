Shader "Custom/Noise/TurbulenceNoise" 
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

			
			float3 permute(float3 x)
			{
				return fmod(((x * 34) + 1) * x, 289);
			}

			float snoise(float2 v)
			{
				// Precompute values for skewed triangular grid
			    const float4 C = float4(0.211324865405187,
			                        // (3.0-sqrt(3.0))/6.0
			                        0.366025403784439,
			                        // 0.5*(sqrt(3.0)-1.0)
			                        -0.577350269189626,
			                        // -1.0 + 2.0 * C.x
			                        0.024390243902439);
			                        // 1.0 / 41.0

			    // First corner (x0)
			    float2 i  = floor(v + dot(v, C.yy));
			    float2 x0 = v - i + dot(i, C.xx);

			    // Other two corners (x1, x2)
			    float2 i1 = float2(0, 0);
			    i1 = (x0.x > x0.y)? float2(1.0, 0.0):float2(0.0, 1.0);
			    float2 x1 = x0.xy + C.xx - i1;
			    float2 x2 = x0.xy + C.zz;

			    // Do some permutations to avoid
			    // truncation effects in permutation
			    i = fmod(i, 289);
			    float3 p = permute(
			            permute( i.y + float3(0.0, i1.y, 1.0))
			                + i.x + float3(0.0, i1.x, 1.0 ));

			    float3 m = max(0.5 - float3(
			                        dot(x0,x0),
			                        dot(x1,x1),
			                        dot(x2,x2)
			                        ), 0.0);

			    m = m*m ;
			    m = m*m ;

			    // Gradients:
			    //  41 pts uniformly over a line, mapped onto a diamond
			    //  The ring size 17*17 = 289 is close to a multiple
			    //      of 41 (41*7 = 287)

			    float3 x = 2.0 * frac(p * C.www) - 1.0;
			    float3 h = abs(x) - 0.5;
			    float3 ox = floor(x + 0.5);
			    float3 a0 = x - ox;

			    // Normalise gradients implicitly by scaling m
			    // Approximation of: m *= inversesqrt(a0*a0 + h*h);
			    m *= 1.79284291400159 - 0.85373472095314 * (a0*a0+h*h);

			    // Compute final noise value at P
			    float3 g = float3(0, 0, 0);
			    g.x  = a0.x  * x0.x  + h.x  * x0.y;
			    g.yz = a0.yz * float2(x1.x,x2.x) + h.yz * float2(x1.y,x2.y);
			    return 130.0 * dot(m, g);
			}


			float turbulence (in float2 st)
			{
				const int OCTAVES = 10;

			    // Initial values
			    float value = 0.0;
			    float amplitude = .5;
			    float frequency = 0.;
			    
			    // Loop of octaves
			    for (int i = 0; i < OCTAVES; i++) {
			        value += amplitude * abs(snoise(st));
			        st *= 2.;
			        amplitude *= .5;
			    }
			    return value;
			}
		
			float4 frag(vertexOutput input) : SV_Target
			{
				float3 color = turbulence(input.uv * 3);

				return float4(1 - color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
