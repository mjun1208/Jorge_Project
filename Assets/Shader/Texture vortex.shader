
Shader "ShaderMan/Texture vortex"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	}

	SubShader
	{
	 Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
	 GrabPass{"iChannel0" }

	Pass
	{
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
float4 _iMouse;
sampler2D iChannel0;

#define PI 3.14
#define WAVE_SIZE 3.0
#define SPEED 3.0

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

	
	 fixed2 screenPos = (i.projPos.xy / i.projPos.w);
	
	// = vec2 ndc    = -1.0 + uv * 2.0;
	// = vec2 mouse  = -1.0 + 2.0 * iMouse.xy * rcpResolution;
	fixed4 mouseNDC =  -1.0 + fixed4(_iMouse.xy * 1, screenPos) * 2.0;
	fixed2 diff     = mouseNDC.zw - mouseNDC.xy;
	
	float dist   = sqrt(diff.x * diff.x + diff.y * diff.y);
	float angle = PI * dist * WAVE_SIZE + _Time.y * SPEED;
	 
	fixed3 sincos;
	sincos.x = sin(angle);
	sincos.y = cos(angle);
	sincos.z = -sincos.x;
	
	fixed2 newUV;

	newUV.x = dot(mouseNDC.zw, sincos.yz);	// = ndc.x * cos(angle) - ndc.y * sin(angle);
	newUV.y = dot(mouseNDC.zw, sincos.xy);  // = ndc.x * sin(angle) + ndc.y * cos(angle);
	
	fixed3 col = tex2D( iChannel0, newUV.xy );
	
	return fixed4(col, 1);
}

	ENDCG
	}
  }
}

