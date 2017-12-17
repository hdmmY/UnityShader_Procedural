Shader "Custom/Color/RGB2HSB" 
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


			fixed4 frag(vertexOutput input) : SV_Target
			{
				return fixed4(rgb2hsb(fixed3(input.uv.x, 1, input.uv.y)), 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"	
}
