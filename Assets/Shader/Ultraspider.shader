
Shader "ShaderMan/Ultraspider"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}
	iChannel2 ("iChannel2", 2D) = "" {}
	iChannel3 ("iChannel3", 2D) = "" {}
	_iMouse("_iMouse", Vector) = (0,0,0,0)

	}

	SubShader
	{
	 Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
	 GrabPass{"iChannel0" }

	Pass
	{
	   Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }

            Cull Front
            ZTest Always

	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
uniform float4 _iMouse;
sampler2D iChannel3;
sampler2D iChannel2;
sampler2D iChannel1;
sampler2D iChannel0;

	




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


    fixed2 screenPos = (i.projPos.xy / i.projPos.w); // position in the screen
    fixed2 mouse = _iMouse.xy /1; // mouse position relative to the screen
    fixed4 channel0 = tex2D(iChannel0, screenPos); // iChannel0
    fixed4 channel1 = tex2D(iChannel1, screenPos); // iChannel1
    fixed4 channel2 = tex2D(iChannel2, screenPos); // iChannel2
    fixed4 channel3 = tex2D(iChannel3, screenPos); // iChannel3
    
//    fixed4 color = fixed4(.0,1.0,.0,1.0); // final color, initial value is white
    fixed2 displaceFactor = fixed2(sin(screenPos.y * 16.0) / screenPos.y * .015 , 0.0);
    fixed4 grey = fixed4(.5, .5, .5, 1.0);
    
	//fixed4 color = channel0;
    float r = tex2D(iChannel0, screenPos - fixed2((0.5 + sin(channel2.y * 5.0)/2.0) * 0.03, 0.0) + displaceFactor).r;
    float b = tex2D(iChannel0, screenPos + fixed2((0.5 + sin(channel2.y * 5.0)/2.0) * 0.03, 0.0) + displaceFactor).b;
    
    float g = tex2D(iChannel0, screenPos + displaceFactor).g;
    
    //color = lerp(color, r, .5);
    fixed4 colorDistort = fixed4(r, g, b, 1.0);
    
    fixed4 color = lerp(grey, colorDistort, 0.8);
	return color;
} 
	ENDCG
	}
  }
}

