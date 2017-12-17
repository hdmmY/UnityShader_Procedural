Shader "Custom/Color/HSB2RGB" 
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


			fixed3 hsb2rgb(in fixed3 c)
			{
				fixed3 rgb = clamp(abs(fmod(c.x * 6.0 + fixed3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0, 
				                0.0,
				                1.0 );

			    rgb = rgb * rgb * fixed3(3.0 - 2.0 * rgb);
			 	
			    return c.z * lerp(fixed3(1, 1, 1), rgb, c.y);
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				return fixed4(hsb2rgb(fixed3(input.uv.x, 1, input.uv.y)), 1.0);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"	
}
