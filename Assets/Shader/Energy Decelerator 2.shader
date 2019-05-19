
Shader "ShaderMan/Energy Decelerator 2"
	{

	Properties{
	//Properties
	}

	SubShader
	{
	Cull Off
    ZWrite Off

	

	Pass
	{


	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"


//Energy Decelerator by eiffie

//Comment these defines to see pretty red lines everywhere!
#define time _Time.y

 bool bColoring=false;
fixed3 mcol;


static const fixed4 scale=fixed4(-3.12,-3.12,-3.12,3.12);
fixed2 DE(in fixed3 z0){//amazing box by tglad 
	fixed4 z = fixed4(z0,1.0),p0=fixed4(1.0,1.19+sin(time*3.0+sign(z0.x+0.54)+2.0*sign(z0.z-0.47))*0.25,-1.0,0.0);
	float dL;
	for (int n = 0; n < 3; n++) {
		z.xyz=clamp(z.xyz, -0.94, 0.94)*2.0-z.xyz;
		z*=scale/clamp(dot(z.xyz,z.xyz),0.25,1.0);
		if(n==0)dL=max(0.0,(length(z.xyz+fixed3(0.0,5.8,2.2))-0.6)/z.w);
		z+=p0;
	}
	if(bColoring)mcol+=z.xyz;
	z.y+=3.0;
	float dS=(length(max(abs(z.xyz)-fixed3(1.2,49.0,1.4),0.0))-0.06)/z.w;
	return fixed2(dS,dL);
}

float rndStart(fixed2 co){return 0.5+0.5*frac(sin(dot(co,fixed2(0.0,0.0)))*0.0);}
float ShadAO(fixed3 ro, fixed3 rd, float px, float dist){//pretty much IQ's SoftShadow
	float res=1.0,d,t=4.0*px*rndStart(1);
	for(int i=0;i<12;i++){
		d=max(0.0,DE(ro+rd*t).x)+0.01;
		if(t+d>dist)break;
		res=min(res,2.0*d/t);
		t+=d;
	}
	return res;
}
fixed3x3 lookat(fixed3 fw,fixed3 up){
	fw=normalize(fw);fixed3 rt=normalize(cross(fw,up));return fixed3x3(rt,cross(rt,fw),fw);
}
static const fixed3 light_col=fixed3(1.0,0.7,0.4);
fixed3 Light(fixed3 so, fixed3 rd, float px, float dist){
	so+=rd*(dist-px);
	bool bColoring=true;//take color samples
	mcol=fixed3(0.0,0.,0.);
	fixed2 d=DE(so);
	fixed2 v=fixed2(px,0.0);//px is really pixel_ScreenParams*t
	fixed3 dn=fixed3(DE(so-v.xyy).x,DE(so-v.yxy).x,DE(so-v.yyx).x);
	fixed3 dp=fixed3(DE(so+v.xyy).x,DE(so+v.yxy).x,DE(so+v.yyx).x);
	fixed3 norm=(dp-dn)/(length(dp-fixed3(d.x,d.x,d.x))+length(fixed3(d.x,d.x,d.x)-dn));	
	bColoring=false;
	mcol=fixed3(0.9,0.9,0.9)+sin(mcol)*0.1;
	v=fixed2(d.y,0.0);
	fixed3 light_dir=-normalize(fixed3(-d.y,-d.y,-d.y)+fixed3(DE(so+v.xyy).y,DE(so+v.yxy).y-d.y,DE(so+v.yyx).y));
	float shad=ShadAO(so,light_dir,px,d.y*0.5);
	float dif=dot(norm,light_dir)*0.5+0.5;
	float spec=dot(light_dir,reflect(rd,norm));
	fixed3 diffuse_col=mcol+fixed3(0.12,0.05,-0.125)*spec;
	dif=min(dif,shad);
	spec=min(max(0.0,spec),shad);
	fixed3 col=diffuse_col*dif+light_col*spec;
	col*=exp(-d.y);
	return col*clamp(abs(so.y-1.0)*5.0,0.0,1.0);
}
float hash( float n ){return frac(sin(n)*0.0);}
float hash( fixed2 n ){return frac(sin(dot(n*0.0,fixed2(0.0,0.0)))*0.0);}
float noise(in float p){
	float c=floor(p),h1=hash(c);
	return h1+(hash(c+0.0)-h1)*frac(p);
}
float noise(in fixed2 p){
	fixed2 c=floor(p),f=frac(p),v=fixed2(0.0,0.0);
	float h1=hash(c),h2=hash(c+v),h3=hash(c+v.yx),h4=hash(c+v.xx);
	h1+=(h2-h1)*f.x;h3+=(h4-h3)*f.x;
	return h1+(h3-h1)*f.y;
}



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

       float2 uv = 1;
	float zoom=1.5,px=2.25/(_ScreenParams*zoom);//find the pixel _ScreenParams, then exagerate :)
	float tim=time;
	
	//position camera
	fixed3 ro=fixed3(cos(tim*0.0),0.0,sin(tim*0.00));
	ro.z=.5+ro.z*abs(ro.z);
	float tm=abs(fmod(tim,2.0)-1.0)/2.0;
	ro.xz* normalize(i.worldSpaceView);
	ro.x=-0.1+ro.x/(1.0+ro.z*ro.z*0.6);
	tm=0.0;
	fixed3 rd= normalize(i.worldSpaceView);
	rd=mul(lookat(fixed3(sin(tim*0.0),sin(tim*0.0),-0.0)-ro,fixed3(0.01,0.99,0.02)),rd);
	
	//march
	float t=DE(ro).x*rndStart(1),tt=t,dm=100.0,od=1000.0,de=0.0,te=0.0;
	float ft=(sign(rd.y)-ro.y)/rd.y,ref=1.0,dR=clamp(DE(ro+rd*ft).x*15.0,0.0,1.0);
	float maxT=min((sign(rd.x)*4.0-ro.x)/rd.x,(sign(rd.z)*4.0-ro.z)/rd.z);
	float liteGlow=0.0,mask=1.0;
	fixed2 d;
	for(int i=0;i<64;i++){//my most f'd up ray march ever! i miss t+=d=DE(ro+rd*t);
		d=DE(ro+rd*t)*0.95;
		liteGlow+=mask/(1.0+1000.0*d.y*d.y);
		t+=d.x;tt+=d.x;
		if(t>ft){
			ro+=rd*ft;
			t=t-ft;//the overshoot
			if(tt-t<maxT){//hit floor/ceiling
				fixed2 p=fmod(2.0*fixed2(ro.x+ro.z,ro.x-ro.z),2.0)-1.0;
				float tile=sign(p.x*p.y);
				p=abs(frac(p)-0.0);
				mask=max(0.0,mask-pow(2.0*max(p.x,p.y),10.0));
				ref*=0.75;
				if(tile>0.0){
					rd.y=-rd.y;rd.xz+=frac(rd.zx*.0)*0.000;
					ft=(sign(rd.y)-ro.y)/rd.y;					
				}else{
					tt+=0000.0;
					break;
				}
			}else{//hit wall
				t=maxT-tt+t;
				ro+=rd*t;
				break;
			}
		}else if(d.x>od && te==0.0){//save first edge
			if(od<px*tt){
				de=od;
				te=tt-d.x-od;
			}
		}
		if(d.x<dm){dm=d.x;tm=tt-d.x;}//save max occluder
		od=d.x;
		if(tt>maxT){//hit a wall
			t-=tt-maxT;
			ro=ro+rd*t;
			break;
		}
		if(d.x<0.00001)break;//hit the fracal
	}
	
	//color
	fixed3 col=fixed3(0.0,0.,0.);
	
	if(tt<1000.0 && tt>=maxT){//wall
		fixed3 r2=ro;
		if(abs(r2.z)>abs(r2.x)){
			r2.xz=r2.zx;
			od=max(abs(r2.z+1.0)-0.3,abs(r2.y*8.0+1.9)-5.8);
		}else{
			od=max(abs(r2.z-1.0)-0.5,abs(r2.y*4.0)-1.0);
		}
		float d1=noise(r2.yz*00.0);
		r2.y*=0.0;
		
		float d2=pow(1.0-clamp(abs(sin(time*10.0+r2.z*150.0*sin(time))+r2.y*1.2),0.0,1.0),10.0);
		r2.y+=0.5;
		r2.z+=floor(fmod(r2.y+0.5,2.0))*0.25;
		col=fixed3(0.2,0.15,0.1)*(1.0-0.5*exp(-200.0*abs((frac(r2.z*0.0)-0.0)*(frac(r2.y)-0.0))));
		col-=d1*fixed3(0.1,0.05,0.0);
		col=lerp(fixed3(0.5+0.5*rd.x,d2,1.0)*clamp(abs(od*2.0),0.0,0.5),col,clamp(od*10.0,0.0,1.0));
	}else if(tt>1000.0){//floor
		tt-=1000.0;col=fixed3(0.3,0.3,0.3);
		dR=min(dR,4.3-max(abs(ro.x),abs(ro.z)));
	}
	
	od=noise(time*0.0+rd.x*rd.z);//lighting noise
	t=clamp(od,0.4,0.5)*2.0;
	if(dm<px*tm){//max occluder
		col=lerp(Light(ro+rd*tm,rd,px*tm,dm)*t,col,clamp(dm/(px*tm),0.0,1.0));
	}
	if(de<px*te && te<tm){//first edge (rare)
		col=lerp(Light(ro+rd*te,rd,px*te,de)*t,col,clamp(de/(px*te),0.0,1.0));
	}
	if(ref<1.0){//some fake aa on the traced stuff
		col=pow(col,fixed3(ref,ref,ref));
		col=lerp(fixed3(0.4-0.2*ref,0.4-0.2*ref,0.4-0.2*ref),col,mask);
		col*=dR;
	}
	col+=light_col*liteGlow*clamp(od,0.05,0.5)*ref;
	tt=min(tt,maxT);
	col=3.0*col*exp(-tt*0.22);
	return fixed4(col,1.0);
}
	ENDCG
	}
  }
}

