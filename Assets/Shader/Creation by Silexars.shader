
Shader "ShaderMan/Creation by Silexars"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Blend SrcColor one
          Cull Off

	Pass
	{


	CGPROGRAM
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
           
            #pragma target 3.0

	  struct appdata{
    float4 vertex : POSITION;
	float2 uv:TEXCOORD0;
	};

	struct v2f
    {
    float2 uv : TEXCOORD0;
    float4 vertex : SV_POSITION;
    float4 screenCoord : TEXCOORD1;
    };

    v2f vert(appdata v)
    {
    v2f o;
    o.vertex = UnityObjectToClipPos(v.vertex);
    o.uv = v.uv;
    o.screenCoord.xy = ComputeScreenPos(o.vertex);
    return o;
    }


	//Variables

	// http://www.pouet.net/prod.php?which=57245
// If you intend to reuse this shader, please add credits to 'Danilo Guanabara'

// http://www.pouet.net/prod.php?which=57245
// If you intend to reuse this shader, please add credits to 'Danilo Guanabara'

#define t _Time.w


fixed4 frag(v2f ii) : SV_Target{
	fixed3 c;
	float l,z=t;
	for(int i=0;i<3;i++) {
		fixed2 duv,p=ii.uv/1;
		duv=p;
		p-=.5;
		p.x*=1/1;
		z+=.07;
		l=length(p);
		duv+=p/l*(sin(z)+1.)*abs(sin(l*9.-z*2.));
		c[i]=.02/length(abs(fmod(duv,1.)-.5));
	}
	return fixed4(c/l,t);
}
	ENDCG
	}
  }
}

