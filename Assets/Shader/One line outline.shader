
Shader "ShaderMan/One line outline"
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
        GrabPass{"iChannel0" }
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

	return fixed4((min(fwidth(tex2D(iChannel0, i.projPos.xy / i.projPos.w))*7.0, 1.0)));
}
	ENDCG
	}
  }
}

