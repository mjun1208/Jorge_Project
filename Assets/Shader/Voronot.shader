
Shader "ShaderMan/Voronot"
	{

	Properties{
	_iDate ("iDate", Vector) = (0,0,0,0)
	}

	SubShader
	{
	Tags { "RenderType" = "Transparent" "Queue" = "Transparent" }

	Pass
	{
	ZWrite OfragColorfragColor
	Blend SrcAlpha OneMinusSrcAlpha

	 CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0

	

	//Variables
float4 _iDate;

	



 struct v2f {
                float4 position : SV_POSITION;
                //float2 uv : TEXCOORD0; // stores uv
                float3 worldSpacePosition : TEXCOORD0;
                float3 worldSpaceView : TEXCOORD1; 
            };
            
            v2f vert(appdata_full i) {
            	
            
                v2f o;
                o.position = UnityObjectToClipPos (i.vertex);
                
                float4 vertexWorld = mul(unity_ObjectToWorld, i.vertex);
                
                o.worldSpacePosition = vertexWorld.xyz;
                o.worldSpaceView = vertexWorld.xyz - _WorldSpaceCameraPos;
                return o;
            }

            fixed4 frag(v2f i) : SV_Target {
	fixed2  r = _ScreenParams.xy, p = p - r*.5;
	float d = length(p) / r.y, c=1., x = pow(d, .1), y = atan2(p.y, p.x) / 6.28;
	
	for (float i = 0.; i < 3.; ++i)    
		c = min(c, length(frac(fixed2(x - _iDate.w*i*.005, frac(y + i*.125)*.5)*20.)*2.-1.));

	return fixed4(d+20.0*(0.6-d));
}
	ENDCG
	}
  }
}

