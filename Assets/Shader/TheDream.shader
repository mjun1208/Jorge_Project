
Shader "ShaderMan/TheDream"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
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



	//Variables
sampler2D iChannel1;
sampler2D iChannel0;

static const fixed3 col1 = fixed3(0.659, 0.435, 0.18);
static const fixed3 col2 = fixed3(0.455, 0.349, 0.059);
static const fixed3 col3 = fixed3(0.667, 0.569, 0.514);

float hash( float n ) { return frac(sin(n)*13.5453123); }
fixed2 hash2(fixed2 p) { return fixed2(hash(p.x), hash(p.y)); }

fixed2x2 rot(float x)
{
    return fixed2x2(cos(x), sin(x), -sin(x), cos(x));
}

float sdBox( fixed3 p, fixed3 b )
{
  fixed3 d = abs(p) - b;
  return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdBoxZ( fixed3 p, fixed3 b )
{
  fixed3 d = abs(p) - b;
  return min(max(d.x,d.y),0.0) + length(max(d.xy,0.0));
}

float cylinder(fixed3 p, fixed2 b)
{
    float d = length(p.yz) - b.x;
    float k = b.y - abs(p.x);
    return max(d, -k);
}

float mid = 0.0;
fixed3 mpos = fixed3(0.0,0,0);

static const float rs = 11.0;
static const float hs = 6.0;

float picpos(fixed3 p)
{
    return floor(p.z / hs + 0.5) + floor(p.x / rs * 7.0 + 0.5);
}

static const float cam = 0.25;

float map(fixed3 p)
{
    p.y += sin(p.z * cam);
    
    mid = 0.0;
    mpos = p;
    
    float rw = 4.2;
    float rh = 4.0;
    float fx = (frac(p.x / rs - 0.5) - 0.5) * rs;
    fixed3 rp = fixed3(p.x, p.y, p.z);
	float rd = -sdBoxZ(rp, fixed3(rw, rh, 1.0));

    fixed3 kp = fixed3(abs(p.x) - rw * 1.75 - 1.0, p.y, p.z);
    float kd = -sdBoxZ(kp, fixed3(rw * 0.75, rh, 1.0));
    if (kd > rd) {
        rd = kd;
        mid = 3.0;
    }
    
    float ct = 0.1;
    float ax = abs(p.x) - rw + ct;
    float cx = (frac(ax / rs - 0.5) - 0.5) * rs;
    fixed3 hp = fixed3(ax, p.y, (frac(p.z / hs) - 0.5) * hs);
    float hd = -sdBox(hp, fixed3(2.0, 2.0, 1.5));
    
    float d = rd;
    if (hd > rd) {
        d = hd;
        mid = 1.0;
    }

    fixed3 cp = fixed3(ax, p.y, (frac(p.z / hs + 0.5) - 0.5) * hs);
    cp.yz = mul(cp.yz,rot(_Time.y * 1.25 + picpos(p)));
    float cd = cylinder(cp, fixed2(2.0, ct));
    
    if (cd < d) {
        d = cd;
        mid = 2.0;
        mpos = cp;
    }
    
    return d;
}

fixed3 normal(fixed3 p)
{
	fixed3 o = fixed3(0.01, 0.0, 0.0);
    return normalize(fixed3(map(p+o.xyy) - map(p-o.xyy),
                          map(p+o.yxy) - map(p-o.yxy),
                          map(p+o.yyx) - map(p-o.yyx)));
}

float trace(fixed3 o, fixed3 r)
{
    float t = 0.0;
    for (int i = 0; i < 40; ++i) {
        t += map(o + r * t);
    }
    return t;
}

fixed3 strips(fixed2 p)
{
    float gap = 0.25;
    float fy = frac(p.y);
    float kx = max(fy - gap, 0.0) / (1.0 - gap);
    float ky = min(fy, gap) / gap;
    float ku = 4.0 * kx * (1.0 - kx);
    ku = 1.0 - pow(1.0 - ku, 5.0);
    fixed3 tex = tex2D(iChannel0, p * 0.1).xyz;
    tex *= tex;
    float dark = 1.0 - ky;
    dark = dark * dark;
    fixed3 gs = lerp(col3 * 0.125, col3, dark);
    return tex * (col3 * ku + gs);
}

fixed3 tiles(fixed2 p)
{
    p *= 0.5;
    fixed2 f = frac(p);
    float gap = 0.01;
    fixed2 kx = max(f - gap, 0.0) / (1.0 - gap);
    fixed2 ky = min(f, gap) / gap;
    fixed2 ku = 4.0 * kx * (1.0 - kx);
    ku = pow(1.0 - ku, fixed2(5.0,5.0));
    fixed2 fp = floor(p);
    fixed2 tu = hash2(fp) * 1000.0 + frac(p);
    fixed3 tex = tex2D(iChannel1, tu * 0.1).xyz;
    tex *= tex;
    float bwt = dot(tex, fixed3(0.299, 0.587, 0.114));
    float alt = fmod(fp.x + fp.y, 2.0);
    float gc = max(ku.x, ku.y);
    fixed3 gl = lerp(col3 * bwt * 0.5, col3 * (1.0 - bwt), alt);
    fixed3 gs = lerp(col1, col1 * 0.125, max(ku.x, ku.y));
    return lerp(gl, gs, gc);
}

fixed3 picture(fixed3 p, fixed3 w)
{
    fixed2 q = p.yz;
    q *= 0.5;
    float d = 1000.0;
    fixed2 tuv = fixed2(0.0,0);
    float fid = 0.0;
    float pp = picpos(w) * 3.14159 * 0.125;
    const int n = 5;
    for (int i = 0; i < n; ++i) {
        float fi = float(i) / float(n);
        q = abs(q) - 0.25;
        q =mul(q,rot(3.14159 * 0.25 + pp * 3.345));
        q.y = abs(q.y) - 0.25;
        q =mul(q, rot(pp));
        float b = sdBoxZ(fixed3(q, 0.0), fixed3(0.5, 0.125, 1.0));
        if (b < d) {
            d = b;
            tuv = q;
            fid = fi;
        }
    }
    fixed3 tex = tex2D(iChannel1, tuv * 0.1).xyz;
    tex *= tex;
    tex = lerp(col3, tex * col3, 1.0-fid);
    return tex;
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

	fixed2 uv =1;
    uv = uv * 2.0 - 1.0;
    uv.x *= 1 / 1;
    
    fixed3 o = fixed3(0.0, 0.0, _Time.y * 2.0);
    fixed3 r = normalize(i.worldSpaceView);
    
    o.y -= sin(o.z * cam);
    r.xy =mul(r.xy, rot(sin(_Time.y * 0.125) * 3.14159 * 0.125));
    
    float t = trace(o, r);
    fixed3 w = o + r * t;
    fixed3 sn = normal(w);
    
    fixed3 tex = fixed3(1.0,1.0,1.0);

    if (mid == 1.0) {
        if (abs(sn.y) < 0.1) {
            tex = strips(mpos.xy);
        } else {
            tex = strips(mpos.xy);
        }
    } else if (mid == 2.0) {
        if (abs(sn.x) < 0.1) {
            tex = col1 * 0.25;
        } else {
            tex = picture(mpos, w);
        }
    } else if (mid == 3.0) {
        fixed2 st = mpos.yz - 2.0 * fixed2(0.0, o.z);
        tex = tiles(st);
    } else if (abs(sn.y) < 0.1) {
        tex = strips(mpos.zy);
    } else {
        fixed2 st = mpos.xz + fixed2(0.0, o.z);
        tex = tiles(st);
    }
    
    fixed3 lit = fixed3(0.3,0.3,0.3);
    
    fixed3 lpos = o + fixed3(0.0, 0.0, 0.0);
    lpos += fixed3(0.0, 0.0, 0.0);
    fixed3 ldel = w - lpos;
    float ldist = length(ldel);
    ldel /= ldist;
    float lm = max(dot(ldel, -sn), 0.0);
    lm /= 1.0 + ldist * ldist * 0.1;
    lit += fixed3(lm,lm,lm) * col3 * 2.0;
    
	float aoc = map(w + sn * 1.2);
    float fog = 1.0 / (1.0 + t * t * 0.001);
    fixed3 fc = lit * tex * aoc * fog;
	return fixed4(sqrt(fc), 1.0);
}
	ENDCG
	}
  }
}

