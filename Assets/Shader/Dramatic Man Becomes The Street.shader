
Shader "ShaderMan/Dramatic Man Becomes The Street"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	iChannel2 ("iChannel2", 2D) = "" {}
	iChannel3 ("iChannel3", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
         GrabPass{ "iChannel1"}
          GrabPass{ "iChannel2"}
           GrabPass{ "iChannel3"}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha one
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel3;
sampler2D iChannel2;
sampler2D iChannel1;
sampler2D iChannel0;

#define FUDGE_AMOUNT 0.06


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

    fixed2 screenCoord =(i.projPos.xy / i.projPos.w);
    fixed2 fuckCoord = screenCoord;
    float fuckAmt = tex2D(iChannel3, fixed2(cos(_Time.y*12.), sin(_Time.y*16.))).r;
    fuckAmt = pow(fuckAmt, 2.);
    fuckCoord.x += (sin(screenCoord.x*pow(_Time.y,2.7))*fuckAmt)/64.;
    fuckCoord.y += (cos(screenCoord.y*pow(_Time.y,2.3))*fuckAmt)/56.;

    //fuckCoord = lerp(fuckCoord, ceil(fuckCoord), sin(_Time.y));
    
    fixed4 co = tex2D( iChannel0, fuckCoord);
    fixed4 oc = tex2D( iChannel1, screenCoord);
    fixed4 test = lerp(co, oc, co.g);
    if(co.g > 0.005 && ((co.g > co.r + FUDGE_AMOUNT) && (co.g > co.b + FUDGE_AMOUNT))){
        test = oc;
        //test = fixed4(0., 0., 0., 1.);
    }
    else{
        fixed4 noise = tex2D(iChannel3, screenCoord);
        noise.r = pow(noise.r, 2.);
        noise.g = pow(noise.g, 2.);
        noise.b = pow(noise.b, 2.);
        test = lerp(co*oc*tex2D(iChannel2, fixed2(screenCoord.x+(_Time.y/5.), screenCoord.y))*noise, oc, co.r);
    }
    return test;
}
	ENDCG
	}
  }
}

