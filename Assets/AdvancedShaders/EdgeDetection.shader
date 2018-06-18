Shader "Hidden/EdgeDetection"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		stepSize("Step size", Vector) = (1, 0, 0, 0)
		kernel0("Kernel center", Float) = 0.25
		kernel1("Kernel corner", Float) = 0.5
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
				float2 uv5 : TEXCOORD5;
				float4 vertex : SV_POSITION;
			};

			uniform float2 stepSize;

			static float2 screenStepSize = stepSize / _ScreenParams.xy; // _ScreenParams is a build in variable from unity storing the target texture/screen resolution in x and y
			static float2 perpScreenStepSize = screenStepSize.yx * float2(-1, 1); // calculatie perpendicular vector


			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv0 = (-screenStepSize) + (perpScreenStepSize)+v.uv;
				o.uv1 = (-screenStepSize) + v.uv;
				o.uv2 = (-screenStepSize) + (-perpScreenStepSize) + v.uv;
				o.uv3 = (screenStepSize)+(perpScreenStepSize)+v.uv;
				o.uv4 = (screenStepSize)+v.uv;
				o.uv5 = (screenStepSize)+(-perpScreenStepSize) + v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			uniform float kernel0;
			uniform float kernel1;

			static float kernel[3] = {kernel1, kernel0, kernel1};

			fixed4 frag (v2f i) : SV_Target
			{
			float2 coordsp[3] = {i.uv0, i.uv1, i.uv2};
			float val = 0.0f;
			for (int j = 0; j < 3; ++j)
			{
				val += dot(tex2D(_MainTex, coordsp[j]).rgb, float3(0.2126, 0.7152, 0.0722)) * kernel[j];
			}
			float2 coordsn[3] = {i.uv3, i.uv4, i.uv5};
			for (int k = 0; k < 3; ++k)
			{
				val -= dot(tex2D(_MainTex, coordsn[k]).rgb, float3(0.2126, 0.7152, 0.0722)) * kernel[k];
			}
			return float4(abs(val).xxx, 1);
			}
			ENDCG
		}
	}
}
