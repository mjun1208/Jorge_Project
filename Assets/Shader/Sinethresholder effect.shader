
Shader "ShaderMan/Sinethresholder effect"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}

	_iMouse("_iMouse", Vector) = (0,0,0,0)

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

            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
uniform float4 _iMouse;
sampler2D iChannel3;
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
   
	fixed2 uv =(i.projPos.xy / i.projPos.w);
    
    float r = tex2D(iChannel0, uv).r;
    float c = step(0., sin(uv.x * 10. + r * 40.));
      
	return fixed4(fixed3(c,c,c), 1.0);    

}
	ENDCG
	}
  }
}

