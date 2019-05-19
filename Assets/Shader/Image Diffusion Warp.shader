
Shader "ShaderMan/Image Diffusion Warp"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	iChannel2 ("iChannel2", 2D) = "" {}
	 iFrame ("Sample count", float) = 100
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{ "iChannel0"}
        GrabPass{ "iChannel1"}
        GrabPass{ "iChannel2"}
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull Front
            ZTest Always
            Blend one SrcAlpha
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel2;
sampler2D iChannel1;
sampler2D iChannel0;
uniform int       iFrame;                // shader playback frame
	



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

   static const float _K0 = -20.0/6.0; // center weight
  static  const float _K1 = 4.0/6.0; // edge-neighbors
static    const float _K2 = 1.0/6.0; // vertex-neighbors
static    const float cs = -0.1; // curl scale
static    const float ls = 0.3; // laplacian scale
static    const float ps = -0.05; // laplacian of divergence scale
static    const float ds = 0.05; // divergence scale
static    const float is = 0.01; // image derivative scale
static    const float pwr = 1.0; // power when deriving rotation angle from curl
static    const float amp = 1.0; // self-amplification
static    const float sq2 = 0.7; // diagonal weight

    fixed2 vUv = (i.projPos.xy / i.projPos.w);
    fixed2 texel = 1. / 1;
    
    // 3x3 neighborhood coordinates
    float step_x = texel.x;
    float step_y = texel.y;
    fixed2 n  = fixed2(0.0, step_y);
    fixed2 ne = fixed2(step_x, step_y);
    fixed2 e  = fixed2(step_x, 0.0);
    fixed2 se = fixed2(step_x, -step_y);
    fixed2 s  = fixed2(0.0, -step_y);
    fixed2 sw = fixed2(-step_x, -step_y);
    fixed2 w  = fixed2(-step_x, 0.0);
    fixed2 nw = fixed2(-step_x, step_y);
    
    // sobel filter
    fixed3 im = tex2D(iChannel2, vUv).xyz;
    fixed3 im_n = tex2D(iChannel2, vUv+n).xyz;
    fixed3 im_e = tex2D(iChannel2, vUv+e).xyz;
    fixed3 im_s = tex2D(iChannel2, vUv+s).xyz;
    fixed3 im_w = tex2D(iChannel2, vUv+w).xyz;
    fixed3 im_nw = tex2D(iChannel2, vUv+nw).xyz;
    fixed3 im_sw = tex2D(iChannel2, vUv+sw).xyz;
    fixed3 im_ne = tex2D(iChannel2, vUv+ne).xyz;
    fixed3 im_se = tex2D(iChannel2, vUv+se).xyz;

    float dx = 3.0 * (length(im_e) - length(im_w)) + (length(im_ne) + length(im_se) - length(im_sw) - length(im_nw));
    float dy = 3.0 * (length(im_n) - length(im_s)) + (length(im_nw) + length(im_ne) - length(im_se) - length(im_sw));

    // fixedtor field neighbors
    fixed3 uv =    tex2D(iChannel0, vUv).xyz;
    fixed3 uv_n =  tex2D(iChannel0, vUv+n).xyz;
    fixed3 uv_e =  tex2D(iChannel0, vUv+e).xyz;
    fixed3 uv_s =  tex2D(iChannel0, vUv+s).xyz;
    fixed3 uv_w =  tex2D(iChannel0, vUv+w).xyz;
    fixed3 uv_nw = tex2D(iChannel0, vUv+nw).xyz;
    fixed3 uv_sw = tex2D(iChannel0, vUv+sw).xyz;
    fixed3 uv_ne = tex2D(iChannel0, vUv+ne).xyz;
    fixed3 uv_se = tex2D(iChannel0, vUv+se).xyz;
    
    // uv.x and uv.y are our x and y components, uv.z is divergence 

    // laplacian of all components
    fixed3 lapl  = _K0*uv + _K1*(uv_n + uv_e + uv_w + uv_s) + _K2*(uv_nw + uv_sw + uv_ne + uv_se);
    float sp = ps * lapl.z;
    
    // calculate curl
    // fixedtors point clockwise about the center point
    float curl = uv_n.x - uv_s.x - uv_e.y + uv_w.y + sq2 * (uv_nw.x + uv_nw.y + uv_ne.x - uv_ne.y + uv_sw.y - uv_sw.x - uv_se.y - uv_se.x);
    
    // compute angle of rotation from curl
    float sc = cs * sign(curl) * pow(abs(curl), pwr);
    
    // calculate divergence
    // fixedtors point inwards towards the center point
    float div  = uv_s.y - uv_n.y - uv_e.x + uv_w.x + sq2 * (uv_nw.x - uv_nw.y - uv_ne.x - uv_ne.y + uv_sw.x + uv_sw.y + uv_se.y - uv_se.x);
    float sd = ds * div;

    fixed2 norm = normalize(uv.xy);
    
    // temp values for the update rule
    float ta = amp * uv.x + ls * lapl.x + norm.x * sp + uv.x * sd + is * dx;
    float tb = amp * uv.y + ls * lapl.y + norm.y * sp + uv.y * sd + is * dy;

    // rotate
    float a = ta * cos(sc) - tb * sin(sc);
    float b = ta * sin(sc) + tb * cos(sc);
    
    // initialize with noise
    if(iFrame<10) {
    fixed4 fragColor;
        fragColor = -0.5 + tex2D(iChannel1,i.projPos.xy / i.projPos.w);
            return fragColor;
    } else {
     fixed4 fragColor;
        fragColor = clamp(fixed4(a,b,div,1), -1., 1.);
       return fragColor;
    }
    

}
	ENDCG
	}
  }
}

