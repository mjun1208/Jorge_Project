
Shader "ShaderMan/Displacement in 137 chars"
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
       
        GrabPass{ "iChannel0"}
         GrabPass{ "iChannel1"}
        Pass {
     
            Cull Front
            ZTest Always
            ZWrite Off
          
	CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma target 3.0



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

	fixed2 p = (i.projPos.xy / i.projPos.w);
	return tex2D(iChannel0, p+(tex2D(iChannel1, p).rb)*.1);
}
	ENDCG
	}
  }
}

