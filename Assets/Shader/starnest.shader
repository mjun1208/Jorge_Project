
Shader "ShaderMan/Fractal Land"
	{

	Properties{

	}

	SubShader
	{

	Pass
	{
	Color (0,0,1,1)
	Cull Off
			CGPROGRAM
			#pragma vertex V
			#pragma fragment P  
	 float4 _iMouse;
	 sampler2D _MainTex;



    // Star Nest by Pablo Roman Andrioli

// This content is under the MIT License.

#define iterations 17
#define formuparam 0.53

#define volsteps 20
#define stepsize 0.1

#define zoom   0.800
#define tile   0.850
#define speed  0.010 

#define brightness 0.0015
#define darkmatter 0.300
#define distfading 0.730
#define saturation 0.850


	void V(uint i:SV_VertexID,out half4 c:POSITION) {c=half4((i<<1&2)*2-1.,1-2.*(i&2),1,1);}

			void P(half4 u:POSITION,out half4 s:COLOR) 
			{	
	//get coords and direction
	fixed2 uv=u.xy/_ScreenParams.xy-.5;
	uv.y*=1/1;
	fixed3 dir=fixed3(uv*zoom,1.);
	float time=_Time.y*speed+.25;

	//mouse rotation
	float a1=.5+_iMouse.x/1*2.;
	float a2=.8+_iMouse.y/1*2.;
	fixed2x2 rot1=fixed2x2(cos(a1),sin(a1),-sin(a1),cos(a1));
	fixed2x2 rot2=fixed2x2(cos(a2),sin(a2),-sin(a2),cos(a2));
	dir.xz=mul(dir.xz,rot1);
	dir.xy=mul(dir.xy,rot2);
	fixed3 from=fixed3(1.,.5,0.5);
	from+=fixed3(time*2.,time,-2.);
	from.xz=mul(from.xz,rot1);
	from.xy=mul(from.xy,rot2);
	
	//volumetric rendering
	float cs=0.1,fade=1.;
	fixed3 v=fixed3(0.,0.,0.);
	for (int r=0; r<volsteps; r++) {
		fixed3 p=from+cs*dir*.2;
		p = abs(fixed3(tile,tile,tile)-fmod(p,fixed3(tile*2.,tile*2.,tile*2.))); // tiling fold
		float pa,a=pa=0.;
		for (int i=0; i<iterations; i++) { 
			p=abs(p)/dot(p,p)-formuparam; // the magic formula
			a+=abs(length(p)-pa); // absolute sum of average change
			pa=length(p);
		}
		float dm=max(0.,darkmatter-a*a*.001); //dark matter
		a*=a*a; // add contrast
		if (r>6) fade*=1.-dm; // dark matter, don't render near
		//v+=fixed3(dm,dm*.5,0.);
		v+=fade;
		v+=fixed3(cs,cs*cs,cs*cs*cs*cs)*a*brightness*fade; // coloring based on distance
		fade*=distfading; // distance fading
		cs+=stepsize;
	}
	v=lerp(fixed3(length(v),length(v),length(v)),v,saturation); //color adjust
	s = fixed4(v*.01,1.);	
	
}



	
	ENDCG
	}
  }
}

