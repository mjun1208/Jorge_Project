
Shader "ShaderMan/GameBoy Shader"
	{

	Properties{
	iChannel1 ("iChannel1", 2D) = "" {}
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
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
sampler2D iChannel1;

	



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

    // the amount to pixelate
    const float amount = 1000.0;
    
    // Normalized pixel coordinates (from 0 to 1)
    fixed2 uv = (i.projPos.xy / i.projPos.w);
    
    float d = 1.0 / amount;
	float ar = 1 / 1;
	uv.x = floor( uv.x / d ) * d;
	d = ar / amount;
	uv.y = floor( uv.y / d ) * d;
    
    fixed4 color = tex2D(iChannel1, uv);
    float average = 0.2126 * color.x + 0.7152 * color.y + 0.0722 * color.z;
    color = fixed4(fixed3(average,average,average), 1);
    
    if (color.x <= 0.25)
    {
        color = fixed4(0.06, 0.22, 0.06, 1);
    }
    else if (color.x > 0.75)
    {
        color = fixed4(0.6, 0.74, 0.06, 1);
    }
    else if (color.x > 0.25 && color.x <= 0.5)
    {
        color = fixed4(0.19, 0.38, 0.19, 1);
    }
    else
    {
        color = fixed4(0.54, 0.67, 0.06, 1);
    }
        

   return color;
}
	ENDCG
	}
  }
}

