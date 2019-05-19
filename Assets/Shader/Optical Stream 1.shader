
Shader "ShaderMan/Optical Stream 1"
	{

	Properties{
	PI ("PI name", Range (0, 50)) = 1
	}

	SubShader
	{
	Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
	 Blend SrcColor one
	cull off
	ZWrite Off
           Ztest Always

	Pass
	{

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



uniform float PI = 3.1415926;

fixed3 rgb2hsv(fixed3 hsv)
{
	fixed4 t = fixed4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	fixed3 p = abs(frac(fixed3(hsv.x,hsv.x,hsv.x) + t.xyz) * 6.0 - fixed3(t.w,t.w,t.w));
	return hsv.z * lerp(fixed3(t.x,t.x,t.x), clamp(p - fixed3(t.x,t.x,t.x), 0.0, 1.0), hsv.y);
}

fixed2x2 rotate(float a)
{
	float s = sin(a);
	float c = cos(a);
	return fixed2x2(
		c, -s,
		s, c
	);
}

float rand(fixed4 co)
{
    return frac(sin(dot(co, fixed4(12.9898, 78.233, 15.2358, 29.23851))) * 43758.5453);
}

float groundDist(fixed3 pos)
{
	pos.y += sin(pos.z * 0.2 + pos.x + _Time.y * 10.0) * 0.5;
	pos.x = fmod(pos.x, 4.0) - 2.0;
	return length(pos.yx);
}

float particleDist(fixed3 pos)
{
    pos += cross(sin(pos * 0.05 + _Time.y), cos(pos * 0.05 + _Time.y)) * 3.0;
    pos.z += _Time.y * 200.0;
    fixed3 id = floor(pos / 16.0);
    pos = fmod(pos, 16.0) - 8.0;
    pos += fixed3(rand(fixed4(id, 0.0)), rand(fixed4(id, 1.0)), rand(fixed4(id, 2.0))) * 10.0 - 5.0;
	return max(length(pos.yx), abs(pos.z) - 2.0);
}

float skyDist(fixed3 pos)
{
	pos.z += _Time.y * 50.0;
    fixed3 id = floor(pos / 50.0);
    
    fixed3 t = _Time.y * fixed3(0.0125, 0.25, 0.5);
    fixed3 a = fixed3(rand(fixed4(id, floor(t.x))), rand(fixed4(id + 10.0, floor(t.y))), rand(fixed4(id + 20.0, floor(t.z))));
    fixed3 b = fixed3(rand(fixed4(id, floor(t.x + 1.0))), rand(fixed4(id + 10.0, floor(t.y + 1.0))), rand(fixed4(id + 20.0, floor(t.z + 1.0))));
    fixed3 c = lerp(a, b, pow(frac(t), fixed3(1.0 / 4.0,1.0 / 4.0,1.0 / 4.0)));
    
    float s = sign(fmod(id.x + id.y + id.z + 0.5, 2.0) - 1.0);
    fixed3 u = _Time.y / 3.0 + fixed3(1.0, 2.0, 3.0) / 3.0;
    fixed3 d = floor(u);
    fixed3 e = floor(u + 1.0);
    fixed3 f = lerp(d, e, pow(frac(u), fixed3(1.0 / 8.0,1.0 / 8.0,1.0 / 8.0)));
    
	pos = fmod(pos, 50.0) - 25.0;
	for (int i = 0; i < 3; ++i)
	{
	    pos.yz = mul(rotate(f.x * PI / 2.0 * s) , pos.yz);
	    pos.xz =  mul (rotate(f.y * PI / 2.0 * s) , pos.xz);
	    pos.xy = mul (rotate(f.z * PI / 2.0 * s) , pos.xy);
		pos = abs(pos);
		pos -= (c * 12.0);
		pos *= 2.0;
		if (pos.x > pos.z) pos.xz = pos.zx;
		if (pos.y > pos.z) pos.yz = pos.zy;
		if (pos.x < pos.y) pos.xy = pos.yx;
	}
	return length(pos.xz) / 8.0;
}

float dist(fixed3 pos)
{
	float d = 3.402823466E+38;
	d = min(d, groundDist(pos));
	d = min(d, skyDist(pos));
	return d;
}

fixed3 calcNormal(fixed3 pos)
{
	fixed2 ep = fixed2(0.001, 0.0);
	return normalize(fixed3(
		dist(pos + ep.xyy) - dist(pos - ep.xyy),
		dist(pos + ep.yxy) - dist(pos - ep.yxy),
		dist(pos + ep.yyx) - dist(pos - ep.yyx)
	));
}

fixed3 calcColor(fixed3 pos)
{
	return rgb2hsv(fixed3(pos.x * 0.04 + _Time.y, 1, 1));
}

fixed3 march(fixed3 pos, fixed3 dir)
{
    fixed3 color = fixed3(0.0, 0.0, 0.0);
	for (int i = 0; i < 32; ++i)
	{
		float d = dist(pos);
		pos += dir * d * 0.9;
		color += max(fixed3(0.0,0,0), 0.02 / d * calcColor(pos));
	}
	
	return color;
}

fixed3 marchParticle(fixed3 pos, fixed3 dir)
{
    fixed3 color = fixed3(0.0, 0.0, 0.0);
	for (int i = 0; i < 32; ++i)
	{
		float d = particleDist(pos);
		pos += dir * d * 0.9;
		color += max(fixed3(0.0,0,0), 0.005 / d * fixed3(1.0, 1.0, 1.0));
	}
	
	return color;
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


	fixed2 p = _WorldSpaceCameraPos;
	
	fixed3 pos = fixed3(400.0, 800.0, 100);
	fixed3 dir =normalize(i.worldSpaceView);
	dir.yz = mul(rotate(-0.5) , dir.yz);
	pos.yz =mul( rotate(-0.5) , pos.yz);
	dir.xz = mul(rotate(sin(_Time.y) * 0.5) , dir.xz);
	pos.xz = mul(rotate(sin(_Time.y) * 0.1) , pos.xz);
	dir.xy = mul(rotate(0.1 + sin(_Time.y * .7) * 1.1) , dir.xy);
	pos.xy = mul(rotate(0.1 + sin(_Time.y * 0.7) * 0.1) , pos.xy);
	
	fixed3 color = fixed3(0, 0, 0) * length(p.xy) * sin(_Time.y * 10.0);
	
	color += march(pos, dir);
	color += marchParticle(pos, dir);
	
	return fixed4(color, 1.0);
}
	ENDCG
	}
  }
}

