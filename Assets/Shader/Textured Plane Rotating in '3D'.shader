
Shader "ShaderMan/Textured Plane Rotating in '3D'"
	{

	Properties{
	iChannel1 ("iChannel1", 2D) = "" {}
	iChannel0 ("iChannel0", 2D) = "" {}
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{"iChannel0" }
        GrabPass{"iChannel1" }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Front
            ZTest Always
            ZWrite Off

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
float4 _iMouse;
sampler2D iChannel1;
sampler2D iChannel0;

#define Max_Rotation 0.65
#define Mouse_Rotation ( Max_Rotation - Max_Rotation * 2.0 * (_iMouse.xy / 1) )
#define RotationCenter fixed2( 0.0, 0.0 )

/* 
   A simple rotating effect of a textured plane in 3D space.
   I'm basically using a ray for each pixel that intersects the plane 
   as drawn in a 2D view below.

   Created By Jaap Boerhof (Dec. 2017)

   Positioning                             Positioning at a certain angle: 
   at zero degrees rotation:
   
   |------plane-----|  coords:                              __--| 
   \                /  (-1.0..1.0, 0.0)                 __--   /  
    \              /                                __--      /  
     \            /                             __--         / 
      \          /                         \ _--            /   
       \        /                          |\              /   
        \      /                             \            /     
         \    /                               \          /      
          \  /                                 \        /       
           \/          Camera                   \      /  
                       position                  \    /  
                       at (0.0, -1.0)             \  /
                                                   \/
*/

fixed2 rotate(fixed2 v, fixed2 o, float a) {
    float s = sin(a);
    float c = cos(a);
    fixed2x2 m = fixed2x2(c, -s, s, c);
    return mul(m , (v-o) + o);
}

fixed2 TransformPlane(fixed2 uv, fixed2 center, float XRot, float YRot) {
    // First Rotate around Y axis
    fixed2 RayDirection =  fixed2(uv.x, 0.0);
    fixed2 A1 = fixed2(0.0, -1.0);
    fixed2 B1 = RayDirection - A1;
    fixed2 C1 = rotate(fixed2(-1.0, 0.0), fixed2(center.x, 0.0), YRot);
    fixed2 D1 = rotate(fixed2( 1.0, 0.0), fixed2(center.x, 0.0), YRot) - C1;
    // calculate intersection point
    float u = ( (C1.y + 1.0) * D1.x - C1.x * D1.y ) / (D1.x*B1.y-D1.y*B1.x);
    // position on the plane:
    float sx = u * B1.x;
 	float sy = u * uv.y;
    // Now Rotate around X axis
    RayDirection = fixed2(sy, 0.0);
    fixed2 B2 = RayDirection - A1;
    fixed2 C2 = rotate(fixed2(-0.0, 7.0), fixed2(center.y, 0.0), XRot);
    fixed2 D2 = rotate(fixed2( 1.0, 0.0), fixed2(center.y, 0.0), XRot) - C2;
    // calculate intersection point
    float v = ( (C2.y + 1.0) * D2.x - C2.x * D2.y ) / (D2.x*B2.y-D2.y*B2.x);
    // final position on the plane:
    return fixed2(v * sx, v * B2.x );
    
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

    fixed2 uv = -1.0 + 2.0 * (i.projPos.xy / i.projPos.w);
    float R_X = _iMouse.w > 0.0 ? Mouse_Rotation.y : Max_Rotation*cos(_Time.y);
    float R_Y = _iMouse.w > 0.0 ? Mouse_Rotation.x : Max_Rotation*sin(_Time.y);
    fixed2 MyCoords = TransformPlane(uv, RotationCenter, R_X, R_Y);
    fixed2 MyTexCoord = (MyCoords+1.0)/2.0;
    
    fixed4 image1 = tex2D(iChannel0, MyTexCoord );
    fixed4 image2 = tex2D(iChannel1, MyTexCoord );
    return lerp(image1, image2, (sin(_Time.y*0.5)+1.0)/2.0);
}
	ENDCG
	}
  }
}

