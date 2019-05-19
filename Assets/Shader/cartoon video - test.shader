
Shader "ShaderMan/cartoon video - test"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
    eps ("eps", Range(0, 1)) = 1
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

uniform float eps = 32;
#define PI 3.1415927

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
	fixed3 t   = tex2D(iChannel0, uv).rgb;
	fixed3 t00 = tex2D(iChannel0, uv+fixed2(-eps,-eps)).rgb;
	fixed3 t10 = tex2D(iChannel0, uv+fixed2( eps,-eps)).rgb;
	fixed3 t01 = tex2D(iChannel0, uv+fixed2(-eps, eps)).rgb;
	fixed3 t11 = tex2D(iChannel0, uv+fixed2( eps, eps)).rgb;
	fixed3 tm = (t00+t01+t10+t11)/4.;
	fixed3 v=t; fixed3 c;
	//t = .5+.5*sin(fixed4(100.,76.43,23.75,1.)*t);
	t = t-tm;
	//t = 1.-t;
	t = t*t*t;
	//t = 1.-t;
	v=t;
	v = 10000.*t;

	float g = (tm.x-.3)*5.;
	//g = (g-.5); g = g*g*g/2.-.5; 
	fixed3 col0 = fixed3(0.,0.,0.);
	fixed3 col1 = fixed3(.2,.5,1.);
	fixed3 col2 = fixed3(1.,.8,.7);
	fixed3 col3 = fixed3(1.,1.,1.);
	if      (g > 2.) c = lerp(col2,col3,g-2.);
	else if (g > 1.) c = lerp(col1,col2,g-1.);
	else             c = lerp(col0,col1,g);
		
	c = clamp(c,0.,1.);
	v = clamp(v,0.,1.);
	v = c*(1.-v); 
	//v = c-1.5*(1.-v); v = 1.-v;
	v = clamp(v,0.,1.);

	return fixed4(v,1.);
}
	ENDCG
	}
  }
}

