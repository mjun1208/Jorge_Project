
Shader "ShaderMan/Broken Pixelsort 2"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
        Pass {
           

            Cull Front
            ZTest Always
            ZWrite Off
            Blend SrcAlpha one

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel0;

//by Vladimir Storm 
//https://twitter.com/vladstorm_

#define t _Time.w

//random hash
fixed4 hash42(fixed2 p){
    
	fixed4 p4 = frac(fixed4(p.xyxy) * fixed4(443.8975,397.2973, 491.1871, 470.7827));
    p4 += dot(p4.wzxy, p4+19.19);
    return frac(fixed4(p4.x * p4.y, p4.x*p4.z, p4.y*p4.w, p4.x*p4.w));
}


float hash( float n ){
    return frac(sin(n)*43758.5453123);
}

// 3d noise function (iq's)
float n( in fixed3 x ){
    fixed3 p = floor(x);
    fixed3 f = frac(x);
    f = f*f*(3.0-2.0*f);
    float n = p.x + p.y*57.0 + 113.0*p.z;
    float res = lerp(lerp(lerp( hash(n+  0.0), hash(n+  1.0),f.x),
                        lerp( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y),
                    lerp(lerp( hash(n+113.0), hash(n+114.0),f.x),
                        lerp( hash(n+170.0), hash(n+171.0),f.x),f.y),f.z);
    return res;
}

//tape noise
float nn(fixed2 p){


    float y = p.y;
    float s = t*7.;
    
    float v = (n( fixed3(y*.01 +s, 			1., 1.0) ) + .0)
          	 *(n( fixed3(y*.011+1000.0+s, 	1., 1.0) ) + .0) 
          	 *(n( fixed3(y*.51+421.0+s, 	1., 1.0) ) + .0)   
        ;
    //v*= n( fixed3( (fragCoord.xy + fixed2(s,0.))*100.,1.0) );
   	v*= hash42(   fixed2(p.x +t*0.01, p.y) ).x +.3 ;

    
    v = pow(v+.3, 1.);
	if(v<.7) v = 0.;  //threshold
    return v;
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
	
    fixed2 uv = (i.projPos.xy / i.projPos.w);


    float linesN = 240.; //fields per seconds
    float one_y = 1 / linesN; //field line
    uv = floor(uv*1/one_y)*one_y;

	float col =  nn(uv);
    
    
    
	return fixed4(fixed3( col,col,col ),1.0);
}
	ENDCG
	}
  }
}

