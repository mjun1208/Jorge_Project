
Shader "ShaderMan/La calanque"
	{

	Properties{
	//Properties
	}

	SubShader
	{

	cull off
	Pass
	{

	CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0




	//Variables

// Created by anatole duprat - XT95/2015
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

float map( in fixed3 p);
fixed3 shade( in fixed3 p, in fixed3 n, in fixed3 ro, in fixed3 rd);

fixed2 rotate( fixed2 v, float a);
fixed3 seaHit( in fixed3 ro, in fixed3 rd, float h, out float t );
fixed3 raymarch( in fixed3 ro, in fixed3 rd, in fixed2 clip);
fixed3 raymarchSmall( in fixed3 ro, in fixed3 rd, in fixed2 clip);

fixed3 normal( in fixed3 p, in float e );
float ambientOcclusion(fixed3 p, fixed3 n, fixed2 a);

float noise( in fixed3 x );
float displacement( fixed3 p );
fixed3 skyColor( in fixed3 rd);






//Distance field maps
float rock( in fixed3 p)
{
	float d = length(abs(p.xy)+fixed2(-220.,50.))-200.; // 2 cylinders 
	d = max(d, -p.z-250.);
    
	d = d*.2  + noise(p*.04-.75)*7. + displacement(p*.25)*2.;
    
	return d;
}
float ground( in fixed3 p )
{
	return p.y-clamp(p.z*.08-5.5,-20., 0.);
}
float map( in fixed3 p )
{
	return min(ground(p), rock(p));
}


//Shading
fixed3 shade( in fixed3 p, in fixed3 n, in fixed3 ro, in fixed3 rd)
{
	//Sky ?
	const fixed3 sunDir = fixed3(-0.128,0.946, -0.189);
	fixed3 sky = skyColor(rd);
	float d = length(p-ro);
	if(d>500. )
		return sky;

    fixed3 nn = normal(p,5.);
    
   	//Materials
	fixed3 col;
	if(rock(p.xyz) < p.y ) //Rock
	{
		col = lerp(fixed3(1.,1.,1.), fixed3(.2,.3/*+noise(p*0.4)*.5*/,.1)*.4, pow(clamp(nn.y*1.1,0.,1.),4.));
		col = lerp(lerp(fixed3(.3,.2,.1), fixed3(.3,.28,.22)*1.9, clamp(p.z-70.,0.,1.)), col, clamp(p.y*.3,0.,1.));
	}
	else //Sand
	{
		col = fixed3(.3,.28,.22)*1.9*(noise(p*10.)*noise(p*fixed3(.8,0.,3.))*.1+.8);
	}


    //BRDF 
    float shad = ambientOcclusion(p.xyz, sunDir, fixed2(7.,12.));
    float ao = ambientOcclusion(p.xyz, n, fixed2(1.,1.5)) * ambientOcclusion(p.xyz, n, fixed2(5.,8.));
    
    fixed3 amb = fixed3(.9,.97,1.)*ao;
    fixed3 diff = fixed3(1.,.8,.5) * min( max(dot(n,sunDir),0.)*max(dot(nn,sunDir)*1.2,0.1)*shad*6., 1.);
    fixed3 ind = fixed3(1.,.8,.5) * max(dot(n,sunDir*fixed3(-1.,0.,-1.)),0.);
    fixed3 skylight = fixed3(.9,.97,1.)*clamp( 0.5 + 0.5*n.y, 0.0, 1.0 )*ao;
    col *=  amb*.3 + diff*.8 + ind*.1 + .2*skylight;
    
    
    
    //Underwater blue
    float a = clamp(-p.y*.4,0.,1.);
    float b = pow(clamp(2.5-displacement(p*fixed3(.5,1.,.3)*.05+1.)*6.*a, 0.8, 1.),4.);
    float c = pow(clamp(2.5-displacement(p*fixed3(.5,1.,.4)*.08+10.)*5.*a, 0.8, 1.),4.);
	col = lerp(col, fixed3(.2,1.,.8)*.2*(b-c+1.), a);
    
    //A little fog
	col = lerp( col, fixed3(1.,.98,.9), clamp( (d-25.)*.0007,0.,1.) );

	return col;
}


fixed3 shadeWater( in fixed3 p, in fixed3 n, in fixed3 ro, in fixed3 rd) 
{
	//Sky ?
	const fixed3 sunDir = fixed3(-0.0828,0.946, -0.189);
	fixed3 sky = skyColor(rd);
	if( map(p)>1.)
		return sky;
    
    //BRDF
	float d = length(p-ro);
	fixed3 col = fixed3(.9,.97,1.)*.1 +  fixed3(1.,.9,.6)*max(dot(n,sunDir),0.)*.3;
    
    //A little fog
	col = lerp( col, fixed3(1.,.98,.9), clamp( (d-25.)*.0007,0.,1.) );
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

    //Screen coords
	fixed2 q =1;
	fixed2 v = -1.0+2.0*q;
	v.x *= _ScreenParams.x/_ScreenParams.y;
    
	//Camera
	float ct = cos(_Time.y*.1);
    fixed3 ro = fixed3(20.*ct,10.,75.+20.*ct);
	fixed3 rd = normalize(i.worldSpaceView);
	rd.xz = rotate(rd.xz, -.5*ct+1.57);
    
    
    //Compute pixel
    fixed3 p = raymarch(ro, rd, fixed2(.1,1800.));
	fixed3 n = normal(p.xyz, 0.01);
    fixed3 col = shade(p,n, ro,rd);
    
    //Water hit ?
	float t;
	fixed3 pWater = seaHit(ro,rd,.1, t);
    float d = length(p-ro);
	if( t>0. && (length(pWater-ro) < d || d>800.) )
	{
		float depth =  map(pWater);
		ro = pWater.xyz;
		n = normalize( fixed3(0.,1.,0.) + (noise(pWater+fixed3(0.,0.,_Time.y))*2.-1.)*.025);
		float fre = (1.-max(dot(rd,n),0.));
		fixed3 refd = reflect(rd, n);
    	p = raymarchSmall(pWater+n, refd, fixed2(.1,800.));
    	n = normal(p.xyz, 5.);
    	fixed3 col2= shadeWater(p,n, ro,refd);
		col = lerp(col, col2, min(depth,1.)*.5*fre);
		col = lerp( col, skyColor(rd), min( d*0.001,1.) );
	}
    
    //Little lens flare
    fixed3 sundir = normalize( fixed3(.5, .2, -1.) );
    col += pow( max(dot(rd, sundir),0.), 2.0)*(float(d<500.)*.8+.2) *.1;
    
    
    //Gamma correction
    col = pow( col, fixed3(1./1.42,1./1.42,1./1.42) );
    
    return fixed4(col, float(d>500.));
}








fixed2 rotate( fixed2 v, float a)
{
  return fixed2( v.y*cos(a) - v.x*sin(a), v.x*cos(a) + v.y*sin(a));
}


fixed3 seaHit( in fixed3 ro, in fixed3 rd, float h, out float t )
{
        fixed4 pl = fixed4(0.0,1.0,0.0,h);
         t = -(dot(pl.xyz,ro)+pl.w)/dot(pl.xyz,rd);
        return ro+rd*t;
}


fixed3 raymarch( in fixed3 ro, in fixed3 rd, in fixed2 clip)
{
    float accD=2.;
    for(int i=0; i<128; i++)
    {
		float d = map( ro+rd*accD);
        if(  accD > clip.y) break;
        accD += d*2.5;
        
    }
    return ro+rd*accD;
}

fixed3 raymarchSmall( in fixed3 ro, in fixed3 rd, in fixed2 clip)
{
    float accD=5.;
    for(int i=0; i<64; i++)
    {
		float d = map( ro+rd*accD);
        if( d < .01 || accD > clip.y) break;
        accD += d*2.5;
        
    }
    return ro+rd*accD;
}

fixed3 normal( in fixed3 p, in float e )
{
    fixed3 eps = fixed3(e,0.0,0.0);
    return normalize(fixed3(
        map(p+eps.xyy)-map(p-eps.xyy),
        map(p+eps.yxy)-map(p-eps.yxy),
        map(p+eps.yyx)-map(p-eps.yyx)
    ));
}


float ambientOcclusion(fixed3 p, fixed3 n, fixed2 a)
{
	float dlt = a.x;
	float oc = 0.0, d = a.y;
	for(int i = 0; i<5; i++)
	{
		oc += (float(i) * dlt - map(p + n * float(i) * dlt)) / d;
		d *= 2.0;
	}
	return clamp(1.0 - oc, 0.0, 1.0);
}





fixed3 skyColor( in fixed3 rd )
{
    fixed3 sundir = normalize( fixed3(-.5, .2, -1.) );
    
    float yd = min(rd.y+0.05, 0.);
    rd.y = max(rd.y+0.05, 0.05);
    
    fixed3 col = fixed3(0.,0.,0.);
    
    col += fixed3(.4, .4 - exp( -rd.y*20. )*.3, .0) * exp(-rd.y*9.); // Red / Green 
    col += fixed3(.3, .5, .6) * (1. - exp(-rd.y*8.) ) * exp(-rd.y*.9) ; // Blue
    
    col = lerp(col*1.2, fixed3(.3,.3,.3),  1.-exp(yd*100.)); // Fog
    
    col += fixed3(1.0, .5, .0) * (pow( max(dot(rd,sundir),0.), 15. ) + pow( max(dot(rd, sundir),0.), 150.0)*.5)*.3; // Sun
    
    
    col -= fixed3(.6,.6,.6)*displacement( fixed3(rd.xz*1.5/(.001+rd.y),0.)-fixed3(.0,.1,.05)*_Time.y )*rd.y-.2; //Clouds
    
    return max(col, fixed3(0.,0.,0.))*.9;
}



static const fixed3x3 m = fixed3x3( 0.00,  0.80,  0.60,
                    -0.80,  0.36, -0.48,
                    -0.60, -0.48,  0.64 );

float displacement( fixed3 p ) //Thx to Inigo Quilez
{	
    p *= fixed3(1.,.8,1.);
    float f;
    f  = 0.5000*noise( p ); p = mul(p,m*2.01);
    f += 0.2500*noise( p); p = mul(p,m*3.5);
    f += 0.0425*noise( p ); /*p = m*p*2.01;
    f += 0.0625*noise( p ); */
	
    return f;
}

float noise(fixed3 p) //Thx to Las^Mercury
{
	fixed3 i = floor(p);
	fixed4 a = dot(i, fixed3(1., 57., 21.)) + fixed4(0., 57., 21., 78.);
	fixed3 f = cos((p-i)*acos(-1.))*(-.5)+.5;
	a = lerp(sin(cos(a)*a),sin(cos(1.+a)*(1.+a)), f.x);
	a.xy = lerp(a.xz, a.yw, f.y);
	return lerp(a.x, a.y, f.z)*.5+.5;
}	
	ENDCG
	}
  }
}

