Shader "Custom/Shaping/RectangleDrawer" 
{
	Properties
	{
		_LineColor ("Line Color", Color) = (1, 1, 1, 1)

		// XY 代表中心点, ZW 代表宽和高
		// 0 < X,Y,Z,W < 1
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

			fixed4 _LineColor;
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

			float rectanglePlot(fixed2 pos)
			{
				// 将uv坐标的坐标空间转换为长方形的坐标空间
				fixed2 posInRectCoord = abs(pos - _Shape.xy);

				fixed2 shape = _Shape.zw * 0.5;

				// fixed2 fillIn = smoothstep(shape - fixed2(0.01, 0.01), shape, posInRectCoord);
				// fixed2 fillOut = 1 - smoothstep(shape, shape + fixed2(0.01, 0.01), posInRectCoord);
				fixed2 fillIn = step(shape - fixed2(0.01, 0.01), posInRectCoord);
				fixed2 fillOut = 1 - step(shape + fixed2(0.01, 0.01), posInRectCoord);

				return (fillOut.x * fillOut.y) * (fillIn.x + fillIn.y);
			}

			fixed4 frag(vertexOutput input) : SV_Target
			{
				fixed3 color = fixed3(1, 1, 1);

				// float factor = rectanglePlot(input.uv);
				float factor = rectanglePlot(frac(input.uv + fixed2(_Time.y, 0) * 0.2));
				color = (1 - factor) * color + factor * _LineColor; 

				return fixed4(color, 1);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
