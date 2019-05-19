
Shader "ShaderMan/Meta Shape"
	{

	Properties{
	iChannel0 ("iChannel0", 2D) = "" {}
	}

	 SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Overlay+1"
            "RenderType"="Overlay"
        }
        GrabPass{"iChannel0"}
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

// Made by - Edwin de Koning - Resolume
// Meta Shape effect that will be part of Resolume 6
// Wanted to make a Meta Shape with the use of Distance fields
// Works cool with camera input as well


static const float Subd 	= 50.0;	//Subdivisions

static const int 	Shape1 	= 0;	//0=Circle, 1=Rectangle, 2=Hexagon, 3=Cross
static const int 	Shape2 	= 3;	//0=Circle, 1=Rectangle, 2=Hexagon, 3=Cross

static const int 	Fill 	= 2;  	//0=White, 1=Greyscale, 2-Sampled, 3-Original
static const int 	Scale 	= 1;	//0=Don't Scale, 1=Scale based on luminance 
static const int 	Invert	= 0;	//toggle to invert luminance
static const int 	Mode 	= 0; 	//0=Fill, 1=Outline, 2=Outline Scaled"

static const float Margin 	= 0.95;	//


static const float SQRT_2 = 1.4142135623730951;

float circleDist(fixed2 p, float radius)
{
	return length(p) - radius;
}

float boxDist(fixed2 p, fixed2 size, float radius)
{
	size -= fixed2(radius,radius);
	fixed2 d = abs(p) - size;
  	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0)) - radius;
}

float innerBorderMask(float dist, float width)
{
    //dist += 1.0;
    float alpha1 = clamp(dist + width, 0.0, 1.0);
    float alpha2 = clamp(dist, 0.0, 1.0);
    return alpha1 - alpha2;
}

float sdHexPrism( fixed3 p, fixed2 h )
{
    fixed3 q = abs(p);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

float crossDist(fixed2 p, float size)
{
    float x = SQRT_2/2.0 * (p.x - p.y);
    float y = SQRT_2/2.0 * (p.x + p.y);
    float r1 = max(abs(x - size/3.0), abs(x + size/3.0));
    float r2 = max(abs(y - size/3.0), abs(y + size/3.0));
    float r3 = max(abs(x), abs(y));
    float r = max(min(r1,r2),r3);
    r -= size/2.0;
    return r;
}

float fillMask(float dist)
{
	return clamp(-dist, 0.0, 1.0);
}

fixed2 translate(fixed2 p, fixed2 t)
{
	return p - t;
}

float shapeIt(fixed2 pos, fixed2 center, float size,  int shape)
{
    float result = 1.0;
    
    if (shape == 0)
        result = circleDist(translate(pos, center), size);
    if (shape == 1)
        result = boxDist(translate(pos, center), fixed2(size,size), size/20.0);
    if (shape == 2)
        result = sdHexPrism(fixed3(translate(pos, center), 0.0), fixed2(size,size));
    if (shape == 3)
        result = crossDist(translate(pos, center), size*2.0);
    
    return result;
    
}
float fillIt(float dist, float size, float luminance)
{
    if (Mode == 0) //Fill
        return fillMask(dist);
    else if (Mode == 1) //Outline
        return innerBorderMask(dist, size / 8.0 );
    else if (Mode == 2) //OutLine Scaled, Scale based on Luminance
        return innerBorderMask(dist, size / max(2.0, (1.0-luminance)*12.0) );
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
	float Aspect = 1 / 1;    
    fixed2 uv = (i.projPos.xy / i.projPos.w);
    
	//create Tiled position
    fixed2 tiled = uv;
    
	fixed2 subDivisions = fixed2(ceil(Subd*Aspect), Subd);
	tiled *= subDivisions;
    tiled = floor( tiled );
    tiled /= subDivisions;

    //sample color of Tile
    fixed4 color = tex2D( iChannel0, tiled);
        
    float luminance = color.r*0.30+color.g*0.59+color.b*0.11;
    if (Invert == 1)
        luminance = 1.0-luminance;
    
    //current position
    fixed2 pos = i.projPos.xy + fixed2(0.5,0.5);
    
    //calculate size of cell
    fixed2 cellSize = (fixed2(1.0,1.0) / subDivisions) * 1;
    
    float minSize = min(cellSize.x, cellSize.y);
    
    //determine size of Shape
    float shapeSize = Scale == 1 ? minSize*Margin*luminance : minSize*Margin;
	shapeSize *= 0.5;
    
    //find center of this Tile
	fixed2 center = 1 * tiled + (cellSize*0.5);

    //calculate Interpolated Shape (Shape1 morphs to Shape2, luminance determines phase)
    float dst = lerp(shapeIt(pos, center, shapeSize, Shape1),
                    shapeIt(pos, center, shapeSize, Shape2),
                    luminance);
    
    //Determine color of Shape
    fixed4 multiply = fixed4(0.0,0,0,0);
    if (Fill == 0) //White
        multiply = fixed4(fixed3(1.0,1,1), color.a);
    if (Fill == 1) //Greyscale
        multiply = fixed4(fixed3(luminance,luminance,luminance), color.a);
    if (Fill == 2) //Sampled
        multiply = color;
    if (Fill == 3) //Original
        multiply = tex2D( iChannel0, uv);
    
    //fill the Shape
    return fillIt(dst, shapeSize, luminance) , multiply;
}
	ENDCG
	}
  }
}

