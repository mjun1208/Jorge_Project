
Shader "ShaderMan/Analytic Motionblur 2D"
	{

	Properties{
	//Properties
	}

	SubShader
	{


	Pass
	{
	Blend SrcAlpha One 
	cull off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	struct appdata{
    float4 vertex : POSITION;
	float2 uv:TEXCOORD0;
	};

	struct v2f
    {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 screenCoord : TEXCOORD1;
    };

    v2f vert(appdata v)
    {
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.screenCoord.xy = ComputeScreenPos(o.vertex);
    return o;
    }

// The MIT License
// Copyright © 2014 Inigo Quilez
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


// Analytic motion blur, for 2D spheres (disks).
//
// (Linearly) Moving Disk - pixel/ray overlap test. The resulting equation is a quadratic 
// that can be solved to compute time coverage of the swept disk behind the pixel over the
// aperture of the camera (a full frame at 24 hz in this test).



// draw a disk with motion blur
fixed3 diskWithMotionBlur( fixed3 col, in fixed2 uv, in fixed3 sph, in fixed2 cd, in fixed3 sphcol )
{
	fixed2 xc = uv - sph.xy;
	float a = dot(cd,cd);
	float b = dot(cd,xc);
	float c = dot(xc,xc) - sph.z*sph.z;
	float h = b*b - a*c;
	if( h>0.0 )
	{
		h = sqrt( h );
		
		float ta = max( 0.0, (-b - h)/a );
		float tb = min( 1.0, (-b + h)/a );
		
		if( ta < tb ) // we can comment this conditional, in fact
		    col = lerp( col, sphcol, clamp(2.0*(tb-ta),0.0,1.0) );
	}

	return col;
}


fixed3 hash3( float n ) { return frac(sin(fixed3(n,n+1.0,n+2.0))*43758.5453123); }
fixed4 hash4( float n ) { return frac(sin(fixed4(n,n+1.0,n+2.0,n+3.0))*43758.5453123); }

static const float speed = 8.0;
fixed2 getPosition( float time, fixed4 id ) { return fixed2(       0.9*sin((speed*(0.75+0.5*id.z))*time+20.0*id.x),        0.75*cos(speed*(0.75+0.5*id.w)*time+20.0*id.y) ); }
fixed2 getVelocity( float time, fixed4 id ) { return fixed2( speed*0.9*cos((speed*(0.75+0.5*id.z))*time+20.0*id.x), -speed*0.75*sin(speed*(0.75+0.5*id.w)*time+20.0*id.y) ); }

fixed4 frag(v2f i) : SV_Target{

	fixed2 p = (2.0*i.uv.xy-1) / 1;
	
	fixed3 col = fixed3(0.2,0.2,0.2) + 0.05*p.y;
	
	for( int i=0; i<16; i++ )
	{		
		fixed4 off = hash4( float(i)*13.13 );
        fixed3 sph = fixed3( getPosition( _Time.y, off ), 0.02+0.1*off.x );
        fixed2 cd = getVelocity( _Time.y, off ) /24.0 ;
		fixed3 sphcol = 0.7 + 0.3*sin( 3.0*off.z + fixed3(4.0,0.0,2.0) );
		
        col = diskWithMotionBlur( col, p, sph, cd, sphcol );
	}		

    col += (1.0/255.0)*hash3(p.x+13.0*p.y);

	return fixed4(col,1.0);
}
	ENDCG
	}
  }
}

