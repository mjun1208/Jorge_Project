
Shader "ShaderMan/Relentless"
	{

	Properties{
	//Properties
	}

	SubShader
	{

	cull off
	ZWrite off
	Blend SrcAlpha OneMinusSrcAlpha
	Pass
	{


	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables

// srtuss, 2013
//
// In this shader I accumulated ideas for a game i was making.
// All geometry is ray-traced.
//
// The effect is inspired by the imges music like this spawns in my mind:
// http://www.youtube.com/watch?v=1uFAu65tZpo
//

// ** improved camera shaking
// ** cleaned up code
// ** added stuff to the gates

//#define GREEN_VERSION

#define time _Time.y

fixed2 rotate(fixed2 p, float a)
{
	return fixed2(p.x * cos(a) - p.y * sin(a), p.x * sin(a) + p.y * cos(a));
}
float box(fixed2 p, fixed2 b, float r)
{
	return length(max(abs(p) - b, 0.0)) - r;
}

// iq's ray-plane-intersection code
fixed3 intersect(in fixed3 o, in fixed3 d, fixed3 c, fixed3 u, fixed3 v)
{
	fixed3 q = o - c;
	return fixed3(
		dot(cross(u, v), q),
		dot(cross(q, u), d),
		dot(cross(v, q), d)) / dot(cross(v, u), d);
}

// some noise functions for fast developing
float rand11(float p)
{
    return frac(sin(p * 591.32) * 43758.5357);
}
float rand12(fixed2 p)
{
    return frac(sin(dot(p.xy, fixed2(12.9898, 78.233))) * 43758.5357);
}
fixed2 rand21(float p)
{
	return frac(fixed2(sin(p * 591.32), cos(p * 391.32)));
}
fixed2 rand22(in fixed2 p)
{
	return frac(fixed2(sin(p.x * 591.32 + p.y * 154.077), cos(p.x * 391.32 + p.y * 49.077)));
}

float noise11(float p)
{
	float fl = floor(p);
	return lerp(rand11(fl), rand11(fl + 1.0), frac(p));//smoothstep(0.0, 1.0, fract(p)));
}
float fbm11(float p)
{
	return noise11(p) * 0.5 + noise11(p * 2.0) * 0.25 + noise11(p * 5.0) * 0.125;
}
fixed3 noise31(float p)
{
	return fixed3(noise11(p), noise11(p + 18.952), noise11(p - 11.372)) * 2.0 - 1.0;
}

// something that looks a bit like godrays coming from the surface
float sky(fixed3 p)
{
	float a = atan2(p.z, p.x);
	float t = time * 0.1;
	float v = rand11(floor(a * 4.0 + t)) * 0.5 + rand11(floor(a * 8.0 - t)) * 0.25 + rand11(floor(a * 16.0 + t)) * 0.125;
	return v;
}

fixed3 voronoi(in fixed2 x)
{
	fixed2 n = floor(x); // grid cell id
	fixed2 f = frac(x); // grid internal position
	fixed2 mg; // shortest distance...
	fixed2 mr; // ..and second shortest distance
	float md = 8.0, md2 = 8.0;
	for(int j = -1; j <= 1; j ++)
	{
		for(int i = -1; i <= 1; i ++)
		{
			fixed2 g = fixed2(float(i), float(j)); // cell id
			fixed2 o = rand22(n + g); // offset to edge point
			fixed2 r = g + o - f;
			
			float d = max(abs(r.x), abs(r.y)); // distance to the edge
			
			if(d < md)
				{md2 = md; md = d; mr = r; mg = g;}
			else if(d < md2)
				{md2 = d;}
		}
	}
	return fixed3(n + mg, md2 - md);
}

#define A2V(a) fixed2(sin((a) * 6.28318531 / 100.0), cos((a) * 6.28318531 / 100.0))

float circles(fixed2 p)
{
	float v, w, l, c;
	fixed2 pp;
	l = length(p);
	
	
	pp = rotate(p, time * 3.0);
	c = max(dot(pp, normalize(fixed2(-0.2, 0.5))), -dot(pp, normalize(fixed2(0.2, 0.5))));
	c = min(c, max(dot(pp, normalize(fixed2(0.5, -0.5))), -dot(pp, normalize(fixed2(0.2, -0.5)))));
	c = min(c, max(dot(pp, normalize(fixed2(0.3, 0.5))), -dot(pp, normalize(fixed2(0.2, 0.5)))));
	
	// innerest stuff
	v = abs(l - 0.5) - 0.03;
	v = max(v, -c);
	v = min(v, abs(l - 0.54) - 0.02);
	v = min(v, abs(l - 0.64) - 0.05);
	
	pp = rotate(p, time * -1.333);
	c = max(dot(pp, A2V(-5.0)), -dot(pp, A2V(5.0)));
	c = min(c, max(dot(pp, A2V(25.0 - 5.0)), -dot(pp, A2V(25.0 + 5.0))));
	c = min(c, max(dot(pp, A2V(50.0 - 5.0)), -dot(pp, A2V(50.0 + 5.0))));
	c = min(c, max(dot(pp, A2V(75.0 - 5.0)), -dot(pp, A2V(75.0 + 5.0))));
	
	w = abs(l - 0.83) - 0.09;
	v = min(v, max(w, c));
	
	return v;
}

float shade1(float d)
{
	float v = 1.0 - smoothstep(0.0, lerp(0.012, 0.2, 0.0), d);
	float g = exp(d * -20.0);
	return v + g * 0.5;
}

struct v2f {
                float4 position : SV_POSITION;
                //float2 uv : TEXCOORD0; // stores uv
                float3 worldSpacePosition : TEXCOORD0;
                float3 worldSpaceView : TEXCOORD1; 
            };
            
            v2f vert(appdata_full i) {
            	
            
                v2f o;
                o.position = UnityObjectToClipPos (i.vertex);
                
                float4 vertexWorld = mul(unity_ObjectToWorld, i.vertex);
                
                o.worldSpacePosition = vertexWorld.xyz;
                o.worldSpaceView = vertexWorld.xyz - _WorldSpaceCameraPos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {

	fixed2 uv = 1;
	uv = uv * 2.0 - 1.0;
	uv.x *= _ScreenParams.x / _ScreenParams.y;
	
	
	// using an iq styled camera this time :)
	// ray origin
	fixed3 ro = 0.7 * fixed3(cos(0.2 * time), 0.0, sin(0.2 * time));
	ro.y = cos(0.6 * time) * 0.3 + 0.65;
	// camera look at
	fixed3 ta = fixed3(0.0, 0.2, 0.0);
	// camera shake intensity
	float shake = clamp(3.0 * (1.0 - length(ro.yz)), 0.3, 1.0);
	float st = fmod(time, 10.0) * 143.0;
	
	// build camera matrix
	fixed3 ww = normalize(ta - ro + noise31(st) * shake * 0.01);
	fixed3 uu = normalize(cross(ww, normalize(fixed3(0.0, 1.0, 0.2 * sin(time)))));
	fixed3 vv = normalize(cross(uu, ww));
	// obtain ray direction
	fixed3 rd =normalize(i.worldSpaceView);
	
	// shaking and movement
	ro += noise31(-st) * shake * 0.015;
	ro.x += time * 2.0;
	
	float inten = 0.0;
	
	// background
	float sd = dot(rd, fixed3(0.0, 1.0, 0.0));
	inten = pow(1.0 - abs(sd), 20.0) + pow(sky(rd), 5.0) * step(0.0, rd.y) * 0.2;
	
	fixed3 its;
	float v, g;
	
	// voronoi floor layers
	for(int i = 0; i < 4; i ++)
	{
		float layer = float(i);
		its = intersect(ro, rd, fixed3(0.0, -5.0 - layer * 5.0, 0.0), fixed3(1.0, 0.0, 0.0), fixed3(0.0, 0.0, 1.0));
		if(its.x > 0.0)
		{
			fixed3 vo = voronoi((its.yz) * 0.05 + 8.0 * rand21(float(i)));
			v = exp(-100.0 * (vo.z - 0.02));
			
			float fx = 0.0;
			
			// add some special fx to lowest layer
			if(i == 3)
			{
				float crd = 0.0;//fract(time * 0.2) * 50.0 - 25.0;
				float fxi = cos(vo.x * 0.2 + time * 1.5);//abs(crd - vo.x);
				fx = clamp(smoothstep(0.9, 1.0, fxi), 0.0, 0.9) * 1.0 * rand12(vo.xy);
				fx *= exp(-3.0 * vo.z) * 2.0;
			}
			inten += v * 0.1 + fx;
		}
	}
	
	// draw the gates, 4 should be enough
	float gatex = floor(ro.x / 8.0 + 0.5) * 8.0 + 4.0;
	float go = -16.0;
	for(int i = 0; i < 4; i ++)
	{
		its = intersect(ro, rd, fixed3(gatex + go, 0.0, 0.0), fixed3(0.0, 1.0, 0.0), fixed3(0.0, 0.0, 1.0));
		if(dot(its.yz, its.yz) < 2.0 && its.x > 0.0)
		{
			v = circles(its.yz);
			inten += shade1(v);
		}
		
		go += 8.0;
	}
	
	// draw the stream
	for(int j = 0; j < 20; j ++)
	{
		float id = float(j);
		
		fixed3 bp = fixed3(0.0, (rand11(id) * 2.0 - 1.0) * 0.25, 0.0);
		fixed3 its = intersect(ro, rd, bp, fixed3(1.0, 0.0, 0.0), fixed3(0.0, 0.0, 1.0));
		
		if(its.x > 0.0)
		{
			fixed2 pp = its.yz;
			float spd = (1.0 + rand11(id) * 3.0) * 2.5;
			pp.y += time * spd;
			pp += (rand21(id) * 2.0 - 1.0) * fixed2(0.3, 1.0);
			float rep = rand11(id) + 1.5;
			pp.y = fmod(pp.y, rep * 2.0) - rep;
			float d = box(pp, fixed2(0.02, 0.3), 0.1);
			float foc = 0.0;
			float v = 1.0 - smoothstep(0.0, 0.03, abs(d) - 0.001);
			float g = min(exp(d * -20.0), 2.0);
			
			inten += (v + g * 0.7) * 0.5;
			
		}
	}
	
	inten *= 0.4 + (sin(time) * 0.5 + 0.5) * 0.6;
	
	// find a color for the computed intensity
#ifdef GREEN_VERSION
	fixed3 col = pow(fixed3(inten), fixed3(2.0, 0.15, 9.0));
#else
	fixed3 col = pow(fixed3(inten,inten,inten), 1.5 * fixed3(0.15, 2.0, 9.0));
#endif
	
return fixed4(col, 1.0);
}
	ENDCG
	}
  }
}

