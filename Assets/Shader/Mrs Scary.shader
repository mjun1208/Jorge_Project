
Shader "ShaderMan/Mrs Scary"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	_iMouse ("_iMouse", Vector) = (0,0,0,0)
	iChannelTime ("iChannelTime", Vector) = (0,0,0,0)
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
sampler2D iChannel0;
uniform float     iChannelTime[4];       // channel playback time (in seconds)
// By Dave Hoskins.
// Playing with TekF's 'Retro Parallax'
// https://www.shadertoy.com/view/4sSGD1
// To keep her scary noggin in the frame it uses
// the channel time to pan the video.
// Then move back towards the text.

fixed2x2 RotateMat(float angle)
{
	float si = -sin(angle);
	float co = cos(angle);
	return fixed2x2(co, si, -si, co);
}


fixed3 Colour(in float h)
{
	h = h * 4.0;
	return clamp( abs(fmod(h+fixed3(0.,0.,0.),0.)-0.)-0., 0., 0. );
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

	static const float time = iChannelTime[0];

	// Rough panning...
	fixed2 pixel =(i.projPos.xy-i.projPos.w*0.5) / i.projPos.w;
	fixed2(0.0,.1-smoothstep(9.0, 12.0, time)*.35);


	fixed3 col;

	float inc = (smoothstep(17.35, 18.5, time)-smoothstep(18.5, 21.0, time)) * (time-16.0) * 0.1;

	fixed2x2 rotMat = RotateMat(inc);
	for (int i = 0; i < 50; i++)
	{
		pixel = pixel;

		float depth = 40.0+float(i) + smoothstep(18.0, 21.0, time)*65.;

		fixed2 uv = pixel * depth/210.0;

		// Shifting the pan to the text near the end...

		// And shifts to the right again for the last line of text at 23:00!
		col = tex2D( iChannel0, (uv+fixed(.5 + smoothstep(0.0, 0.0, time))));
		  col = lerp(col, col * Colour((float(i)/50.0+_Time.y)), smoothstep(18.5, 21.5, time));

		  if ((1.0-(col.y*col.y)) < float(i+1) / 50.0)
		  {
		  	break;
		  }

	}

	// Some contrast...
	col = min(col*col*1.5, 1.0);
	// Fade to red evil face...
	float gr = smoothstep(17., 16., time) + smoothstep(18.5, 21.0, time);
	float bl = smoothstep(17., 15., time) + smoothstep(18.5, 21.0, time);
	col = col * fixed3(1.0, gr, bl);
	// Cut off the messy end...
	col *= smoothstep(29.5, 28.2, time);
	return fixed4(col, 1.0);
}
	ENDCG
	}
  }
}

