
Shader "ShaderMan/TV Moire Pattern Effect"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
         GrabPass{ "iChannel1"}
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


	//Variables
sampler2D iChannel0;
sampler2D iChannel1;
// TV Moire Pattern Effect
// by rinf 2014.
//
// Simulates a TV screen consisting of RGB pixels and a camera filming the screen,
// which creates a nice Moire pattern.
//
// Use fullscreen mode for best experience
//
// Press 'x' to toggle effect on and off

#define KEY_X 88.5/256.0
#define TV_SCREEN_RESOLUTION_X 640.0

struct Rectangle
{
    fixed3 v1;
    fixed3 v2;
    fixed3 v3;
};

fixed3 CalcNormal(Rectangle A)
{
 fixed3 first = A.v1 - A.v2;
 fixed3 second = A.v2 - A.v3;
    
 return cross(first,second);
}

fixed3 Intersect(fixed3 B, fixed3 r, fixed3 A, fixed3 p)
{
 float u=0.0;
 if (r.x*p.x+r.y*p.y+r.z*p.z!=0.0)
 {
 	u =  (dot(A,p)-dot(B,p))/(dot(r,p));
 }
 
 return B+r*u;
}

fixed2 Calc_ul(fixed3 B, fixed3 C, fixed3 r, fixed3 s)
{
    float l = (C.y*r.x-B.y*r.x-C.x*r.y+B.x*r.y)/(s.y-s.x*r.y);
    float u = 0.0;
	if (r.x==0.0)
	{
		u=0.0;
	}
	else
	{
		u = (C.x-B.x-l*s.x)/r.x;
	}
    
    return fixed2(u,l);
}

fixed3 GetScreenPixelColor(fixed2 ul)
{
    float x = fmod(ul.x * TV_SCREEN_RESOLUTION_X / (1600.0/1) * 3.0,3.0);

    fixed3 tex = tex2D(iChannel0, fixed2(ul.x,ul.y) ).xyz;
    
    return lerp(lerp(fixed3(tex.r,0.0,0.0),fixed3(0.0,tex.g,0.0),step(1.0,x)),
              fixed3(0.0,0.0,tex.b),step(2.0,x));
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


	fixed2 q =(i.projPos.xy / i.projPos.w);
    
    fixed2 rect_offset = fixed2(-0.5, -0.5);
    float zoom = 0.9+sin(_Time.y*0.3)*0.55;
 
    Rectangle rect;
    rect.v1 = fixed3(0.1+rect_offset.x, 0.1+rect_offset.y, 0.4+sin(_Time.y*1.5)*0.15);
    rect.v2 = fixed3(0.1+rect_offset.x, 0.9+rect_offset.y, 0.5+sin(_Time.y*1.5)*0.15);
    rect.v3 = fixed3(0.9+rect_offset.x, 0.9+rect_offset.y, 0.5+cos(_Time.y*1.0)*0.15);
    
    float bu = abs(rect.v2.x - rect.v3.x);
    float bl = abs(rect.v1.y - rect.v2.y);
    
    
    fixed3 rect_normal_fixedtor = CalcNormal(rect);
    rect_normal_fixedtor = normalize(rect_normal_fixedtor);
    
    fixed3 plane_fixedtor1 = normalize(rect.v2 - rect.v1);
    fixed3 plane_fixedtor2 = normalize(rect.v3 - rect.v2);
    
    
    fixed3 screen_fixedtor = fixed3( q.x/10.0 , q.y/10.0 , -1);
    fixed3 camera = fixed3( q.x-0.5, q.y+0.5, zoom);
    fixed3 ray = camera - screen_fixedtor;
    fixed3 intersection = Intersect(camera,ray,rect.v3,rect_normal_fixedtor);
    
    fixed2 ul = Calc_ul(rect.v2, intersection, plane_fixedtor2, plane_fixedtor1);
	fixed3 new_col = fixed3(0.0, 0.0, 0.0);
    fixed3 old_col = fixed3(0.0, 0.0, 0.0);
    
    if (ul.x>0.0 && ul.x<1.0 && ul.y>0.0 && ul.y<1.0)
    {
        float count=0.0;
        
        for (float i=-1.0;i<1.0;i+=0.33)
        {
            new_col += GetScreenPixelColor(fixed2(ul.x+i/1,ul.y));
            count = count + 1.0;
        }

        new_col = 3.0*new_col/count;
        old_col = tex2D(iChannel0, fixed2(ul.x,ul.y) ).xyz;
    }
    
    
    if (tex2D(iChannel1,fixed2(KEY_X, 0.75)).x > 0.0)
        new_col =old_col;
        
    return fixed4(new_col,1.0);
}
	ENDCG
	}
  }
}

