
Shader "ShaderMan/Two And A Half Rotozoomers"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	iChannel1 ("iChannel1", 2D) = "" {}

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
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0



	

	//Variables
float4 _iMouse;
sampler2D iChannel0;
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

	fixed2 uv = (i.projPos.xy / i.projPos.w);
	float time = _Time.y;
	float time2 = _Time.y/1.2;
	
	fixed3 zoomy1 = tex2D(iChannel0,fixed2(
		uv.x+uv.y*sin(time/2.0)*4.0+time
		,
		uv.y-uv.x*sin(time/2.0)*4.0-time*0.6
	)).rgb;
	
	fixed3 zoomy2 = tex2D(iChannel1,fixed2(
		uv.x-uv.y*sin(time2/2.0+0.3)*4.0+time2
		,
		uv.y+uv.x*sin(time2/2.0+0.3)*4.0-time2*0.6
	)).rgb;
	
	float zoomyA = sin((
		uv.x*8.0-uv.y*8.0*sin(time2/2.0+0.7)*4.0+time2*15.0
	))*sin(
		uv.y*8.0+uv.x*8.0*sin(time2/2.0+0.7)*4.0-time2*6.2
	);
	return fixed4(lerp(zoomy1,zoomy2,smoothstep(-0.01,0.01,zoomyA)),1.0);
}
	ENDCG
	}
  }
}

