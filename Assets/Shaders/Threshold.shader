Shader "Custom/Threshold" 
{
	Properties 
	{
		_Color ("Color", Color) = (1,1,1,1)
		_MainTex ("Albedo (RGB)", 2D) = "white" {}
		_Glossiness ("Smoothness", Range(0,1)) = 0.5
		_Metallic ("Metallic", Range(0,1)) = 0.0
	}

	SubShader 
	{
		CGPROGRAM
		#pragma surface surf Standard
		#define TWO_PI 6.28318530718

		sampler2D _MainTex;

		struct Input 
		{
			float2 uv_MainTex;
		};

		half _Glossiness;
		half _Metallic;
		fixed4 _Color;

		fixed3 hsb2rgb(fixed3 c)
		{
			fixed3 rgb = clamp(abs(modf(c.x*6.0+fixed3(0.0,4.0,2.0),6.0)-3.0)-1.0, 0.0, 1.0);
			rgb = rgb*rgb*(3.0-2.0*rgb);
			return c.z * lerp( fixed3(1.0), rgb, c.y);
		}

		fixed avg3(fixed3 c)
		{
			return (c.r + c.g + c.b)*0.333333;
		}

		void surf (Input IN, inout SurfaceOutputStandard o) 
		{
			fixed4 col = tex2D (_MainTex, IN.uv_MainTex) * _Color;
			fixed3 bw = lerp(0.0, 1.0, avg3(col.rgb));
			fixed3 ext = hsb2rgb(vec3((sin(_Time.y*360.0)/TWO_PI)+0.5,0.25,1.0));
			fixed3 res = lerp(col.rgb, bw, sin(_Time.y * 4.0));

			o.Metallic = _Metallic;
			o.Smoothness = _Glossiness;
			o.Albedo = res;
			o.Alpha = col.a;
		}
		ENDCG
	}
	FallBack "Diffuse"
}
