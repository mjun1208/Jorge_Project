// Shader created with Shader Forge v1.38 
// Shader Forge (c) Neat Corporation / Joachim Holmer - http://www.acegikmo.com/shaderforge/
// Note: Manually altering this data may prevent you from opening it in Shader Forge
/*SF_DATA;ver:1.38;sub:START;pass:START;ps:flbk:,iptp:0,cusa:False,bamd:0,cgin:,lico:0,lgpr:1,limd:0,spmd:1,trmd:0,grmd:0,uamb:True,mssp:True,bkdf:False,hqlp:False,rprd:False,enco:False,rmgx:True,imps:True,rpth:0,vtps:0,hqsc:True,nrmq:1,nrsp:0,vomd:0,spxs:False,tesm:0,olmd:1,culm:2,bsrc:0,bdst:1,dpts:2,wrdp:False,dith:0,atcv:False,rfrpo:True,rfrpn:Refraction,coma:15,ufog:False,aust:True,igpj:True,qofs:0,qpre:3,rntp:2,fgom:False,fgoc:False,fgod:False,fgor:False,fgmd:0,fgcr:0.5,fgcg:0.5,fgcb:0.5,fgca:1,fgde:0.01,fgrn:0,fgrf:300,stcl:True,atwp:False,stva:128,stmr:255,stmw:255,stcp:6,stps:0,stfa:0,stfz:0,ofsf:0,ofsu:0,f2p0:False,fnsp:False,fnfb:False,fsmp:False;n:type:ShaderForge.SFN_Final,id:3138,x:32719,y:32712,varname:node_3138,prsc:2|emission-8807-OUT;n:type:ShaderForge.SFN_Multiply,id:7860,x:31819,y:32393,varname:node_7860,prsc:2|A-6391-OUT,B-5262-OUT;n:type:ShaderForge.SFN_Add,id:6064,x:31498,y:32837,varname:node_6064,prsc:2|A-5524-OUT,B-1967-OUT,C-9724-OUT;n:type:ShaderForge.SFN_Add,id:6391,x:31609,y:32466,varname:node_6391,prsc:2|A-7557-OUT,B-486-OUT;n:type:ShaderForge.SFN_Vector1,id:5262,x:31733,y:32589,varname:node_5262,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Min,id:486,x:31385,y:32532,varname:node_486,prsc:2|A-1084-RGB,B-2677-RGB;n:type:ShaderForge.SFN_Max,id:7557,x:31385,y:32400,varname:node_7557,prsc:2|A-1084-RGB,B-2677-RGB;n:type:ShaderForge.SFN_Lerp,id:9550,x:30929,y:32492,varname:node_9550,prsc:2|A-2101-OUT,B-8020-OUT,T-1197-OUT;n:type:ShaderForge.SFN_Lerp,id:8546,x:30908,y:32733,varname:node_8546,prsc:2|A-2101-OUT,B-8585-OUT,T-1197-OUT;n:type:ShaderForge.SFN_Append,id:8423,x:30557,y:32323,varname:node_8423,prsc:2|A-6549-OUT,B-1301-OUT;n:type:ShaderForge.SFN_Append,id:2101,x:30547,y:32514,varname:node_2101,prsc:2|A-9340-OUT,B-1301-OUT;n:type:ShaderForge.SFN_Append,id:8020,x:30547,y:32693,varname:node_8020,prsc:2|A-1864-OUT,B-3504-OUT;n:type:ShaderForge.SFN_Append,id:8585,x:30547,y:32862,varname:node_8585,prsc:2|A-1864-OUT,B-2246-OUT;n:type:ShaderForge.SFN_Round,id:1197,x:30571,y:32154,varname:node_1197,prsc:2|IN-6705-OUT;n:type:ShaderForge.SFN_Frac,id:6705,x:30341,y:32154,varname:node_6705,prsc:2|IN-6171-OUT;n:type:ShaderForge.SFN_Time,id:2835,x:29989,y:32135,varname:node_2835,prsc:2;n:type:ShaderForge.SFN_Vector1,id:7254,x:30021,y:32275,varname:node_7254,prsc:2,v1:0.5;n:type:ShaderForge.SFN_Multiply,id:6171,x:30182,y:32154,varname:node_6171,prsc:2|A-2835-T,B-7254-OUT;n:type:ShaderForge.SFN_Subtract,id:6549,x:30284,y:32315,varname:node_6549,prsc:2|A-6321-U,B-3978-OUT;n:type:ShaderForge.SFN_Add,id:9340,x:30307,y:32457,varname:node_9340,prsc:2|A-6321-U,B-3978-OUT;n:type:ShaderForge.SFN_Relay,id:1301,x:30337,y:32590,varname:node_1301,prsc:2|IN-6321-V;n:type:ShaderForge.SFN_Relay,id:1864,x:30337,y:32647,varname:node_1864,prsc:2|IN-6321-U;n:type:ShaderForge.SFN_Subtract,id:3504,x:30307,y:32722,varname:node_3504,prsc:2|A-6321-V,B-3978-OUT;n:type:ShaderForge.SFN_Add,id:2246,x:30307,y:32862,varname:node_2246,prsc:2|A-3978-OUT,B-6321-V;n:type:ShaderForge.SFN_Multiply,id:3978,x:30052,y:32834,varname:node_3978,prsc:2|A-127-OUT,B-1399-OUT;n:type:ShaderForge.SFN_RemapRangeAdvanced,id:1399,x:29590,y:32369,varname:node_1399,prsc:2|IN-4740-OUT,IMIN-445-OUT,IMAX-6061-OUT,OMIN-7901-OUT,OMAX-1853-OUT;n:type:ShaderForge.SFN_Vector1,id:445,x:29393,y:32343,varname:node_445,prsc:2,v1:0;n:type:ShaderForge.SFN_Vector1,id:6061,x:29393,y:32392,varname:node_6061,prsc:2,v1:1;n:type:ShaderForge.SFN_Multiply,id:4740,x:29144,y:32645,varname:node_4740,prsc:2|A-8495-OUT,B-2313-OUT;n:type:ShaderForge.SFN_Negate,id:7901,x:29560,y:32560,varname:node_7901,prsc:2|IN-1853-OUT;n:type:ShaderForge.SFN_Slider,id:1853,x:29200,y:32537,ptovrint:False,ptlb:GlitchDistr,ptin:_GlitchDistr,varname:node_1853,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.2701014,max:1;n:type:ShaderForge.SFN_Noise,id:8495,x:28844,y:32594,varname:node_8495,prsc:2|XY-8671-OUT;n:type:ShaderForge.SFN_Multiply,id:2313,x:29083,y:32848,varname:node_2313,prsc:2|A-9502-OUT,B-9502-OUT,C-9502-OUT,D-9502-OUT;n:type:ShaderForge.SFN_Max,id:9502,x:28860,y:32933,varname:node_9502,prsc:2|A-1369-OUT,B-9464-OUT;n:type:ShaderForge.SFN_OneMinus,id:1417,x:29273,y:32944,varname:node_1417,prsc:2|IN-2313-OUT;n:type:ShaderForge.SFN_Relay,id:2667,x:29388,y:32865,varname:node_2667,prsc:2|IN-2313-OUT;n:type:ShaderForge.SFN_Noise,id:1369,x:28657,y:32864,varname:node_1369,prsc:2|XY-8035-OUT;n:type:ShaderForge.SFN_Noise,id:9464,x:28629,y:32997,varname:node_9464,prsc:2|XY-447-OUT;n:type:ShaderForge.SFN_Append,id:8671,x:28607,y:32594,varname:node_8671,prsc:2|A-4720-OUT,B-4720-OUT;n:type:ShaderForge.SFN_Round,id:4720,x:28071,y:32582,varname:node_4720,prsc:2|IN-5292-OUT;n:type:ShaderForge.SFN_Round,id:469,x:28028,y:32716,varname:node_469,prsc:2|IN-725-OUT;n:type:ShaderForge.SFN_Multiply,id:5292,x:27880,y:32582,varname:node_5292,prsc:2|A-1596-OUT,B-3818-OUT,C-3818-OUT,D-3818-OUT;n:type:ShaderForge.SFN_Multiply,id:725,x:27828,y:32754,varname:node_725,prsc:2|A-3818-OUT,B-230-OUT;n:type:ShaderForge.SFN_Vector1,id:1596,x:27750,y:32497,varname:node_1596,prsc:2,v1:80;n:type:ShaderForge.SFN_Frac,id:3818,x:27646,y:32609,varname:node_3818,prsc:2|IN-70-T;n:type:ShaderForge.SFN_Slider,id:230,x:27357,y:32824,ptovrint:False,ptlb:Swgments,ptin:_Swgments,varname:node_230,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:16.83625,max:32;n:type:ShaderForge.SFN_Time,id:70,x:27277,y:32597,varname:node_70,prsc:2;n:type:ShaderForge.SFN_Multiply,id:5524,x:30548,y:33356,varname:node_5524,prsc:2|A-151-OUT,B-2341-OUT,C-5540-OUT,D-9742-OUT;n:type:ShaderForge.SFN_Vector3,id:9742,x:30548,y:33483,varname:node_9742,prsc:2,v1:0,v2:0.4264706,v3:0;n:type:ShaderForge.SFN_Multiply,id:1967,x:30568,y:33648,varname:node_1967,prsc:2|A-1417-OUT,B-6518-OUT,C-5540-OUT,D-4537-OUT;n:type:ShaderForge.SFN_Vector3,id:4537,x:30568,y:33777,varname:node_4537,prsc:2,v1:0.1911765,v2:0.1226166,v3:0;n:type:ShaderForge.SFN_Multiply,id:9724,x:30568,y:33863,varname:node_9724,prsc:2|A-1417-OUT,B-151-OUT,C-2458-OUT,D-5540-OUT,E-3273-OUT;n:type:ShaderForge.SFN_Vector3,id:3273,x:30588,y:34007,varname:node_3273,prsc:2,v1:1,v2:0,v3:0;n:type:ShaderForge.SFN_Max,id:2458,x:29924,y:34000,varname:node_2458,prsc:2|A-2341-OUT,B-6518-OUT;n:type:ShaderForge.SFN_Relay,id:151,x:29465,y:33629,varname:node_151,prsc:2|IN-2667-OUT;n:type:ShaderForge.SFN_Power,id:2341,x:28999,y:33560,varname:node_2341,prsc:2|VAL-3297-OUT,EXP-6562-OUT;n:type:ShaderForge.SFN_Power,id:6518,x:29009,y:33702,varname:node_6518,prsc:2|VAL-2250-OUT,EXP-6562-OUT;n:type:ShaderForge.SFN_Frac,id:3297,x:28458,y:33251,varname:node_3297,prsc:2|IN-2215-OUT;n:type:ShaderForge.SFN_Frac,id:2250,x:28598,y:33702,varname:node_2250,prsc:2|IN-5265-OUT;n:type:ShaderForge.SFN_Vector1,id:6562,x:28729,y:33665,varname:node_6562,prsc:2,v1:8;n:type:ShaderForge.SFN_Multiply,id:2215,x:28148,y:33202,varname:node_2215,prsc:2|A-230-OUT,B-230-OUT,C-1770-V;n:type:ShaderForge.SFN_Multiply,id:5265,x:28123,y:33400,varname:node_5265,prsc:2|A-1770-U,B-8593-OUT,C-8593-OUT;n:type:ShaderForge.SFN_Slider,id:8593,x:27751,y:33816,ptovrint:False,ptlb:Sub_segments,ptin:_Sub_segments,varname:node_8593,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:10,max:16;n:type:ShaderForge.SFN_Posterize,id:8035,x:28408,y:32691,varname:node_8035,prsc:2|IN-1324-OUT,STPS-8266-OUT;n:type:ShaderForge.SFN_Posterize,id:447,x:28407,y:33022,varname:node_447,prsc:2|IN-1324-OUT,STPS-6454-OUT;n:type:ShaderForge.SFN_Add,id:1324,x:28218,y:32915,varname:node_1324,prsc:2|A-469-OUT,B-1770-UVOUT;n:type:ShaderForge.SFN_Relay,id:8266,x:27929,y:32884,varname:node_8266,prsc:2|IN-230-OUT;n:type:ShaderForge.SFN_Slider,id:6454,x:27955,y:33071,ptovrint:False,ptlb:SegmentsLarge,ptin:_SegmentsLarge,varname:node_6454,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:2.260742,max:4;n:type:ShaderForge.SFN_Multiply,id:127,x:29369,y:32131,varname:node_127,prsc:2|A-4490-OUT,B-4971-OUT,C-8913-OUT;n:type:ShaderForge.SFN_Vector1,id:4490,x:29333,y:32009,varname:node_4490,prsc:2,v1:0.25;n:type:ShaderForge.SFN_If,id:8913,x:29152,y:32175,varname:node_8913,prsc:2|A-2129-OUT,B-5759-OUT,GT-8368-OUT,EQ-8368-OUT,LT-3562-OUT;n:type:ShaderForge.SFN_Vector1,id:8368,x:28907,y:32175,varname:node_8368,prsc:2,v1:1;n:type:ShaderForge.SFN_Vector1,id:3562,x:28907,y:32226,varname:node_3562,prsc:2,v1:0;n:type:ShaderForge.SFN_Slider,id:5759,x:28724,y:32100,ptovrint:False,ptlb:CicleNormal,ptin:_CicleNormal,varname:node_5759,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:0.4351348,max:1;n:type:ShaderForge.SFN_Frac,id:2129,x:28963,y:31917,varname:node_2129,prsc:2|IN-4631-OUT;n:type:ShaderForge.SFN_Divide,id:4631,x:28773,y:31899,varname:node_4631,prsc:2|A-1719-OUT,B-8878-OUT;n:type:ShaderForge.SFN_Round,id:4971,x:28963,y:31762,varname:node_4971,prsc:2|IN-5499-OUT;n:type:ShaderForge.SFN_Slider,id:5499,x:28566,y:31761,ptovrint:False,ptlb:FadeIn,ptin:_FadeIn,varname:node_5499,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:4,max:4;n:type:ShaderForge.SFN_Add,id:1719,x:28616,y:31870,varname:node_1719,prsc:2|A-1665-OUT,B-1785-T;n:type:ShaderForge.SFN_Frac,id:1665,x:28411,y:31870,varname:node_1665,prsc:2|IN-1785-T;n:type:ShaderForge.SFN_Slider,id:8878,x:28365,y:32060,ptovrint:False,ptlb:Average,ptin:_Average,varname:node_8878,prsc:2,glob:False,taghide:False,taghdr:False,tagprd:False,tagnsco:False,tagnrm:False,min:0,cur:6.079581,max:10;n:type:ShaderForge.SFN_Time,id:1785,x:28172,y:31761,varname:node_1785,prsc:2;n:type:ShaderForge.SFN_Relay,id:1034,x:29614,y:32009,varname:node_1034,prsc:2|IN-127-OUT;n:type:ShaderForge.SFN_Relay,id:5540,x:29990,y:33748,varname:node_5540,prsc:2|IN-1034-OUT;n:type:ShaderForge.SFN_SceneColor,id:1084,x:31113,y:32215,varname:node_1084,prsc:2|UVIN-9550-OUT;n:type:ShaderForge.SFN_SceneColor,id:2677,x:31102,y:32627,varname:node_2677,prsc:2|UVIN-8546-OUT;n:type:ShaderForge.SFN_Blend,id:8807,x:31845,y:32769,varname:node_8807,prsc:2,blmd:17,clmp:True|SRC-7860-OUT,DST-6064-OUT;n:type:ShaderForge.SFN_ScreenPos,id:6321,x:30021,y:32387,varname:node_6321,prsc:2,sctp:2;n:type:ShaderForge.SFN_ScreenPos,id:1770,x:27614,y:32952,varname:node_1770,prsc:2,sctp:2;proporder:230-8593-6454-5759-5499-8878-1853;pass:END;sub:END;*/

