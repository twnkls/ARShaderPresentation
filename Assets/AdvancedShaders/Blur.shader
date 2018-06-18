Shader "Hidden/Blur"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		stepSize ("Step size", Vector) = (1, 0, 0, 0)
		gaus0 ("Gausian center", Float) = 0.375 // 6/16
		gaus1 ("Gausian distance 1", Float) = 0.25 // 4/16
		gaus2 ("Gausian distance 2", Float) = 0.0625 // 1/16
	}
	SubShader
	{
		// No culling or depth
		Cull Off ZWrite Off ZTest Always

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv0 : TEXCOORD0;
				float2 uv1 : TEXCOORD1;
				float2 uv2 : TEXCOORD2;
				float2 uv3 : TEXCOORD3;
				float2 uv4 : TEXCOORD4;
				float4 vertex : SV_POSITION;
			};

			uniform float2 stepSize;

			static float2 screenStepSize = stepSize / _ScreenParams.xy;

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0 = (-screenStepSize * 2.0f) + v.uv;
				o.uv1 = -screenStepSize + v.uv;
				o.uv2 = v.uv;
				o.uv3 = screenStepSize + v.uv;
				o.uv4 = (screenStepSize * 2.0f) + v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			uniform float gaus0;
			uniform float gaus1;
			uniform float gaus2;

			static float kernel[5] = {gaus2, gaus1, gaus0, gaus1, gaus2};

			float4 frag (v2f i) : SV_Target
			{
				float2 coords[5] = {i.uv0, i.uv1, i.uv2, i.uv3, i.uv4};
				float3 col = 0.0f;
				for (int j = 0; j < 5; ++j)
				{
					col += tex2D(_MainTex, coords[j]) * kernel[j];
				}
				return float4(col, 1);
			}
			ENDCG
		}
	}
}
