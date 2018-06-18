Shader "Hidden/BrightPassFilter"
{
	Properties
	{
		_MainTex ("Texture", 2D) = "white" {}
		falloffLum("Luminance falloff", Range(0, 1)) = 0.5
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
				float2 uv : TEXCOORD0;
				float4 vertex : SV_POSITION;
			};

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				return o;
			}
			
			sampler2D _MainTex;

			uniform fixed falloffLum;

			fixed4 frag (v2f i) : SV_Target
			{
				fixed4 col = tex2D(_MainTex, i.uv);

				fixed luminance = dot(col.rgb, fixed3(0.2126, 0.7152, 0.0722)); // calculate luminance

				col = luminance > falloffLum ? col : fixed4(0, 0, 0, 1);

				return col;
			}
			ENDCG
		}
	}
}
