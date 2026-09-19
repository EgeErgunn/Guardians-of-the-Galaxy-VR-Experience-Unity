// Made with Amplify Shader Editor v1.9.9.9
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Vefects/SH_Vefects_BIRP_Free_Blood_01_Lit"
{
	Properties
	{
		_FlatColor( "Flat Color", Range( 0, 1 ) ) = 0
		_Metallic( "Metallic", Float ) = 0
		_Smoothness( "Smoothness", Float ) = 1
		_EmissionMultiply( "Emission Multiply", Float ) = 0
		_OpacityMultiply( "Opacity Multiply", Float ) = 1
		_DepthFade( "Depth Fade", Float ) = 0
		[Space(33)][Header(LUT)][Space(13)] _LUT( "LUT", 2D ) = "white" {}
		_LUTAmplitude( "LUT Amplitude", Float ) = 1
		_LUTOffset( "LUT Offset", Float ) = 0
		_LUTSpeed( "LUT Speed", Float ) = 0
		_LUTHueShift( "LUT Hue Shift", Float ) = 0
		_LUTHueShiftSpeed( "LUT Hue Shift Speed", Float ) = 0
		_LUTDesaturate( "LUT Desaturate", Range( 0, 1 ) ) = 0
		_LUTValueIntensity( "LUT Value Intensity", Float ) = 1
		[Toggle( _LUTERODES_ON )] _LUTErodes( "LUT Erodes", Float ) = 0
		[Toggle( _LUTERODESMASKS_ON )] _LUTErodesMasks( "LUT Erodes Masks", Float ) = 0
		[Toggle( _LUTINVERT_ON )] _LUTInvert( "LUT Invert", Float ) = 0
		[Space(33)][Header(Normal)][Space(13)] _NormalTexture( "Normal Texture", 2D ) = "white" {}
		_NormalIntensity( "Normal Intensity", Float ) = 1
		[Space(33)][Header(Distortion)][Space(13)] _DistortionTexture( "Distortion Texture", 2D ) = "white" {}
		_NoiseDistortionUVS( "Noise Distortion UV S", Vector ) = ( 1, 1, 0, 0 )
		_NoiseDistortionUVPan( "Noise Distortion UV Pan", Vector ) = ( 0, 0, 0, 0 )
		_DistortionIntensity( "Distortion Intensity", Float ) = 0.1
		[Space(33)][Header(Erosion)][Space(13)] _ErosionTexture( "Erosion Texture", 2D ) = "white" {}
		_ErosionUVS( "Erosion UV S", Vector ) = ( 1, 1, 0, 0 )
		_ErosionUVPan( "Erosion UV Pan", Vector ) = ( 0, 0, 0, 0 )
		_ErosionIntensity( "Erosion Intensity", Float ) = 0
		_ErosionSmoothness( "Erosion Smoothness", Float ) = 1
		[Space(33)][Header(Opacity Mask)][Space(13)] _OpacityMask( "Opacity Mask", 2D ) = "white" {}
		_OpacityMaskErosion( "Opacity Mask Erosion", Float ) = 0
		_OpacityMaskErosionSmoothness( "Opacity Mask Erosion Smoothness", Float ) = 1
		[Space(33)][Header(AR)][Space(13)] _Cull( "Cull", Float ) = 2
		_Src( "Src", Float ) = 5
		_Dst( "Dst", Float ) = 10
		_ZWrite( "ZWrite", Float ) = 0
		_ZTest( "ZTest", Float ) = 2


		//_TransmissionShadow( "Transmission Shadow", Range( 0, 1 ) ) = 0.5
		//_TransStrength( "Trans Strength", Range( 0, 50 ) ) = 1
		//_TransNormal( "Trans Normal Distortion", Range( 0, 1 ) ) = 0.5
		//_TransScattering( "Trans Scattering", Range( 1, 50 ) ) = 2
		//_TransDirect( "Trans Direct", Range( 0, 1 ) ) = 0.9
		//_TransAmbient( "Trans Ambient", Range( 0, 1 ) ) = 0.1
		//_TransShadow( "Trans Shadow", Range( 0, 1 ) ) = 0.5

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25

		[ToggleOff] _SpecularHighlights("Specular Highlights", Float) = 1.0
		[ToggleOff] _GlossyReflections("Reflections", Float) = 1.0

		//_InstancedTerrainNormals("Specular Highlights", Float) = 1.0
	}

	SubShader
	{
		

		

		Tags { "RenderType"="Transparent" "Queue"="Transparent" "DisableBatching"="False" }

	LOD 0

		Cull [_Cull]
		AlphaToMask Off
		ZWrite [_ZWrite]
		ZTest [_ZTest]
		ColorMask RGBA

		

		Blend Off
		

		CGINCLUDE
			#pragma target 3.5
			// ensure rendering platforms toggle list is visible

			float4 FixedTess( float tessValue )
			{
				return tessValue;
			}

			float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
			{
				float3 wpos = mul(o2w,vertex).xyz;
				float dist = distance (wpos, cameraPos);
				float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
				return f;
			}

			float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
			{
				float4 tess;
				tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
				tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
				tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
				tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
				return tess;
			}

			float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
			{
				float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
				float len = distance(wpos0, wpos1);
				float f = max(len * scParams.y / (edgeLen * dist), 1.0);
				return f;
			}

			float DistanceFromPlane (float3 pos, float4 plane)
			{
				float d = dot (float4(pos,1.0f), plane);
				return d;
			}

			bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
			{
				float4 planeTest;
				planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
				planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
				planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
				planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
							  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
				return !all (planeTest);
			}

			float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
			{
				float3 f;
				f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
				f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
				f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

				return CalcTriEdgeTessFactors (f);
			}

			float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
			{
				float3 pos0 = mul(o2w,v0).xyz;
				float3 pos1 = mul(o2w,v1).xyz;
				float3 pos2 = mul(o2w,v2).xyz;
				float4 tess;
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
				return tess;
			}

			float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
			{
				float3 pos0 = mul(o2w,v0).xyz;
				float3 pos1 = mul(o2w,v1).xyz;
				float3 pos2 = mul(o2w,v2).xyz;
				float4 tess;

				if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
				{
					tess = 0.0f;
				}
				else
				{
					tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
					tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
					tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
					tess.w = (tess.x + tess.y + tess.z) / 3.0f;
				}
				return tess;
			}

			float4 ComputeClipSpacePosition( float2 screenPosNorm, float deviceDepth )
			{
				float4 positionCS = float4( screenPosNorm * 2.0 - 1.0, deviceDepth, 1.0 );
			#if UNITY_UV_STARTS_AT_TOP
				positionCS.y = -positionCS.y;
			#endif
				return positionCS;
			}
		ENDCG

		
		Pass
		{
			
			Name "ForwardBase"
			Tags { "LightMode"="ForwardBase" }

			Blend [_Src] [_Dst]

			CGPROGRAM
				#define ASE_GEOMETRY
				#define ASE_FRAGMENT_NORMAL 0
				#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
				#pragma shader_feature_local_fragment _GLOSSYREFLECTIONS_OFF
				#pragma multi_compile_instancing
				#pragma multi_compile _ LOD_FADE_CROSSFADE
				#pragma multi_compile_fog
				#define ASE_FOG
				#define _ALPHABLEND_ON 1
				#define UNITY_STANDARD_USE_DITHER_MASK 1
				#define ASE_RECEIVE_SHADOWS
				#define ASE_NO_AMBIENT 1
				#define ASE_VERSION 19909

				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fwdbase
				#ifndef UNITY_PASS_FORWARDBASE
					#define UNITY_PASS_FORWARDBASE
				#endif
				#include "HLSLSupport.cginc"
				#if defined( ASE_GEOMETRY ) || defined( ASE_IMPOSTOR )
					#ifndef UNITY_INSTANCED_LOD_FADE
						#define UNITY_INSTANCED_LOD_FADE
					#endif
					#ifndef UNITY_INSTANCED_SH
						#define UNITY_INSTANCED_SH
					#endif
					#ifndef UNITY_INSTANCED_LIGHTMAPSTS
						#define UNITY_INSTANCED_LIGHTMAPSTS
					#endif
				#endif
				#include "UnityShaderVariables.cginc"
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
					#define ENABLE_TERRAIN_PERPIXEL_NORMAL
				#endif

				#define ASE_NEEDS_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
				#define ASE_NEEDS_FRAG_COLOR
				#pragma shader_feature_local _LUTINVERT_ON
				#pragma shader_feature_local _LUTERODESMASKS_ON
				#pragma shader_feature_local _LUTERODES_ON


				struct appdata
				{
					float4 vertex : POSITION;
					half3 normal : NORMAL;
					half4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0; // xyz = positionWS, w = fogCoord
					half3 normalWS : TEXCOORD1;
					float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					half4 ambientOrLightmapUV : TEXCOORD3;
					UNITY_LIGHTING_COORDS( 4, 5 )
					float4 ase_texcoord6 : TEXCOORD6;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				#ifdef ASE_TRANSMISSION
					float _TransmissionShadow;
				#endif
				#ifdef ASE_TRANSLUCENCY
					float _TransStrength;
					float _TransNormal;
					float _TransScattering;
					float _TransDirect;
					float _TransAmbient;
					float _TransShadow;
				#endif
				#ifdef ASE_TESSELLATION
					float _TessPhongStrength;
					float _TessValue;
					float _TessMin;
					float _TessMax;
					float _TessEdgeLength;
					float _TessMaxDisp;
				#endif

				uniform float _Src;
				uniform float _Dst;
				uniform float _Cull;
				uniform float _ZWrite;
				uniform float _ZTest;
				uniform sampler2D _LUT;
				uniform float _LUTSpeed;
				uniform sampler2D _ErosionTexture;
				uniform float2 _ErosionUVPan;
				uniform float2 _ErosionUVS;
				uniform sampler2D _DistortionTexture;
				uniform float2 _NoiseDistortionUVPan;
				uniform float2 _NoiseDistortionUVS;
				uniform float _DistortionIntensity;
				uniform float _ErosionIntensity;
				uniform float _ErosionSmoothness;
				uniform float _OpacityMaskErosion;
				uniform float _OpacityMaskErosionSmoothness;
				uniform sampler2D _OpacityMask;
				uniform float4 _OpacityMask_ST;
				uniform float _LUTAmplitude;
				uniform float _LUTOffset;
				uniform float _LUTHueShift;
				uniform float _LUTHueShiftSpeed;
				uniform float _LUTValueIntensity;
				uniform float _LUTDesaturate;
				uniform float _FlatColor;
				uniform sampler2D _NormalTexture;
				uniform float _NormalIntensity;
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				uniform float4 _CameraDepthTexture_TexelSize;
				uniform float _DepthFade;
				uniform float _OpacityMultiply;
				uniform float _Metallic;
				uniform float _Smoothness;
				uniform float _EmissionMultiply;


				float3 HSVToRGB( float3 c )
				{
					float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
					float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
					return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
				}
				
				float3 RGBToHSV(float3 c)
				{
					float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
					float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
					float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
					float d = q.x - min( q.w, q.y );
					float e = 1.0e-10;
					return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
				}

				v2f VertexFunction( appdata v  )
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					o.ase_texcoord6 = v.texcoord.xyzw;
					o.ase_color = v.ase_color;

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					float3 positionWS = mul( unity_ObjectToWorld, v.vertex ).xyz;
					half3 normalWS = UnityObjectToWorldNormal( v.normal );
					half3 tangentWS = UnityObjectToWorldDir( v.tangent.xyz );

					o.pos = UnityObjectToClipPos( v.vertex );
					o.worldPos.xyz = positionWS;
					o.normalWS = normalWS;
					o.tangentWS = half4( tangentWS, v.tangent.w );

					o.ambientOrLightmapUV = 0;
					#ifdef LIGHTMAP_ON
						o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#elif UNITY_SHOULD_SAMPLE_SH
						#ifdef VERTEXLIGHT_ON
							o.ambientOrLightmapUV.rgb += Shade4PointLights(
								unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
								unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
								unity_4LightAtten0, positionWS, normalWS );
						#endif
						o.ambientOrLightmapUV.rgb = ShadeSHPerVertex( normalWS, o.ambientOrLightmapUV.rgb );
					#endif
					#ifdef DYNAMICLIGHTMAP_ON
						o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					#endif

					#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
						o.tangentWS.zw = v.texcoord.xy;
						o.tangentWS.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#endif

					UNITY_TRANSFER_LIGHTING(o, v.texcoord1.xy);
					#if defined( ASE_FOG )
						UNITY_TRANSFER_FOG_COMBINED_WITH_WORLD_POS( o, o.pos );
					#endif
					return o;
				}

				#if defined(ASE_TESSELLATION)
				struct VertexControl
				{
					float4 vertex : INTERNALTESSPOS;
					half4 tangent : TANGENT;
					half3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
					float4 ase_color : COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct TessellationFactors
				{
					float edge[3] : SV_TessFactor;
					float inside : SV_InsideTessFactor;
				};

				VertexControl vert ( appdata v )
				{
					VertexControl o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.vertex = v.vertex;
					o.tangent = v.tangent;
					o.normal = v.normal;
					o.texcoord = v.texcoord;
					o.texcoord1 = v.texcoord1;
					o.texcoord2 = v.texcoord2;
					o.ase_color = v.ase_color;
					return o;
				}

				TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
				{
					TessellationFactors o;
					float4 tf = 1;
					float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
					float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
					#if defined(ASE_FIXED_TESSELLATION)
					tf = FixedTess( tessValue );
					#elif defined(ASE_DISTANCE_TESSELLATION)
					tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
					#elif defined(ASE_LENGTH_TESSELLATION)
					tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
					#elif defined(ASE_LENGTH_CULL_TESSELLATION)
					tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
					#endif
					o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
					return o;
				}

				[domain("tri")]
				[partitioning("fractional_odd")]
				[outputtopology("triangle_cw")]
				[patchconstantfunc("TessellationFunction")]
				[outputcontrolpoints(3)]
				VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
				{
				   return patch[id];
				}

				[domain("tri")]
				v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
				{
					appdata o = (appdata) 0;
					o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
					o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
					o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
					o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
					o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
					o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
					o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
					#if defined(ASE_PHONG_TESSELLATION)
					float3 pp[3];
					for (int i = 0; i < 3; ++i)
						pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
					float phongStrength = _TessPhongStrength;
					o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
					#endif
					UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
					return VertexFunction(o);
				}
				#else
				v2f vert ( appdata v )
				{
					return VertexFunction( v );
				}
				#endif

				half4 frag( v2f IN 
							#if defined( ASE_DEPTH_WRITE_ON )
								, out float outputDepth : SV_Depth
							#endif
							) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);

					#ifdef LOD_FADE_CROSSFADE
						UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
					#endif

					#if defined(ASE_LIGHTING_SIMPLE)
						SurfaceOutput o = (SurfaceOutput)0;
					#else
						#if defined(_SPECULAR_SETUP)
							SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
						#else
							SurfaceOutputStandard o = (SurfaceOutputStandard)0;
						#endif
					#endif

					half atten;
					{
						#if defined( ASE_RECEIVE_SHADOWS )
							UNITY_LIGHT_ATTENUATION( temp, IN, IN.worldPos.xyz )
							atten = temp;
						#else
							atten = 1;
						#endif
					}

					float3 PositionWS = IN.worldPos.xyz;
					half3 ViewDirWS = normalize( UnityWorldSpaceViewDir( PositionWS ) );
					float4 ScreenPosNorm = float4( IN.pos.xy * ( _ScreenParams.zw - 1.0 ), IN.pos.zw );
					float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, IN.pos.z ) * IN.pos.w;
					float4 ScreenPos = ComputeScreenPos( ClipPos );
					half3 NormalWS = IN.normalWS;
					half3 TangentWS = IN.tangentWS.xyz;
					half3 BitangentWS = cross( IN.normalWS, IN.tangentWS.xyz ) * IN.tangentWS.w * unity_WorldTransformParams.w;
					half3 LightAtten = atten;

					#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
						float2 sampleCoords = (IN.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
						NormalWS = UnityObjectToWorldNormal(normalize(tex2D(_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
						TangentWS = -cross(unity_ObjectToWorld._13_23_33, NormalWS);
						BitangentWS = cross(NormalWS, -TangentWS);
					#endif

					float2 temp_cast_0 = (_LUTSpeed).xx;
					float2 texCoord21 = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner26 = ( 1.0 * _Time.y * _ErosionUVPan + ( texCoord21 * _ErosionUVS ));
					float2 texCoord9 = IN.ase_texcoord6.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner13 = ( 1.0 * _Time.y * _NoiseDistortionUVPan + ( texCoord9 * _NoiseDistortionUVS ));
					float2 DIST23 = ( ( ( (tex2D( _DistortionTexture, panner13 )).rg + -0.5 ) * 2.0 ) * ( _DistortionIntensity * 0.01 ) );
					float2 temp_output_28_0 = ( panner26 + DIST23 );
					float dotResult34 = dot( tex2D( _ErosionTexture, temp_output_28_0 ) , float4( 0, 1, 0, 0 ) );
					float temp_output_40_0 = saturate( dotResult34 );
					float temp_output_45_0 = ( _ErosionIntensity + IN.ase_texcoord6.z );
					float smoothstepResult47 = smoothstep( temp_output_45_0 , ( temp_output_45_0 + ( _ErosionSmoothness - IN.ase_texcoord6.w ) ) , temp_output_40_0);
					float temp_output_49_0 = saturate( smoothstepResult47 );
					#ifdef _LUTERODES_ON
					float staticSwitch92 = temp_output_49_0;
					#else
					float staticSwitch92 = temp_output_40_0;
					#endif
					float2 uv_OpacityMask = IN.ase_texcoord6.xy * _OpacityMask_ST.xy + _OpacityMask_ST.zw;
					float dotResult35 = dot( tex2D( _OpacityMask, uv_OpacityMask ) , float4( 0, 1, 0, 0 ) );
					float smoothstepResult46 = smoothstep( _OpacityMaskErosion , ( _OpacityMaskErosion + _OpacityMaskErosionSmoothness ) , saturate( dotResult35 ));
					float temp_output_53_0 = saturate( ( temp_output_49_0 * saturate( smoothstepResult46 ) ) );
					#ifdef _LUTERODESMASKS_ON
					float staticSwitch93 = temp_output_53_0;
					#else
					float staticSwitch93 = staticSwitch92;
					#endif
					#ifdef _LUTINVERT_ON
					float staticSwitch95 = ( 1.0 - staticSwitch93 );
					#else
					float staticSwitch95 = staticSwitch93;
					#endif
					float2 temp_cast_3 = (( ( staticSwitch95 * _LUTAmplitude ) + _LUTOffset )).xx;
					float2 panner85 = ( 1.0 * _Time.y * temp_cast_0 + temp_cast_3);
					float3 hsvTorgb80 = RGBToHSV( tex2D( _LUT, panner85 ).rgb );
					float mulTime77 = _Time.y * _LUTHueShiftSpeed;
					float3 hsvTorgb75 = HSVToRGB( float3(( ( hsvTorgb80.x + _LUTHueShift ) + mulTime77 ),hsvTorgb80.y,( hsvTorgb80.z * _LUTValueIntensity )) );
					float3 desaturateInitialColor81 = hsvTorgb75;
					float desaturateDot81 = dot( desaturateInitialColor81, float3( 0.299, 0.587, 0.114 ));
					float3 desaturateVar81 = lerp( desaturateInitialColor81, desaturateDot81.xxx, _LUTDesaturate );
					float3 temp_output_106_0 = (IN.ase_color).rgb;
					float3 lerpResult109 = lerp( ( desaturateVar81 * temp_output_106_0 ) , temp_output_106_0 , _FlatColor);
					float3 BC66 = lerpResult109;
					
					float screenDepth52 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ScreenPosNorm.xy ));
					float distanceDepth52 = saturate( ( screenDepth52 - LinearEyeDepth( ScreenPosNorm.z ) ) / ( _DepthFade ) );
					float OP64 = saturate( ( saturate( ( saturate( ( temp_output_53_0 * saturate( distanceDepth52 ) ) ) * _OpacityMultiply ) ) * IN.ase_color.a ) );
					float3 lerpResult99 = lerp( float3( 0, 0, 1 ) , tex2D( _NormalTexture, temp_output_28_0 ).rgb , saturate( ( _NormalIntensity * OP64 ) ));
					float3 N103 = lerpResult99;
					

					o.Albedo = BC66;
					o.Normal = N103;

					half3 Specular = half3( 0, 0, 0 );
					half Metallic = _Metallic;
					half Smoothness = _Smoothness;
					half Occlusion = 1;

					#if defined(ASE_LIGHTING_SIMPLE)
						o.Specular = Specular.x;
						o.Gloss = Smoothness;
					#else
						#if defined(_SPECULAR_SETUP)
							o.Specular = Specular;
						#else
							o.Metallic = Metallic;
						#endif
						o.Occlusion = Occlusion;
						o.Smoothness = Smoothness;
					#endif

					o.Emission = ( BC66 * _EmissionMultiply );
					o.Alpha = OP64;
					half AlphaClipThreshold = 0.5;
					half AlphaClipThresholdShadow = 0.5;
					half3 BakedGI = 0;
					half3 Transmission = 1;
					half3 Translucency = 1;

					#if defined( ASE_DEPTH_WRITE_ON )
						IN.pos.z = IN.pos.z;
					#endif

					#ifdef _ALPHATEST_ON
						clip( o.Alpha - AlphaClipThreshold );
					#endif

					#if defined( ASE_CHANGES_WORLD_POS )
					{
						#if defined( ASE_RECEIVE_SHADOWS )
							UNITY_LIGHT_ATTENUATION( temp, IN, PositionWS )
							LightAtten = temp;
						#else
							LightAtten = 1;
						#endif
					}
					#endif

					#if ( ASE_FRAGMENT_NORMAL == 0 )
						o.Normal = normalize( o.Normal.x * TangentWS + o.Normal.y * BitangentWS + o.Normal.z * NormalWS );
					#elif ( ASE_FRAGMENT_NORMAL == 1 )
						o.Normal = UnityObjectToWorldNormal( o.Normal );
					#elif ( ASE_FRAGMENT_NORMAL == 2 )
						// @diogo: already in world-space; do nothing
					#endif

					#if defined( ASE_DEPTH_WRITE_ON )
						outputDepth = IN.pos.z;
					#endif

					#ifndef USING_DIRECTIONAL_LIGHT
						half3 lightDir = normalize( UnityWorldSpaceLightDir( PositionWS ) );
					#else
						half3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif

					UnityGI gi;
					UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
					gi.indirect.diffuse = 0;
					gi.indirect.specular = 0;
					gi.light.color = _LightColor0.rgb;
					gi.light.dir = lightDir;

					UnityGIInput giInput;
					UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
					giInput.light = gi.light;
					giInput.worldPos = PositionWS;
					giInput.worldViewDir = ViewDirWS;
					giInput.atten = atten;
					#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
						giInput.lightmapUV = IN.ambientOrLightmapUV;
					#else
						giInput.lightmapUV = 0.0;
					#endif
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						giInput.ambient = IN.ambientOrLightmapUV.rgb;
					#else
						giInput.ambient.rgb = 0.0;
					#endif
					giInput.probeHDR[0] = unity_SpecCube0_HDR;
					giInput.probeHDR[1] = unity_SpecCube1_HDR;
					#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
						giInput.boxMin[0] = unity_SpecCube0_BoxMin;
					#endif
					#ifdef UNITY_SPECCUBE_BOX_PROJECTION
						giInput.boxMax[0] = unity_SpecCube0_BoxMax;
						giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
						giInput.boxMax[1] = unity_SpecCube1_BoxMax;
						giInput.boxMin[1] = unity_SpecCube1_BoxMin;
						giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
					#endif

					#if defined(ASE_LIGHTING_SIMPLE)
						#if defined(_SPECULAR_SETUP)
							LightingBlinnPhong_GI(o, giInput, gi);
						#else
							LightingLambert_GI(o, giInput, gi);
						#endif
					#else
						#if defined(_SPECULAR_SETUP)
							LightingStandardSpecular_GI(o, giInput, gi);
						#else
							LightingStandard_GI(o, giInput, gi);
						#endif
					#endif

					#ifdef ASE_BAKEDGI
						gi.indirect.diffuse = BakedGI;
					#endif

					#if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON) && defined(ASE_NO_AMBIENT)
						gi.indirect.diffuse = 0;
					#endif

					half4 c = 0;
					#if defined(ASE_LIGHTING_SIMPLE)
						#if defined(_SPECULAR_SETUP)
							c += LightingBlinnPhong (o, ViewDirWS, gi);
						#else
							c += LightingLambert( o, gi );
						#endif
					#else
						#if defined(_SPECULAR_SETUP)
							c += LightingStandardSpecular (o, ViewDirWS, gi);
						#else
							c += LightingStandard(o, ViewDirWS, gi);
						#endif
					#endif

					#ifdef ASE_TRANSMISSION
					{
						half shadow = _TransmissionShadow;
						#ifdef DIRECTIONAL
							half3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
						#else
							half3 lightAtten = gi.light.color;
						#endif
						half3 transmission = max(0 , -dot(o.Normal, gi.light.dir)) * lightAtten * Transmission;
						c.rgb += o.Albedo * transmission;
					}
					#endif

					#ifdef ASE_TRANSLUCENCY
					{
						half shadow = _TransShadow;
						half normal = _TransNormal;
						half scattering = _TransScattering;
						half direct = _TransDirect;
						half ambient = _TransAmbient;
						half strength = _TransStrength;

						#ifdef DIRECTIONAL
							half3 lightAtten = lerp( _LightColor0.rgb, gi.light.color, shadow );
						#else
							half3 lightAtten = gi.light.color;
						#endif
						half3 lightDir = gi.light.dir + o.Normal * normal;
						half transVdotL = pow( saturate( dot( ViewDirWS, -lightDir ) ), scattering );
						half3 translucency = lightAtten * (transVdotL * direct + gi.indirect.diffuse * ambient) * Translucency;
						c.rgb += o.Albedo * translucency * strength;
					}
					#endif

					c.rgb += o.Emission;

					#if defined( ASE_FOG )
						UNITY_EXTRACT_FOG_FROM_WORLD_POS( IN );
						UNITY_APPLY_FOG(_unity_fogCoord, c.rgb);
					#endif
					return c;
				}
			ENDCG
		}

		
		Pass
		{
			
			Name "Deferred"
			Tags { "LightMode"="Deferred" }

			AlphaToMask Off

			CGPROGRAM
				#define ASE_GEOMETRY
				#define ASE_FRAGMENT_NORMAL 0
				#pragma shader_feature_local_fragment _SPECULARHIGHLIGHTS_OFF
				#pragma shader_feature_local_fragment _GLOSSYREFLECTIONS_OFF
				#pragma multi_compile_instancing
				#pragma multi_compile _ LOD_FADE_CROSSFADE
				#define ASE_FOG
				#define _ALPHABLEND_ON 1
				#define UNITY_STANDARD_USE_DITHER_MASK 1
				#define ASE_RECEIVE_SHADOWS
				#define ASE_NO_AMBIENT 1
				#define ASE_VERSION 19909

				#pragma vertex vert
				#pragma fragment frag
				#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
				#pragma multi_compile_prepassfinal
				#ifndef UNITY_PASS_DEFERRED
					#define UNITY_PASS_DEFERRED
				#endif
				#include "HLSLSupport.cginc"
				#if defined( ASE_GEOMETRY ) || defined( ASE_IMPOSTOR )
					#ifndef UNITY_INSTANCED_LOD_FADE
						#define UNITY_INSTANCED_LOD_FADE
					#endif
					#ifndef UNITY_INSTANCED_SH
						#define UNITY_INSTANCED_SH
					#endif
					#ifndef UNITY_INSTANCED_LIGHTMAPSTS
						#define UNITY_INSTANCED_LIGHTMAPSTS
					#endif
				#endif
				#include "UnityShaderVariables.cginc"
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"

				#if defined( UNITY_INSTANCING_ENABLED ) && defined( ASE_INSTANCED_TERRAIN ) && ( defined(_TERRAIN_INSTANCED_PERPIXEL_NORMAL) || defined(_INSTANCEDTERRAINNORMALS_PIXEL) )
					#define ENABLE_TERRAIN_PERPIXEL_NORMAL
				#endif

				#define ASE_NEEDS_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_SCREEN_POSITION_NORMALIZED
				#define ASE_NEEDS_FRAG_COLOR
				#pragma shader_feature_local _LUTINVERT_ON
				#pragma shader_feature_local _LUTERODESMASKS_ON
				#pragma shader_feature_local _LUTERODES_ON


				struct appdata
				{
					float4 vertex : POSITION;
					half3 normal : NORMAL;
					half4 tangent : TANGENT;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0; // xyz = positionWS, w = fogCoord
					half3 normalWS : TEXCOORD1;
					float4 tangentWS : TEXCOORD2; // holds terrainUV ifdef ENABLE_TERRAIN_PERPIXEL_NORMAL
					half4 ambientOrLightmapUV : TEXCOORD3;
					float4 ase_texcoord4 : TEXCOORD4;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				#ifdef LIGHTMAP_ON
				float4 unity_LightmapFade;
				#endif
				half4 unity_Ambient;
				#ifdef ASE_TESSELLATION
					float _TessPhongStrength;
					float _TessValue;
					float _TessMin;
					float _TessMax;
					float _TessEdgeLength;
					float _TessMaxDisp;
				#endif

				uniform float _Src;
				uniform float _Dst;
				uniform float _Cull;
				uniform float _ZWrite;
				uniform float _ZTest;
				uniform sampler2D _LUT;
				uniform float _LUTSpeed;
				uniform sampler2D _ErosionTexture;
				uniform float2 _ErosionUVPan;
				uniform float2 _ErosionUVS;
				uniform sampler2D _DistortionTexture;
				uniform float2 _NoiseDistortionUVPan;
				uniform float2 _NoiseDistortionUVS;
				uniform float _DistortionIntensity;
				uniform float _ErosionIntensity;
				uniform float _ErosionSmoothness;
				uniform float _OpacityMaskErosion;
				uniform float _OpacityMaskErosionSmoothness;
				uniform sampler2D _OpacityMask;
				uniform float4 _OpacityMask_ST;
				uniform float _LUTAmplitude;
				uniform float _LUTOffset;
				uniform float _LUTHueShift;
				uniform float _LUTHueShiftSpeed;
				uniform float _LUTValueIntensity;
				uniform float _LUTDesaturate;
				uniform float _FlatColor;
				uniform sampler2D _NormalTexture;
				uniform float _NormalIntensity;
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				uniform float4 _CameraDepthTexture_TexelSize;
				uniform float _DepthFade;
				uniform float _OpacityMultiply;
				uniform float _Metallic;
				uniform float _Smoothness;
				uniform float _EmissionMultiply;


				float3 HSVToRGB( float3 c )
				{
					float4 K = float4( 1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0 );
					float3 p = abs( frac( c.xxx + K.xyz ) * 6.0 - K.www );
					return c.z * lerp( K.xxx, saturate( p - K.xxx ), c.y );
				}
				
				float3 RGBToHSV(float3 c)
				{
					float4 K = float4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
					float4 p = lerp( float4( c.bg, K.wz ), float4( c.gb, K.xy ), step( c.b, c.g ) );
					float4 q = lerp( float4( p.xyw, c.r ), float4( c.r, p.yzx ), step( p.x, c.r ) );
					float d = q.x - min( q.w, q.y );
					float e = 1.0e-10;
					return float3( abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
				}

				v2f VertexFunction (appdata v  ) {
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					o.ase_texcoord4 = v.texcoord.xyzw;
					o.ase_color = v.ase_color;

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					float3 positionWS = mul( unity_ObjectToWorld, v.vertex ).xyz;
					half3 normalWS = UnityObjectToWorldNormal( v.normal );
					half3 tangentWS = UnityObjectToWorldDir( v.tangent.xyz );

					o.pos = UnityObjectToClipPos( v.vertex );
					o.worldPos.xyz = positionWS;
					o.normalWS = normalWS;
					o.tangentWS = half4( tangentWS, v.tangent.w );

					o.ambientOrLightmapUV = 0;
					#ifdef LIGHTMAP_ON
						o.ambientOrLightmapUV.xy = v.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#elif UNITY_SHOULD_SAMPLE_SH
						#ifdef VERTEXLIGHT_ON
							o.ambientOrLightmapUV.rgb += Shade4PointLights(
								unity_4LightPosX0, unity_4LightPosY0, unity_4LightPosZ0,
								unity_LightColor[0].rgb, unity_LightColor[1].rgb, unity_LightColor[2].rgb, unity_LightColor[3].rgb,
								unity_4LightAtten0, positionWS, normalWS );
						#endif
						o.ambientOrLightmapUV.rgb = ShadeSHPerVertex( normalWS, o.ambientOrLightmapUV.rgb );
					#endif
					#ifdef DYNAMICLIGHTMAP_ON
						o.ambientOrLightmapUV.zw = v.texcoord2.xy * unity_DynamicLightmapST.xy + unity_DynamicLightmapST.zw;
					#endif

					#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
						o.tangentWS.zw = v.texcoord.xy;
						o.tangentWS.xy = v.texcoord.xy * unity_LightmapST.xy + unity_LightmapST.zw;
					#endif
					return o;
				}

				#if defined(ASE_TESSELLATION)
				struct VertexControl
				{
					float4 vertex : INTERNALTESSPOS;
					half4 tangent : TANGENT;
					half3 normal : NORMAL;
					float4 texcoord : TEXCOORD0;
					float4 texcoord1 : TEXCOORD1;
					float4 texcoord2 : TEXCOORD2;
					float4 ase_color : COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct TessellationFactors
				{
					float edge[3] : SV_TessFactor;
					float inside : SV_InsideTessFactor;
				};

				VertexControl vert ( appdata v )
				{
					VertexControl o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.vertex = v.vertex;
					o.tangent = v.tangent;
					o.normal = v.normal;
					o.texcoord = v.texcoord;
					o.texcoord1 = v.texcoord1;
					o.texcoord2 = v.texcoord2;
					o.ase_color = v.ase_color;
					return o;
				}

				TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
				{
					TessellationFactors o;
					float4 tf = 1;
					float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
					float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
					#if defined(ASE_FIXED_TESSELLATION)
					tf = FixedTess( tessValue );
					#elif defined(ASE_DISTANCE_TESSELLATION)
					tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
					#elif defined(ASE_LENGTH_TESSELLATION)
					tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
					#elif defined(ASE_LENGTH_CULL_TESSELLATION)
					tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
					#endif
					o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
					return o;
				}

				[domain("tri")]
				[partitioning("fractional_odd")]
				[outputtopology("triangle_cw")]
				[patchconstantfunc("TessellationFunction")]
				[outputcontrolpoints(3)]
				VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
				{
				   return patch[id];
				}

				[domain("tri")]
				v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
				{
					appdata o = (appdata) 0;
					o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
					o.tangent = patch[0].tangent * bary.x + patch[1].tangent * bary.y + patch[2].tangent * bary.z;
					o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
					o.texcoord = patch[0].texcoord * bary.x + patch[1].texcoord * bary.y + patch[2].texcoord * bary.z;
					o.texcoord1 = patch[0].texcoord1 * bary.x + patch[1].texcoord1 * bary.y + patch[2].texcoord1 * bary.z;
					o.texcoord2 = patch[0].texcoord2 * bary.x + patch[1].texcoord2 * bary.y + patch[2].texcoord2 * bary.z;
					o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
					#if defined(ASE_PHONG_TESSELLATION)
					float3 pp[3];
					for (int i = 0; i < 3; ++i)
						pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
					float phongStrength = _TessPhongStrength;
					o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
					#endif
					UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
					return VertexFunction(o);
				}
				#else
				v2f vert ( appdata v )
				{
					return VertexFunction( v );
				}
				#endif

				void frag (v2f IN 
					, out half4 outGBuffer0 : SV_Target0
					, out half4 outGBuffer1 : SV_Target1
					, out half4 outGBuffer2 : SV_Target2
					, out half4 outEmission : SV_Target3
					#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
					, out half4 outShadowMask : SV_Target4
					#endif
					#if defined( ASE_DEPTH_WRITE_ON )
					, out float outputDepth : SV_Depth
					#endif
				)
				{
					UNITY_SETUP_INSTANCE_ID(IN);

					#ifdef LOD_FADE_CROSSFADE
						UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
					#endif

					#if defined(ASE_LIGHTING_SIMPLE)
						SurfaceOutput o = (SurfaceOutput)0;
					#else
						#if defined(_SPECULAR_SETUP)
							SurfaceOutputStandardSpecular o = (SurfaceOutputStandardSpecular)0;
						#else
							SurfaceOutputStandard o = (SurfaceOutputStandard)0;
						#endif
					#endif

					float3 PositionWS = IN.worldPos.xyz;
					half3 ViewDirWS = normalize( UnityWorldSpaceViewDir( PositionWS ) );
					float4 ScreenPosNorm = float4( IN.pos.xy * ( _ScreenParams.zw - 1.0 ), IN.pos.zw );
					float4 ClipPos = ComputeClipSpacePosition( ScreenPosNorm.xy, IN.pos.z ) * IN.pos.w;
					float4 ScreenPos = ComputeScreenPos( ClipPos );
					half3 NormalWS = IN.normalWS;
					half3 TangentWS = IN.tangentWS.xyz;
					half3 BitangentWS = cross( IN.normalWS, IN.tangentWS.xyz ) * IN.tangentWS.w * unity_WorldTransformParams.w;

					#if defined(ENABLE_TERRAIN_PERPIXEL_NORMAL)
						float2 sampleCoords = (IN.tangentWS.zw / _TerrainHeightmapRecipSize.zw + 0.5f) * _TerrainHeightmapRecipSize.xy;
						NormalWS = UnityObjectToWorldNormal(normalize(tex2D(_TerrainNormalmapTexture, sampleCoords).rgb * 2 - 1));
						TangentWS = -cross(unity_ObjectToWorld._13_23_33, NormalWS);
						BitangentWS = cross(NormalWS, -TangentWS);
					#endif

					float2 temp_cast_0 = (_LUTSpeed).xx;
					float2 texCoord21 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner26 = ( 1.0 * _Time.y * _ErosionUVPan + ( texCoord21 * _ErosionUVS ));
					float2 texCoord9 = IN.ase_texcoord4.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner13 = ( 1.0 * _Time.y * _NoiseDistortionUVPan + ( texCoord9 * _NoiseDistortionUVS ));
					float2 DIST23 = ( ( ( (tex2D( _DistortionTexture, panner13 )).rg + -0.5 ) * 2.0 ) * ( _DistortionIntensity * 0.01 ) );
					float2 temp_output_28_0 = ( panner26 + DIST23 );
					float dotResult34 = dot( tex2D( _ErosionTexture, temp_output_28_0 ) , float4( 0, 1, 0, 0 ) );
					float temp_output_40_0 = saturate( dotResult34 );
					float temp_output_45_0 = ( _ErosionIntensity + IN.ase_texcoord4.z );
					float smoothstepResult47 = smoothstep( temp_output_45_0 , ( temp_output_45_0 + ( _ErosionSmoothness - IN.ase_texcoord4.w ) ) , temp_output_40_0);
					float temp_output_49_0 = saturate( smoothstepResult47 );
					#ifdef _LUTERODES_ON
					float staticSwitch92 = temp_output_49_0;
					#else
					float staticSwitch92 = temp_output_40_0;
					#endif
					float2 uv_OpacityMask = IN.ase_texcoord4.xy * _OpacityMask_ST.xy + _OpacityMask_ST.zw;
					float dotResult35 = dot( tex2D( _OpacityMask, uv_OpacityMask ) , float4( 0, 1, 0, 0 ) );
					float smoothstepResult46 = smoothstep( _OpacityMaskErosion , ( _OpacityMaskErosion + _OpacityMaskErosionSmoothness ) , saturate( dotResult35 ));
					float temp_output_53_0 = saturate( ( temp_output_49_0 * saturate( smoothstepResult46 ) ) );
					#ifdef _LUTERODESMASKS_ON
					float staticSwitch93 = temp_output_53_0;
					#else
					float staticSwitch93 = staticSwitch92;
					#endif
					#ifdef _LUTINVERT_ON
					float staticSwitch95 = ( 1.0 - staticSwitch93 );
					#else
					float staticSwitch95 = staticSwitch93;
					#endif
					float2 temp_cast_3 = (( ( staticSwitch95 * _LUTAmplitude ) + _LUTOffset )).xx;
					float2 panner85 = ( 1.0 * _Time.y * temp_cast_0 + temp_cast_3);
					float3 hsvTorgb80 = RGBToHSV( tex2D( _LUT, panner85 ).rgb );
					float mulTime77 = _Time.y * _LUTHueShiftSpeed;
					float3 hsvTorgb75 = HSVToRGB( float3(( ( hsvTorgb80.x + _LUTHueShift ) + mulTime77 ),hsvTorgb80.y,( hsvTorgb80.z * _LUTValueIntensity )) );
					float3 desaturateInitialColor81 = hsvTorgb75;
					float desaturateDot81 = dot( desaturateInitialColor81, float3( 0.299, 0.587, 0.114 ));
					float3 desaturateVar81 = lerp( desaturateInitialColor81, desaturateDot81.xxx, _LUTDesaturate );
					float3 temp_output_106_0 = (IN.ase_color).rgb;
					float3 lerpResult109 = lerp( ( desaturateVar81 * temp_output_106_0 ) , temp_output_106_0 , _FlatColor);
					float3 BC66 = lerpResult109;
					
					float screenDepth52 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ScreenPosNorm.xy ));
					float distanceDepth52 = saturate( ( screenDepth52 - LinearEyeDepth( ScreenPosNorm.z ) ) / ( _DepthFade ) );
					float OP64 = saturate( ( saturate( ( saturate( ( temp_output_53_0 * saturate( distanceDepth52 ) ) ) * _OpacityMultiply ) ) * IN.ase_color.a ) );
					float3 lerpResult99 = lerp( float3( 0, 0, 1 ) , tex2D( _NormalTexture, temp_output_28_0 ).rgb , saturate( ( _NormalIntensity * OP64 ) ));
					float3 N103 = lerpResult99;
					

					o.Albedo = BC66;
					o.Normal = N103;

					half3 Specular = half3( 0, 0, 0 );
					half Metallic = _Metallic;
					half Smoothness = _Smoothness;
					half Occlusion = 1;

					#if defined(ASE_LIGHTING_SIMPLE)
						o.Specular = Specular.x;
						o.Gloss = Smoothness;
					#else
						#if defined(_SPECULAR_SETUP)
							o.Specular = Specular;
						#else
							o.Metallic = Metallic;
						#endif
						o.Occlusion = Occlusion;
						o.Smoothness = Smoothness;
					#endif

					o.Emission = ( BC66 * _EmissionMultiply );
					o.Alpha = OP64;
					half AlphaClipThreshold = 0.5;
					half3 BakedGI = 0;

					#if defined( ASE_DEPTH_WRITE_ON )
						IN.pos.z = IN.pos.z;
					#endif

					#if ( ASE_FRAGMENT_NORMAL == 0 )
						o.Normal = normalize( o.Normal.x * TangentWS + o.Normal.y * BitangentWS + o.Normal.z * NormalWS );
					#elif ( ASE_FRAGMENT_NORMAL == 1 )
						o.Normal = UnityObjectToWorldNormal( o.Normal );
					#elif ( ASE_FRAGMENT_NORMAL == 2 )
						// @diogo: already in world-space; do nothing
					#endif

					#ifdef _ALPHATEST_ON
						clip( o.Alpha - AlphaClipThreshold );
					#endif

					#if defined( ASE_DEPTH_WRITE_ON )
						outputDepth = IN.pos.z;
					#endif

					#ifndef USING_DIRECTIONAL_LIGHT
						half3 lightDir = normalize( UnityWorldSpaceLightDir( PositionWS ) );
					#else
						half3 lightDir = _WorldSpaceLightPos0.xyz;
					#endif

					UnityGI gi;
					UNITY_INITIALIZE_OUTPUT(UnityGI, gi);
					gi.indirect.diffuse = 0;
					gi.indirect.specular = 0;
					gi.light.color = 0;
					gi.light.dir = half3( 0, 1, 0 );

					UnityGIInput giInput;
					UNITY_INITIALIZE_OUTPUT(UnityGIInput, giInput);
					giInput.light = gi.light;
					giInput.worldPos = PositionWS;
					giInput.worldViewDir = ViewDirWS;
					giInput.atten = 1;
					#if defined(LIGHTMAP_ON) || defined(DYNAMICLIGHTMAP_ON)
						giInput.lightmapUV = IN.ambientOrLightmapUV;
					#else
						giInput.lightmapUV = 0.0;
					#endif
					#if UNITY_SHOULD_SAMPLE_SH && !UNITY_SAMPLE_FULL_SH_PER_PIXEL
						giInput.ambient = IN.ambientOrLightmapUV.rgb;
					#else
						giInput.ambient.rgb = 0.0;
					#endif
					giInput.probeHDR[0] = unity_SpecCube0_HDR;
					giInput.probeHDR[1] = unity_SpecCube1_HDR;
					#if defined(UNITY_SPECCUBE_BLENDING) || defined(UNITY_SPECCUBE_BOX_PROJECTION)
						giInput.boxMin[0] = unity_SpecCube0_BoxMin;
					#endif
					#ifdef UNITY_SPECCUBE_BOX_PROJECTION
						giInput.boxMax[0] = unity_SpecCube0_BoxMax;
						giInput.probePosition[0] = unity_SpecCube0_ProbePosition;
						giInput.boxMax[1] = unity_SpecCube1_BoxMax;
						giInput.boxMin[1] = unity_SpecCube1_BoxMin;
						giInput.probePosition[1] = unity_SpecCube1_ProbePosition;
					#endif

					#if defined(ASE_LIGHTING_SIMPLE)
						#if defined(_SPECULAR_SETUP)
							LightingBlinnPhong_GI(o, giInput, gi);
						#else
							LightingLambert_GI(o, giInput, gi);
						#endif
					#else
						#if defined(_SPECULAR_SETUP)
							LightingStandardSpecular_GI(o, giInput, gi);
						#else
							LightingStandard_GI(o, giInput, gi);
						#endif
					#endif

					#ifdef ASE_BAKEDGI
						gi.indirect.diffuse = BakedGI;
					#endif

					#if UNITY_SHOULD_SAMPLE_SH && !defined(LIGHTMAP_ON) && defined(ASE_NO_AMBIENT)
						gi.indirect.diffuse = 0;
					#endif

					#if defined(ASE_LIGHTING_SIMPLE)
						#if defined(_SPECULAR_SETUP)
							outEmission = LightingBlinnPhong_Deferred( o, ViewDirWS, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
						#else
							outEmission = LightingLambert_Deferred( o, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
						#endif
					#else
						#if defined(_SPECULAR_SETUP)
							outEmission = LightingStandardSpecular_Deferred( o, ViewDirWS, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
						#else
							outEmission = LightingStandard_Deferred( o, ViewDirWS, gi, outGBuffer0, outGBuffer1, outGBuffer2 );
						#endif
					#endif

					#if defined(SHADOWS_SHADOWMASK) && (UNITY_ALLOWED_MRT_COUNT > 4)
						outShadowMask = UnityGetRawBakedOcclusions( IN.ambientOrLightmapUV.xy, float3( 0, 0, 0 ) );
					#endif
					#ifndef UNITY_HDR_ON
						outEmission.rgb = exp2(-outEmission.rgb);
					#endif
				}
			ENDCG
		}

		
		Pass
		{
			
			Name "SceneSelectionPass"
			Tags { "LightMode"="SceneSelectionPass" }

			ZWrite On

			CGPROGRAM
				#define ASE_GEOMETRY
				#define ASE_FRAGMENT_NORMAL 0
				#pragma multi_compile_instancing
				#pragma multi_compile _ LOD_FADE_CROSSFADE
				#define ASE_FOG
				#define _ALPHABLEND_ON 1
				#define UNITY_STANDARD_USE_DITHER_MASK 1
				#define ASE_RECEIVE_SHADOWS
				#define ASE_NO_AMBIENT 1
				#define ASE_VERSION 19909

				#pragma vertex vert
				#pragma fragment frag
				#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2

				#pragma multi_compile_fwdbase
				#ifndef UNITY_PASS_FORWARDBASE
					#define UNITY_PASS_FORWARDBASE
				#endif
				#include "HLSLSupport.cginc"
				#if defined( ASE_GEOMETRY ) || defined( ASE_IMPOSTOR )
					#ifndef UNITY_INSTANCED_LOD_FADE
						#define UNITY_INSTANCED_LOD_FADE
					#endif
					#ifndef UNITY_INSTANCED_SH
						#define UNITY_INSTANCED_SH
					#endif
					#ifndef UNITY_INSTANCED_LIGHTMAPSTS
						#define UNITY_INSTANCED_LIGHTMAPSTS
					#endif
				#endif
				#include "UnityShaderVariables.cginc"
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define ASE_NEEDS_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0


				int _ObjectId;
				int _PassValue;

				struct appdata
				{
					float4 vertex : POSITION;
					half3 normal : NORMAL;
					half4 tangent : TANGENT;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0; // xyz = positionWS
					half3 normalWS : TEXCOORD1;
					float4 ase_texcoord2 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				#ifdef ASE_TESSELLATION
					float _TessPhongStrength;
					float _TessValue;
					float _TessMin;
					float _TessMax;
					float _TessEdgeLength;
					float _TessMaxDisp;
				#endif

				uniform float _Src;
				uniform float _Dst;
				uniform float _Cull;
				uniform float _ZWrite;
				uniform float _ZTest;
				uniform float _ErosionIntensity;
				uniform float _ErosionSmoothness;
				uniform sampler2D _ErosionTexture;
				uniform float2 _ErosionUVPan;
				uniform float2 _ErosionUVS;
				uniform sampler2D _DistortionTexture;
				uniform float2 _NoiseDistortionUVPan;
				uniform float2 _NoiseDistortionUVS;
				uniform float _DistortionIntensity;
				uniform float _OpacityMaskErosion;
				uniform float _OpacityMaskErosionSmoothness;
				uniform sampler2D _OpacityMask;
				uniform float4 _OpacityMask_ST;
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				uniform float4 _CameraDepthTexture_TexelSize;
				uniform float _DepthFade;
				uniform float _OpacityMultiply;


				
				v2f VertexFunction( appdata v  )
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					float4 ase_positionCS = UnityObjectToClipPos( v.vertex );
					float4 screenPos = ComputeScreenPos( ase_positionCS );
					o.ase_texcoord3 = screenPos;
					
					o.ase_texcoord2 = v.ase_texcoord;
					o.ase_color = v.ase_color;

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					float3 positionWS = mul( unity_ObjectToWorld, v.vertex ).xyz;
					half3 normalWS = UnityObjectToWorldNormal( v.normal );

					o.pos = UnityObjectToClipPos( v.vertex );
					o.worldPos.xyz = positionWS;
					o.normalWS = normalWS;
					return o;
				}

				#if defined(ASE_TESSELLATION)
				struct VertexControl
				{
					float4 vertex : INTERNALTESSPOS;
					half3 normal : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct TessellationFactors
				{
					float edge[3] : SV_TessFactor;
					float inside : SV_InsideTessFactor;
				};

				VertexControl vert ( appdata v )
				{
					VertexControl o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.vertex = v.vertex;
					o.normal = v.normal;
					o.ase_texcoord = v.ase_texcoord;
					o.ase_color = v.ase_color;
					return o;
				}

				TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
				{
					TessellationFactors o;
					float4 tf = 1;
					float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
					float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
					#if defined(ASE_FIXED_TESSELLATION)
					tf = FixedTess( tessValue );
					#elif defined(ASE_DISTANCE_TESSELLATION)
					tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
					#elif defined(ASE_LENGTH_TESSELLATION)
					tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
					#elif defined(ASE_LENGTH_CULL_TESSELLATION)
					tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
					#endif
					o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
					return o;
				}

				[domain("tri")]
				[partitioning("fractional_odd")]
				[outputtopology("triangle_cw")]
				[patchconstantfunc("TessellationFunction")]
				[outputcontrolpoints(3)]
				VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
				{
				   return patch[id];
				}

				[domain("tri")]
				v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
				{
					appdata o = (appdata) 0;
					o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
					o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
					o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
					o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
					#if defined(ASE_PHONG_TESSELLATION)
					float3 pp[3];
					for (int i = 0; i < 3; ++i)
						pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
					float phongStrength = _TessPhongStrength;
					o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
					#endif
					UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
					return VertexFunction(o);
				}
				#else
				v2f vert ( appdata v )
				{
					return VertexFunction( v );
				}
				#endif

				half4 frag( v2f IN 
							#if defined( ASE_DEPTH_WRITE_ON )
								, out float outputDepth : SV_Depth
							#endif
							) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);

					#ifdef LOD_FADE_CROSSFADE
						UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
					#endif

					float temp_output_45_0 = ( _ErosionIntensity + IN.ase_texcoord2.z );
					float2 texCoord21 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner26 = ( 1.0 * _Time.y * _ErosionUVPan + ( texCoord21 * _ErosionUVS ));
					float2 texCoord9 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner13 = ( 1.0 * _Time.y * _NoiseDistortionUVPan + ( texCoord9 * _NoiseDistortionUVS ));
					float2 DIST23 = ( ( ( (tex2D( _DistortionTexture, panner13 )).rg + -0.5 ) * 2.0 ) * ( _DistortionIntensity * 0.01 ) );
					float2 temp_output_28_0 = ( panner26 + DIST23 );
					float dotResult34 = dot( tex2D( _ErosionTexture, temp_output_28_0 ) , float4( 0, 1, 0, 0 ) );
					float temp_output_40_0 = saturate( dotResult34 );
					float smoothstepResult47 = smoothstep( temp_output_45_0 , ( temp_output_45_0 + ( _ErosionSmoothness - IN.ase_texcoord2.w ) ) , temp_output_40_0);
					float temp_output_49_0 = saturate( smoothstepResult47 );
					float2 uv_OpacityMask = IN.ase_texcoord2.xy * _OpacityMask_ST.xy + _OpacityMask_ST.zw;
					float dotResult35 = dot( tex2D( _OpacityMask, uv_OpacityMask ) , float4( 0, 1, 0, 0 ) );
					float smoothstepResult46 = smoothstep( _OpacityMaskErosion , ( _OpacityMaskErosion + _OpacityMaskErosionSmoothness ) , saturate( dotResult35 ));
					float temp_output_53_0 = saturate( ( temp_output_49_0 * saturate( smoothstepResult46 ) ) );
					float4 screenPos = IN.ase_texcoord3;
					float4 ase_positionSSNorm = screenPos / screenPos.w;
					ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
					float screenDepth52 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
					float distanceDepth52 = saturate( ( screenDepth52 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _DepthFade ) );
					float OP64 = saturate( ( saturate( ( saturate( ( temp_output_53_0 * saturate( distanceDepth52 ) ) ) * _OpacityMultiply ) ) * IN.ase_color.a ) );
					

					half Alpha = OP64;
					half AlphaClipThreshold = 0.5;

					#if defined( ASE_DEPTH_WRITE_ON )
						IN.pos.z = IN.pos.z;
					#endif

					#ifdef _ALPHATEST_ON
						clip( Alpha - AlphaClipThreshold );
					#endif

					#if defined( ASE_DEPTH_WRITE_ON )
						outputDepth = IN.pos.z;
					#endif

					return float4( _ObjectId, _PassValue, 1.0, 1.0 );
				}
			ENDCG
		}

		
		Pass
		{
			
			Name "ScenePickingPass"
			Tags { "LightMode"="Picking" }

			ZWrite On

			CGPROGRAM
				#define ASE_GEOMETRY
				#define ASE_FRAGMENT_NORMAL 0
				#pragma multi_compile_instancing
				#pragma multi_compile _ LOD_FADE_CROSSFADE
				#define ASE_FOG
				#define _ALPHABLEND_ON 1
				#define UNITY_STANDARD_USE_DITHER_MASK 1
				#define ASE_RECEIVE_SHADOWS
				#define ASE_NO_AMBIENT 1
				#define ASE_VERSION 19909

				#pragma vertex vert
				#pragma fragment frag
				#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2

				#pragma multi_compile_fwdbase
				#ifndef UNITY_PASS_FORWARDBASE
					#define UNITY_PASS_FORWARDBASE
				#endif
				#include "HLSLSupport.cginc"
				#if defined( ASE_GEOMETRY ) || defined( ASE_IMPOSTOR )
					#ifndef UNITY_INSTANCED_LOD_FADE
						#define UNITY_INSTANCED_LOD_FADE
					#endif
					#ifndef UNITY_INSTANCED_SH
						#define UNITY_INSTANCED_SH
					#endif
					#ifndef UNITY_INSTANCED_LIGHTMAPSTS
						#define UNITY_INSTANCED_LIGHTMAPSTS
					#endif
				#endif
				#include "UnityShaderVariables.cginc"
				#include "UnityCG.cginc"
				#include "Lighting.cginc"
				#include "UnityPBSLighting.cginc"
				#include "AutoLight.cginc"

				#define ASE_NEEDS_TEXTURE_COORDINATES0
				#define ASE_NEEDS_FRAG_TEXTURE_COORDINATES0


				float4 _SelectionID;

				struct appdata
				{
					float4 vertex : POSITION;
					half3 normal : NORMAL;
					half4 tangent : TANGENT;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					float4 pos : SV_POSITION;
					float4 worldPos : TEXCOORD0; // xyz = positionWS
					half3 normalWS : TEXCOORD1;
					float4 ase_texcoord2 : TEXCOORD2;
					float4 ase_texcoord3 : TEXCOORD3;
					float4 ase_color : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
					UNITY_VERTEX_OUTPUT_STEREO
				};

				#ifdef ASE_TESSELLATION
					float _TessPhongStrength;
					float _TessValue;
					float _TessMin;
					float _TessMax;
					float _TessEdgeLength;
					float _TessMaxDisp;
				#endif

				uniform float _Src;
				uniform float _Dst;
				uniform float _Cull;
				uniform float _ZWrite;
				uniform float _ZTest;
				uniform float _ErosionIntensity;
				uniform float _ErosionSmoothness;
				uniform sampler2D _ErosionTexture;
				uniform float2 _ErosionUVPan;
				uniform float2 _ErosionUVS;
				uniform sampler2D _DistortionTexture;
				uniform float2 _NoiseDistortionUVPan;
				uniform float2 _NoiseDistortionUVS;
				uniform float _DistortionIntensity;
				uniform float _OpacityMaskErosion;
				uniform float _OpacityMaskErosionSmoothness;
				uniform sampler2D _OpacityMask;
				uniform float4 _OpacityMask_ST;
				UNITY_DECLARE_DEPTH_TEXTURE( _CameraDepthTexture );
				uniform float4 _CameraDepthTexture_TexelSize;
				uniform float _DepthFade;
				uniform float _OpacityMultiply;


				
				v2f VertexFunction( appdata v  )
				{
					UNITY_SETUP_INSTANCE_ID(v);
					v2f o;
					UNITY_INITIALIZE_OUTPUT(v2f,o);
					UNITY_TRANSFER_INSTANCE_ID(v,o);
					UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

					float4 ase_positionCS = UnityObjectToClipPos( v.vertex );
					float4 screenPos = ComputeScreenPos( ase_positionCS );
					o.ase_texcoord3 = screenPos;
					
					o.ase_texcoord2 = v.ase_texcoord;
					o.ase_color = v.ase_color;

					#ifdef ASE_ABSOLUTE_VERTEX_POS
						float3 defaultVertexValue = v.vertex.xyz;
					#else
						float3 defaultVertexValue = float3(0, 0, 0);
					#endif
					float3 vertexValue = defaultVertexValue;
					#ifdef ASE_ABSOLUTE_VERTEX_POS
						v.vertex.xyz = vertexValue;
					#else
						v.vertex.xyz += vertexValue;
					#endif
					v.vertex.w = 1;
					v.normal = v.normal;
					v.tangent = v.tangent;

					float3 positionWS = mul( unity_ObjectToWorld, v.vertex ).xyz;
					half3 normalWS = UnityObjectToWorldNormal( v.normal );

					o.pos = UnityObjectToClipPos( v.vertex );
					o.worldPos.xyz = positionWS;
					o.normalWS = normalWS;
					return o;
				}

				#if defined(ASE_TESSELLATION)
				struct VertexControl
				{
					float4 vertex : INTERNALTESSPOS;
					half3 normal : NORMAL;
					float4 ase_texcoord : TEXCOORD0;
					float4 ase_color : COLOR;

					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct TessellationFactors
				{
					float edge[3] : SV_TessFactor;
					float inside : SV_InsideTessFactor;
				};

				VertexControl vert ( appdata v )
				{
					VertexControl o;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					o.vertex = v.vertex;
					o.normal = v.normal;
					o.ase_texcoord = v.ase_texcoord;
					o.ase_color = v.ase_color;
					return o;
				}

				TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
				{
					TessellationFactors o;
					float4 tf = 1;
					float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
					float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
					#if defined(ASE_FIXED_TESSELLATION)
					tf = FixedTess( tessValue );
					#elif defined(ASE_DISTANCE_TESSELLATION)
					tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, UNITY_MATRIX_M, _WorldSpaceCameraPos );
					#elif defined(ASE_LENGTH_TESSELLATION)
					tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams );
					#elif defined(ASE_LENGTH_CULL_TESSELLATION)
					tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, UNITY_MATRIX_M, _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
					#endif
					o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
					return o;
				}

				[domain("tri")]
				[partitioning("fractional_odd")]
				[outputtopology("triangle_cw")]
				[patchconstantfunc("TessellationFunction")]
				[outputcontrolpoints(3)]
				VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
				{
				   return patch[id];
				}

				[domain("tri")]
				v2f DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
				{
					appdata o = (appdata) 0;
					o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
					o.normal = patch[0].normal * bary.x + patch[1].normal * bary.y + patch[2].normal * bary.z;
					o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
					o.ase_color = patch[0].ase_color * bary.x + patch[1].ase_color * bary.y + patch[2].ase_color * bary.z;
					#if defined(ASE_PHONG_TESSELLATION)
					float3 pp[3];
					for (int i = 0; i < 3; ++i)
						pp[i] = o.vertex.xyz - patch[i].normal * (dot(o.vertex.xyz, patch[i].normal) - dot(patch[i].vertex.xyz, patch[i].normal));
					float phongStrength = _TessPhongStrength;
					o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
					#endif
					UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
					return VertexFunction(o);
				}
				#else
				v2f vert ( appdata v )
				{
					return VertexFunction( v );
				}
				#endif

				half4 frag( v2f IN 
							#if defined( ASE_DEPTH_WRITE_ON )
								, out float outputDepth : SV_Depth
							#endif
							) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(IN);

					#ifdef LOD_FADE_CROSSFADE
						UNITY_APPLY_DITHER_CROSSFADE(IN.pos.xy);
					#endif

					float temp_output_45_0 = ( _ErosionIntensity + IN.ase_texcoord2.z );
					float2 texCoord21 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner26 = ( 1.0 * _Time.y * _ErosionUVPan + ( texCoord21 * _ErosionUVS ));
					float2 texCoord9 = IN.ase_texcoord2.xy * float2( 1,1 ) + float2( 0,0 );
					float2 panner13 = ( 1.0 * _Time.y * _NoiseDistortionUVPan + ( texCoord9 * _NoiseDistortionUVS ));
					float2 DIST23 = ( ( ( (tex2D( _DistortionTexture, panner13 )).rg + -0.5 ) * 2.0 ) * ( _DistortionIntensity * 0.01 ) );
					float2 temp_output_28_0 = ( panner26 + DIST23 );
					float dotResult34 = dot( tex2D( _ErosionTexture, temp_output_28_0 ) , float4( 0, 1, 0, 0 ) );
					float temp_output_40_0 = saturate( dotResult34 );
					float smoothstepResult47 = smoothstep( temp_output_45_0 , ( temp_output_45_0 + ( _ErosionSmoothness - IN.ase_texcoord2.w ) ) , temp_output_40_0);
					float temp_output_49_0 = saturate( smoothstepResult47 );
					float2 uv_OpacityMask = IN.ase_texcoord2.xy * _OpacityMask_ST.xy + _OpacityMask_ST.zw;
					float dotResult35 = dot( tex2D( _OpacityMask, uv_OpacityMask ) , float4( 0, 1, 0, 0 ) );
					float smoothstepResult46 = smoothstep( _OpacityMaskErosion , ( _OpacityMaskErosion + _OpacityMaskErosionSmoothness ) , saturate( dotResult35 ));
					float temp_output_53_0 = saturate( ( temp_output_49_0 * saturate( smoothstepResult46 ) ) );
					float4 screenPos = IN.ase_texcoord3;
					float4 ase_positionSSNorm = screenPos / screenPos.w;
					ase_positionSSNorm.z = ( UNITY_NEAR_CLIP_VALUE >= 0 ) ? ase_positionSSNorm.z : ase_positionSSNorm.z * 0.5 + 0.5;
					float screenDepth52 = LinearEyeDepth(SAMPLE_DEPTH_TEXTURE( _CameraDepthTexture, ase_positionSSNorm.xy ));
					float distanceDepth52 = saturate( ( screenDepth52 - LinearEyeDepth( ase_positionSSNorm.z ) ) / ( _DepthFade ) );
					float OP64 = saturate( ( saturate( ( saturate( ( temp_output_53_0 * saturate( distanceDepth52 ) ) ) * _OpacityMultiply ) ) * IN.ase_color.a ) );
					

					half Alpha = OP64;
					half AlphaClipThreshold = 0.5;

					#if defined( ASE_DEPTH_WRITE_ON )
						IN.pos.z = IN.pos.z;
					#endif

					#ifdef _ALPHATEST_ON
						clip( Alpha - AlphaClipThreshold );
					#endif

					#if defined( ASE_DEPTH_WRITE_ON )
						outputDepth = IN.pos.z;
					#endif

					return _SelectionID;
				}
			ENDCG
		}
		
	}
	CustomEditor "AmplifyShaderEditor.MaterialInspector"
	
	Fallback Off
}
/*ASEBEGIN
Version=19909
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;8;-11696,-176;Inherit;False;3364;418.95;Distortion;13;23;20;19;18;17;16;15;14;13;12;11;10;9;Distortion;0,0,0,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;9;-11648,-128;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;10;-11264,0;Inherit;False;Property;_NoiseDistortionUVS;Noise Distortion UV S;21;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;11;-11264,-128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;12;-10752,0;Inherit;False;Property;_NoiseDistortionUVPan;Noise Distortion UV Pan;22;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;13;-10752,-128;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;14;-10240,-128;Inherit;True;Property;_DistortionTexture;Distortion Texture;20;0;Create;True;0;0;0;False;3;Space(33);Header(Distortion);Space(13);False;-1;68f40dd3ecb9ff44c80cf000682ee400;68f40dd3ecb9ff44c80cf000682ee400;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;15;-9856,-128;Inherit;False;True;True;False;False;1;0;COLOR;0,0,0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;16;-8960,128;Inherit;False;Constant;_Float1;Float 1;18;0;Create;True;0;0;0;False;0;False;0.01;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;17;-9216,0;Inherit;False;Property;_DistortionIntensity;Distortion Intensity;23;0;Create;True;0;0;0;False;0;False;0.1;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.FunctionNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;18;-9600,-128;Inherit;False;ConstantBiasScale;-1;;1;63208df05c83e8e49a48ffbdce2e43a0;0;3;3;FLOAT2;0,0;False;1;FLOAT;-0.5;False;2;FLOAT;2;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;19;-8960,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;20;-9216,-128;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.TextureCoordinatesNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;21;-9728,768;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;22;-9344,896;Inherit;False;Property;_ErosionUVS;Erosion UV S;25;0;Create;True;0;0;0;False;0;False;1,1;1,1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;23;-8576,-128;Inherit;False;DIST;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;24;-9344,768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector2Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;25;-8832,896;Inherit;False;Property;_ErosionUVPan;Erosion UV Pan;26;0;Create;True;0;0;0;False;0;False;0,0;0,0;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;26;-8832,768;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;27;-8192,896;Inherit;False;23;DIST;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;28;-8192,768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;29;-7168,1024;Inherit;False;Constant;_ErosionMaskSelector;Erosion Mask Selector;28;0;Create;True;0;0;0;False;0;False;0,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;30;-7168,768;Inherit;True;Property;_ErosionTexture;Erosion Texture;24;0;Create;True;0;0;0;False;3;Space(33);Header(Erosion);Space(13);False;-1;50f92059060fd1d43bbb4c3917d30fc3;50f92059060fd1d43bbb4c3917d30fc3;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.Vector4Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;31;-7168,2944;Inherit;False;Constant;_OpacityMaskSelector;Opacity Mask Selector;28;0;Create;True;0;0;0;False;0;False;0,1,0,0;0,0,0,0;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;32;-7168,2688;Inherit;True;Property;_OpacityMask;Opacity Mask;29;0;Create;True;0;0;0;False;3;Space(33);Header(Opacity Mask);Space(13);False;-1;None;None;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;33;-6144,1152;Inherit;False;Property;_ErosionSmoothness;Erosion Smoothness;28;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;34;-6528,768;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;35;-6528,2688;Inherit;False;2;0;COLOR;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;36;-6272,3072;Inherit;False;Property;_OpacityMaskErosionSmoothness;Opacity Mask Erosion Smoothness;31;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;37;-6144,1024;Inherit;False;Property;_ErosionIntensity;Erosion Intensity;27;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TexCoordVertexDataNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;38;-7168,1280;Inherit;False;0;4;0;5;FLOAT4;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleSubtractOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;39;-5888,1152;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;40;-6272,768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;41;-6272,2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;42;-6016,2944;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;43;-6272,2944;Inherit;False;Property;_OpacityMaskErosion;Opacity Mask Erosion;30;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;44;-5632,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;45;-5888,1024;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;46;-6016,2688;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;47;-5632,768;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;48;-5760,2688;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;49;-5376,768;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;50;-3968,1664;Inherit;False;Property;_DepthFade;Depth Fade;6;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;51;-4864,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DepthFade, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;52;-3968,1536;Inherit;False;True;True;False;2;1;FLOAT3;0,0,0;False;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;53;-4608,1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;54;-3712,1536;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;55;-3968,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;56;-3712,1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;57;-3328,1408;Inherit;False;Property;_OpacityMultiply;Opacity Multiply;5;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;58;-3328,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;59;-3072,1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;60;-2816,1408;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;61;-2560,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;62;-2304,1280;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;63;592,-48;Inherit;False;1252;162.95;Ge Lush was here! <3;5;115;114;113;112;111;Ge Lush was here! <3;0,0,0,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;64;-1792,1280;Inherit;False;OP;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;65;-5888,1280;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;66;-1792,0;Inherit;False;BC;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;67;-640,384;Inherit;False;Property;_Specular;Specular;2;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;68;-640,512;Inherit;False;Property;_Smoothness;Smoothness;3;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;69;-640,256;Inherit;False;Property;_Metallic;Metallic;1;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;70;-640,768;Inherit;False;Property;_EmissionMultiply;Emission Multiply;4;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;71;-640,128;Inherit;False;103;N;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;72;-640,0;Inherit;False;66;BC;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;73;-3968,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;74;-3712,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.HSVToRGBNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;75;-3456,0;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;76;-3968,512;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleTimeNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;77;-3712,128;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;78;-3712,256;Inherit;False;Property;_LUTHueShiftSpeed;LUT Hue Shift Speed;12;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;79;-3968,128;Inherit;False;Property;_LUTHueShift;LUT Hue Shift;11;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RGBToHSVNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;80;-4352,0;Inherit;False;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.DesaturateOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;81;-3200,0;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;82;-3200,128;Inherit;False;Property;_LUTDesaturate;LUT Desaturate;13;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;83;-5888,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;84;-5504,0;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PannerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;85;-5120,0;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;86;-5888,128;Inherit;False;Property;_LUTAmplitude;LUT Amplitude;8;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;87;-5504,128;Inherit;False;Property;_LUTOffset;LUT Offset;9;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;88;-5120,128;Inherit;False;Property;_LUTSpeed;LUT Speed;10;0;Create;True;0;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;89;-4736,0;Inherit;True;Property;_LUT;LUT;7;0;Create;True;0;0;0;False;3;Space(33);Header(LUT);Space(13);False;-1;cefbf3db17ebe674db0d21108dfd0f4a;cefbf3db17ebe674db0d21108dfd0f4a;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;90;-3968,640;Inherit;False;Property;_LUTValueIntensity;LUT Value Intensity;14;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;91;-640,896;Inherit;False;64;OP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;92;-5888,384;Inherit;False;Property;_LUTErodes;LUT Erodes;15;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;93;-5504,384;Inherit;False;Property;_LUTErodesMasks;LUT Erodes Masks;16;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;94;-4992,512;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StaticSwitch, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;95;-4736,384;Inherit;False;Property;_LUTInvert;LUT Invert;17;0;Create;True;0;0;0;False;0;False;0;0;0;True;;Toggle;2;Key0;Key1;Create;True;True;All;9;1;FLOAT;0;False;0;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT;0;False;7;FLOAT;0;False;8;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;96;-7168,1664;Inherit;True;Property;_NormalTexture;Normal Texture;18;0;Create;True;0;0;0;False;3;Space(33);Header(Normal);Space(13);False;-1;6690b0fec148ad2478bc8e01570c413f;6690b0fec148ad2478bc8e01570c413f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;False;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;6;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT3;5
Node;AmplifyShaderEditor.Vector3Node, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;97;-7168,1920;Inherit;False;Constant;_Vector0;Vector 0;28;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;98;-6528,1920;Inherit;False;Property;_NormalIntensity;Normal Intensity;19;0;Create;True;0;0;0;False;0;False;1;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;99;-6016,1664;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;100;-6016,1920;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;101;-6272,1920;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;102;-6528,2048;Inherit;False;64;OP;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;103;-5504,1664;Inherit;False;N;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;104;-640,640;Inherit;False;66;BC;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;105;-384,640;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ComponentMaskNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;106;-2560,256;Inherit;False;True;True;True;False;1;0;COLOR;0,0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;107;-2304,0;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.VertexColorNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;108;-2816,256;Inherit;False;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;109;-2048,0;Inherit;False;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;110;-2048,384;Inherit;False;Property;_FlatColor;Flat Color;0;0;Create;True;0;0;0;False;0;False;0;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;111;896,0;Inherit;False;Property;_Src;Src;33;0;Create;True;0;0;0;True;0;False;5;5;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;112;1152,0;Inherit;False;Property;_Dst;Dst;34;0;Create;True;0;0;0;True;0;False;10;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;113;640,0;Inherit;False;Property;_Cull;Cull;32;0;Create;True;0;0;0;True;3;Space(33);Header(AR);Space(13);False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;114;1408,0;Inherit;False;Property;_ZWrite;ZWrite;35;0;Create;True;0;0;0;True;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;115;1664,0;Inherit;False;Property;_ZTest;ZTest;36;0;Create;True;0;0;0;True;0;False;2;2;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;0;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ExtraPrePass;0;0;ExtraPrePass;6;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;True;1;1;False;;0;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;True;True;0;False;;0;False;;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;1;0,0;Float;False;True;-1;3;AmplifyShaderEditor.MaterialInspector;0;3;Vefects/SH_Vefects_BIRP_Free_Blood_01_Lit;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardBase;0;1;ForwardBase;17;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;True;True;0;True;_Cull;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;True;True;2;True;_ZWrite;True;3;True;_ZTest;False;False;True;3;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;True;True;1;5;True;_Src;10;True;_Dst;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=ForwardBase;False;False;0;;0;0;Standard;44;Category;0;0;  Instanced Terrain Normals;1;0;Workflow;1;639127845816817077;Surface;1;639127845853497711;  Blend;0;0;  Dither Shadows;1;0;Two Sided;1;0;Alpha Clipping;0;0;  Use Shadow Threshold;0;0;Deferred Pass;1;0;Normal Space;0;0;Transmission;0;0;  Transmission Shadow;0.5,False,;0;Translucency;0;0;  Translucency Strength;1,False,;0;  Normal Distortion;0.5,False,;0;  Scattering;2,False,;0;  Direct;0.9,False,;0;  Ambient;0.1,False,;0;  Shadow;0.5,False,;0;Cast Shadows;0;639127846149751550;Receive Shadows;1;639127846160659975;Receive Specular;2;0;Receive Reflections;2;0;GPU Instancing;1;0;LOD CrossFade;1;0;Built-in Fog;1;0;Ambient Light;0;639127846201188463;Meta Pass;0;639127846195420591;Add Pass;0;639127846197983952;Override Baked GI;0;0;Write Depth;0;0;Extra Pre Pass;0;0;Tessellation;0;0;  Phong;0;0;  Strength;0.5,False,;0;  Type;0;0;  Tess;16,False,;0;  Min;10,False,;0;  Max;25,False,;0;  Edge Length;16,False,;0;  Max Displacement;25,False,;0;Disable Batching;0;0;Vertex Position;1;0;0;8;False;True;False;True;False;False;True;True;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;2;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ForwardAdd;0;2;ForwardAdd;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;True;4;5;False;;1;False;;0;1;False;;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;True;1;LightMode=ForwardAdd;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;3;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Deferred;0;3;Deferred;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Deferred;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;4;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;Meta;0;4;Meta;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;2;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;5;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ShadowCaster;0;5;ShadowCaster;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;True;0;False;;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;True;3;False;;False;False;True;1;LightMode=ShadowCaster;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;6;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;SceneSelectionPass;0;6;SceneSelectionPass;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;True;1;LightMode=SceneSelectionPass;False;False;0;;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode, AmplifyShaderEditor, Version=0.0.0.0, Culture=neutral, PublicKeyToken=null;7;0,0;Float;False;False;-1;3;AmplifyShaderEditor.MaterialInspector;0;1;New Amplify Shader;ed95fe726fd7b4644bb42f4d1ddd2bcd;True;ScenePickingPass;0;7;ScenePickingPass;0;False;True;0;1;False;;0;False;;0;1;False;;0;False;;True;0;False;;0;False;;False;False;False;False;False;False;False;False;False;True;0;False;;False;True;0;False;;False;True;True;True;True;True;0;False;;False;False;False;False;False;False;False;True;False;0;False;;255;False;;255;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;0;False;;False;True;1;False;;True;3;False;;False;False;True;3;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;DisableBatching=False=DisableBatching;True;3;True;12;all;0;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;1;False;;False;False;False;True;1;LightMode=Picking;False;False;0;;0;0;Standard;0;False;0
WireConnection;11;0;9;0
WireConnection;11;1;10;0
WireConnection;13;0;11;0
WireConnection;13;2;12;0
WireConnection;14;1;13;0
WireConnection;15;0;14;0
WireConnection;18;3;15;0
WireConnection;19;0;17;0
WireConnection;19;1;16;0
WireConnection;20;0;18;0
WireConnection;20;1;19;0
WireConnection;23;0;20;0
WireConnection;24;0;21;0
WireConnection;24;1;22;0
WireConnection;26;0;24;0
WireConnection;26;2;25;0
WireConnection;28;0;26;0
WireConnection;28;1;27;0
WireConnection;30;1;28;0
WireConnection;34;0;30;0
WireConnection;34;1;29;0
WireConnection;35;0;32;0
WireConnection;35;1;31;0
WireConnection;39;0;33;0
WireConnection;39;1;38;4
WireConnection;40;0;34;0
WireConnection;41;0;35;0
WireConnection;42;0;43;0
WireConnection;42;1;36;0
WireConnection;44;0;45;0
WireConnection;44;1;39;0
WireConnection;45;0;37;0
WireConnection;45;1;38;3
WireConnection;46;0;41;0
WireConnection;46;1;43;0
WireConnection;46;2;42;0
WireConnection;47;0;40;0
WireConnection;47;1;45;0
WireConnection;47;2;44;0
WireConnection;48;0;46;0
WireConnection;49;0;47;0
WireConnection;51;0;49;0
WireConnection;51;1;48;0
WireConnection;52;0;50;0
WireConnection;53;0;51;0
WireConnection;54;0;52;0
WireConnection;55;0;53;0
WireConnection;55;1;54;0
WireConnection;56;0;55;0
WireConnection;58;0;56;0
WireConnection;58;1;57;0
WireConnection;59;0;58;0
WireConnection;61;0;59;0
WireConnection;61;1;60;4
WireConnection;62;0;61;0
WireConnection;64;0;62;0
WireConnection;65;0;33;0
WireConnection;65;1;38;4
WireConnection;66;0;109;0
WireConnection;73;0;80;1
WireConnection;73;1;79;0
WireConnection;74;0;73;0
WireConnection;74;1;77;0
WireConnection;75;0;74;0
WireConnection;75;1;80;2
WireConnection;75;2;76;0
WireConnection;76;0;80;3
WireConnection;76;1;90;0
WireConnection;77;0;78;0
WireConnection;80;0;89;5
WireConnection;81;0;75;0
WireConnection;81;1;82;0
WireConnection;83;0;95;0
WireConnection;83;1;86;0
WireConnection;84;0;83;0
WireConnection;84;1;87;0
WireConnection;85;0;84;0
WireConnection;85;2;88;0
WireConnection;89;1;85;0
WireConnection;92;1;40;0
WireConnection;92;0;49;0
WireConnection;93;1;92;0
WireConnection;93;0;53;0
WireConnection;94;0;93;0
WireConnection;95;1;93;0
WireConnection;95;0;94;0
WireConnection;96;1;28;0
WireConnection;99;0;97;0
WireConnection;99;1;96;5
WireConnection;99;2;100;0
WireConnection;100;0;101;0
WireConnection;101;0;98;0
WireConnection;101;1;102;0
WireConnection;103;0;99;0
WireConnection;105;0;104;0
WireConnection;105;1;70;0
WireConnection;106;0;108;0
WireConnection;107;0;81;0
WireConnection;107;1;106;0
WireConnection;109;0;107;0
WireConnection;109;1;106;0
WireConnection;109;2;110;0
WireConnection;1;0;72;0
WireConnection;1;1;71;0
WireConnection;1;4;69;0
WireConnection;1;5;68;0
WireConnection;1;2;105;0
WireConnection;1;7;91;0
ASEEND*/
//CHKSM=8E9ADE377773BE881062874A31D4940245A27A73