
Shader "ShaderMan/Tileable Water Caustic W Distort"
	{

		Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	fragColor ("display name", Color) = (1,1,1,1)
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



// Found this on GLSL sandbox. I really liked it, changed a few things and made it tileable.
// :)
// by David Hoskins.


// Water turbulence effect by joltz0r 2013-07-04, improved 2013-07-07
sampler2D iChannel0;

// Redefine below to see the tiling...
//#define SHOW_TILING

#define TAU 6.28318530718
#define MAX_ITER 5

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

	float time = _Time.y * .5+23.0;
    // uv should be the 0-1 uv of texture...
	fixed2 uv =(i.projPos.xy / i.projPos.w);
    
#ifdef SHOW_TILING
	fixed2 p = fmod(uv*TAU*2.0, TAU)-250.0;
#else
    fixed2 p = fmod(uv*TAU, TAU)-250.0;
#endif
	fixed2 ii = fixed2(p);
	float c = 1.0;
	float inten = .005;

	for (int n = 0; n < MAX_ITER; n++) 
	{
		float t = time * (1.0 - (3.5 / float(n+1)));
		ii = p + fixed2(cos(t - ii.x) + sin(t + ii.y), sin(t - ii.y) + cos(t + ii.x));
		c += 1.0/length(fixed2(p.x / (sin(ii.x+t)/inten),p.y / (cos(ii.y+t)/inten)));
	}
	c /= float(MAX_ITER);
	c = 1.17-pow(c, 1.4);
	fixed3 colour = fixed3(pow(abs(c), 8.0),pow(abs(c), 8.0),pow(abs(c), 8.0));
    colour = clamp((colour + fixed3(0.0, 0.35, 0.5))*1.2, 0.0, 1.0);
    

	#ifdef SHOW_TILING
	// Flash tile borders...
	fixed2 pixel = 2.0 / iResolution.xy;
	uv *= 2.0;

	float f = floor(mod(_Time.y*.5, 2.0)); 	// Flash value.
	fixed2 first = step(pixel, uv) * f;		   	// Rule out first screen pixels and flash.
	uv  = step(frac(uv), pixel);				// Add one line of pixels per tile.
	colour = lerp(colour, fixed3(1.0, 1.0, 0.0), (uv.x + uv.y) * first.x * first.y); // Yellow line
	#endif
    
    // added distortion of background image
	fixed2 coord =(i.projPos.xy / i.projPos.w);
    
    // perterb uv based on value of c from caustic calc above
    fixed2 tc = fixed2(cos(c)-0.75,sin(c)-0.75)*0.04;
    coord = clamp(coord + tc,0.0,1.0);
    fixed4 fragColor;
    fragColor = tex2D(iChannel0, coord);
    // give transparent pixels a color
    if (fragColor.a == 0.0 ) fragColor=fixed4(1.0,1.0,1.0,1.0);    
    fragColor *= fixed4(colour, 1.0);
    return fragColor;
}
	ENDCG
	}
  }
}

