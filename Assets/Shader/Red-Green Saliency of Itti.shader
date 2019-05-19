
Shader "ShaderMan/Red-Green Saliency of Itti"
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



	//Variables
float4 _iMouse;
sampler2D iChannel0;

float saturate( float x ) { return clamp( x, 0.0, 1.0 ); }

// color visualization forked from https://www.shadertoy.com/view/XtGGzG

fixed3 viridis_quintic( float x )
{
	x = saturate( x );
	fixed4 x1 = fixed4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
	fixed4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
	return fixed3(
		dot( x1.xyzw, fixed4( +0.280268003, -0.143510503, +2.225793877, -14.815088879 ) ) + dot( x2.xy, fixed2( +25.212752309, -11.772589584 ) ),
		dot( x1.xyzw, fixed4( -0.002117546, +1.617109353, -1.909305070, +2.701152864 ) ) + dot( x2.xy, fixed2( -1.685288385, +0.178738871 ) ),
		dot( x1.xyzw, fixed4( +0.300805501, +2.614650302, -12.019139090, +28.933559110 ) ) + dot( x2.xy, fixed2( -33.491294770, +13.762053843 ) ) );
}

fixed3 inferno_quintic( float x )
{
	x = saturate( x );
	fixed4 x1 = fixed4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
	fixed4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
	return fixed3(
		dot( x1.xyzw, fixed4( -0.027780558, +1.228188385, +0.278906882, +3.892783760 ) ) + dot( x2.xy, fixed2( -8.490712758, +4.069046086 ) ),
		dot( x1.xyzw, fixed4( +0.014065206, +0.015360518, +1.605395918, -4.821108251 ) ) + dot( x2.xy, fixed2( +8.389314011, -4.193858954 ) ),
		dot( x1.xyzw, fixed4( -0.019628385, +3.122510347, -5.893222355, +2.798380308 ) ) + dot( x2.xy, fixed2( -3.608884658, +4.324996022 ) ) );
}

fixed3 magma_quintic( float x )
{
	x = saturate( x );
	fixed4 x1 = fixed4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
	fixed4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
	return fixed3(
		dot( x1.xyzw, fixed4( -0.023226960, +1.087154378, -0.109964741, +6.333665763 ) ) + dot( x2.xy, fixed2( -11.640596589, +5.337625354 ) ),
		dot( x1.xyzw, fixed4( +0.010680993, +0.176613780, +1.638227448, -6.743522237 ) ) + dot( x2.xy, fixed2( +11.426396979, -5.523236379 ) ),
		dot( x1.xyzw, fixed4( -0.008260782, +2.244286052, +3.005587601, -24.279769818 ) ) + dot( x2.xy, fixed2( +32.484310068, -12.688259703 ) ) );
}

fixed3 plasma_quintic( float x )
{
	x = saturate( x );
	fixed4 x1 = fixed4( 1.0, x, x * x, x * x * x ); // 1 x x2 x3
	fixed4 x2 = x1 * x1.w * x; // x4 x5 x6 x7
	return fixed3(
		dot( x1.xyzw, fixed4( +0.063861086, +1.992659096, -1.023901152, -0.490832805 ) ) + dot( x2.xy, fixed2( +1.308442123, -0.914547012 ) ),
		dot( x1.xyzw, fixed4( +0.049718590, -0.791144343, +2.892305078, +0.811726816 ) ) + dot( x2.xy, fixed2( -4.686502417, +2.717794514 ) ),
		dot( x1.xyzw, fixed4( +0.513275779, +1.580255060, -5.164414457, +4.559573646 ) ) + dot( x2.xy, fixed2( -1.916810682, +0.570638854 ) ) );
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
    fixed3 col = tex2D(iChannel0, uv).rgb; 
    float inmax = max(col.r, max(col.g, col.b)); 
	float rg = inmax > 0.1 ? ((col.r - col.g) / inmax) : 0.0; 
	float by = inmax > 0.1 ? ((col.b - min(col.r, col.g)) / inmax) : 0.0; 
    return fixed4(inferno_quintic(_iMouse.z < 0.5 ? rg : by), 0.0); 
}
	ENDCG
	}
  }
}

