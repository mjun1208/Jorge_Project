
Shader "ShaderMan/Weaving"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}

}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
       
        GrabPass{ "iChannel0"}
        Pass {
     
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel0;

static	const fixed amt = 30.0;


 struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {

	fixed2 uv =(i.projPos.xy / i.projPos.w);
    
    float bars = _ScreenParams.x / amt;
    
    //x bars
    float s = step(0.0, sin(uv.y *bars));
    float nuv = uv.x;
    nuv *= s;
	float uuv = 1.0 -uv.x;
    uuv *= (1.0 - s);
    uv.x = lerp(uuv, nuv, s);
    
    
    //y bars
    float s2 = step(0.0, sin(uv.x *(bars * (_ScreenParams.x / _ScreenParams.y))));
    float nuv2 = uv.y;
    nuv2 *= s2;
	float uuv2 = 1.0 -uv.y;
    uuv2 *= (1.0 - s2);
    
    uv.y = lerp(uuv2, nuv2, s2);
    
    fixed4 fragColor;
	fragColor = tex2D(iChannel0, uv);
    fragColor.a = 1.0;
    return fragColor;
}
	ENDCG
	}
  }
}