Shader "Autist/GlitchScreen_v1" {
    Properties {
        _Swgments ("Swgments", Range(0, 32)) = 16.83625
        _Sub_segments ("Sub_segments", Range(0, 16)) = 10
        _SegmentsLarge ("SegmentsLarge", Range(0, 4)) = 2.260742
        _CicleNormal ("CicleNormal", Range(0, 1)) = 0.4351348
        _FadeIn ("FadeIn", Range(0, 4)) = 4
        _Average ("Average", Range(0, 10)) = 6.079581
        _GlitchDistr ("GlitchDistr", Range(0, 1)) = 0.2701014
    }
    SubShader {
        Tags {
            "IgnoreProjector"="True"
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        GrabPass{ "_GrabGlitchTexture" }
        Pass {
            Name "FORWARD"
            Tags {
                "LightMode"="ForwardBase"
            }
            Cull Off
            ZWrite Off
            Ztest Always
            Stencil {
                Ref 128
            }
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_FORWARDBASE
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            uniform sampler2D _GrabGlitchTexture;
            uniform float _GlitchDistr;
            uniform float _Swgments;
            uniform float _Sub_segments;
            uniform float _SegmentsLarge;
            uniform float _CicleNormal;
            uniform float _FadeIn;
            uniform float _Average;

            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                float4 pos : SV_POSITION;
                float4 projPos : TEXCOORD0;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                o.projPos = ComputeScreenPos (o.pos);
                COMPUTE_EYEDEPTH(o.projPos.z);
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 0 ? 1 : 0 );
                float faceSign = ( facing >= 0 ? 1 : -1 );
                float2 sceneUVs = (i.projPos.xy / i.projPos.w);
                float4 sceneColor = tex2D(_GrabGlitchTexture, sceneUVs);
////// Lighting:
////// Emissive:
                float4 node_1785 = _Time.w;
                float node_8913_if_leA = step(frac(((frac(node_1785.g)+node_1785.g)/_Average)),_CicleNormal);
                float node_8913_if_leB = step(_CicleNormal,frac(((frac(node_1785.g)+node_1785.g)/_Average)));
                float node_8368 = 1.0;
                float node_127 = (0.25*round(_FadeIn)*lerp((node_8913_if_leA*0.0)+(node_8913_if_leB*node_8368),node_8368,node_8913_if_leA*node_8913_if_leB));
                float4 node_70 = _Time.w;
                float node_3818 = frac(node_70.g);
                float node_4720 = round((80.0*node_3818*node_3818*node_3818));
                float2 node_8671 = float2(node_4720,node_4720);
                float2 node_8495_skew = node_8671 + 0.2127+node_8671.x*0.3713*node_8671.y;
                float2 node_8495_rnd = 4.789*sin(489.123*(node_8495_skew));
                float node_8495 = frac(node_8495_rnd.x*node_8495_rnd.y*(1+node_8495_skew.x));
                float2 node_1324 = (round((node_3818*_Swgments))+sceneUVs.rg);
                float node_8266 = _Swgments;
                float2 node_8035 = floor(node_1324 * node_8266) / (node_8266 - 1);
                float2 node_1369_skew = node_8035 + 0.2127+node_8035.x*0.3713*node_8035.y;
                float2 node_1369_rnd = 4.789*sin(489.123*(node_1369_skew));
                float node_1369 = frac(node_1369_rnd.x*node_1369_rnd.y*(1+node_1369_skew.x));
                float2 node_447 = floor(node_1324 * _SegmentsLarge) / (_SegmentsLarge - 1);
                float2 node_9464_skew = node_447 + 0.2127+node_447.x*0.3713*node_447.y;
                float2 node_9464_rnd = 4.789*sin(489.123*(node_9464_skew));
                float node_9464 = frac(node_9464_rnd.x*node_9464_rnd.y*(1+node_9464_skew.x));
                float node_9502 = max(node_1369,node_9464);
                float node_2313 = (node_9502*node_9502*node_9502*node_9502);
                float node_445 = 0.0;
                float node_7901 = (-0*_GlitchDistr);
                float node_3978 = (node_127*(node_7901 + ( ((node_8495*node_2313) - node_445) * (_GlitchDistr - node_7901) ) / (1.0 - node_445)));
                float node_1301 = sceneUVs.g;
                float2 node_2101 = float2((sceneUVs.r+node_3978),node_1301);
                float node_1864 = sceneUVs.r;
                float4 node_2835 = _Time.w;
                float node_1197 = round(frac((node_2835.g*0.0)));
                float4 node_1084 = tex2D( _GrabGlitchTexture, lerp(node_2101,float2(node_1864,(sceneUVs.g-node_3978)),node_1197));
                float4 node_2677 = tex2D( _GrabGlitchTexture, lerp(node_2101,float2(node_1864,(node_3978+sceneUVs.g)),node_1197));
                float node_151 = node_2313;
                float node_6562 = 8.0;
                float node_2341 = pow(frac((_Swgments*_Swgments*sceneUVs.g)),node_6562);
                float node_5540 = node_127;
                float node_1417 = (1.0 - node_2313);
                float node_6518 = pow(frac((sceneUVs.r*_Sub_segments*_Sub_segments)),node_6562);
                float3 emissive = saturate(abs(((max(node_1084.rgb,node_2677.rgb)+min(node_1084.rgb,node_2677.rgb))*.5)-((node_151*node_2341*node_5540*float3(0,0.4264706,0))+(node_1417*node_6518*node_5540*float3(0.1911765,0.1226166,0))+(node_1417*node_151*max(node_2341,node_6518)*node_5540*float3(1,0,0)))));
                float3 finalColor = emissive;
                return fixed4(finalColor,1);
            }
            ENDCG
        }
        Pass {
            Name "ShadowCaster"
            Tags {
                "LightMode"="ShadowCaster"
            }
            Offset 1, 1
            Cull Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #define UNITY_PASS_SHADOWCASTER
            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #pragma fragmentoption ARB_precision_hint_fastest
            #pragma multi_compile_shadowcaster
            #pragma only_renderers d3d9 d3d11 glcore gles 
            #pragma target 3.0
            struct VertexInput {
                float4 vertex : POSITION;
            };
            struct VertexOutput {
                V2F_SHADOW_CASTER;
            };
            VertexOutput vert (VertexInput v) {
                VertexOutput o = (VertexOutput)0;
                o.pos = UnityObjectToClipPos( v.vertex );
                TRANSFER_SHADOW_CASTER(o)
                return o;
            }
            float4 frag(VertexOutput i, float facing : VFACE) : COLOR {
                float isFrontFace = ( facing >= 1 ? 1 : 1 );
                float faceSign = ( facing >= 1 ? 1 : -1 );
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG
        }
    }
    FallBack "Diffuse"
    CustomEditor "ShaderForgeMaterialInspector"
}
