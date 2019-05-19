
Shader "ShaderMan/Eğlenceli GLSL 08"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	iChannel2 ("iChannel2", 2D) = "" {}
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
        GrabPass{ "iChannel1"}

        GrabPass{ "iChannel2"}
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
sampler2D iChannel2;
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
	fixed2 uv = (i.projPos.xy / i.projPos.w);
    
    fixed4 renk0 =  tex2D( iChannel0, uv);
    fixed4 renk1 =  tex2D( iChannel1, uv);
    fixed4 renk2 =  tex2D( iChannel2, uv);
    
    fixed4 renk;
    
    if(renk0.g > renk0.r + renk0.b ) {
    	renk = renk2;
    }
    else {
        float sb = renk1.r * 0.21 + renk1.g * 0.71 + renk1.b * 0.07;
        
        renk = fixed4( sb, sb, sb, 1.0);
    }
    
    return renk;

}
	ENDCG
	}
  }
}

