Shader "Custom/Shaping/Useful Functions/CubicPulse" 
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)
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

			fixed4 _LineColor;

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


			// 脉冲函数
			// c : 中心点; w : 脉冲宽度; x : 当前点坐标
			// 当 x 不在脉冲范围内时, 返回 0; 否则返回一个[0, 1] 之间的数
			// 具体见 : http://www.iquilezles.org/www/articles/functions/functions.htm
			float cubicPulse(float c, float w, float x)
			{
				x = abs(x - c);
				
				if(x > w) return 0;
				
				x /= w;
				return 1 - x * x * (3 - 2 * x); 
			}



			float plot(float2 pos, float dest)
			{
				return smoothstep(dest - 0.02, dest, pos.y) - smoothstep(dest, dest + 0.02, pos.y);
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				float y = cubicPulse(0.5, 0.3, input.uv.x);

				fixed3 color = fixed3(0, 0, 0);

				float factor = plot(input.uv, y);
				color = (1 - factor) * color + factor * _LineColor; 

				return fixed4(color, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"	
}
