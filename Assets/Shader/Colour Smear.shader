
Shader "ShaderMan/Colour Smear"
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

    float pyt=3.1415926*2./3.;
    float m=-1e10;//very negitive start value for maximisation algorithm.
    fixed4 mv= fixed4(0.,0,0,0);//lank starting value of max so far
    
    fixed2 xy = (i.projPos.xy / i.projPos.w);
    int ic=0;//stores smear distance
    for (int i=0;i<30;i++){
        //point offset on a circle
        fixed2 np=fixed2(xy.x+float(i)/ _ScreenParams.x*sin(_Time.y),xy.y+float(i)/ _ScreenParams.y*cos(_Time.y));
        //colour cycles faster than position
        float jTime = _Time.y*1.618;  
        //get neerby point
    	fixed4 tk=tex2D(iChannel0,np);
        // and if its colourfull enough, use that
        float t=tk.r*sin(jTime)+tk.g*sin(jTime+pyt)+tk.b*sin(jTime+2.*pyt)-.01*float(i);
        if (t>m){m=t; mv=tk;ic=i;}
    }
    //mix smeared with background depending ondistance
    float sc=float(ic)/30.;
    fixed4 tk=tex2D(iChannel0,xy);
    mv=sc*tk+(1.-sc)*mv;
    return fixed4(mv.r,mv.g,mv.b,1.0);
}
	ENDCG
	}
  }
}

