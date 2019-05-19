
Shader "ShaderMan/More spheres"
	{

	Properties{

	}

	SubShader
	{


	Pass
	{
	cull off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables



uniform int       iFrame;                // shader playback frame
// More spheres. Created by Reinder Nijhoff 2013
// @reindernijhoff
//
// https://www.shadertoy.com/view/lsX3DH
//
// based on: http://www.iquilezles.org/www/articles/simplepathtracing/simplepathtracing.htm
//

#define MOTIONBLUR
#define DEPTHOFFIELD

#define CUBEMAPSIZE 256

#define SAMPLES 8
#define PATHDEPTH 4
#define TARGETFPS 60.

#define FOCUSDISTANCE 17.
#define FOCUSBLUR 0.25

#define RAYCASTSTEPS 20
#define RAYCASTSTEPSRECURSIVE 2

#define EPSILON 0.111
#define MAXDISTANCE 180.
#define GRIDSIZE 8.
#define GRIDSIZESMALL 5.9
#define MAXHEIGHT 10.
#define SPEED 0.5

float time;

//
// math functions

float hash( const float n ) {
	return frac(sin(n)*43758.54554213);
}
fixed2 hash2( const float n ) {
	return frac(sin(fixed2(n,n+1.))*fixed2(43758.5453123,43758.5453123));
}
fixed2 hash2( const fixed2 n ) {
	return frac(sin(fixed2( n.x*n.y, n.x+n.y))*fixed2(25.1459123,312.3490423));
}
fixed3 hash3( const fixed2 n ) {
	return frac(sin(fixed3(n.x, n+2.0))*fixed3(36.5453123,43.1459123,11234.3490423));
}
//
// intersection functions
//

float intersectPlane( const fixed3 ro, const fixed3 rd, const float height) {	
	if (rd.y==0.0) return 500.;	
	float d = -(ro.y - height)/rd.y;
	if( d > 0. ) {
		return d;
	}
	return 500.;
}

float intersectUnitSphere ( const fixed3 ro, const fixed3 rd, const fixed3 sph ) {
	fixed3  ds = ro - sph;
	float bs = dot( rd, ds );
	float cs = dot( ds, ds ) - 1.0;
	float ts = bs*bs - cs;

	if( ts > 0.0 ) {
		ts = -bs - sqrt( ts );
		if( ts > 0. ) {
			return ts;
		}
	}
	return 500.;
}

//
// Scene
//

void getSphereOffset( const fixed2 grid, out fixed2 center ) {
	center = (hash2( grid+fixed2(43.12,1.23) ) - fixed2(0.5,0.5) )*(GRIDSIZESMALL);
}
void getMovingSpherePosition( const fixed2 grid, const fixed2 sphereOffset, out fixed3 center ) {
	// falling?
	float s = 0.1+hash( grid.x*1.23114+5.342+74.324231*grid.y );
	float t = 14.*s + time/s;
	
	float y =  s * MAXHEIGHT * abs( cos( t ) );
	fixed2 offset = grid + sphereOffset;
	
	center = fixed3( offset.x, y, offset.y ) + 0.5*fixed3( GRIDSIZE, 2., GRIDSIZE );
}
void getSpherePosition( const fixed2 grid, const fixed2 sphereOffset, out fixed3 center ) {
	fixed2 offset = grid + sphereOffset;
	center = fixed3( offset.x, 0., offset.y ) + 0.5*fixed3( GRIDSIZE, 2., GRIDSIZE );
}
fixed3 getSphereColor( const fixed2 grid ) {
	fixed3 col = hash3( grid+fixed2(43.12*grid.y,12.23*grid.x) );
    return lerp(col,col*col,.8);
}

fixed3 getBackgroundColor( const fixed3 ro, const fixed3 rd ) {	
	return 1.4*lerp(fixed3(.5,.5,.5),fixed3(.7,.9,1), .5+.5*rd.y);
}

fixed3 trace(const fixed3 ro, const fixed3 rd, out fixed3 intersection, out fixed3 normal, 
           out float dist, out int material, const int steps) {
	dist = MAXDISTANCE;
	float distcheck;
	
	fixed3 sphereCenter, col, normalcheck;
	
	material = 0;
	col = getBackgroundColor(ro, rd);
	
	if( (distcheck = intersectPlane( ro,  rd, 0.)) < MAXDISTANCE ) {
		dist = distcheck;
		material = 1;
		normal = fixed3( 0., 1., 0. );
		col = fixed3(.7,.7,.7);
	} 
	
	// trace grid
	fixed3 pos = floor(ro/GRIDSIZE)*GRIDSIZE;
	fixed3 ri = 1.0/rd;
	fixed3 rs = sign(rd) * GRIDSIZE;
	fixed3 dis = (pos-ro + 0.5  * GRIDSIZE + rs*0.5) * ri;
	fixed3 mm = fixed3(0.0,0.,0.);
	fixed2 offset;
		
	for( int i=0; i<steps; i++ )	{
		if( material == 2 ||  distance( ro.xz, pos.xz ) > dist+GRIDSIZE ) break; {
			getSphereOffset( pos.xz, offset );
			
			getMovingSpherePosition( pos.xz, -offset, sphereCenter );			
			if( (distcheck = intersectUnitSphere( ro, rd, sphereCenter )) < dist ) {
				dist = distcheck;
				normal = normalize((ro+rd*dist)-sphereCenter);
				col = getSphereColor(pos.xz);
				material = 2;
			}
			
			getSpherePosition( pos.xz, offset, sphereCenter );
			if( (distcheck = intersectUnitSphere( ro, rd, sphereCenter )) < dist ) {
				dist = distcheck;
				normal = normalize((ro+rd*dist)-sphereCenter);
				col = getSphereColor(pos.xz+fixed2(1.,2.));
				material = 2;
			}		
			mm = step(dis.xyz, dis.zyx);
			dis += mm * rs * ri;
			pos += mm * rs;		
		}
	}
	
	intersection = ro+rd*dist;
	
	return col;
}

fixed2 rv2;

fixed3 cosWeightedRandomHemisphereDirection2( const fixed3 n ) {
	fixed3  uu = normalize( cross( n, fixed3(0.0,1.0,1.0) ) );
	fixed3  vv = cross( uu, n );
	
	float ra = sqrt(rv2.y);
	float rx = ra*cos(6.2831*rv2.x); 
	float ry = ra*sin(6.2831*rv2.x);
	float rz = sqrt( 1.0-rv2.y );
	fixed3  rr = fixed3( rx*uu + ry*vv + rz*n );

    return normalize( rr );
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

	time = _Time.y;
    fixed2 q = 1.0;
	fixed2 p = -1.0+2.0*q;
	p.x *= 1/1;
	
	fixed3 col = fixed3( 0.,0.,0. );
	
	// raytrace
	int material;
	fixed3 normal, intersection;
	float dist;
	float seed = time+(p.x+_ScreenParams.x*p.y)*1.51269341231;
	
	for( int j=0; j<SAMPLES + min(0,iFrame); j++ ) {
		float fj = float(j);
		
#ifdef MOTIONBLUR
		time = _Time.y + fj/(float(SAMPLES)*TARGETFPS);
#endif
		
		rv2 = hash2( 24.4316544311*fj+time+seed );
		
		fixed2 pt = p+rv2/(0.5*_ScreenParams.xy);
				
		// camera	
		fixed3 ro = fixed3( cos( 0.232*time) * 10., 6.+3.*cos(0.3*time), GRIDSIZE*(time/SPEED) );
		fixed3 ta = ro + fixed3( -sin( 0.232*time) * 10., -2.0+cos(0.23*time), 10.0 );
		
		float roll = -0.15*sin(0.5*time);
		
		// camera tx
		fixed3 cw =normalize(i.worldSpaceView);
		fixed3 cp = fixed3( sin(roll), cos(roll),0.0 );
		fixed3 cu = normalize(i.worldSpaceView);
		fixed3 cv = normalize(i.worldSpaceView);
	
#ifdef DEPTHOFFIELD
    // create ray with depth of field
		static const float fov = 3.0;
		
        fixed3 er = normalize( fixed3( pt.xy, fov ) );
        fixed3 rd = er.x*cu + er.y*cv + er.z*cw;

        fixed3 go = FOCUSBLUR*fixed3( (rv2-fixed2(0.5,0.5))*2., 0.0 );
        fixed3 gd = normalize( er*FOCUSDISTANCE - go );
		
        ro += go.x*cu + go.y*cv;
        rd += gd.x*cu + gd.y*cv;
		rd = normalize(rd);
#else
		fixed3 rd = normalize( pt.x*cu + pt.y*cv + 1.5*cw );		
#endif			
		fixed3 colsample = fixed3( 1.,1.,1. );
		
		// first hit
		rv2 = hash2( (rv2.x*2.4543263+rv2.y)*(time+1.) );
		colsample *= trace(ro, rd, intersection, normal, dist, material, RAYCASTSTEPS);

		// bounces
		for( int i=0; i<(PATHDEPTH-1); i++ ) {
			if( material != 0 ) {
				rd = cosWeightedRandomHemisphereDirection2( normal );
				ro = intersection + EPSILON*rd;
						
				rv2 = hash2( (rv2.x*2.4543263+rv2.y)*(time+1.)+(float(i+1)*.23) );
						
				colsample *= trace(ro, rd, intersection, normal, dist, material, RAYCASTSTEPSRECURSIVE);
			}
		}	
		if( material == 0 ) {			
			col += colsample;	
		}
	}
	col  /= float(SAMPLES);
	col = sqrt(clamp(col, 0., 1.));
	
	return fixed4( col,1.0);
}
	ENDCG
	}
  }
}

