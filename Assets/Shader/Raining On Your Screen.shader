
Shader "ShaderMan/Raining On Your Screen"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	}

	SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{"iChannel0" }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel1;
sampler2D iChannel0;

	



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
	float time = _Time.y;
	fixed3 raintex = tex2D(iChannel1,fixed2(uv.x*2.0,uv.y*0.1+time*0.125)).rgb/8.0;
	fixed2 where = (uv.xy-raintex.xy);
	fixed3 texchur1 = tex2D(iChannel0,fixed2(where.x,where.y)).rgb;
	
	return fixed4(texchur1,1.0);
}
	ENDCG
	}
  }
}

