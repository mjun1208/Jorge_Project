
Shader "ShaderMan/counter"
	{

	Properties{
	 
	}

	SubShader
	{
	 Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }

      
    Blend SrcColor one
          Cull Off
            ZWrite Off
            Ztest Always
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

#define PI 3.14159265359

fixed2 rotate(fixed2 p, float rad) {
    fixed2x2 m = fixed2x2(cos(rad), sin(rad), -sin(rad), cos(rad));
    return mul(m , p);
}

fixed2 translate(fixed2 p, fixed2 diff) {
    return p - diff;
}

fixed2 scale(fixed2 p, float r) {
    return p*r;
}

float circle(float pre, fixed2 p, float r1, float r2, float power) {
    float leng = length(p);
    if (r1<leng && leng<r2) pre = 0.0;
    float d = min(abs(leng-r1), abs(leng-r2));
    float res = power / d;
    return clamp(pre + res, 0.0, 1.0);
}

float rectangle(float pre, fixed2 p, fixed2 half1, fixed2 half2, float power) {
    p = abs(p);
    if ((half1.x<p.x || half1.y<p.y) && (p.x<half2.x && p.y<half2.y)) {
        pre = max(0.01, pre);
    }
    float dx1 = (p.y < half1.y) ? abs(half1.x-p.x) : length(p-half1);
    float dx2 = (p.y < half2.y) ? abs(half2.x-p.x) : length(p-half2);
    float dy1 = (p.x < half1.x) ? abs(half1.y-p.y) : length(p-half1);
    float dy2 = (p.x < half2.x) ? abs(half2.y-p.y) : length(p-half2);
    float d = min(min(dx1, dx2), min(dy1, dy2));
    float res = power / d;
    return clamp(pre + res, 0.0, 1.0);
}

float radiation(float pre, fixed2 p, float r1, float r2, int num, float power) {
    float angle = 2.0*PI/float(num);
    float d = 1e10;
    for(int i=0; i<360; i++) {
        if (i>=num) break;
        float _d = (r1<p.y && p.y<r2) ? 
            abs(p.x) : 
        	min(length(p-fixed2(0.0, r1)), length(p-fixed2(0.0, r2)));
        d = min(d, _d);
        p = rotate(p, angle);
    }
    float res = power / d;
    return clamp(pre + res, 0.0, 1.0);
}

fixed3 calc(fixed2 p) {
    float dest = 0.0;
    p = scale(p, sin(PI*_Time.y/1.0)*0.02+1.1);

    {
        fixed2 q = p;
        q = rotate(q, _Time.y * PI / 6.0);
        dest = circle(dest, q, 0.85, 0.9, 0.006);
        dest = radiation(dest, q, 0.87, 0.88, 36, 0.0008);
    }
    {
        fixed2 q = p;
        q = rotate(q, _Time.y * PI / 6.0);
        const int n = 6;
        float angle = PI / float(n);
        q = rotate(q, floor(atan2(q.y, q.x)/angle + 0.5) * angle);
        for(int i=0; i<n; i++) {
            dest = rectangle(dest, q, fixed2(0.85/sqrt(2.0),0.85/sqrt(2.0)), fixed2(0.85/sqrt(2.0),0.85/sqrt(2.0)), 0.0015);
            q = rotate(q, angle);
        }
    }
    {
        fixed2 q = p;
        q = rotate(q, _Time.y * PI / 6.0);
        const int n = 12;
        q = rotate(q, 2.0*PI/float(n)/2.0);
        float angle = 2.0*PI / float(n);
        for(int i=0; i<n; i++) {
            dest = circle(dest, q-fixed2(0.0, 0.875), 0.001, 0.05, 0.004);
            dest = circle(dest, q-fixed2(0.0, 0.875), 0.001, 0.001, 0.008);
            q = rotate(q, angle);
        }
    }
    {
        fixed2 q = p;
        dest = circle(dest, q, 0.5, 0.55, 0.002);
    }
    {
        fixed2 q = p;
        q = rotate(q, -_Time.y * PI / 6.0);
        const int n = 3;
        float angle = PI / float(n);
        q = rotate(q, floor(atan2(q.y, q.x)/angle + 0.5) * angle);
        for(int i=0; i<n; i++) {
            dest = rectangle(dest, q, fixed2(0.36, 0.36), fixed2(0.36, 0.36), 0.0015);
            q = rotate(q, angle);
        }
    }
    {
        fixed2 q = p;
        q = rotate(q, -_Time.y * PI / 6.0);
        const int n = 12;
        q = rotate(q, 2.0*PI/float(n)/2.0);
        float angle = 2.0*PI / float(n);
        for(int i=0; i<n; i++) {
            dest = circle(dest, q-fixed2(0.0, 0.53), 0.001, 0.035, 0.004);
            dest = circle(dest, q-fixed2(0.0, 0.53), 0.001, 0.001, 0.001);
            q = rotate(q, angle);
        }
    }
    {
        fixed2 q = p;
        q = rotate(q, _Time.y * PI / 6.0);
        dest = radiation(dest, q, 0.25, 0.3, 12, 0.005);
    }
    {
        fixed2 q = p;
    	q = scale(q, sin(PI*_Time.y/1.0)*0.04+1.1);
        q = rotate(q, -_Time.y * PI / 6.0);
        for(float i=0.0; i<6.0; i++) {
            float r = 0.13-i*0.01;
            q = translate(q, fixed2(0.1, 0.0));
        	dest = circle(dest, q, r, r, 0.002);
        	q = translate(q, -fixed2(0.1, 0.0));
        	q = rotate(q, -_Time.y * PI / 12.0);
        }
        dest = circle(dest, q, 0.04, 0.04, 0.004);
    }
    return pow(dest, 2.5) * fixed3(1.0, 0.95, 0.8);
}

fixed4 frag(v2f i) : SV_Target{
	fixed2 uv = (1 - i.uv.xy*2.0) / min(1, 1);
	return fixed4(calc(uv),1.0);
}
	ENDCG
	}
  }
}

