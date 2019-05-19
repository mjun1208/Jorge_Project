
Shader "ShaderMan/Another Blue World"
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

fixed4 lerp(fixed4 a,fixed4 b, float t)
{
    t = clamp(t, 0.0, 1.0);
    return clamp(t * a + (1.0-t) * b, 0.0, 1.0);
}

fixed4 stepped(fixed4 p, float t)
{
    return fixed4(step(p.r, t), step(p.g, t), step(p.b, t), 1.0);
}

fixed2 quantize(fixed2 uv, float w, float h)
{
    return floor(uv * fixed2(w, h)) / fixed2(w, h);
}

fixed4 metalize(sampler2D from, sampler2D to, fixed2 fragCoord)
{
    fixed2 uv = fragCoord.xy / 1;
    fixed4 f = tex2D(from, uv);
    return tex2D(to, f.xy);
}

fixed4 old_tv(sampler2D tex, fixed2 fragCoord)
{
	fixed2 uv = fragCoord.xy /1;
    float segs =1 / 10.0;
    float ts = sin((fragCoord.y * _Time.y) / segs) / (1/10.0);
    uv.x += ts;    
    return tex2D(tex, uv);
}

fixed4 stepped_blue(sampler2D tex, fixed2 fragCoord)
{
    fixed2 uv = fragCoord.xy /1;
    float t = (1.0 + cos(_Time.y)) / 2.0;
    fixed2 qt = quantize(fixed2(t, t), 50.0, 50.0);
    uv = quantize(uv, 10.0 + qt.x * 1000.0, 10.0 + qt.y * 1000.0);
    fixed4 pix = tex2D(tex, uv);
    return stepped(pix, 0.3);
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
    float t = (1.0 + cos(_Time.y)) / 2.0;
    if(t < 0.3)
    {
    	return stepped_blue(iChannel0, (i.projPos.xy / i.projPos.w));    
    }
    else if(t < 0.6)
    {
        return metalize(iChannel0, iChannel0, (i.projPos.xy / i.projPos.w));
    }
    else
    {
        return old_tv(iChannel0, (i.projPos.xy / i.projPos.w));
    }
    
    
    
    // Metalized
    //fragColor = metalize(iChannel0, iChannel0);
    // Pixelized blue
    //fragColor = stepped(pixa, 0.3);
    //fragColor = sin(_Time.y) * pixa + cos(_Time.y) * pixb;
    //fragColor = lerp(pixa, pixb, (1.0+sin(_Time.y))/2.0);
	//fragColor = fixed4(uv,0.5+0.5*sin(_Time.y),1.0);
}
	ENDCG
	}
  }
}

