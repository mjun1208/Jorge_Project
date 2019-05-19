
Shader "ShaderMan/Difference Blend Mode"
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
    
    //Get the texture color
    fixed4 image = tex2D(iChannel0, uv);
    
    //Make a simple sine wave stripe
    float mask_pattern = 0.5 * sin(8.0 * uv.x - _Time.y) + 0.5;
    fixed4 mask = mask_pattern * fixed4(1.0,1,1,1);
    
    //Absolute difference blend mode as described at
    //https://docs.gimp.org/en/gimp-concepts-layer-modes.html
    fixed4 difference = abs(mask - image);
    
	return difference;
}
	ENDCG
	}
  }
}

