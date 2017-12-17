// 来源于:  Sinuousity -- Galactic Dance(https://www.shadertoy.com/view/XtlGWs)


Shader "Custom/ShaderToyEffect/FlowingGalactic" 
{
	Properties
	{
		_ArmNumber ("Arm Number", Float) = 3    // 星臂数量，需要是一个整数

		_InnerColor ("Inner Color", Color) = (1, 1, 1, 1)   // 靠近原点的颜色
		_OuterColor ("Outer Color", Color) = (0, 0, 0, 0)   // 远离原点的颜色
		_Brightness ("Brightness", Float) = 1 // 整体变亮
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

			fixed _ArmNumber;

			fixed4 _InnerColor;
			fixed4 _OuterColor;

			fixed _Brightness;

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

			
			fixed3 frag(vertexOutput input) : SV_Target
			{
				// 静态的缓速转动
				// 0.2 是转速
				float cosSlowR = cos(_Time.y * 0.2);   
				float sinSlowR = sin(_Time.y * 0.2);
				float2x2 slowRMatrix = float2x2(cosSlowR, -sinSlowR, sinSlowR, cosSlowR);

				// 将 uv 映射至 [-1, 1]
				// 将缓速转动应用到 uv 上
				input.uv = input.uv * 2 - 1;
				input.uv = mul(slowRMatrix, input.uv);

				// 圆心距 
				float dist = length(input.uv);

				// 基于圆心距的转动
				// 0.5 控制转速
				float cosDist = cos(0.5 * _Time.y);
				float sinDist = sin(0.5 * _Time.y);
				float2x2 distRMatrix = float2x2(cosDist, -sinDist, sinDist, cosDist);

				// 圆心角, 范围在 [0, 1]
				input.uv = lerp(input.uv, mul(distRMatrix, input.uv), dist);
				float angle = atan2(input.uv.y, input.uv.x) / UNITY_TWO_PI * 0.5 + 0.5;

				//
				angle *= 2 * _ArmNumber;
				angle = frac(angle);

				// 臂宽, [0, 1]
				float armWidth = abs(angle * 2 - 1);
				armWidth = pow(armWidth, dist * dist * dist * 5 + 30); // 这里是让臂宽更加锐利, 10 和 50 都是控制参数

				// 如果这个像素在星臂上, visible = 1
				float visible = 1 - saturate(dist);

				// 中心点高亮
				float coreColor = pow(visible, 5);

				// 整个图像的混合颜色
				fixed3 color = lerp(_InnerColor, _OuterColor, dist * 2);  
				// 星臂上的颜色
				color = visible * armWidth * color;
				// 中心高亮
				color += lerp(coreColor, color, dist);

				return fixed4(color * _Brightness, 1.0);
			}



			ENDCG
		}
	}
	FallBack "Diffuse"
}
