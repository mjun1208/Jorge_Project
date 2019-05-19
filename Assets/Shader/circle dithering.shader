
Shader "ShaderMan/Shining Supernova"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	col  (  "Ambient Color",  Color  ) = ( 1, 1, 1, 1 )
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
            
            #include "UnityCG.cginc"
            #pragma vertex vert
            #pragma fragment frag
            
            #pragma target 3.0
           



	//Variables
sampler2D iChannel0;

// ref image: http://www.boredpanda.com/single-line-plotter-scribbles-sergej-stoppel/
// ( doing it simpler: circles instead of scribbles ;-) )

float L = 8.,                   // L*T = neightborhood size
      T = 4.,                   // grid step for circle centers
      d = 1.;                   // density

#define T(U) tex2D(iChannel0, (U)/R).r // * 1.4
//#define T(U) sqrt( texture(iChannel0, (U)/R).r * 1.4 )
//#define T(U) length(texture(iChannel0, (U)/R).rgb)
    
#define rnd(P)  frac( sin( dot(P,fixed2(12.1,31.7)) + 0.*_Time.y )*43758.5453123)
#define rnd2(P) frac( sin( mul((P) , fixed2x2(12.1,-37.4,-17.3,31.7)) )*43758.5453123)

#define C(U,P,r) smoothstep(1.5,0.,abs(length(P-U)-r))                       // ring
//#define C(U,P,r) exp(-.5*dot(P-U,P-U)/(r*r)) * sin(1.5*6.28*length(P-U)/r) // Gabor

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


    fixed2 R = _ScreenParams.xy;
//  O += T(U)-O; return;
fixed4 O;
    O += 1.-O; 
  
    for (float j = -L; j <=L; j++)    // test potential circle centers in a window around U
        for (float i = -L; i <=L; i++) {
         // fixed2 P = U+fixed2(i,j);
            fixed2 P = floor( 1/T + fixed2(i,j) ) *T;          // potential circle center
            P += T*(rnd2(P)-.5);
            float v = T(P),                                // target grey value
                  r = lerp(2., L*T ,v);                     // target radius
            if ( rnd(P) < (1.-v)/ r*4.*d /L*T*T )          // draw circle with probability
             return sqrt(O);
 }            


}
	ENDCG
	}
  }
}

