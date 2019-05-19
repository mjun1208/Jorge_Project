
Shader "ShaderMan/Shake"
	{

	Properties{
	_GrabGlitchTexture ("_GrabGlitchTexture", 2D) = "" {}
	}

	SubShader
	{
	  Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{"_GrabGlitchTexture" }
	Pass
	{
	    Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZTest Always



	 CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0

            struct appdata{
    float4 vertex : POSITION;
	float2 uv:TEXCOORD0;
	};


struct v2f
    {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 screenCoord : TEXCOORD1;
    };

    v2f vert(appdata v)
    {
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.screenCoord.xy = ComputeScreenPos(o.vertex);
    return o;
    }

	 uniform sampler2D _GrabGlitchTexture;




	//Variables
sampler2D _MainTex;

	


fixed4 frag(v2f i) : SV_Target{


	fixed2 uv = i.vertex / _ScreenParams;
    
    float s = sin(_Time.y * 12.);
	float l = .01;
    
    float r = tex2D(_GrabGlitchTexture, uv).x;
    float g = tex2D(_GrabGlitchTexture, uv + fixed2(l*s,0.)).y;
    float b = tex2D(_GrabGlitchTexture, uv - fixed2(0.,l*s)).z;
   
    return fixed4(r,g,b,1.);
    
}
	ENDCG
	}
  }
}

