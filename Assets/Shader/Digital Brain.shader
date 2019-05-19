
Shader "ShaderMan/Digital Brain"
	{

	Properties{
	iChannel0("iChannel0", 2D) = "" {}  
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
            Blend one One
            Cull off
            ZTest Always
            ZWrite Off
	CGPROGRAM
	#pragma vertex vert
	#pragma fragment frag
	#include "UnityCG.cginc"

	fixed cell_size;
	sampler2D inputImage;
	fixed IMG_THIS_PIXEL;
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

// CALCULATE EDGES OF CURRENT CELL
	//	At 0.0 just do a pass-thru

	else	{
		// Position of current pixel
		fixed2 xy; 
		xy.x = isf_FragNormCoord[0];
		xy.y = isf_FragNormCoord[1];


		// Left and right of tile
		float CellWidth = cell_size;
		float CellHeight = cell_size;
		
		CellHeight = cell_size * RENDERSIZE.x / RENDERSIZE.y;

		float x1 = floor(xy.x / CellWidth)*CellWidth;
		float x2 = clamp((ceil(xy.x / CellWidth)*CellWidth), 0.0, 1.0);
		// Top and bottom of tile
		float y1 = floor(xy.y / CellHeight)*CellHeight;
		float y2 = clamp((ceil(xy.y / CellHeight)*CellHeight), 0.0, 1.0);
		
		//	get the normalized local coords in the cell
		float x = (xy.x-x1) / CellWidth;
		float y = (xy.y-y1) / CellHeight;
		fixed4 avgClr = fixed4(0.0);
		
		//	style 0, two right triangles making a square
		if (style == 0)	{
			//	if above the center line...
			if (x < y)	{
				// Average bottom left, top left, center and top right pixels
				fixed4 avgL = (IMG_NORM_PIXEL(inputImage, fixed2(x1, y1))+(IMG_NORM_PIXEL(inputImage, fixed2(x1, y2)))) / 2.0;
				fixed4 avgR = IMG_NORM_PIXEL(inputImage, fixed2(x2, y2));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;
			}
			else	{
				// Average bottom right, bottom left, center and top right pixels
				fixed4 avgR = (IMG_NORM_PIXEL(inputImage, fixed2(x2, y1))+(IMG_NORM_PIXEL(inputImage, fixed2(x2, y2)))) / 2.0;
				fixed4 avgL = IMG_NORM_PIXEL(inputImage, fixed2(x1, y1));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;
			}
		}
		//	style 1, four triangles making a square
		else {
			//	if above the B2T center line and below the T2B center line...
			if ((x > y)&&(x < 1.0 - y))	{
				// Average bottom left, bottom right, center
				fixed4 avgL = IMG_NORM_PIXEL(inputImage, fixed2(x1, y1));
				fixed4 avgR = IMG_NORM_PIXEL(inputImage, fixed2(x2, y1));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;				
			}
			else if ((x < y)&&(x < 1.0 - y))	{
				// Average bottom left, top left, center
				fixed4 avgL = IMG_NORM_PIXEL(inputImage, fixed2(x1, y1));
				fixed4 avgR = IMG_NORM_PIXEL(inputImage, fixed2(x1, y2));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;
			}
			else if ((x > 1.0 - y)&&(x < y))	{
				// Average top left, top right, center
				fixed4 avgL = IMG_NORM_PIXEL(inputImage, fixed2(x1, y2));
				fixed4 avgR = IMG_NORM_PIXEL(inputImage, fixed2(x2, y2));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;
				//avgClr = fixed4(0.0,1.0,0.0,1.0);
			}
			else	{
				// Average top right, bottom right, center
				fixed4 avgL = IMG_NORM_PIXEL(inputImage, fixed2(x2, y1));
				fixed4 avgR = IMG_NORM_PIXEL(inputImage, fixed2(x2, y2));
				fixed4 avgC = IMG_NORM_PIXEL(inputImage, fixed2(x1+(CellWidth/2.0), y2+(CellHeight/2.0)));	// Average the averages + centre
				avgClr = (avgL+avgR+avgC) / 3.0;
				//avgClr = fixed4(0.0,0.0,1.0,1.0);
			}
		}
		
		return avgClr;
	}
}

	ENDCG
	}
  }
}

