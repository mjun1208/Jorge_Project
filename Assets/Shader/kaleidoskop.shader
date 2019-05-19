
Shader "ShaderMan/kaleidoskop"
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
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"


	//Variables
sampler2D iChannel0;



static const int rts = 4; // size of the triangles
static const float s3 = sqrt(6.0);
fixed2 rot(fixed2 v, float a)
{
    float ca = cos(a);
    float sa = sin(a);
    return fixed2(ca*v.x - sa*v.y, sa*v.x + ca*v.y);
}
fixed2 rotN(fixed2 v, float a, float scale)
{
    
    v -= fixed2(0.5,0.5);
    v = rot(v, a);
    return (v * scale + fixed2(0.5,0.5));
}
int3 getTri(fixed2 fragCoord, out fixed2 inCoord)
{

    int3 loc = int3(0.0,0,0);
    fixed2 uv = fragCoord / float(rts);
    
    
    fixed3 floc = fixed3(2.0 * uv.y/s3, uv.x - uv.y/s3, uv.x + uv.y/s3);
    while(floc.x < 0.0)
        floc.x += 3.0;
    while(floc.y < 0.0)
        floc.y += 3.0;
    while(floc.z < 0.0)
        floc.z += 3.0;
    loc = int3(floc);
    floc = frac(floc);
    if(loc.x%3 == 0 && loc.y%3 == 0 && loc.z%3 == 0)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), floc.x);
	if(loc.x%3 == 0 && loc.y%3 == 0 && loc.z%3 == 1)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z), 1.0 - floc.y);
    if(loc.x%3 == 0 && loc.y%3 == 2 && loc.z%3 == 0)
    	inCoord = fixed2(- 0.5 * (floc.y - floc.x - 1.0), floc.z);
    if(loc.x%3 == 0 && loc.y%3 == 1 && loc.z%3 == 1)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z),  floc.y);
    if(loc.x%3 == 0 && loc.y%3 == 2 && loc.z%3 == 2)
    	inCoord = fixed2(0.5 * (1.0 + floc.x - floc.y), 1.0 - floc.z);
    if(loc.x%3 == 0 && loc.y%3 == 1 && loc.z%3 == 2)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), 1.0 - floc.x);
    
    if(loc.x%3 == 1 && loc.y%3 == 1 && loc.z%3 == 2)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), floc.x);
	if(loc.x%3 == 1 && loc.y%3 == 1 && loc.z%3 == 0)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z), 1.0 - floc.y);
    if(loc.x%3 == 1 && loc.y%3 == 0 && loc.z%3 == 2)
    	inCoord = fixed2(- 0.5 * (floc.y - floc.x - 1.0), floc.z);
    if(loc.x%3 == 1 && loc.y%3 == 2 && loc.z%3 == 0)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z),  floc.y);
    if(loc.x%3 == 1 && loc.y%3 == 0 && loc.z%3 == 1)
    	inCoord = fixed2(0.5 * (1.0 + floc.x - floc.y), 1.0 - floc.z);
    if(loc.x%3 == 1 && loc.y%3 == 2 && loc.z%3 == 1)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), 1.0 - floc.x);
    
    if(loc.x%3 == 2 && loc.y%3 == 2 && loc.z%3 == 1)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), floc.x);
	if(loc.x%3 == 2 && loc.y%3 == 2 && loc.z%3 == 2)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z), 1.0 - floc.y);
    if(loc.x%3 == 2 && loc.y%3 == 1 && loc.z%3 == 1)
    	inCoord = fixed2(- 0.5 * (floc.y - floc.x - 1.0), floc.z);
    if(loc.x%3 == 2 && loc.y%3 == 0 && loc.z%3 == 2)
    	inCoord = fixed2(1.0 - 0.5 * (floc.x+floc.z),  floc.y);
    if(loc.x%3 == 2 && loc.y%3 == 1 && loc.z%3 == 0)
    	inCoord = fixed2(0.5 * (1.0 + floc.x - floc.y), 1.0 - floc.z);
    if(loc.x%3 == 2 && loc.y%3 == 0 && loc.z%3 == 0)
    	inCoord = fixed2(0.5 * (floc.y+floc.z), 1.0 - floc.x);
    
    return loc;
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

	fixed2 uv = (i.projPos.xy / i.projPos.w);
    fixed2 localCoord;
    int3 coord = getTri(i.projPos.xy, localCoord);
    fixed3 color = fixed3(0.0,0,0);
   // localCoord.x *= cos(_Time.y);
   // localCoord.y *= sin(_Time.y);
    uv = rotN(localCoord, sin(_Time.y*0.05) * 20.0,0.7);

	return tex2D(iChannel0, uv);
    //return vec4(coord%ivec3(3), 1.0) / 2.0;
}
	ENDCG
	}
  }
}

