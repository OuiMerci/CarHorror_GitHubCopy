// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "TidalFlask/Waterfall Standard"
{
	Properties
	{
		[HDR]_BaseColor("Base Color", Color) = (0,0.711586,1,0)
		_BaseColorContrast("Base Color Contrast", Range( 0.1 , 0.9)) = 0.2
		_TopFadeAmount("Top Fade Amount", Range( -1 , 1)) = -0.01
		_TopFadeFalloff("Top Fade Falloff", Range( 0.1 , 2)) = 0.1
		_CutoutValue("Cutout Value", Range( 0 , 1)) = 0.42
		_VertexOffset("Vertex Offset", Range( 0 , 1)) = 0.2
		_NoiseSpeed("Noise Speed", Float) = 0.25
		_RippleSpeed("Ripple Speed", Float) = 0.15
		_RipplesNoiseScale("Ripples Noise Scale", Float) = 10
		_RipplesCoverageAmount("Ripples Coverage Amount", Range( 0 , 1)) = 0.6
		_RipplesCoverageFalloff("Ripples Coverage Falloff", Range( 0 , 40)) = 4
		_RipplesBottomHeight("Ripples Bottom Height", Range( 0 , 1)) = 0.8
		_RipplesBottomNoiseScale("Ripples Bottom Noise Scale", Float) = 7
		_RipplesBottomCoverageAmount("Ripples Bottom Coverage Amount", Range( 0 , 1)) = 1
		_RipplesBottomCoverageFalloff("Ripples Bottom Coverage Falloff", Range( 0 , 40)) = 1
		[HideInInspector]_MaskClipValueControl("Mask Clip Value Control", Range( 0 , 1)) = 0.5
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "TransparentCutout"  "Queue" = "AlphaTest+0" "IgnoreProjector" = "True" }
		Cull Off
		CGPROGRAM
		#include "UnityShaderVariables.cginc"
		#pragma target 4.6
		#pragma surface surf Standard keepalpha addshadow fullforwardshadows exclude_path:deferred vertex:vertexDataFunc 
		struct Input
		{
			float3 worldPos;
			half ASEVFace : VFACE;
			float2 uv_texcoord;
		};

		uniform float _RippleSpeed;
		uniform float _RipplesBottomNoiseScale;
		uniform float _VertexOffset;
		uniform float4 _BaseColor;
		uniform float _RipplesNoiseScale;
		uniform float _NoiseSpeed;
		uniform float _RipplesCoverageAmount;
		uniform float _RipplesCoverageFalloff;
		uniform float _BaseColorContrast;
		uniform float _RipplesBottomHeight;
		uniform float _RipplesBottomCoverageAmount;
		uniform float _RipplesBottomCoverageFalloff;
		uniform float _CutoutValue;
		uniform float _TopFadeAmount;
		uniform float _TopFadeFalloff;
		uniform float _MaskClipValueControl;


		float3 mod2D289( float3 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float2 mod2D289( float2 x ) { return x - floor( x * ( 1.0 / 289.0 ) ) * 289.0; }

		float3 permute( float3 x ) { return mod2D289( ( ( x * 34.0 ) + 1.0 ) * x ); }

		float snoise( float2 v )
		{
			const float4 C = float4( 0.211324865405187, 0.366025403784439, -0.577350269189626, 0.024390243902439 );
			float2 i = floor( v + dot( v, C.yy ) );
			float2 x0 = v - i + dot( i, C.xx );
			float2 i1;
			i1 = ( x0.x > x0.y ) ? float2( 1.0, 0.0 ) : float2( 0.0, 1.0 );
			float4 x12 = x0.xyxy + C.xxzz;
			x12.xy -= i1;
			i = mod2D289( i );
			float3 p = permute( permute( i.y + float3( 0.0, i1.y, 1.0 ) ) + i.x + float3( 0.0, i1.x, 1.0 ) );
			float3 m = max( 0.5 - float3( dot( x0, x0 ), dot( x12.xy, x12.xy ), dot( x12.zw, x12.zw ) ), 0.0 );
			m = m * m;
			m = m * m;
			float3 x = 2.0 * frac( p * C.www ) - 1.0;
			float3 h = abs( x ) - 0.5;
			float3 ox = floor( x + 0.5 );
			float3 a0 = x - ox;
			m *= 1.79284291400159 - 0.85373472095314 * ( a0 * a0 + h * h );
			float3 g;
			g.x = a0.x * x0.x + h.x * x0.y;
			g.yz = a0.yz * x12.xz + h.yz * x12.yw;
			return 130.0 * dot( m, g );
		}


		float2 voronoihash1( float2 p )
		{
			
			p = float2( dot( p, float2( 127.1, 311.7 ) ), dot( p, float2( 269.5, 183.3 ) ) );
			return frac( sin( p ) *43758.5453);
		}


		float voronoi1( float2 v, float time, inout float2 id, inout float2 mr, float smoothness, inout float2 smoothId )
		{
			float2 n = floor( v );
			float2 f = frac( v );
			float F1 = 8.0;
			float F2 = 8.0; float2 mg = 0;
			for ( int j = -1; j <= 1; j++ )
			{
				for ( int i = -1; i <= 1; i++ )
			 	{
			 		float2 g = float2( i, j );
			 		float2 o = voronoihash1( n + g );
					o = ( sin( time + o * 6.2831 ) * 0.5 + 0.5 ); float2 r = f - g - o;
					float d = 0.5 * dot( r, r );
			 		if( d<F1 ) {
			 			F2 = F1;
			 			F1 = d; mg = g; mr = r; id = o;
			 		} else if( d<F2 ) {
			 			F2 = d;
			
			 		}
			 	}
			}
			return F1;
		}


		void vertexDataFunc( inout appdata_full v, out Input o )
		{
			UNITY_INITIALIZE_OUTPUT( Input, o );
			float3 ase_worldPos = mul( unity_ObjectToWorld, v.vertex );
			float3 break66 = ase_worldPos;
			float2 break62 = v.texcoord.xy;
			float2 appendResult63 = (float2(break62.x , ( break62.y + ( _Time.y * _RippleSpeed ) )));
			float simplePerlin2D19 = snoise( appendResult63*_RipplesBottomNoiseScale );
			simplePerlin2D19 = simplePerlin2D19*0.5 + 0.5;
			float4 appendResult70 = (float4(break66.x , ( ( simplePerlin2D19 * _VertexOffset ) + break66.y ) , break66.z , 0.0));
			float4 lerpResult71 = lerp( float4( ase_worldPos , 0.0 ) , appendResult70 , v.texcoord.xy.y);
			float3 worldToObj72 = mul( unity_WorldToObject, float4( lerpResult71.xyz, 1 ) ).xyz;
			v.vertex.xyz = worldToObj72;
			v.vertex.w = 1;
		}

		void surf( Input i , inout SurfaceOutputStandard o )
		{
			float3 switchResult37 = (((i.ASEVFace>0)?(float3(0,0,1)):(float3(0,0,-1))));
			o.Normal = switchResult37;
			float time1 = ( _Time.y * _NoiseSpeed );
			float2 voronoiSmoothId0 = 0;
			float2 break62 = i.uv_texcoord;
			float2 appendResult63 = (float2(break62.x , ( break62.y + ( _Time.y * _RippleSpeed ) )));
			float2 coords1 = appendResult63 * _RipplesNoiseScale;
			float2 id1 = 0;
			float2 uv1 = 0;
			float voroi1 = voronoi1( coords1, time1, id1, uv1, 0, voronoiSmoothId0 );
			float temp_output_12_0 = pow( saturate( ( voroi1 + _RipplesCoverageAmount ) ) , _RipplesCoverageFalloff );
			float simplePerlin2D19 = snoise( appendResult63*_RipplesBottomNoiseScale );
			simplePerlin2D19 = simplePerlin2D19*0.5 + 0.5;
			float temp_output_52_0 = saturate( pow( (0.0 + (( pow( ( 1.0 - i.uv_texcoord.y ) , ( ( 1.0 - _RipplesBottomHeight ) * 50.0 ) ) * simplePerlin2D19 ) - 0.0) * (( _RipplesBottomCoverageAmount * 10.0 ) - 0.0) / (1.0 - 0.0)) , _RipplesBottomCoverageFalloff ) );
			o.Albedo = ( _BaseColor * saturate( ( (_BaseColorContrast + (temp_output_12_0 - 0.0) * (1.0 - _BaseColorContrast) / (1.0 - 0.0)) + temp_output_52_0 ) ) ).rgb;
			o.Alpha = 1;
			float lerpResult39 = lerp( saturate( ( saturate( temp_output_12_0 ) + temp_output_52_0 ) ) , 1.0 , _CutoutValue);
			float temp_output_94_0 = ( 1.0 - i.uv_texcoord.y );
			float temp_output_106_0 = pow( temp_output_94_0 , 3.31 );
			clip( ( lerpResult39 * pow( saturate( ( ( ( simplePerlin2D19 * temp_output_94_0 ) + ( temp_output_106_0 + temp_output_106_0 ) ) + _TopFadeAmount ) ) , _TopFadeFalloff ) ) - _MaskClipValueControl );
		}

		ENDCG
	}
	Fallback "Diffuse"
}
/*ASEBEGIN
Version=18912
349;460;1906;989;2819.268;745.246;2.227452;True;False
Node;AmplifyShaderEditor.CommentaryNode;80;-4301.287,-301.2764;Inherit;False;2466.288;733.5212;;15;2;62;61;3;63;1;13;10;11;7;12;16;43;42;65;Base Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;77;-4286.778,-1012.524;Inherit;False;775.6482;492.8155;;5;60;56;59;58;57;Speed;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;79;-4287.232,648.1026;Inherit;False;2715.205;780.5831;;16;27;47;18;46;20;53;19;49;25;26;23;48;24;51;50;52;Bottom Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleTimeNode;56;-3964.475,-962.5238;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;60;-4235.659,-635.7087;Inherit;False;Property;_RippleSpeed;Ripple Speed;7;0;Create;True;0;0;0;False;0;False;0.15;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-4251.286,22.20546;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.BreakToComponentsNode;62;-3952.912,21.88923;Inherit;False;FLOAT2;1;0;FLOAT2;0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;59;-3680.126,-652.7085;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;27;-4237.232,1310.082;Inherit;False;Property;_RipplesBottomHeight;Ripples Bottom Height;11;0;Create;True;0;0;0;False;0;False;0.8;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;-3785.838,152.3535;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;18;-3921.286,1000.594;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;58;-4236.778,-814.3101;Inherit;False;Property;_NoiseSpeed;Noise Speed;6;0;Create;True;0;0;0;False;0;False;0.25;1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;47;-3697.691,1104.5;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;0;False;0;False;50;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;20;-3709.954,1313.684;Inherit;False;Property;_RipplesBottomNoiseScale;Ripples Bottom Noise Scale;12;0;Create;True;0;0;0;False;0;False;7;10.16;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;3;-3557.806,317.2448;Inherit;False;Property;_RipplesNoiseScale;Ripples Noise Scale;8;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;63;-3619.891,20.91383;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;53;-3708.129,704.6051;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;57;-3681.245,-831.3099;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;46;-3694.491,1000.075;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;109;-3083.964,-1012.945;Inherit;False;1760.555;583.3445;;11;94;103;105;96;97;98;99;95;107;106;110;Top Fade;1,1,1,1;0;0
Node;AmplifyShaderEditor.NoiseGeneratorNode;19;-3414.418,975.9706;Inherit;True;Simplex2D;True;False;2;0;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.VoronoiNode;1;-3291.098,22.52241;Inherit;True;0;0;1;0;1;False;1;False;False;False;4;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;3;FLOAT;0;FLOAT2;1;FLOAT2;2
Node;AmplifyShaderEditor.RangedFloatNode;13;-3080.139,315.9824;Inherit;False;Property;_RipplesCoverageAmount;Ripples Coverage Amount;9;0;Create;True;0;0;0;False;0;False;0.6;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;26;-3126.325,703.0928;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;49;-2525.717,1097.216;Inherit;False;Constant;_Float1;Float 1;9;0;Create;True;0;0;0;False;0;False;10;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;25;-2837.281,1302.183;Inherit;False;Property;_RipplesBottomCoverageAmount;Ripples Bottom Coverage Amount;13;0;Create;True;0;0;0;False;0;False;1;1.18;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-3034.481,-551.1868;Inherit;False;Constant;_Float3;Float 3;16;0;Create;True;0;0;0;False;0;False;3.31;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;48;-2517.829,985.3347;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;10;-2850.493,26.82858;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;23;-2796.585,699.541;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;94;-3033.964,-664.0784;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;106;-2800.715,-682.601;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;11;-2580.908,27.8525;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;81;-3401.144,1577.021;Inherit;False;1824.764;592.5461;;10;75;73;66;67;68;69;70;71;72;74;Vertex Position Offset;1,1,1,1;0;0
Node;AmplifyShaderEditor.RangedFloatNode;7;-2610.568,316.7498;Inherit;False;Property;_RipplesCoverageFalloff;Ripples Coverage Falloff;10;0;Create;True;0;0;0;False;0;False;4;0;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;24;-2380.149,698.1026;Inherit;True;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;51;-2270.809,1295.129;Inherit;False;Property;_RipplesBottomCoverageFalloff;Ripples Bottom Coverage Falloff;14;0;Create;True;0;0;0;False;0;False;1;0;0;40;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;110;-2542.893,-684.0248;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;12;-2359.821,25.80099;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;103;-2789.839,-957.2142;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;75;-3351.144,1689.832;Inherit;False;Property;_VertexOffset;Vertex Offset;5;0;Create;True;0;0;0;False;0;False;0.2;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;73;-3047.74,1814.642;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.PowerNode;50;-2016.355,698.9891;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-2784.205,1670.647;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;43;-2360.598,-251.2764;Inherit;False;Property;_BaseColorContrast;Base Color Contrast;1;0;Create;True;0;0;0;False;0;False;0.2;0.1;0.1;0.9;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;95;-2137.016,-645.9638;Float;False;Property;_TopFadeAmount;Top Fade Amount;2;0;Create;True;0;0;0;False;0;False;-0.01;-0.18;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;16;-2041.373,280.3769;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;52;-1747.028,699.8962;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;66;-2775.741,1814.642;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;105;-2418.258,-962.9454;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;67;-2580.741,1670.642;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;44;-1499.771,275.8244;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-2090.42,-960.1993;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.TFHCRemapNode;42;-2047.992,28.25065;Inherit;False;5;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;3;FLOAT;0;False;4;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;85;-779.9738,620.2021;Inherit;False;352;165;;1;40;Mask Clip Value;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;45;-1218.767,277.5811;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;69;-2361.353,1627.02;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;40;-729.9738,670.2021;Inherit;False;Property;_CutoutValue;Cutout Value;4;0;Create;True;0;0;0;False;0;False;0.42;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;41;-583.2131,352.377;Inherit;False;Constant;_Float2;Float 2;7;0;Create;True;0;0;0;False;0;False;1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;97;-1812.563,-956.4179;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;93;-762.6695,-349.1187;Inherit;False;284;257;;1;5;Color;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;78;-769.7571,-1011.066;Inherit;False;563.5065;394.7423;;3;36;35;37;Normal;1,1,1,1;0;0
Node;AmplifyShaderEditor.SimpleAddOpNode;28;-1502.951,27.06094;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;98;-1621.41,-649.9092;Float;False;Property;_TopFadeFalloff;Top Fade Falloff;3;0;Create;True;0;0;0;False;0;False;0.1;0.65;0.1;2;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;70;-2359.74,1814.642;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;68;-2351.202,2013.565;Inherit;False;0;-1;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;71;-2066.227,1791.078;Inherit;False;3;0;FLOAT4;0,0,0,0;False;1;FLOAT4;0,0,0,0;False;2;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.ColorNode;5;-712.6695,-299.1187;Inherit;False;Property;_BaseColor;Base Color;0;1;[HDR];Create;True;0;0;0;False;0;False;0,0.711586,1,0;0,0.711586,1,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.LerpOp;39;-371.5898,273.4969;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;99;-1605.264,-957.0906;Inherit;True;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;84;257.8934,617.8522;Inherit;False;352;165;mask clip value controller which stays constant and is hidden in inspector;1;83;leave as is ;1,1,1,1;0;0
Node;AmplifyShaderEditor.SaturateNode;29;-1220.06,27.16042;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.Vector3Node;35;-715.9305,-961.0657;Inherit;False;Constant;_Vector1;Vector 1;5;0;Create;True;0;0;0;False;0;False;0,0,1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.Vector3Node;36;-719.7571,-800.3234;Inherit;False;Constant;_Vector0;Vector 0;5;0;Create;True;0;0;0;False;0;False;0,0,-1;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.TransformPositionNode;72;-1824.38,1786.642;Inherit;False;World;Object;False;Fast;True;1;0;FLOAT3;0,0,0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ScaleAndOffsetNode;65;-2827.308,-229.1107;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;1;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;4;-368.555,2.262138;Inherit;True;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SwitchByFaceNode;37;-427.2504,-956.3782;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;101;-75.71655,271.5891;Inherit;True;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;83;307.8934,667.8522;Inherit;False;Constant;_MaskClipValueControl;Mask Clip Value Control;16;1;[HideInInspector];Create;True;0;0;0;False;0;False;0.5;0;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;281.8627,4.765707;Float;False;True;-1;6;;0;0;Standard;TidalFlask/Waterfall Standard;False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Masked;0.5;True;True;0;False;TransparentCutout;;AlphaTest;ForwardOnly;16;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;0;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Absolute;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;True;83;0;0;0;False;0.1;False;-1;0;False;-1;False;16;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;5;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;62;0;2;0
WireConnection;59;0;56;0
WireConnection;59;1;60;0
WireConnection;61;0;62;1
WireConnection;61;1;59;0
WireConnection;18;0;27;0
WireConnection;63;0;62;0
WireConnection;63;1;61;0
WireConnection;53;0;2;2
WireConnection;57;0;56;0
WireConnection;57;1;58;0
WireConnection;46;0;18;0
WireConnection;46;1;47;0
WireConnection;19;0;63;0
WireConnection;19;1;20;0
WireConnection;1;0;63;0
WireConnection;1;1;57;0
WireConnection;1;2;3;0
WireConnection;26;0;53;0
WireConnection;26;1;46;0
WireConnection;48;0;25;0
WireConnection;48;1;49;0
WireConnection;10;0;1;0
WireConnection;10;1;13;0
WireConnection;23;0;26;0
WireConnection;23;1;19;0
WireConnection;94;0;2;2
WireConnection;106;0;94;0
WireConnection;106;1;107;0
WireConnection;11;0;10;0
WireConnection;24;0;23;0
WireConnection;24;4;48;0
WireConnection;110;0;106;0
WireConnection;110;1;106;0
WireConnection;12;0;11;0
WireConnection;12;1;7;0
WireConnection;103;0;19;0
WireConnection;103;1;94;0
WireConnection;50;0;24;0
WireConnection;50;1;51;0
WireConnection;74;0;19;0
WireConnection;74;1;75;0
WireConnection;16;0;12;0
WireConnection;52;0;50;0
WireConnection;66;0;73;0
WireConnection;105;0;103;0
WireConnection;105;1;110;0
WireConnection;67;0;74;0
WireConnection;67;1;66;1
WireConnection;44;0;16;0
WireConnection;44;1;52;0
WireConnection;96;0;105;0
WireConnection;96;1;95;0
WireConnection;42;0;12;0
WireConnection;42;3;43;0
WireConnection;45;0;44;0
WireConnection;97;0;96;0
WireConnection;28;0;42;0
WireConnection;28;1;52;0
WireConnection;70;0;66;0
WireConnection;70;1;67;0
WireConnection;70;2;66;2
WireConnection;71;0;69;0
WireConnection;71;1;70;0
WireConnection;71;2;68;2
WireConnection;39;0;45;0
WireConnection;39;1;41;0
WireConnection;39;2;40;0
WireConnection;99;0;97;0
WireConnection;99;1;98;0
WireConnection;29;0;28;0
WireConnection;72;0;71;0
WireConnection;65;2;1;0
WireConnection;4;0;5;0
WireConnection;4;1;29;0
WireConnection;37;0;35;0
WireConnection;37;1;36;0
WireConnection;101;0;39;0
WireConnection;101;1;99;0
WireConnection;0;0;4;0
WireConnection;0;1;37;0
WireConnection;0;10;101;0
WireConnection;0;11;72;0
ASEEND*/
//CHKSM=CB135DB71ABBB05323C7A668DFAAD27A54BC0487