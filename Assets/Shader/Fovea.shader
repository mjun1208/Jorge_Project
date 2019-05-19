
Shader "ShaderMan/Fovea"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	Pass
	{
	ZWrite Off
	Blend SrcAlpha OneMinusSrcAlpha

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"


	//Variables

//Human fovea detector by nimitz (twitter: @stormoid)

/*
I was playing with procedural texture generation when I came across this.
You might need to tweak the scale value depending on your monitor's ppi.

Different shapes might provide better results, haven't tried many.
*/

//migh need ot tweak this value depending on monitor ppi (tuned for ~100 ppi)
#define scale 60.

#define thickness 0.0
#define lengt 0.13
#define layers 60.
#define time _Time.y*3.

fixed2 hash12(float p)
{
	return frac(fixed2(sin(p * 591.32), cos(p * 391.32)));
}

float hash21(in fixed2 n) 
{ 
	return frac(sin(dot(n, fixed2(12.9898, 4.1414))) * 43758.5453);
}

fixed2 hash22(in fixed2 p)
{
    p = fixed2( dot(p,fixed2(127.1,311.7)), dot(p,fixed2(269.5,183.3)) );
	return frac(sin(p)*43758.5453);
}

fixed2x2 makem2(in float theta)
{
	float c = cos(theta);
	float s = sin(theta);
	return fixed2x2(c,-s,s,c);
}

float field1(in fixed2 p)
{
	fixed2 n = floor(p)-0.5;
    fixed2 f = frac(p)-0.5;
    fixed2 o = hash22(n)*.35;
	fixed2 r = - f - o;
	r =mul(r, makem2(time+hash21(n)*3.14));
	
	float d =  1.0-smoothstep(thickness,thickness+0.09,abs(r.x));
	d *= 1.-smoothstep(lengt,lengt+0.02,abs(r.y));
	
	float d2 =  1.0-smoothstep(thickness,thickness+0.09,abs(r.y));
	d2 *= 1.-smoothstep(lengt,lengt+0.02,abs(r.x));
	
    return max(d,d2);
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

	fixed2 p = i.position.xy / _ScreenParams.xy-0.5;
	p.x *= _ScreenParams.x/_ScreenParams.y;
	
	float mul = (_ScreenParams.x+_ScreenParams.y)/scale;
	
	fixed3 col = fixed3(0,0,0);
	for (float i=0.;i <layers;i++)
	{
		fixed2 ds = hash12(i*2.5)*.20;
		col = max(col,field1((p+ds)*mul)*(sin(ds.x*5100. + fixed3(1.,2.,3.5))*.4+.6));
	}
	
	return fixed4(col,1.0);
}
	ENDCG
	}
  }
}

