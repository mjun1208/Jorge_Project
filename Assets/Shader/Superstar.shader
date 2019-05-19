
Shader "ShaderMan/Superstar"
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
uniform float     iChannelTime[4];       // channel playback time (in seconds)
// Superstar
// By David Hoskins.

#define RES 96.0
#define MOD2 fixed2(.27232,.17369)
#define MOD3 fixed3(.27232,.17369,.20787)

fixed2 add = fixed2(1.0, 0.0);

float Video(fixed2 uv)
{
    fixed2 c = tex2D(iChannel0, uv).xz;
    return max(sqrt((c.x*c.y))-.1, 0.0);
}


//----------------------------------------------------------------------------------------
float GetDotImage(fixed2 uv, float res)
{
	fixed2 st = floor(uv * res) / res;
	float t = Video(st);
	return  smoothstep(t, 0.0, length(frac(uv * res)-.5))*3.;
}

//----------------------------------------------------------------------------------------
///  2 out, 2 in...
fixed2 Hash22(fixed2 p)
{
	fixed3 p3 = frac(fixed3(p.xyx) * MOD3);
    p3 += dot(p3.zxy, p3.yxz+19.19);
    return frac(fixed2(p3.x * p3.y, p3.z*p3.x))-.5;
}
//----------------------------------------------------------------------------------------
//  2 out, 2 in...
fixed2 Noise22(fixed2 x)
{
    fixed2 p = floor(x);
    fixed2 f = frac(x);
    f = f*f*(3.0-2.0*f);
    
    fixed2 res = lerp(lerp( Hash22(p),          Hash22(p + add.xy),f.x),
                    lerp( Hash22(p + add.yx), Hash22(p + add.xx),f.x),f.y);
    return res;
}


//----------------------------------------------------------------------------------------
fixed2 FBM(fixed2 x, float add)
{
    fixed2 r = fixed2(0.0,0);
    float a = 1.0;
    
    for (int i = 0; i < 2; i++)
    {
        r += Noise22(x*a) / a;
        a += a;
    }
    r.x-=add;
     
    return r;
}
//----------------------------------------------------------------------------------------
//  1 out, 1 in ...
float Hash11(float p)
{
	fixed2 p2 = frac(fixed2(p,p) * MOD2);
    p2 += dot(p2.yx, p2.xy+19.19);
	return frac(p2.x * p2.y)-.5;
}

//----------------------------------------------------------------------------------------
//  1 out, 1 in...
float Noise11(float x)
{
    float p = floor(x);
    x = frac(x);
    x = x*x*(3.0-2.0*x);
    x = lerp( Hash11(p), Hash11(p + 1.0), x);
    return x;
}
//----------------------------------------------------------------------------------------
float FBM(float x)
{
    float f = 0.0, m = .8;    
    for (int i = 0; i < 3; i++)
    {
        f+= Noise11(x*m)/m;
        m+=m;
    }
	return f;
}

//----------------------------------------------------------------------------------------
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
    float time = -iChannelTime[0];
    float a = sin(FBM(time*.22+2.75)*6.28)*.2;
    uv.x += a; a= a*3.;
    fixed3 col = fixed3(0,0,0);
    col = fixed3(GetDotImage(uv, RES),GetDotImage(uv, RES),GetDotImage(uv, RES));
    
    for (float y = 0.03; y < .4; y+=.015)
    {
        col.x += Video(uv+FBM(uv*2.4+time*1.5, a)*1.5*y)*(.4-y)*.1;
        col.y += Video(uv+FBM(uv*2.1+time*1.2, a)*1.5*y)*(.4-y)*.07;
        col.z += Video(uv+FBM(uv*2.5+time*1.4, a)*1.5*y)*(.4-y)*.1;


    }
    col = min(col, 1.0);
    return fixed4(sqrt(col), 1.0);
}
	ENDCG
	}
  }
}

