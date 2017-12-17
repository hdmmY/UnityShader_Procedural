Shader "Custom/Shaping/CircleToy" 
{
	Properties
	{
		_HSBColor ("HSB Color", Color) = (1, 1, 1, 1)
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

			fixed4 _HSBColor;

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

			fixed3 hsb2rgb(in fixed3 c)
			{
				fixed3 rgb = clamp(abs(fmod(c.x * 6.0 + fixed3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
				                0.0,
				                1.0 );

			    rgb = rgb * rgb * fixed3(3.0 - 2.0 * rgb);
			 	
			    return c.z * lerp(fixed3(1, 1, 1), rgb, c.y);
			}

			fixed3 rgb2hsb(in fixed3 c)
			{
				fixed4 K = fixed4(0, -1.0/3.0, 2.0/3.0, -1);
				
				fixed4 p = lerp(fixed4(c.bg, K.wz),
								fixed4(c.gb, K.xy),
								step(c.b, c.g));
				fixed4 q = lerp(fixed4(p.xyw, c.r),
								fixed4(c.r, p.yzx),
								step(p.x, c.r));

				fixed d = q.x - min(q.w, q.y);
				fixed e = 1.0e-10;
				
				return fixed3(abs(q.z + (q.w - q.y) / (6 * d + e)),
								d / (q.x + e),
								q.x); 
			}

			float4 frag(vertexOutput input) : SV_Target
			{
				// 将 uv 映射到 (-1, 1)
				input.uv = input.uv * 2 - 1;
				
				// float d = length(abs(input.uv) - fixed2(0.5, 0.5));
				// float d = length(min(abs(input.uv) - fixed2(0.5, 0.5), 0));
				float d = length(max(abs(input.uv) - fixed2(0.5, 0.5), 0));
				
				float factor = frac(d * fmod(_Time.y * 2, 30));

				float3 color = hsb2rgb(fixed3(factor, _HSBColor.y, _HSBColor.z));

				return float4(color, 1.0);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
