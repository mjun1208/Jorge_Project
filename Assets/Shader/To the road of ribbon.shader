
Shader "ShaderMan/To the road of ribbon"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Cull Off
    ZWrite Off

	Pass
	{


	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables

float tunnel(fixed3 p)
{
	return cos(p.x)+cos(p.y*1.5)+cos(p.z)+cos(p.y*20.)*.05;
}

float ribbon(fixed3 p)
{
	return length(max(abs(p-fixed3(cos(p.z*1.5)*.3,-.5+cos(p.z)*.2,.0))-fixed3(.125,.02,_Time.y+3.),fixed3(.0,.0,.0)));
}

float scene(fixed3 p)
{
	return min(tunnel(p),ribbon(p));
}

fixed3 getNormal(fixed3 p)
{
	fixed3 eps=fixed3(.1,0,0);
	return normalize(fixed3(scene(p+eps.xyy),scene(p+eps.yxy),scene(p+eps.yyx)));
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

	fixed2 v = 1;
	v.x *= _ScreenParams.x/_ScreenParams.y;
 
	fixed4 color = fixed4(0.0,0.,0.,0.);
	fixed3 org   = fixed3(sin(_Time.y)*.5,cos(_Time.y*.5)*.25+.25,_Time.y);
	fixed3 dir   =  normalize(i.worldSpaceView);
	fixed3 p     = org,pp;
	float d    = .0;

	//First raymarching
	for(int i=0;i<64;i++)
	{
	  	d = scene(p);
		p += d*dir;
	}
	pp = p;
	float f=length(p-org)*0.02;

	//Second raymarching (reflection)
	dir=reflect(dir,getNormal(p));
	p+=dir;
	for(int i=0;i<32;i++)
	{
		d = scene(p);
	 	p += d*dir;
	}
	color = max(dot(getNormal(p),fixed3(.1,.1,.0)), .0) + fixed4(.3,cos(_Time.y*.5)*.5+.5,sin(_Time.y*.5)*.5+.5,1.)*min(length(p-org)*.04, 1.);

	//Ribbon Color
	if(tunnel(pp)>ribbon(pp))
		color = lerp(color, fixed4(cos(_Time.y*.3)*.5+.5,cos(_Time.y*.2)*.5+.5,sin(_Time.y*.3)*.5+.5,1.),.3);

	//Final Color
	fixed4 fcolor = ((color+fixed4(f,f,f,f))+(1.-min(pp.y+1.9,1.))*fixed4(1.,.8,.7,1.))*min(_Time.y*.5,1.);
	return fixed4(fcolor.xyz,1.0);
}

	ENDCG
	}
  }
}

