
Shader "ShaderMan/scape test"
	{

	Properties{

	}

	SubShader
	{


	Pass
	{

	CGPROGRAM
	#pragma vertex vertex_shader
	#pragma fragment pixel_shader
	#pragma target 3.0

	static  const int NUM_STEPS = 8;
static const float PI	 	= 3.141592;
static const float EPSILON	= 0.001;
static const float epsilon_nrm = 0.0001 ;
static const int ITER_GEOMETRY = 3;
static const int ITER_FRAGMENT = 5;
static const float SEA_HEIGHT = 0.6;
static const float SEA_CHOPPY = 4.0;
static const float sea_speed = 0.8;
static const float SEA_FREQ = 0.16;
static const fixed3 SEA_BASE = fixed3(0.1,0.19,0.22);
static const fixed3 SEA_WATER_COLOR = fixed3(0.8,0.9,0.6);
static const fixed2x2 octave_m = fixed2x2(1.6,1.2,-1.2,1.6); 

	struct custom_type
			{
				float4 screen_vertex : SV_POSITION;
				float3 world_vertex : TEXCOORD1;
			};

	//Variables
float4 _iMouse;

/*
 * "Seascape" by Alexander Alekseev aka TDM - 2014
 * License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 * Contact: tdmaav@gmail.com
 */







// math
fixed3x3 fromEuler(fixed3 ang) {
	fixed2 a1 = fixed2(sin(ang.x),cos(ang.x));
    fixed2 a2 = fixed2(sin(ang.y),cos(ang.y));
    fixed2 a3 = fixed2(sin(ang.z),cos(ang.z));
    fixed3x3 m;
    m[0] = fixed3(a1.y*a3.y+a1.x*a2.x*a3.x,a1.y*a2.x*a3.x+a3.y*a1.x,-a2.y*a3.x);
	m[1] = fixed3(-a2.y*a1.x,a1.y*a2.y,a2.x);
	m[2] = fixed3(a3.y*a1.x*a2.x+a1.y*a3.x,a1.x*a3.x-a1.y*a3.y*a2.x,a2.y*a3.y);
	return m;
}
float hash( fixed2 p ) {
	float h = dot(p,fixed2(127.1,311.7));	
    return frac(sin(h)*43758.5453123);
}
float noise( in fixed2 p ) {
    fixed2 i = floor( p );
    fixed2 f = frac( p );	
	fixed2 u = f*f*(3.0-2.0*f);
    return -1.0+2.0*lerp( lerp( hash( i + fixed2(0.0,0.0) ), 
                     hash( i + fixed2(1.0,0.0) ), u.x),
                lerp( hash( i + fixed2(0.0,1.0) ), 
                     hash( i + fixed2(1.0,1.0) ), u.x), u.y);
}

// lighting
float diffuse(fixed3 n,fixed3 l,float p) {
    return pow(dot(n,l) * 0.4 + 0.6,p);
}
float specular(fixed3 n,fixed3 l,fixed3 e,float s) {    
    float nrm = (s + 8.0) / (PI * 8.0);
    return pow(max(dot(reflect(e,n),l),0.0),s) * nrm;
}

// sky
fixed3 getSkyColor(fixed3 e) {
    e.y = max(e.y,0.0);
    return fixed3(pow(1.0-e.y,2.0), 1.0-e.y, 0.6+(1.0-e.y)*0.4);
}

// sea
float sea_octave(fixed2 uv, float choppy) {
    uv += noise(uv);        
    fixed2 wv = 1.0-abs(sin(uv));
    fixed2 swv = abs(cos(uv));    
    wv = lerp(wv,swv,wv);
    return pow(1.0-pow(wv.x * wv.y,0.65),choppy);
}

float map(fixed3 p) {
    float freq = SEA_FREQ;
    float amp = SEA_HEIGHT;
    float choppy = SEA_CHOPPY;
    fixed2 uv = p.xz; uv.x *= 0.75;
    
    float d, h = 0.0;    
    for(int i = 0; i < ITER_GEOMETRY; i++) {        
    	d = sea_octave((uv+float(_Time.g * sea_speed))*freq,choppy);
    	d += sea_octave((uv-float(_Time.g * sea_speed))*freq,choppy);
        h += d * amp;        
    	uv =mul(uv, octave_m); freq *= 1.9; amp *= 0.22;
        choppy = lerp(choppy,1.0,0.2);
    }
    return p.y - h;
}

float map_detailed(fixed3 p) {
    float freq = SEA_FREQ;
    float amp = SEA_HEIGHT;
    float choppy = SEA_CHOPPY;
    fixed2 uv = p.xz; uv.x *= 0.75;
    
    float d, h = 0.0;    
    for(int i = 0; i < ITER_FRAGMENT; i++) {        
    	d = sea_octave((uv+float(_Time.g * sea_speed))*freq,choppy);
    	d += sea_octave((uv-float(_Time.g * sea_speed))*freq,choppy);
        h += d * amp;        
    	uv =mul(uv, octave_m); freq *= 1.9; amp *= 0.22;
        choppy = lerp(choppy,1.0,0.2);
    }
    return p.y - h;
}

fixed3 getSeaColor(fixed3 p, fixed3 n, fixed3 l, fixed3 eye, fixed3 dist) {  
    float fresnel = clamp(1.0 - dot(n,-eye), 0.0, 1.0);
    fresnel = pow(fresnel,3.0) * 0.65;
        
    fixed3 reflected = getSkyColor(reflect(eye,n));    
    fixed3 refracted = SEA_BASE + diffuse(n,l,80.0) * SEA_WATER_COLOR * 0.12; 
    
    fixed3 color = lerp(refracted,reflected,fresnel);
    
    float atten = max(1.0 - dot(dist,dist) * 0.001, 0.0);
    color += SEA_WATER_COLOR * (p.y - SEA_HEIGHT) * 0.18 * atten;
    
    color += fixed3(specular(n,l,eye,60.0),specular(n,l,eye,60.0),specular(n,l,eye,60.0));
    
    return color;
}

// tracing
fixed3 getNormal(fixed3 p, float eps) {
    fixed3 n;
    n.y = map_detailed(p);    
    n.x = map_detailed(fixed3(p.x+eps,p.y,p.z)) - n.y;
    n.z = map_detailed(fixed3(p.x,p.y,p.z+eps)) - n.y;
    n.y = eps;
    return normalize(n);
}

float heightMapTracing(fixed3 ori, fixed3 dir, out fixed3 p) {  
    float tm = 0.0;
    float tx = 1000.0;    
    float hx = map(ori + dir * tx);
    if(hx > 0.0) return tx;   
    float hm = map(ori + dir * tm);    
    float tmid = 0.0;
    for(int i = 0; i < NUM_STEPS; i++) {
        tmid = lerp(tm,tx, hm/(hm-hx));                   
        p = ori + dir * tmid;                   
    	float hmid = map(p);
		if(hmid < 0.0) {
        	tx = tmid;
            hx = hmid;
        } else {
            tm = tmid;
            hm = hmid;
        }
    }
    return tmid;
}



custom_type vertex_shader (float4 vertex : POSITION)
			{
				custom_type vs;
				vs.screen_vertex = UnityObjectToClipPos (vertex);
				vs.world_vertex = mul(unity_ObjectToWorld, vertex).xyz;
				return vs;
			}

			float4 pixel_shader (custom_type ps) : SV_TARGET
			{
				float3 worldPosition = _WorldSpaceCameraPos;
				float3 viewDirection = normalize(ps.world_vertex - _WorldSpaceCameraPos);
				float3 p = float3(5.0,233.0,1.0);
				float3 dist = heightMapTracing(worldPosition,viewDirection,p) - worldPosition;
				float3 n = getNormal(p, dot(dist,dist) * epsilon_nrm);
				float3 light = normalize (float3 (0.0,1.0,0.8));
				float3 color = lerp (getSkyColor(viewDirection), getSeaColor(p,n,light,viewDirection,dist), pow(smoothstep(0.0,-0.05,viewDirection.y),0.3));
				float4 fragColor;
				return fragColor = float4(pow(color,float3(0.75,0.75,0.75)),1.0);
			}

			ENDCG
		}
	}
}

