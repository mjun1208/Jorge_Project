
Shader "ShaderMan/Apollonian "
	{

	Properties{
time ("tot", Color) = (1,1,1,1)

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
float4 _iMouse;
uniform fixed time;
// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
//
// I can't recall where I learnt about this fractal.
//
// Coloring and fake occlusions are done by orbit trapping, as usual.


// Antialiasing level. Make it 2 or 3 if you have a fast machine
#define AA 1

 fixed4 orb; 	

float map( fixed3 p, float s )
{
	float scale = 1.0;

	orb = fixed4(1000.0,1000.0,1000.0,1000.0); 
	
	for( int i=0; i<8;i++ )
	{
		p = -1.0 + 2.0*frac(0.5*p+0.5);

		float r2 = dot(p,p);
		
        orb = min( orb, fixed4(abs(p),r2) );
		
		float k = s/r2;
		p     *= k;
		scale *= k;
	}
	
	return 0.25*abs(p.y)/scale;
}

float trace( in fixed3 ro, in fixed3 rd, float s )
{
	float maxd = 30.0;
    float t = 0.01;
    for( int i=0; i<200; i++ )
    {
	    float precis = 0.001 * t;
        
	    float h = map( ro+rd*t, s );
        if( h<precis||t>maxd ) break;
        t += h;
    }

    if( t>maxd ) t=-1.0;
    return t;
}

fixed3 calcNormal( in fixed3 pos, in float t, in float s )
{
    float precis = 0.001 * t;

    fixed2 e = fixed2(1.0,-1.0)*precis;
    return normalize( e.xyy*map( pos + e.xyy, s ) + 
					  e.yyx*map( pos + e.yyx, s ) + 
					  e.yxy*map( pos + e.yxy, s ) + 
                      e.xxx*map( pos + e.xxx, s ) );
}

fixed3 render( in fixed3 ro, in fixed3 rd, in float anim )
{
    // trace	
    fixed3 col = fixed3(0.0,0.0,0.0);
    float t = trace( ro, rd, anim );
    if( t>0.0 )
    {
        fixed4 tra = orb;
        fixed3 pos = ro + t*rd;
        fixed3 nor = calcNormal( pos, t, anim );

        // lighting
        fixed3  light1 = fixed3(  0.577, 0.577, -0.577 );
        fixed3  light2 = fixed3( -0.707, 0.000,  0.707 );
        float key = clamp( dot( light1, nor ), 0.0, 1.0 );
        float bac = clamp( 0.2 + 0.8*dot( light2, nor ), 0.0, 1.0 );
        float amb = (0.7+0.3*nor.y);
        float ao = pow( clamp(tra.w*2.0,0.0,1.0), 1.2 );
        fixed3 brdf  = 1.0*fixed3(0.40,0.40,0.40)*amb*ao;
        brdf += 1.0*fixed3(1.00,1.00,1.00)*key*ao;
        brdf += 1.0*fixed3(0.40,0.40,0.40)*bac*ao;

        // material		
        fixed3 rgb = fixed3(1.0,1.0,1.0);
        rgb = lerp( rgb, fixed3(1.0,0.40,0.8), clamp(6.0*tra.y,0.0,1.0) );
        rgb = lerp( rgb, fixed3(1.0,0.15,0.0), pow(clamp(1.0-2.0*tra.z,0.0,1.0),8.0) );

        // color
        col = rgb*brdf*exp(-0.2*t);
    }

    return sqrt(col);
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

    float time = _Time.y*0.25 + 0.01*_iMouse.x;
    float anim = 1.1 + 0.5*smoothstep( -0.3, 0.3, cos(0.1*_Time.y) );
    
    fixed3 tot = fixed3(0.0,0,0);
    #if AA>1
    for( int jj=0; jj<AA; jj++ )
    for( int ii=0; ii<AA; ii++ )
    #else
    int ii = 1, jj = 1;
    #endif
    {
        fixed2 q =1;
        fixed2 p = (2.0*q-1)/1;

        // camera
        fixed3 ro = fixed3( 2.8*cos(0.1+.33*time), 0.4 + 0.30*cos(0.37*time), 2.8*cos(0.5+0.35*time) );
        fixed3 ta = fixed3( 1.9*cos(1.2+.41*time), 0.4 + 0.10*cos(0.27*time), 1.9*cos(2.0+0.38*time) );
        float roll = 0.2*cos(0.1*time);
        fixed3 cw = normalize(i.worldSpaceView);
        fixed3 cp = fixed3(sin(roll), cos(roll),0.0);
        fixed3 cu = normalize(i.worldSpaceView);
        fixed3 cv =  normalize(i.worldSpaceView);
        fixed3 rd =  normalize(i.worldSpaceView);

        tot += render( ro, rd, anim );
    }
    
    tot = tot/float(AA*AA);
    
	return fixed4( tot, 1.0 );	

}


	ENDCG
	}
  }
}

