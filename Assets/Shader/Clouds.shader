
Shader "ShaderMan/Clouds"
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


static const float cloudscale = 1.1;
static const float speed = 0.03;
static const float clouddark = 0.5;
static const float cloudlight = 0.3;
static const float cloudcover = 0.2;
static const float cloudalpha = 8.0;
static const float skytint = 0.5;
static const fixed3 skycolour1 = fixed3(0.2, 0.4, 0.6);
static const fixed3 skycolour2 = fixed3(0.4, 0.7, 1.0);

static const fixed2x2 m = fixed2x2( 1.6,  1.2, -1.2,  1.6 );

fixed2 hash( fixed2 p ) {
	p = fixed2(dot(p,fixed2(127.1,311.7)), dot(p,fixed2(269.5,183.3)));
	return -1.0 + 2.0*frac(sin(p)*43758.5453123);
}

float noise( in fixed2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	fixed2 i = floor(p + (p.x+p.y)*K1);	
    fixed2 a = p - i + (i.x+i.y)*K2;
    fixed2 o = (a.x>a.y) ? fixed2(1.0,0.0) : fixed2(0.0,1.0); //fixed2 of = 0.5 + 0.5*fixed2(sign(a.x-a.y), sign(a.y-a.x));
    fixed2 b = a - o + K2;
	fixed2 c = a - 1.0 + 2.0*K2;
    fixed3 h = max(0.5-fixed3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	fixed3 n = h*h*h*h*fixed3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, fixed3(70.0,70.0,70.0));	
}

float fbm(fixed2 n) {
	float total = 0.0, amplitude = 0.1;
	for (int i = 0; i < 7; i++) {
		total += noise(n) * amplitude;
		n = mul(m , n);
		amplitude *= 0.4;
	}
	return total;
}

// -----------------------------------------------

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

    fixed2 p = i.position.xy / _ScreenParams.xy;
	fixed2 uv = p*fixed2(_ScreenParams.x/_ScreenParams.y,1.0);    
    float time = _Time.y * speed;
    float q = fbm(uv * cloudscale * 0.5);
    
    //ridged noise shape
	float r = 0.0;
	uv *= cloudscale;
    uv -= q - time;
    float weight = 0.8;
    for (int i=0; i<8; i++){
		r += abs(weight*noise( uv ));
        uv = mul(m,uv) + time;
		weight *= 0.7;
    }
    
    //noise shape
	float f = 0.0;
    uv = p*fixed2(_ScreenParams.x/_ScreenParams.y,1.0);
	uv *= cloudscale;
    uv -= q - time;
    weight = 0.7;
    for (int i=0; i<8; i++){
		f += weight*noise( uv );
        uv = mul(m,uv) + time;
		weight *= 0.6;
    }
    
    f *= r + f;
    
    //noise colour
    float c = 0.0;
    time = _Time.y * speed * 2.0;
    uv = p*fixed2(_ScreenParams.x/_ScreenParams.y,1.0);
	uv *= cloudscale*2.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c += weight*noise( uv );
        uv = mul(m,uv) + time;
		weight *= 0.6;
    }
    
    //noise ridge colour
    float c1 = 0.0;
    time = _Time.y * speed * 3.0;
    uv = p*fixed2(_ScreenParams.x/_ScreenParams.y,1.0);
	uv *= cloudscale*3.0;
    uv -= q - time;
    weight = 0.4;
    for (int i=0; i<7; i++){
		c1 += abs(weight*noise( uv ));
        uv = mul(m,uv) + time;
		weight *= 0.6;
    }
	
    c += c1;
    
    fixed3 skycolour = lerp(skycolour2, skycolour1, p.y);
    fixed3 cloudcolour = fixed3(1.1, 1.1, 0.9) * clamp((clouddark + cloudlight*c), 0.0, 1.0);
   
    f = cloudcover + cloudalpha*f*r;
    
    fixed3 result = lerp(skycolour, clamp(skytint * skycolour + cloudcolour, 0.0, 1.0), clamp(f + c, 0.0, 1.0));
    
	return fixed4( result, 1.0 );
}
	ENDCG
	}
  }
}

