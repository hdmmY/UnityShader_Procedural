Shader "Custom/Pattern/BasePattern" 
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


			fixed circle(in fixed2 pos, in float radius)
			{
				fixed len = length(pos - fixed2(0.5f, 0.5f));

				return smoothstep(radius - 0.02f, radius + 0.02f, len);
			}



			fixed4 frag(vertexOutput input) : SV_Target
			{
				// Scale up the space by 3
				input.uv *= 5;
				// Wrap around 1
				input.uv = frac(input.uv);

				// Draw circle
				fixed3 color = circle(input.uv, 0.3f).xxx;

				return fixed4(color, 0);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
