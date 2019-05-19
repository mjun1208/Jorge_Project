
Shader "ShaderMan/Screen Split"
	{


Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
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

	fixed2 uv = (i.projPos.xy / i.projPos.w);
    fixed3 tc=tex2D(iChannel0,uv).rgb;
    
    // divide screen by/3 .. 0->.33  .. 33->.66 ...66->1.0
    if(uv.x>0.0 && uv.x<0.33) tc.rgb*=fixed3(0.0,0.0,1.0); // b
    if(uv.x>0.33 && uv.x<0.66) tc.rgb*=fixed3(1.0,1.0,1.0);//w
    if(uv.x>0.66) tc.rgb*=fixed3(1.0,0.0,0.0);             //r
    
	return fixed4(tc,1.0);
}
	ENDCG
	}
  }
}

