
Shader "ShaderMan/Psychedelic Ghost Britney"
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

fixed3 rainbow(float h) {
	h = fmod(fmod(h, 1.0) + 1.0, 1.0);
	float h6 = h * 6.0;
	float r = clamp(h6 - 4.0, 0.0, 1.0) +
		clamp(2.0 - h6, 0.0, 1.0);
	float g = h6 < 2.0
		? clamp(h6, 0.0, 1.0)
		: clamp(4.0 - h6, 0.0, 1.0);
	float b = h6 < 4.0
		? clamp(h6 - 2.0, 0.0, 1.0)
		: clamp(6.0 - h6, 0.0, 1.0);
	return fixed3(r, g, b);
}

fixed3 plasma(fixed2 fragCoord)
{
	static const float speed = 12.0;
	
	static const float scale = 2.5;
	
	static const float startA = 563.0 / 512.0;
	static const float startB = 233.0 / 512.0;
	static const float startC = 4325.0 / 512.0;
	static const float startD = 312556.0 / 512.0;
	
	static const float advanceA = 6.34 / 512.0 * 18.2 * speed;
	static const float advanceB = 4.98 / 512.0 * 18.2 * speed;
	static const float advanceC = 4.46 / 512.0 * 18.2 * speed;
	static const float advanceD = 5.72 / 512.0 * 18.2 * speed;
	
	fixed2 uv = fragCoord * scale / 1;
	
	float a = startA + _Time.y * advanceA;
	float b = startB + _Time.y * advanceB;
	float c = startC + _Time.y * advanceC;
	float d = startD + _Time.y * advanceD;
	
	float n = sin(a + 3.0 * uv.x) +
		sin(b - 4.0 * uv.x) +
		sin(c + 2.0 * uv.y) +
		sin(d + 5.0 * uv.y);
	
	n = fmod(((4.0 + n) / 4.0), 1.0);
	
	fixed2 tuv = fragCoord.xy / 1;
	n += tex2D(iChannel0, tuv).r;
	
	return rainbow(n);
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

	fixed3 green = fixed3(0.173, 0.5, 0.106);
	fixed2 uv =(i.projPos.xy / i.projPos.w);
	fixed3 britney = tex2D(iChannel0, uv).rgb;
	float greenness = 1.0 - (length(britney - green) / length(fixed3(1, 1, 1)));
	float britneyAlpha = clamp((greenness - 0.7) / 0.2, 0.0, 1.0);
	return fixed4(britney * (1.0 - britneyAlpha), 1.0) + fixed4(plasma(i.projPos) * britneyAlpha, 1.0);
}
	ENDCG
	}
  }
}

