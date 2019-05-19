
Shader "ShaderMan/[SH2014] Evolving visualizer"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
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
sampler2D iChannel1;
sampler2D iChannel0;

fixed3 hsv(in float h, in float s, in float v) {
	return lerp(fixed3(1.0,1.0,1.0), clamp((abs(frac(h + fixed3(3, 2, 1) / 3.0) * 6.0 - 3.0) - 1.0), 0.0 , 1.0), s) * v;
}

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
	float t = _Time.y*.1;
	fixed2 uv = (i.projPos.xy / i.projPos.w);
	fixed2 p = uv;
	p.x *= 1/1;
	//p = fixed2(p.x*sin(t) + p.y*cos(t), p.x*cos(t)-p.y*sin(t));
	float x = atan2(p.y, p.x)/6.28+3.14;
	float r = tex2D(iChannel1, fixed2(x, 0.0)).x;
	fixed4 col = tex2D(iChannel0, abs(fmod(p, 2.0)-1.0));
	fixed2 y = p*2.0;
	for (int i = 0; i < 7; i++) {
		y = fixed2(y.x*sin(r) + y.y*cos(r), -y.x*cos(r)+y.y*sin(r));
		y = abs(fmod(y+t, 2.0)-1.0);
	}
	col = lerp(col, hsv(r+length(y), 1.0, 1.0).xyzz, 
			  smoothstep(0.03, 0.0, min(abs(y.x), abs(y.y))) *
			  smoothstep(0.0, 0.01, r));
	return col;
}
	ENDCG
	}
  }
}

