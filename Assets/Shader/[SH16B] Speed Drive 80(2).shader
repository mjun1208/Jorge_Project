
Shader "ShaderMan/[SH16B] Speed Drive 80(2)"
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

// Post processing

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

 	fixed2 screenUV =(i.projPos.xy / i.projPos.w);
    // radial blur
    fixed4 mainSample = tex2D( iChannel0, screenUV );    
    fixed2 blurOffset = ( screenUV - fixed2( 0.5 ,0.5) ) * 0.002 * mainSample.w;
    fixed3 color = mainSample.xyz;
	for ( int iSample = 1; iSample < 16; ++iSample )
	{
		color += tex2D( iChannel0, screenUV - blurOffset * float( iSample ) ).xyz;
	}    
    color /= 16.0;
    
    // vignette
    float vignette = screenUV.x * screenUV.y * ( 1.0 - screenUV.x ) * ( 1.0 - screenUV.y );
    vignette = clamp( pow( 16.0 * vignette, 0.3 ), 0.0, 1.0 );
    color *= vignette;
    
    float scanline   = clamp( 0.95 + 0.05 * cos( 3.14 * ( screenUV.y + 0.008 * _Time.y ) * 240.0 * 1.0 ), 0.0, 1.0 );
    float grille  	= 0.85 + 0.15 * clamp( 1.5 * cos( 3.14 * screenUV.x * 640.0 * 1.0 ), 0.0, 1.0 );
    color *= scanline * grille * 1.2;    
        
    return fixed4( color, 1.0 );
}


	ENDCG
	}
  }
}

