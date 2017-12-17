Shader "Custom/Random/SimpleRandom2D" 
{
	Properties
	{
		_Amptitude ("Amptitude", Float) = 1.0
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

			struct vertexOutput
			{
				fixed4 vertex : SV_POSITION;
				fixed2 uv : TEXCOORD0; 
			};

			float _Amptitude;

			vertexOutput vert(appdata_base input)
			{
				vertexOutput output;

				output.vertex = UnityObjectToClipPos(input.vertex);
				output.uv = input.texcoord.xy;

				return output;
			}

		
			float4 frag(vertexOutput input) : SV_Target
			{
				float value = frac(sin(dot(input.uv, float2(12.9898,78.233))) * _Amptitude) * 0.5 + 0.25;

				return float4(value, value, value, 1);
			}

			ENDCG
		}
	}
	FallBack "Diffuse"
}
