
Shader "ShaderMan/Screen fade-in"
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

    int mode = 3;
    
    
    // k from 0 to 1
    float k = (1.0 + sin(_Time.y)) / 2.0;
	fixed2 uv = (i.projPos.xy / i.projPos.w);
    
    fixed2 ruv = uv - fixed2(0.5, 0.5);

    if (mode == 0)
    	uv = ruv / (k + k * (1.0 - k) * sin(uv.y * 3.0 + uv.x * 4.0)) + fixed2(0.5, 0.5);
	if (mode == 1)
    	uv = ruv / (k + k * (1.0 - k) * sin(uv.y * 100.0 + uv.x * 100.0)) + fixed2(0.5, 0.5);
    if (mode == 2)
    	uv = ruv / (k + k * (1.0 - k) * sin(uv.x * uv.y * 100.0*atan2(uv.y, uv.x))) + fixed2(0.5, 0.5);
    if (mode == 3)
	    uv = ruv / (k + k * (1.0 - k) * sin((1.0 + uv.x) * (1.0 + uv.y) * 100.0*atan2(uv.y, uv.x))) + fixed2(0.5, 0.5);
    
    if (uv.x > 1.0 || uv.y > 1.0 || uv.x < 0.0 || uv.y < 0.0)
        return fixed4(0, 0, 0, 0);
    else
		return tex2D(iChannel0, uv);
}
	ENDCG
	}
  }
}

