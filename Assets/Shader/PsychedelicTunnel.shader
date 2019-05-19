
Shader "ShaderMan/PsychedelicTunnel"
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
	fixed2 uv =  (i.projPos.xy / i.projPos.w);
    fixed2 p = uv ;
    float lengthp = length(p);
    float time = frac(_Time.y/100.0);
    float r = 0.5*lengthp + (time);
    float a = sin(_Time.y*1.0+16.0*lengthp)*0.05 + (1.0/3.14)*atan2(p.y, p.x)
        /* + 0.05*cos(50.0*time)*/ ;
    fixed4 col = tex2D(iChannel0, fixed2(r, a));
	return fixed4(col.xyz,1.0);
}
	ENDCG
	}
  }
}

