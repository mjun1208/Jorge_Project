
Shader "ShaderMan/Triangulation"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	}

		 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull Front
            ZTest Always
            ZWrite Off
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	#define vec2 float2
  	#define vec3 float3
  	#define vec4 float4
  	#define mat2 float2x2
  	#define mat4 float4x4
  	#define iTime _Time.y
  	#define mod fmod
  	#define mix lerp
  	#define atan atan2
  	#define fract frac 
  	#define texture tex2D

	//Variables
sampler2D iChannel0;

// Broken picture - by JiepengTan - 2018
// jiepengtan@gmail.com
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.

//you can modify the "MoveOffset" function to get better explode effect

#define NUM 20	// chip center point num
#define DRAW_POINTS 0 // draw the center points
#define DRAW_GAP_LINE 1 // draw the gap line
// xy  is center point's coord
// zw  is chip 's move offset
vec4 chipInfo[NUM];//
// crack's offset
vec2 center =vec2(.0,-.0);//creak center pos

float rnd(vec2 s)
{
    return 1.-2.*fract(sin(s.x*253.13+s.y*341.41)*589.19);
}
float rand(float x)
{
    return fract(sin(x*873.15)*519.19);
}
//find the nearest point
int GetNearPos(vec2 p){
    vec2 v = chipInfo[0].xy;
    int idx = 0;
	for(int c=0;c<NUM;c++)
    {
        vec2 vc=chipInfo[c].xy;
        vec2 vp2 =vc-p;
        vec2 vp = v-p;
        if(dot(vp2,vp2)<dot(vp,vp))
        {
	        v=vc;
            idx = c;
        }
    }
    return idx;
}

// calculate the ith chip's move offset
vec2 MoveOffset(int idx,float t){
    vec2 offset = vec2(0.,0);
    float radVal  =rand(float(idx+1))+0.1;
    vec2 centerPos = chipInfo[idx].xy;
    vec2 diff = centerPos -center;
    float dist = length(diff);
    if(t>0.0)
    {
        //init velocity
        vec2 initVel = normalize(diff)*dist*1.;
        //add gravity
        offset = initVel*t + vec2(0.,1.)* t*t*-0.5;	
    }
    return offset;
}

// ref https://www.shadertoy.com/view/XdBSzW
float GetGapFactor(vec2 p){
	vec2 v=vec2(1E3,1E3);
    vec2 v2=vec2(1E4,1E4);
    //find the most near pos v and v2
    for(int c=0;c<NUM;c++)
    {
        vec2 vc=chipInfo[c].xy;
        if(length(vc-p)<length(v-p))
        {
            v2=v;
            v=vc;
        }
        else if(length(vc-p)<length(v2-p))
        {
            v2=vc;
        }
    }
    //check for whether p is at the middle of v and v2
    float factor= abs(length(dot(p-v,normalize(v-v2)))-length(dot(p-v2,normalize(v-v2))))
        +.002*length(p-center);
    factor=7E-4/factor;
    if(length(v-v2)<4E-3) factor=0.;
    if(factor<.01) factor = 0.;
    return factor;

}

struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                float4 objPos = mul ( unity_ObjectToWorld, float4(0,0,0,1) );
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i) : COLOR {
           
	vec2 p= (i.projPos.xy*2.-i.projPos.w)/i.projPos.w;
    
    vec2 center=vec2(.0,-.0);
    float isNear = 0.;
  
    float modT = mod(iTime,7.);
    float time = modT-6.;
    
    for(int c=0;c<NUM;c++)
    {
        //1.generate Random point 
        float angle=floor(rnd(vec2(float(c),387.44))*16.)//-15~15
            *3.1415*.4-.5;
        float dist=pow(rnd(vec2(float(c),78.21)),2.)*1.5;//0~0.5
        vec2 vc=vec2(center.x+cos(angle)*dist,
                     center.y+sin(angle)*dist);
        chipInfo[c].xy= vc.xy;
        //2.compute each chip's move offset
        chipInfo[c].zw = MoveOffset(c,time);
    }
    int belongIdx = -1;
    for(int c=0;c<NUM;c++)
    {
        //3.get raw pos 
        vec2 rawPos = p - chipInfo[c].zw;
        //4.compute which chip the rawPos locate at
        int idx = GetNearPos(rawPos);
        if(idx == c){
            belongIdx = c;
        	break;
        }
    }
    vec3 finalCol = vec3(0.,0,0);
    // if this fragment is belong to any chip
    if(belongIdx != -1){
        vec2 moveOffset = chipInfo[belongIdx];
        //calc the raw pos before the picture is broken
        vec2 rawPos = p - moveOffset;
        //5.calc the uv from the raw pos
        vec2 rawCoord = (rawPos*1 + 1)* 0.5;
        rawCoord =1-rawCoord;
        // simulate the reflect effect 
        vec2 brokenOffset = vec2(rnd(vec2(belongIdx,belongIdx))*.036,rnd(vec2(belongIdx,belongIdx))*.006);
        vec2 uv =(rawCoord)/1 + brokenOffset;
        
        vec4 tex=tex2D(iChannel0,uv);
        finalCol = tex;
        
        //if uv is out of window then get black color
        if(time>0.){
            if(uv.x>1.||uv.x<0.||uv.y>1.||uv.y<0.){
                finalCol = vec3(0.,0,0);
            }
        }
    }
    #if DRAW_GAP_LINE
    if(time<0.)
    {
        //draw Gap line
        float gapFactor = GetGapFactor(p);
        finalCol=gapFactor*vec3(1.-finalCol)+(1.-gapFactor)*finalCol;
        //draw the points
        #if  DRAW_POINTS
        float isNear = 0.;
        for(int c=0;c<NUM;c++)
        {
            vec2 vc = chipInfo[c].xy;
            //get raw pos 
            if(length(vc-p)<0.01){
                isNear = 1.;
            }
        }
        finalCol = finalCol *(1.-isNear);
        #endif
    }
    #endif
  
    return vec4(finalCol,1.);
}
	ENDCG
	}
  }
}

