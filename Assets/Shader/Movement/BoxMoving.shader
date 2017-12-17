Shader "Custom/Movement/BoxMoving" 
{
	Properties
	{
		_MoveRadius ("Move Radius", Range(0.05, 0.5)) = 0.35
		_Size ("Size", Range(0.05, 1)) = 0.2
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

			fixed _Size;
			fixed _MoveRadius;

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

			
			// 画一个形状是 shape 的长方形
			// 当 pos 在长方形内时, 返回 1; 否则返回 0
			fixed box(in fixed2 pos, in fixed2 shape)
			{
				fixed2 edge = fixed2(0.5, 0.5) - shape * 0.5;

				fixed2 uv = step(edge, pos);    // 左边 u 为 0, 下边 v 为 0
				uv *= step(edge, 1 - pos);      // 右边 u 为 0, 上边 v 为 0. 乘相当于逻辑或

				return uv.x * uv.y;
			}


			// 画一个十字架
			fixed crossBox(fixed2 pos, fixed size)
			{
				return box(pos, fixed2(size, size/4)) + box(pos, fixed2(size / 4, size));
			}
			

			fixed3 frag(vertexOutput input) : SV_Target
			{
				fixed2 translate = fixed2(cos(_Time.y), sin(_Time.y));
				input.uv += translate * _MoveRadius;

				fixed3 color = crossBox(input.uv, _Size).xxx;

				return fixed4(color, 1.0);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
