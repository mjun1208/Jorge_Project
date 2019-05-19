
Shader "ShaderMan/BlackHole"
	{

	Properties{
	iChannel1 ("iChannel1", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	 pi ("pi", Range(0, 32)) = 16.83625
	}

	 SubShader {
       
        GrabPass{ "iChannel0"}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull Front



	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
float4 _iMouse;
sampler2D iChannel1;

uniform float pi = 3.1415927;

float sdSphere( fixed3 p, float s )
{
  return length(p)-s;
}

float sdCappedCylinder( fixed3 p, fixed2 h )
{
  fixed2 d = abs(fixed2(length(p.xz),p.y)) - h;
  return min(max(d.x,d.y),0.0) + length(max(d,0.0));
}

float sdTorus( fixed3 p, fixed2 t )
{
  fixed2 q = fixed2(length(p.xz)-t.x,p.y);
  return length(q)-t.y;
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

	fixed2 pp =(i.projPos.xy / i.projPos.w);
	pp = -1.0 + 2.0*pp;
	pp.x *= 1/1;

	fixed3 lookAt = fixed3(0.0, -0.1, 0.0);
    
    float eyer = 2.0;
    float eyea = (_iMouse.x / 1) * pi * 2.0;
    float eyea2 = ((_iMouse.y / 1)-0.24) * pi * 2.0;
    
	fixed3 ro = fixed3(
        eyer * cos(eyea) * sin(eyea2),
       eyer * cos(eyea2),
        eyer * sin(eyea) * sin(eyea2)); //camera position
    
    
	fixed3 front = normalize(lookAt - ro);
	fixed3 left = normalize(cross(normalize(fixed3(0.0,1,-0.1)), front));
	fixed3 up = normalize(cross(front, left));
	fixed3 rd = normalize(front*1.5 + left*pp.x + up*pp.y); // rect fixedtor
    
    
    fixed3 bh = fixed3(0.0,0.0,0.0);
    float bhr = 0.3;
    float bhmass = 5.0;
   	bhmass *= 0.001; // premul G
    
    fixed3 p = ro;
    fixed3 pv = rd;
    float dt = 0.02;
    
    fixed3 col = fixed3(0.0,0,0);
    
    float noncaptured = 1.0;
    
    fixed3 c1 = fixed3(0.5,0.35,0.1);
    fixed3 c2 = fixed3(1.0,0.8,0.6);
    
    
    for(float t=0.0;t<1.0;t+=0.005)
    {
        p += pv * dt * noncaptured;
        
        // gravity
        fixed3 bhv = bh - p;
        float r = dot(bhv,bhv);
        pv += normalize(bhv) * ((bhmass) / r);
        
        noncaptured = smoothstep(0.0,0.01,sdSphere(p-bh,bhr));
        
        
        
        // texture the disc
        // need polar coordinates of xz plane
        float dr = length(bhv.xz);
        float da = atan2(bhv.x,bhv.z);
        fixed2 ra = fixed2(dr,da * (0.01 + (dr - bhr)*0.002) + 2.0 * pi + _Time.y*0.02 );
        ra *= fixed2(10.0,20.0);
        
        fixed3 dcol = lerp(c2,c1,pow(length(bhv)-bhr,2.0)) * max(0.0,tex2D(iChannel1,ra*fixed2(0.1,0.5)).r+0.05) * (4.0 / ((0.001+(length(bhv) - bhr)*50.0) ));
        
        col += max(fixed3(0.0,0,0),dcol * step(0.0,-sdTorus( (p * fixed3(1.0,50.0,1.0)) - bh, fixed2(0.8,0.99))) * noncaptured);
        
        //col += dcol * (1.0/dr) * noncaptured * 0.01;
        
        // glow
        col += fixed3(1.0,0.9,0.7) * (1.0/fixed3(dot(bhv,bhv),dot(bhv,bhv),dot(bhv,bhv))) * 0.003 * noncaptured;
        
        //if (noncaptured<1.0) break;
        
    }
    
    // background - projection not right
    //col += pow(texture(iChannel0,pv.xy+fixed2(1.5)).rgb,fixed3(3.0));
    
    
    return fixed4(col,1.0);
}
	ENDCG
	}
  }
}

