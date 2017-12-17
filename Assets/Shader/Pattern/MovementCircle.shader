Shader "Custom/Pattern/MovementCircle" 
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
				input.uv *= 20;

				fixed3 color;
				fixed speed = (step(1, fmod(input.uv.y, 2)) - 0.5) * 2;
				fixed offsetX = speed * frac(_Time.y);

				input.uv = frac(input.uv);

				input.uv.x = input.uv.x - 1 + offsetX;
				color = circle(input.uv, 0.3);
				input.uv.x += 1;
				color *= circle(input.uv, 0.3);
				input.uv.x += 1;
				color *= circle(input.uv, 0.3);

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
