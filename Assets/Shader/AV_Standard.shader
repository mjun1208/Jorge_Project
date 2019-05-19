// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Custom/AV Standard"
{
	Properties
	{
		_Metallic("Metallic", Range( 0 , 1)) = 0
		_Smoothness("Smoothness", Range( 0 , 1)) = 0.3
		_AlbedoColor("Albedo Color", Color) = (1,0,0,0)
		[NoScaleOffset]_Albedo("Albedo", 2D) = "white" {}
		_FresnelColor("Fresnel Color", Color) = (1,0,0,0)
		[NoScaleOffset]_Normal("Normal", 2D) = "bump" {}
		_NormalIntensity("Normal Intensity", Range( 0 , 2)) = 1
		_PannerXYAlbedoZNormalW("Panner XY, Albedo Z, Normal W", Vector) = (1,1,1,1)
		[NoScaleOffset]_Emission("Emission", 2D) = "black" {}
		_EmissionIntensity("Emission Intensity", Range( 0 , 1)) = 0
		[NoScaleOffset]_TextureSample0("Texture Sample 0", 2D) = "bump" {}
		_Vector0("Vector 0", Vector) = (-0.5,0.5,4,2)
		_FresnelBias("Fresnel Bias", Range( -1 , 0)) = -0.07563148
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Back
		CGINCLUDE
		#include "UnityStandardUtils.cginc"
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#ifdef UNITY_PASS_SHADOWCASTER
			#undef INTERNAL_DATA
			#undef WorldReflectionVector
			#undef WorldNormalVector
			#define INTERNAL_DATA half3 internalSurfaceTtoW0; half3 internalSurfaceTtoW1; half3 internalSurfaceTtoW2;
			#define WorldReflectionVector(data,normal) reflect (data.worldRefl, half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal)))
			#define WorldNormalVector(data,normal) half3(dot(data.internalSurfaceTtoW0,normal), dot(data.internalSurfaceTtoW1,normal), dot(data.internalSurfaceTtoW2,normal))
		#endif
		struct Input
		{
			float2 uv_texcoord;
			float3 worldPos;
			INTERNAL_DATA
			float3 worldNormal;
		};

		uniform float _NormalIntensity;
		uniform sampler2D _Normal;
		uniform float4 _PannerXYAlbedoZNormalW;
		uniform float4 _Vector0;
		uniform sampler2D _TextureSample0;
		uniform float _FresnelBias;
		uniform float4 _AlbedoColor;
		uniform sampler2D _Albedo;
		uniform float4 _FresnelColor;
		uniform sampler2D _Emission;
		uniform float _EmissionIntensity;
		uniform float _Metallic;
		uniform float _Smoothness;

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float2 temp_cast_1 = (_PannerXYAlbedoZNormalW.w).xx;
			float2 uv_TexCoord147 = i.uv_texcoord * temp_cast_1;
			float2 panner144 = ( ( _PannerXYAlbedoZNormalW.w * _Time.x ) * _PannerXYAlbedoZNormalW.xy + uv_TexCoord147);
			float3 ase_worldPos = i.worldPos;
			float3 ase_worldViewDir = normalize( UnityWorldSpaceViewDir( ase_worldPos ) );
			float2 temp_cast_3 = (_Vector0.z).xx;
			float2 uv_TexCoord169 = i.uv_texcoord * temp_cast_3;
			float2 panner170 = ( 1.0 * _Time.y * _Vector0.xy + uv_TexCoord169);
			float3 ase_worldNormal = WorldNormalVector( i, float3( 0, 0, 1 ) );
			float fresnelNdotV138 = dot( ase_worldNormal, ase_worldViewDir );
			float fresnelNode138 = ( _FresnelBias + 2.0 * pow( 1.0 - fresnelNdotV138, 1.5 ) );
			o.Normal = ( UnpackScaleNormal( tex2D( _Normal, panner144 ) ,_NormalIntensity ) + fresnelNode138 );
			float2 temp_cast_5 = (_PannerXYAlbedoZNormalW.z).xx;
			float2 uv_TexCoord7 = i.uv_texcoord * temp_cast_5;
			float2 panner8 = ( ( _PannerXYAlbedoZNormalW.z * _Time.x ) * _PannerXYAlbedoZNormalW.xy + uv_TexCoord7);
			o.Albedo = ( _AlbedoColor * tex2D( _Albedo, panner8 ) ).rgb;
			float2 panner154 = ( _Time.x * _PannerXYAlbedoZNormalW.xy + i.uv_texcoord);
			o.Emission = ( ( fresnelNode138 * _FresnelColor ) + ( tex2D( _Emission, panner154 ) * _EmissionIntensity ) ).rgb;
			o.Metallic = _Metallic;
			o.Smoothness = _Smoothness;
			o.Alpha = 1;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Standard alpha:fade keepalpha fullforwardshadows exclude_path:deferred 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float4 tSpace0 : TEXCOORD2;
				float4 tSpace1 : TEXCOORD3;
				float4 tSpace2 : TEXCOORD4;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				half3 worldTangent = UnityObjectToWorldDir( v.tangent.xyz );
				half tangentSign = v.tangent.w * unity_WorldTransformParams.w;
				half3 worldBinormal = cross( worldNormal, worldTangent ) * tangentSign;
				o.tSpace0 = float4( worldTangent.x, worldBinormal.x, worldNormal.x, worldPos.x );
				o.tSpace1 = float4( worldTangent.y, worldBinormal.y, worldNormal.y, worldPos.y );
				o.tSpace2 = float4( worldTangent.z, worldBinormal.z, worldNormal.z, worldPos.z );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = float3( IN.tSpace0.w, IN.tSpace1.w, IN.tSpace2.w );
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				surfIN.worldPos = worldPos;
				surfIN.worldNormal = float3( IN.tSpace0.z, IN.tSpace1.z, IN.tSpace2.z );
				surfIN.internalSurfaceTtoW0 = IN.tSpace0.xyz;
				surfIN.internalSurfaceTtoW1 = IN.tSpace1.xyz;
				surfIN.internalSurfaceTtoW2 = IN.tSpace2.xyz;
				SurfaceOutputStandard o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutputStandard, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=15401
265;516;1351;850;1553.276;34.0131;1.589203;True;True
Node;AmplifyShaderEditor.Vector4Node;171;-1821.978,310.4651;Float;False;Property;_Vector0;Vector 0;11;0;Create;True;0;0;False;0;-0.5,0.5,4,2;-0.5,0.5,4,2;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;169;-1591.911,235.2379;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TimeNode;10;-1655.12,-289.0259;Float;False;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector4Node;146;-1993.432,-271.9478;Float;False;Property;_PannerXYAlbedoZNormalW;Panner XY, Albedo Z, Normal W;7;0;Create;True;0;0;False;0;1,1,1,1;1,1,1,1;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.TextureCoordinatesNode;153;-1592.964,487.4852;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;170;-1284.896,247.3249;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;157;-1429.509,-49.49205;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;147;-1667.759,-124.7662;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;175;-1055.123,807.8304;Float;False;Property;_FresnelBias;Fresnel Bias;12;0;Create;True;0;0;False;0;-0.07563148;-0.434;-1;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;158;-1427.205,-337.2076;Float;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;154;-1288.292,487.856;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;7;-1663.73,-411.0302;Float;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode;168;-1077.902,238.6772;Float;True;Property;_TextureSample0;Texture Sample 0;10;1;[NoScaleOffset];Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;145;-1373.369,68.02209;Float;False;Property;_NormalIntensity;Normal Intensity;6;0;Create;True;0;0;False;0;1;2;0;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode;144;-1274.641,-96.58608;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.FresnelNode;138;-723.0448,163.4141;Float;True;Standard;TangentNormal;ViewDir;False;5;0;FLOAT3;0,0,1;False;4;FLOAT3;0,0,0;False;1;FLOAT;-0.8;False;2;FLOAT;2;False;3;FLOAT;1.5;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-1056.414,676.9653;Float;False;Property;_EmissionIntensity;Emission Intensity;9;0;Create;True;0;0;False;0;0;0.111706;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;89;-1075.063,476.9879;Float;True;Property;_Emission;Emission;8;1;[NoScaleOffset];Create;True;0;0;False;0;None;c68296334e691ed45b62266cbc716628;True;0;False;black;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.ColorNode;140;-678.6979,391.315;Float;False;Property;_FresnelColor;Fresnel Color;4;0;Create;True;0;0;False;0;1,0,0,0;1,1,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;8;-1283.297,-411.6499;Float;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;49;-1079.404,18.17333;Float;True;Property;_Normal;Normal;5;1;[NoScaleOffset];Create;True;0;0;False;0;None;dd2fd2df93418444c8e280f1d34deeb5;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;96;-679.3362,590.8669;Float;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.ColorNode;2;-992.8099,-365.7351;Float;False;Property;_AlbedoColor;Albedo Color;2;0;Create;True;0;0;False;0;1,0,0,0;1,0,0,0;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;139;-452.984,268.514;Float;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SamplerNode;4;-1078.645,-193.4564;Float;True;Property;_Albedo;Albedo;3;1;[NoScaleOffset];Create;True;0;0;False;0;None;84508b93f15f2b64386ec07486afc7a3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;6;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;100;-433.0363,30.55696;Float;False;Property;_Smoothness;Smoothness;1;0;Create;True;0;0;False;0;0.3;0.5;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;3;-763.6763,-214.5295;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;142;-353.4833,512.0181;Float;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-433.0363,-44.15702;Float;False;Property;_Metallic;Metallic;0;0;Create;True;0;0;False;0;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;174;-408.8311,135.3775;Float;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;-117.6505,101.0768;Float;False;True;2;Float;ASEMaterialInspector;0;0;Standard;Custom/AV Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;Back;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;ForwardOnly;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;1;False;-1;10;False;-1;-1;False;-1;-1;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;1;-1;0;0;0;False;0;0;False;-1;-1;0;False;-1;0;0;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;169;0;171;3
WireConnection;170;0;169;0
WireConnection;170;2;171;0
WireConnection;157;0;146;4
WireConnection;157;1;10;1
WireConnection;147;0;146;4
WireConnection;158;0;146;3
WireConnection;158;1;10;1
WireConnection;154;0;153;0
WireConnection;154;2;146;0
WireConnection;154;1;10;1
WireConnection;7;0;146;3
WireConnection;168;1;170;0
WireConnection;168;5;171;4
WireConnection;144;0;147;0
WireConnection;144;2;146;0
WireConnection;144;1;157;0
WireConnection;138;0;168;0
WireConnection;138;1;175;0
WireConnection;89;1;154;0
WireConnection;8;0;7;0
WireConnection;8;2;146;0
WireConnection;8;1;158;0
WireConnection;49;1;144;0
WireConnection;49;5;145;0
WireConnection;96;0;89;0
WireConnection;96;1;97;0
WireConnection;139;0;138;0
WireConnection;139;1;140;0
WireConnection;4;1;8;0
WireConnection;3;0;2;0
WireConnection;3;1;4;0
WireConnection;142;0;139;0
WireConnection;142;1;96;0
WireConnection;174;0;49;0
WireConnection;174;1;138;0
WireConnection;0;0;3;0
WireConnection;0;1;174;0
WireConnection;0;2;142;0
WireConnection;0;3;98;0
WireConnection;0;4;100;0
ASEEND*/
//CHKSM=FCB757A3E9E43232F806D98C3A94686B0F546FB8