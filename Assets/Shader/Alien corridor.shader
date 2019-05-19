
Shader "ShaderMan/Alien corridor"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "white" {}
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
sampler2D iChannel0;

float EPSILON = 0.002;
fixed2 twist = fixed2(2.0,7.0);
float planesDistance = 0.3;
fixed4 bumpMapParams1 = fixed4(2.0,7.0,0.01,-0.01);
fixed4 bumpMapParams2 = fixed4(2.0,3.0,-0.01,0.01);
fixed4 heightMapParams = fixed4(3.0,1.0,0.0,0.01);
fixed4 heightInfluence = fixed4(-0.025,-0.05,0.8,1.8);
float fogDensity = 0.2;
float fogDistance = 0.1;
fixed3 groundColor1 = fixed3(0.2,0.3,0.3);
fixed3 groundColor2 = fixed3(0.4,0.8,0.4);
fixed3 columnColors = fixed3(0.9,0.3,0.3);
fixed4 ambient = fixed4(0.2,0.3,0.4,0.0);
fixed3 lightColor = fixed3(0.4,0.7,0.7);
fixed4 fogColor = fixed4(0.0,0.1,0.5,1.0);
fixed3 rimColor = fixed3(1.0,0.75,0.75);

static const float pi = 3.14159265359;

fixed2x2 rot(float a) 
{
    fixed2 s = sin(fixed2(a, a + pi/2.0));
    return fixed2x2(s.y,s.x,-s.x,s.y);
}

float smin( float a, float b, float k )
{
    float h = clamp( 0.5+0.5*(b-a)/k, 0.0, 1.0 );
    return lerp( b, a, h ) - k*h*(1.0-h);
}

float sphere(fixed3 pos, float radius, fixed3 scale)
{
    return length(pos*scale)-radius;
}

float heightmap(fixed2 uv)
{
    return heightMapParams.x*tex2D(iChannel0, (uv + _Time.y*heightMapParams.zw)*heightMapParams.y).x;
}

float bumpmap(fixed2 uv)
{
    float b1 = bumpMapParams1.x*(1.0 - tex2D(iChannel0, (uv + _Time.y*bumpMapParams1.zw)*bumpMapParams1.y).x);
    float b2 = bumpMapParams2.x*(1.0-tex2D(iChannel0, (uv + _Time.y*bumpMapParams2.zw)*bumpMapParams2.x).x);
    return b1+b2;
}

float distfunc(fixed3 pos)
{
    fixed3 p2 = pos;
    p2.x += sin(p2.z*3.0 + p2.y*5.0)*0.15;
    p2.xy =mul(p2.xy, rot(floor(p2.z*2.0)*twist.y));
    pos.xy =mul( pos.xy, rot(pos.z*twist.x));
    
    float h = heightmap(pos.xz)*heightInfluence.x;
    
    fixed3 columnsrep = fixed3(0.75,1.0,0.5);
    fixed3 reppos = (fmod(p2 + fixed3(_Time.y*0.01 + sin(pos.z*0.5),0.0,0.0),columnsrep)-0.5*columnsrep);
    
    float columnsScaleX = 1.0 + sin(p2.y*20.0*sin(p2.z) + _Time.y*5.0 + pos.z)*0.15;
    float columnsScaleY = (sin(_Time.y + pos.z*4.0)*0.5+0.5);
    
    float columns = sphere(fixed3(reppos.x, pos.y+0.25, reppos.z), 0.035, fixed3(columnsScaleX,columnsScaleY,columnsScaleX));
    float corridor = planesDistance - abs(pos.y) + h;
    float d = smin(corridor, columns, 0.25); 
           
    return d;
}

float rayMarch(fixed3 rayDir, fixed3 cameraOrigin)
{
    static const int MAX_ITER = 50;
	static const float MAX_DIST = 30.0;
    
    float totalDist = 0.0;
    float totalDist2 = 0.0;
	fixed3 pos = cameraOrigin;
	float dist = EPSILON;
    fixed3 col = fixed3(0.0,0.,0.);
    float glow = 0.0;
    
    for(int j = 0; j < MAX_ITER; j++)
	{
		dist = distfunc(pos);
		totalDist = totalDist + dist;
		pos += dist*rayDir;
        
        if(dist < EPSILON || totalDist > MAX_DIST)
		{
			break;
		}
	}
    
    return totalDist  ;
}

