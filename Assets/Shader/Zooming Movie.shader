
Shader "ShaderMan/Zooming Movie"
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
         GrabPass{"iChannel1" }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
           
            Cull Front
            ZTest Always
          
            


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
    float scale = .5 + .5 * (1.0 + sin(_Time.y * .5));
    fixed4 c = tex2D(iChannel0, (.5 + -.5 * scale +  uv * scale));
    c.r = c.r * .5 + c.r * 1.2 * sin(_Time.y * 2.0);
    c.g = c.g * .5 + c.g * 1.2 * sin(_Time.y * 1.5);
    c.b = c.b * .5 + c.b * 1.2 * sin(_Time.y * 1.25);
    fixed4 fragColor;
    fragColor = c;
    
    fixed2 offset = tex2D(iChannel1, fixed2(frac(_Time.y * 2.0), frac(_Time.y))).xy;
    fragColor += tex2D(iChannel1, offset + uv);
    return fragColor;
}
	ENDCG
	}
  }
}

