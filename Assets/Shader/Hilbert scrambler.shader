
Shader "ShaderMan/Hilbert scrambler"
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

//#define SHOWPACKING
static const int MaxIter=9;//try other values .
//For more fun use the 'checker' texture (2nd row 5th column)

float scl=1.;
float scl2=1.;
void init(){
	scl=pow(0.5,float(MaxIter));
	scl2=scl*scl;
}

//Coposition of two "rotations"
fixed2 fG(fixed2 t0, fixed2 t1){
	return fixed2(dot(t0,t1), dot(t0, t1.yx));
}

//Action of rotation on "elementary" coordinates
fixed2 fA(fixed2 t, fixed2 p){
	return fG(t,p-fixed2(0.5,0.5))+fixed2(0.5,0.5);
}

//Given "elementary" coordinates of position, returns the corresponding "rotation".
fixed2 fCg(fixed2 p){
	return fixed2(p.y, (1.-2.*p.x)*(1.-p.y));
}

//Given "elementary" coordinates of position (c=2*p.x+p.y), returns the "elementary" linear coordinates
float fL(float c){
	return max(0.,0.5*((-3.*c+13.)*c-8.));
}

//Given a point inside unit square, return the linear coordinate
float C2L(fixed2 p){
	fixed2 t=fixed2(1.,0.);//initial rotation is the identity
	float l=0.;//initial linear coordinate
	for(int i=0; i<MaxIter;i++){
		p*=2.; fixed2 p0=floor(p); p-=p0;//extract leading bits from p. Those are the "elementary" (cartesian) coordinates.
		p0=fA(t,p0);//Rotate p0 by the current rotation
		t=fG(t,fCg(p0));//update the current rotation
		float c= p0.x*2.+p0.y;
		l=l*4.+fL(c);//update l
	}
	return l*scl2;//scale the result in order to keep between 0. and 1.
}

//Given the linear coordinate of a point (in [0,1[), return the coordinates in unit square
//it's the reverse of C2L
fixed2 L2C(float l){
	fixed2 t=fixed2(1.,0.);
	fixed2 p=fixed2(0.,0.);
	for(int i=0; i<MaxIter;i++){
		l*=4.; float c=floor(l); l-=c;
		c=0.5* fL(c);
		fixed2 p0=fixed2(floor(c),2.*(c-floor(c)));
		t=fG(t,fCg(p0));
		p0=fA(t,p0);
		p=p*2.+p0;
	}
	return p*scl;
}

float dist2box(fixed2 p, float a){
	p=abs(p)-fixed2(a,a);
	return max(p.x,p.y);
}

float d2line(fixed2 p, fixed2 a, fixed2 b){//distance to line (a,b)
	fixed2 v=b-a;
	p-=a;
	p=p-v*clamp(dot(p,v)/(dot(v,v)),0.,1.);//Fortunately it still work well when a==b => division by 0
	return min(0.5*scl,length(p));
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

	fixed2 uv =(i.projPos.xy / i.projPos.w);
	init();
	fixed4 fragColor;


#ifndef SHOWPACKING
	//scramble the texture
	float l=C2L(uv);
	float t=fmod(1./4.*scl*_Time.y,1.)*1./scl2;
	l=fmod(l+t*scl2,1.);
	fixed2 ps=L2C(l)+fixed2(.5*scl,.5*scl);
	return tex2D(iChannel0,ps);
#else
	//shows the texture along the Hilbert curve



	fragColor = tex2D(iChannel0,ps);
#endif
}
	ENDCG
	}
  }
}