//Taken from https://www.shadertoy.com/view/Xds3zN
fixed3x3 setCamera( in fixed3 ro, in fixed3 ta, float cr )
{
	fixed3 cw = normalize(ta-ro);
	fixed3 cp = fixed3(sin(cr), cos(cr),0.0);
	fixed3 cu = normalize( cross(cw,cp) );
	fixed3 cv = normalize( cross(cu,cw) );
    return fixed3x3( cu, cv, cw );
}

fixed3 calculateNormals(fixed3 pos)
{
	fixed2 eps = fixed2(0.0, EPSILON*1.0);
	fixed3 n = normalize(fixed3(
	distfunc(pos + eps.yxx) - distfunc(pos - eps.yxx),
	distfunc(pos + eps.xyx) - distfunc(pos - eps.xyx),
	distfunc(pos + eps.xxy) - distfunc(pos - eps.xxy)));
    
	return n;
}

//Taken from https://www.shadertoy.com/view/XlXXWj
fixed3 doBumpMap(fixed2 uv, fixed3 nor, float bumpfactor)
{
   
    static const float eps = 0.001;
    float ref = bumpmap(uv); 
    
    fixed3 grad = fixed3(bumpmap(fixed2(uv.x-eps, uv.y))-ref, 0.0, bumpmap(fixed2(uv.x, uv.y-eps))-ref); 
             
    grad -= nor*dot(nor, grad);          
                      
    return normalize( nor + grad*bumpfactor );
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

    fixed3 cameraOrigin = fixed3(0.0, 0.0, _Time.y*-0.1);
    fixed3 cameraTarget = cameraOrigin + fixed3(0.0, 0.0, 1.0);;
    
	fixed2 screenPos = (i.position.xy/_ScreenParams.xy)*2.0-1.0;
	screenPos.x *= _ScreenParams.x/_ScreenParams.y;
    
	fixed3x3 cam = setCamera(cameraOrigin, cameraTarget, 0.0 );
    
    fixed3 rayDir =mul(cam, normalize( fixed3(screenPos.xy,2.0)) );
    rayDir.xy =mul( rayDir.xy,rot(_Time.y*0.1));
    float dist = rayMarch(rayDir, cameraOrigin);
   
    fixed3 pos = cameraOrigin + dist*rayDir;
    fixed2 uv = mul(pos.xy , rot(pos.z*twist.x));
    float h = heightmap(fixed2(uv.x, pos.z));
    fixed3 n = calculateNormals(pos);
    fixed3 bump = doBumpMap(fixed2(uv.x, pos.z), n, 3.0);
    float m = smoothstep(-0.15,0.2, planesDistance - abs(uv.y) + h*heightInfluence.y + sin(_Time.y)*0.05);
    fixed3 color = lerp(lerp(groundColor1, groundColor2, smoothstep(heightInfluence.z,heightInfluence.w,h)), columnColors, m);
    float fog = dist*fogDensity-fogDistance;
    float heightfog = pos.y;
    float rim = (1.0-max(0.0, dot(-normalize(rayDir), bump)));
    fixed3 lightPos = pos - (cameraOrigin + fixed3(0.0,0.0,1.0));
    fixed3 lightDir = -normalize(lightPos);
    float lightdist = length(lightPos);
    float atten = 1.0 / (1.0 + lightdist*lightdist*3.0);
    float light = max(0.0, dot(lightDir, bump));
   	fixed3 r = reflect(normalize(rayDir), bump);
    float spec = clamp (dot (r, lightDir),0.0,1.0);
    float specpow = pow(spec,20.0);
    fixed3 c = color*(ambient.xyz + lerp(rim*rim*rim, rim*0.35+0.65, m)*rimColor + lightColor*(light*atten*2.0 + specpow*1.5));
    fixed4 res = lerp(fixed4(c, rim), fogColor, clamp(fog+heightfog,0.0,1.0));

    
	return res;
}
	ENDCG
	}
  }
}

