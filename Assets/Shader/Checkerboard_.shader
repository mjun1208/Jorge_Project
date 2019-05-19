
Shader "ShaderMan/Checkerboard_"
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
           ColorMask G

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel0;
sampler2D iChannel1;
uniform fixed4 fragColor;
	
	static const float pi = 3.141592653;

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
	//COLORS FOR SQUARES
    fixed4 black = tex2D(iChannel1,uv);
    fixed4 white = tex2D(iChannel0,uv);
    
    uv.y *=1/1;

    //SIZE OF BOARD
    float xSide = 20.0;
    float ySide = 20.0;
    uv += _Time.y * uv;
    float angvel = sin(uv.x*1.0+uv.x*0.0) * 0.5*pi*_Time.w;
    float angle = atan2(xSide, ySide*angvel);
    fixed4 fragColor;
    //Black Layer
    fragColor = black;
    
    //Place white boxes on top of black background
    if (fmod(uv.x * xSide, 2.0)> 1.0 && fmod(uv.y * ySide, 2.0)>1.0 ||
        fmod(uv.x * xSide, 2.0)< 1.0 && fmod(uv.y * ySide, 2.0)<1.0){
     fragColor = white;   

    }
    return (fragColor*angle);
}
	ENDCG
	}
  }
}

