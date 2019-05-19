
Shader "ShaderMan/Sobel Edge Detection"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	edgeColor  (  "Ambient Color",  Color  ) = ( 1, 1, 1, 1 )
}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
     
        GrabPass{ "iChannel0"}
        Pass {
     
            Cull Front
            ZTest Always
            ZWrite Off

           
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"



	//Variables
sampler2D iChannel0;

// http://en.wikipedia.org/wiki/Sobel_operator

 fixed3x3 gx = fixed3x3(
	 1.0,  2.0,  1.0,
	 0.0,  0.0,  0.0,
	-1.0, -2.0, -1.0
);

fixed3x3 gy = fixed3x3(
	-1.0, 0.0, 1.0,
	-2.0, 0.0, 2.0,
	-1.0, 0.0, 1.0
);

static  const fixed3 edgeColor = fixed3(1.0, 1.0, 1.0);

float intensity(fixed3 pixel) {
	return (pixel.r + pixel.g + pixel.b) / 3.0;
}

float pixelIntensity(fixed2 uv, fixed2 d) {
	fixed3 pix = tex2D(iChannel0, uv + d / 1).rgb;
	return intensity(pix);
}

float convolv(fixed3x3 a, fixed3x3 b) {
	float result = 0.0;

	for (int i=0; i<3; i++) {
		for (int j=0; j<3; j++) {
			result += a[i][j] * b[i][j];
		}
	}

	return result;
}

float sobel(fixed2 uv) {
	fixed3x3 pixel = fixed3x3(0.0,0,0,0,0,0,0,0,0);

	for (int x=-1; x<2; x++) {
		for (int y=-1; y<2; y++) {
			pixel[x+1][y+1] = pixelIntensity(uv, fixed2(float(x), float(y)));
		}
	}

	float xxx = convolv(gx, pixel);
	float yxx = convolv(gy, pixel);

	return sqrt(xxx * xxx + yxx * yxx);
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


	fixed2 uv = (i.projPos.xy / i.projPos.w);

	float time = _Time.y * 0.75;

	float x = 0.5 + sin(time) * 0.25;
	float y = 0.5 + cos(time) * 0.25;

	fixed3 color = tex2D(iChannel0, uv).rgb;	
	float s = sobel(uv);

	// Top left
	if (uv.x < x && uv.y > y) {
		// original
	}
	// Bottom right
	else if (uv.x > x && uv.y < y) {
		color += edgeColor * s;
	}
	// Top right
	else if (uv.x > x && uv.y > y) {
		color = edgeColor * s;
	}
	// Bottom left
	else {
		color = edgeColor * (1.0 - s);
	}
	
	return fixed4(color, 1.0);
}
	ENDCG
	}
  }
}

