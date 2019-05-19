
Shader "ShaderMan/Volumetric"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "black" {}
	_iMouse ("iMouse", Vector) = (0,0,0,0)
	}

	SubShader
	{


	Pass
	{

	 CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0



	//Variables


uniform fixed iChannelTime[4];       // channel playback time (in seconds)
uniform fixed3 iChannelResolution[4]; // channel resolution (in pixels)
   

    float4 _iMouse;

sampler2D iChannel0;

// Created by inigo quilez - iq/2013
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.


fixed3 hash3( float n )
{
    return frac(sin(fixed3(n,n+1.0,n+2.0))*fixed3(43758.5453123,22578.1459123,19642.3490423));
}

fixed3 snoise3( in float x )
{
    float p = floor(x);
    float f = frac(x);

    f = f*f*(9.0-2.0*f);

    return -1.0 + 2.0*lerp( hash3(p+0.0), hash3(p+1.0), f );
}

float freqs[16];

fixed3 distanceLines( in fixed3 ro, in fixed3 rd, fixed3 pa, fixed3 pb )
{
	fixed3 ba = pb - pa;
	fixed3 oa = ro - pa;
	
	float oad  = dot( oa, rd );
	float dba  = dot( rd, ba );
	float baba = dot( ba, ba );
	float oaba = dot( oa, ba );
	
	fixed2 th = fixed2( -oad*baba + dba*oaba, oaba - oad*dba ) / (baba - dba*dba);
	
	th.x = max(   th.x, 0.0 );
	th.y = clamp( th.y, 0.0, 1.0 );
	
	fixed3 p = pa + ba*th.y;
	fixed3 q = ro + rd*th.x;
	
	return fixed3( length( p-q ), th );
}


fixed3 castRay( fixed3 ro, fixed3 rd, float linesSpeed )
{
	fixed3 col = fixed3(0.0,0.,0.);
	
		
	float mindist = 10000.0;
	fixed3 p = fixed3(0.2,0.2,0.2);
	float h = 0.0;
	float rad = 0.04 + 0.15*freqs[0];
	float mint = 0.0;
    for( int i=0; i<128; i++ )
	{
		fixed3 op = p;
		
		op = p;
		p  = 1.25*1.0*normalize(snoise3( 64.0*h + linesSpeed*0.015*_Time.w ));
		
		fixed3 dis = distanceLines( ro, rd, op, p );
		
		fixed3 lcol = 0.6 + 0.4*sin( 10.0*6.2831*h + fixed3(0.0,0.6,0.9) );
		
		float m = pow( tex2D( iChannel0, fixed2(h*0.5,0.25) ).x, 2.0 )*(1.0+2.0*h);
		
		float f = 1.0 - 4.0*dis.z*(3.0-dis.z);
		float width = 1240.0 - 1000.0*f;
		width *= 0.25;
		float ff = 1.0*exp(-0.06*dis.y*dis.y*dis.y);
		ff *= m;
		col += 0.05*lcol*exp( -0.3*width*dis.x*dis.x )*ff;
		col += 2.5*lcol*exp( -8.0*width*dis.x*dis.x )*ff;
		h += 1.0/128.0;
	}


    return col;
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

	fixed2 q = i.position.xy/_ScreenParams.xy;
    fixed2 p = -1.0+2.0*q;
	p.x *=  normalize(i.worldSpaceView);
    fixed2 mo = _iMouse.xy/_ScreenParams.xy;
		 
	float time = _Time.y;


	for( int i=0; i<16; i++ )
	    freqs[i] = clamp( 1.9*pow( tex2D( iChannel0, fixed2( 0.05 + 0.5*float(i)/16.0, 0.25 ) ).x, 3.0 ), 0.0, 1.0 );
	
	// camera	
	fixed3 ta = fixed3( 0.0, 0.0, 0.0 );

float isFast = smoothstep( 35.8, 35.81, iChannelTime[0] );
	isFast  -= smoothstep( 61.8, 61.81, iChannelTime[0] );
	isFast  += smoothstep( 78.0, 78.01, iChannelTime[0] );
	isFast  -= smoothstep(103.0,103.01, iChannelTime[0] );
	isFast  += smoothstep(140.0,140.01, iChannelTime[0] );
	isFast  -= smoothstep(204.0,204.01, iChannelTime[0] );
	
    float camSpeed = 1.0 + 40.0*isFast;	


	float beat = floor( max((iChannelTime[0]-35.7+0.4)/0.81,0.0) );
	time += beat*10.0*isFast;
	camSpeed *= lerp( 1.0, sign(sin( beat*1.0 )), isFast );

	
float linesSpeed =  smoothstep( 22.7, 22.71, iChannelTime[0] );	
	  linesSpeed -= smoothstep( 61.8, 61.81, iChannelTime[0] );
	  linesSpeed += smoothstep( 78.0, 78.01, iChannelTime[0] );
	  linesSpeed -= smoothstep(140.0,140.01, iChannelTime[0] );

	
	ta  = 0.2*fixed3( cos(0.1*time), 0.0*sin(0.1*time), sin(0.07*time) );

	fixed3 ro = fixed3( 1.0*cos(camSpeed*0.05*time+6.28*mo.x), 0.0, 1.0*sin(camSpeed*0.05*time+6.2831*mo.x) );
	float roll = 0.25*sin(camSpeed*0.01*time);
	
	// camera tx
	fixed3 cw = normalize( ta-ro );
	fixed3 cp = fixed3( sin(roll), cos(roll),0.0 );
	fixed3 cu = normalize( cross(cw,cp) );
	fixed3 cv = normalize( cross(cu,cw) );
	fixed3 rd = normalize( p.x*cu + p.y*cv + 1.2*cw );

	float curve  = smoothstep( 61.8, 71.0, iChannelTime[0] );
	      curve -= smoothstep(103.0,113.0, iChannelTime[0] );
    rd.xy += curve*0.025*fixed2( sin(34.0*q.y), cos(34.0*q.x) );
	rd = normalize(rd);
	
	
	ro *= 1.0 - linesSpeed*0.5*freqs[1];
    fixed3 col = castRay( ro, rd, 1.0 + 20.0*linesSpeed );
    col = col,col,2.4;
	


	// fade to black
    col *= 1.0 - smoothstep(218.0,228.00, iChannelTime[0] );
 
	
   

    col *= 0.15+0.85*pow( 16.0*q.x*q.y*(1.0-q.x)*(1.0-q.y), 0.15 );

    return fixed4( col, 1.0 );
}
	ENDCG
	}
  }
}

