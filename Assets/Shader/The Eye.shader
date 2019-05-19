
Shader "ShaderMan/The Eye"
	{

	Properties{


_Color ("display name", Color) = (1,1,1,1)





	}

	SubShader
	{
	cull off

	Pass
	{

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	  

	struct VertexInput {
    fixed4 vertex : POSITION;
	fixed2 uv:TEXCOORD0;
    fixed4 tangent : TANGENT;
    fixed3 normal : NORMAL;
	//VertexInput
	};


	struct VertexOutput {
	fixed4 pos : SV_POSITION;
	fixed2 uv:TEXCOORD0;
	//VertexOutput
	};

	//Variables
	uniform fixed3 _Color = fixed3(0.6, 0.8, 1.0);

	sampler2D iChannel0;
	// srtuss, 2014

// A fun little effect based on repetition and motion-blur.
// Enjoy staring at the center, in fullscreen! :)

#define pi2 3.1415926535897932384626433832795

fixed2 hash( fixed2 uv )
{
	return tex2D( iChannel0, (uv+0.5)/200.0).xy;
	}
fixed tri(fixed x, fixed s)
{
    return (abs(frac(x / s) - 0.5) - 0.25) * s;
}

fixed hash(fixed x)
{
    return frac(sin(x * 171.2972) * 18267.978 + 31.287);
}

fixed3 pix(fixed2 p, fixed t, fixed s)
{
    s += floor(t * 0.25);
    fixed scl = (hash(s + 30.0) * 4.0);
    scl += sin(t * 2.0) * 0.25 + sin(t) * 0.5;
    t *= 3.0;
    fixed2 pol = fixed2(atan2( p.x,p.y), length(p));
    fixed v;
    fixed id = floor(pol.y * 2.0 * scl);
    pol.x += t * (hash(id + s) * 2.0 - 1.0) * 0.4;
    fixed si = hash(id + s * 2.0);
    fixed rp = floor(hash(id + s * 4.0) * 5.0 + 4.0);
    v = (abs(tri(pol.x, pi2 / rp)) - si * 0.1) * pol.y;
    v = max(v, abs(tri(pol.y, 1.0 / scl)) - (1.0 - si) * 0.11);
    v = smoothstep(0.01, 0.0, v);
    return fixed3(v,v,v);
}

fixed3 pix2(fixed2 p, fixed t, fixed s)
{
    return clamp(pix(p, t, s) - pix(p, t, s + 8.0) + pix(p * 0.1, t, s + 80.0) * 0.2, fixed3(0.0,0.0,0.0), fixed3(1.0,1.0,1.0))*_Color;
}

fixed2 hash2(in fixed2 p)
{
	return frac(1965.5786 * fixed2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

#define globaltime (_Time.y - 2.555)

fixed3 blur(fixed2 p)
{
    fixed3 ite = fixed3(0.0,0.0,0.0);
 
for(int i = 0; i < 20; i ++)
    {
        fixed tc = 0.15;
        ite += pix2(p, globaltime * 3.0 + (hash2(p + fixed(i)) - 0.5).x * tc, 5.0);
    }
    ite /= 20.0;
    ite += exp(frac(globaltime * 0.25 * 6.0) * -40.0) * 2.0;
    return ite;
}





	VertexOutput vert (VertexInput v)
	{
	VertexOutput o;
	o.pos = UnityObjectToClipPos (v.vertex);
	o.uv = v.uv;
	//VertexFactory
	return o;
	}
	fixed4 frag(VertexOutput i) : SV_Target
	{
	
	fixed2 uv = i.uv / 1;


    uv = 2.0 * uv - 1.0;
    uv.x *= 1 / 1;
    uv += (fixed2(hash(globaltime), hash(globaltime + 9.999)) - 0.5) * 0.03;
     fixed3 _Color = fixed3(blur(uv + fixed2(0.005, 0.0)).x, blur(uv + fixed2(0.0, 0.005)).y, blur(uv).z);
    _Color = pow(_Color, fixed3(0.4, 0.6, 1.0) * 2.0) * 1.5;
    _Color *= exp(length(uv) * -1.0) * 2.5;
    _Color = pow(_Color, fixed3(1.0 / 2.2,1.0 / 2.2,1.0 / 2.2));

	return fixed4(_Color , 1.0);

	}
	ENDCG
	}
  }
}

