
Shader "ShaderMan/Simple UV rotator"
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
            #define UNITY_PASS_FORWARDBASE
            #define _GLOSSYENV 1
            #include "UnityCG.cginc"
            #include "UnityPBSLighting.cginc"
            #include "UnityStandardBRDF.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0



	//Variables
sampler2D iChannel0;

// The MIT License
// Copyright © 2017 Michael Schuresko
// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


 struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {

    // Normalized pixel coordinates (from 0 to 1)
    fixed2 uv =  (i.projPos.xy / i.projPos.w);

   static const fixed3x3 to_yuvish = fixed3x3(0.299, -0.14713, 0.615,
                          0.587, -0.28886, -0.51499,
                          0.114, 0.436, -0.10001);
   static const fixed3x3 from_yuvish = fixed3x3(1.0, 1.0, 1.0,
                            0.0, -0.39465, 2.03211,
                            1.13983, -0.58060, 0.0);

    // Output to screen
    fixed4 fragColor;
    fragColor = tex2D(iChannel0, uv );
    float rot_amount = smoothstep(0.2, 0.6, 0.95 * length(fragColor.rgb)) * 
        smoothstep(1.0, 0.6, 0.95 * length(fragColor.rgb));
    fragColor.r += 0.2 * rot_amount;
    rot_amount *= 6.0 * sin(12.0 * _Time.y + 100.0 * length(fragColor.rgb));
    float stheta = sin(rot_amount);
    float ctheta = cos(rot_amount);
    fixed3x3 rot =  fixed3x3(1.0, 0.0, 0.0,
                    0.0, ctheta, -stheta,
                    0.0, stheta, ctheta);
    fragColor.rgb = (from_yuvish  , rot , to_yuvish , smoothstep(0.3, 0.7, fragColor.rgb));
    return fragColor;
}
	ENDCG
	}
  }
}

