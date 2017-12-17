Shader "Custom/Color/HSB2RGBExercise01" 
{
	Properties
	{
		_Color ("Color", Color) = (1, 1, 1, 1)
		_Center ("Center", Range(0, 1)) = 0.5
		_Width ("Width", Range(0, 1)) = 0.5
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

			fixed4 _Color;

			fixed _Center;
			fixed _Width;

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


			float cubicPulse(float c, float w, float x)
			{
				x = abs(x - c);
				
				if(x > w) return 0;
				
				x /= w;
				return 1 - x * x * (3 - 2 * x); 
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed3 hsbColor = rgb2hsb(_Color);

				float brightness = cubicPulse(_Center, _Width, input.uv.x);

				fixed3 color = hsb2rgb(fixed3(hsbColor.x, brightness, 1));

				return fixed4(color, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"	
}
