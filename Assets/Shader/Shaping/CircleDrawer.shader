Shader "Custom/Shaping/CircleDrawer" 
{
	Properties
	{
		_EdgeColor ("Edge Color", Color) = (1, 1, 1, 1)

		// XY 代表中心点, Z 代表半径, W 无用
		// 0 < X,Y,Z < 1
		_Shape ("Shape", Vector) = (0.5, 0.5, 0.3, 0.3)  
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

			fixed4 _EdgeColor;
			fixed4 _Shape;

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


			// 圆内为 0, 圆外为 1
			float circlePlot(fixed2 pos)
			{
				fixed2 direction = pos - _Shape.xy;

				return smoothstep(
							_Shape.z - _Shape.z * 0.1, 
							_Shape.z + _Shape.z * 0.1, 
							length(direction));

				// return smoothstep(
				// 			_Shape.z - _Shape.z * 0.1, 
				// 			_Shape.z + _Shape.z * 0.1, 
				// 			dot(direction, direction) * 4);
			}


			// 圆上为 1, 不在圆上为 0
			float circleEdgePlot(fixed2 pos)
			{
				float dirLength = length(pos - _Shape.xy);

				float fillIn = smoothstep(_Shape.z - _Shape.z * 0.1, _Shape.z, dirLength);
				float fillOut = 1 - smoothstep(_Shape.z, _Shape.z + _Shape.z * 0.1, dirLength);

				return fillOut * fillIn;
			}


			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed factor = circleEdgePlot(frac(input.uv + fixed2(_Time.y * 0.3, 0)));

				fixed3 color = lerp(fixed3(0, 0, 0), _EdgeColor, factor);

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
