
Shader "ShaderMan/Screen Transition 1"
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

static const float divisions=30.;

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

	fixed2 corrected_coord =(i.projPos.xy / i.projPos.w);
    float biggest_dim = max(1,1);
    fixed2 st = corrected_coord/biggest_dim;
    
    fixed3 color = fixed3(1.,1,1);
    // PARAMETERS
    
    //float time = 0.5;

    // CODE
    float t = frac(_Time.x)*9.-1.;
    fixed2 f_st = frac(st*divisions);
    fixed2 i_st = floor(st*divisions);
    f_st -= 0.5;
    t = (1.-t+(i_st.x/divisions) - (1.-i_st.y/divisions));
    float a = (step(t, 1.-abs(f_st.x+f_st.y))*step(t, 1.-abs((f_st.x)-(f_st.y))));
    //result_color.a = 1-(step(t, abs(f_st.x+f_st.y))+step(t, abs((1-f_st.x)-(1-f_st.y))));
    return tex2D(iChannel0, st) * (1.-a);
}
	ENDCG
	}
  }
}

