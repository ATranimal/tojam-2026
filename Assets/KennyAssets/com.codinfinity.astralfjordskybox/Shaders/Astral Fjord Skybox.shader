Shader "Custom/Astral Fjord Skybox"
{
    Properties
    {
        _SkyTop("Sky Top Color", Color) = (0.02, 0.02, 0.08, 1)
        _SkyBottom("Sky Bottom Color", Color) = (0.0, 0.01, 0.03, 1)
        _VerticalExponent("Vertical Falloff", Range(0.1, 4)) = 1.5

        // Rotation comme le Skybox/Procedural
        _SkyRotation("Sky Rotation", Range(0, 360)) = 0

        // Étoiles
        [HDR]_StarColor("Star Color", Color) = (0.0, 1.0, 0.9, 1)
        _StarTiling("Star Tiling", Range(50, 2000)) = 400
        _StarSizeMin("Star Size Min", Range(0.005, 1.0)) = 0.04
        _StarSizeMax("Star Size Max", Range(0.005, 1.0)) = 0.12
        _StarConcavity("Star Concavity", Range(0.0, 1.0)) = 0.3
        _StarDensity("Star Density", Range(0.0, 1.0)) = 0.2
        _EquatorFocus("Equator Focus", Range(0.0, 4.0)) = 2.0
        _StarIntensity("Star Intensity", Range(0.0, 10.0)) = 2.0

        _TwinkleSpeed("Twinkle Speed", Range(0.0, 10.0)) = 2.0
        _TwinkleStrength("Twinkle Strength", Range(0.0, 1.0)) = 0.5
        _TwinkleProbability("Twinkle Probability", Range(0.0, 1.0)) = 0.8

        //nuages
         // Clouds
        [HDR]_CloudColor("Cloud Color", Color) = (0.0, 1.0, 0.9, 1)
        _CloudIntensity("Cloud Intensity", Range(0.0, 5.0)) = 1.0

        _CloudTiling("Cloud Tiling", Range(1.0, 40.0)) = 14.0
        _CloudDensity("Cloud Density", Range(0.0, 1.0)) = 0.4

        _CloudLengthMin("Cloud Length Min", Range(0.2, 3.0)) = 0.8
        _CloudLengthMax("Cloud Length Max", Range(0.2, 3.0)) = 1.8

        _CloudThicknessMin("Cloud Thickness Min", Range(0.0001, 0.4)) = 0.03   // épaisseur aux extrémités
        _CloudThicknessMax("Cloud Thickness Max", Range(0.0001, 0.4)) = 0.12   // épaisseur au milieu
        _CloudSoftness("Cloud Softness", Range(0.0005, 4.0)) = 1.5
        _CloudEdgeSharpness("Cloud Edge Sharpness", Range(0.5, 4.0)) = 2.0   // contrôle "fin au début, au milieu, fin à la fin"

        _CloudLayerCount("Cloud Layer Count", Range(1, 4)) = 3
        _CloudBaseHeight("Cloud Base Height", Range(0.0, 1.0)) = 0.3
        _CloudLayerSpacing("Cloud Layer Spacing", Range(0.0, 0.5)) = 0.06
        _CloudVerticalJitter("Cloud Vertical Jitter", Range(0.0, 0.3)) = 0.06
        _CloudLayerXOffset("Cloud Layer X Offset", Range(-1.0, 1.0)) = 0.12
        _CloudScrollBaseSpeed("Cloud Scroll Base Speed", Range(-0.2, 0.2)) = 0.01
        _CloudScrollSpeedVariation("Cloud Scroll Speed Variation", Range(0.0, 0.2)) = 0.01

        // Aurora
        [HDR]_AuroraColorLow("Aurora Color Low", Color) = (0.0, 1.0, 0.6, 1)
        [HDR]_AuroraColorMid("Aurora Color Mid", Color) = (0.0, 0.9, 1.0, 1)
        [HDR]_AuroraColorHigh("Aurora Color High", Color) = (1.0, 0.3, 0.9, 1)
        _AuroraGradientStop("Aurora Gradient Stop", Range(0.2, 0.8)) = 0.3
        _AuroraGradientStop2("Aurora Gradient Stop 2", Range(0.2, 0.8)) = 0.3

        _AuroraIntensity("Aurora Intensity", Range(0.0, 10.0)) = 3.0

        _AuroraHeight("Aurora Height Center", Range(0.0, 1.0)) = 0.75        // position verticale moyenne
        _AuroraTiltAngle("Aurora Tilt Angle", Range(-90.0, 90.0)) = 20.0
        _AuroraTiltAxis("Aurora Tilt Axis", Vector) = (0, 0, 1, 0)
    
        _AuroraAmplitude("Aurora Amplitude", Range(0.0, 0.5)) = 0.12         // amplitude verticale du sinus
        _AuroraThickness("Aurora Thickness", Range(0.01, 0.5)) = 0.15        // épaisseur de la bande

        _AuroraFrequency("Aurora Waves Count", Range(0.5, 6.0)) = 2.0        // nb de vagues autour du ciel
        _AuroraScrollSpeed("Aurora Scroll Speed", Range(-2.0, 2.0)) = 0.3    // vitesse de défilement

        _AuroraSharpness("Aurora Sharpness", Range(0.5, 6.0)) = 2.0          // bord plus ou moins net
        _AuroraBottomFade("Aurora Bottom Fade", Range(0.0, 4.0)) = 2.0       // fondu vers le bas du ciel

    }

    SubShader
    {
        Tags
        {
            "Queue" = "Background"
            "RenderType" = "Background"
            "PreviewType" = "Skybox"
        }

        Cull Back
        ZWrite Off
        Fog { Mode Off }

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 dir : TEXCOORD0;
            };

            float4 _SkyTop;
            float4 _SkyBottom;
            float _VerticalExponent;
            float _SkyRotation;

            float4 _StarColor;
            float _StarTiling;
            float _StarSizeMin;
            float _StarSizeMax;
            float _StarConcavity;
            float _EquatorFocus;
            float _StarDensity;
            float _StarIntensity;

            float _TwinkleSpeed;
            float _TwinkleStrength;
            float _TwinkleProbability;

            float4 _CloudColor;
            float _CloudIntensity;

            float _CloudTiling;
            float _CloudDensity;

            float _CloudLengthMin;
            float _CloudLengthMax;

            float _CloudThicknessMin;
            float _CloudThicknessMax;
            float _CloudSoftness;
            float _CloudEdgeSharpness;

            float _CloudLayerCount;
            float _CloudBaseHeight;
            float _CloudLayerSpacing;
            float _CloudVerticalJitter;
            float _CloudLayerXOffset;
            float _CloudScrollBaseSpeed;
            float _CloudScrollSpeedVariation;

            float4 _AuroraColorLow;
            float4 _AuroraColorMid;
            float4 _AuroraColorHigh;
            float _AuroraGradientStop;
            float _AuroraGradientStop2;
            float  _AuroraIntensity;

            float  _AuroraHeight;
            float  _AuroraTiltAngle;
            float4 _AuroraTiltAxis;
            float  _AuroraAmplitude;
            float  _AuroraThickness;

            float  _AuroraFrequency;
            float  _AuroraScrollSpeed;

            float  _AuroraSharpness;
            float  _AuroraBottomFade;


            // Rotation autour de Y comme dans le Skybox/Procedural
            float3 RotateY(float3 dir, float degrees)
            {
                float rad = radians(degrees);
                float s, c;
                sincos(rad, s, c);

                float3 r;
                r.x = dir.x * c - dir.z * s;
                r.z = dir.x * s + dir.z * c;
                r.y = dir.y;
                return r;
            }

            float3 RotateAroundAxis(float3 v, float3 axis, float angleDeg)
            {
                float rad = radians(angleDeg);
                float s = sin(rad);
                float c = cos(rad);
                axis = normalize(axis);

                // formule de Rodrigues
                return v * c
                     + cross(axis, v) * s
                     + axis * dot(axis, v) * (1.0 - c);
            }

            // Petit hash déterministe pour le bruit
            float hash(float2 p)
            {
                p = frac(p * float2(123.34, 345.45));
                p += dot(p, p + 34.345);
                return frac(p.x * p.y);
            }

            float valueNoise(float2 p)
            {
                float2 i = floor(p);
                float2 f = frac(p);

                float a = hash(i);
                float b = hash(i + float2(1.0, 0.0));
                float c = hash(i + float2(0.0, 1.0));
                float d = hash(i + float2(1.0, 1.0));

                float2 u = f * f * (3.0 - 2.0 * f); // smoothstep

                return lerp(lerp(a, b, u.x), lerp(c, d, u.x), u.y);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);

                // Direction du rayon dans l'espace monde
                float3 worldDir = mul((float3x3)unity_ObjectToWorld, v.vertex.xyz);
                o.dir = normalize(worldDir);

                return o;
            }

            float3 ComputeBackground(float3 dir)
            {
                // Dégradé vertical simple : bas -> haut
                float t = saturate(dir.y * 0.5 + 0.5);
                t = pow(t, _VerticalExponent);
                return lerp(_SkyBottom.rgb, _SkyTop.rgb, t);
            }

            float ComputeStars(float3 dir)
{
    // Projection sphérique -> coordonnées "UV" equirectangulaires
    float2 uv;
    uv.x = atan2(dir.z, dir.x) / (2.0 * UNITY_PI) + 0.5;
    uv.y = asin(dir.y) / UNITY_PI + 0.5;

    // Grille de cellules
    float2 grid = uv * _StarTiling;
    float2 cell = floor(grid);
    float2 f    = frac(grid);   // position dans la cellule [0,1]

    // distance à l'équateur en [0,1] : 0 = équateur, 1 = pôles
    float equatorDist   = abs(uv.y - 0.5) * 2.0;
    float equatorFactor = pow(saturate(1.0 - equatorDist), _EquatorFocus);
    float localDensity  = _StarDensity * equatorFactor;

    // tirage : est-ce qu'on dessine une étoile dans cette cellule ?
    float cellRandom = hash(cell);
    if (cellRandom > localDensity)
        return 0.0;

    // ----- FORME LOSANGE LÉGÈREMENT CONCAVE -----

    // Centre (fixe) de l'étoile dans la cellule
    float2 starPos = float2(0.5, 0.5);

    // Taille aléatoire de l'étoile dans cette cellule
    float starSizeRand = hash(cell + 456.789);
    float starSize     = lerp(_StarSizeMin, _StarSizeMax, starSizeRand);
    starSize           = max(starSize, 0.0005); // sécurité

    // Coordonnées locales, normalisées par la taille aléatoire
    float2 p  = (f - starPos) / starSize;
    float2 ap = abs(p);

    // n = 1   -> losange classique |x| + |y| <= 1
    // n < 1   -> côtés concaves
    float n = lerp(1.0, 0.3, _StarConcavity);

    // Super-ellipse : |x|^n + |y|^n ≈ 1 sur le bord
    float d = pow(ap.x, n) + pow(ap.y, n);

    // Sécurité : très loin du losange → rien
    if (d > 1.5)
        return 0.0;

    // Largeur de bord FIXE (plus de fwidth → plus de rectangles par tiles)
    // Ajuste ce paramètre si tu veux un bord plus fin ou plus doux
    float edgeWidth = 0.08;  // entre ~0.03 et 0.12 selon ton goût

    // Bord net mais doux, sans dérivées écran
    float star = 1.0 - smoothstep(1.0 - edgeWidth, 1.0 + edgeWidth, d);

    // Cœur un peu plus dense
    star = pow(saturate(star), 0.6);

    // ----- TWINKLE (scintillement) -----
    float twinkleSelector = hash(cell + 123.456);
    if (twinkleSelector < _TwinkleProbability)
    {
        float phase     = hash(cell + 23.98) * (2.0 * UNITY_PI);
        float speedRand = lerp(0.5, 2.0, hash(cell + 87.21));

        float s   = sin(_Time.y * _TwinkleSpeed * speedRand + phase);
        float s01 = s * 0.5 + 0.5;

        float minMul = 1.0 - _TwinkleStrength;
        float maxMul = 1.0 + _TwinkleStrength;
        float tw     = lerp(minMul, maxMul, s01);

        star *= tw;
    }

    return star;
}

            // Calcule la contribution d'un niveau de nuages (layerIndex = 0,1,2,...)
            float ComputeCloudLayer(float2 uv, float layerIndex)
            {
                // ---------- VITESSE PAR LAYER ----------
                // seed aléatoire pour ce layer
                float layerSeed  = hash(float2(layerIndex * 37.21, 5.37));
                // vitesse propre à ce layer (autour de _CloudScrollBaseSpeed)
                float layerSpeed = _CloudScrollBaseSpeed + (layerSeed - 0.5) * 2.0 * _CloudScrollSpeedVariation;

                // offset animé (positif ou négatif selon layerSpeed)
                float animOffset = _Time.y * layerSpeed;

                // ---------- DÉCALAGE EN X ----------
                // on décale en X en fonction du layer + du temps
                float shiftedX = uv.x + layerIndex * _CloudLayerXOffset + animOffset;
                shiftedX = frac(shiftedX);   // reste dans [0,1] pour que ça boucle proprement

                // découpage horizontal en cellules
                float cx    = shiftedX * _CloudTiling;
                float cellX = floor(cx);
                float fx    = frac(cx);      // position dans la cellule [0,1] en X

                // On encode le layer dans la cellule pour avoir du bruit différent par niveau
                float2 cell = float2(cellX, layerIndex * 17.0);

                // Est-ce qu'on met un nuage dans cette cellule ?
                float cellRandom = hash(cell);
                if (cellRandom > _CloudDensity)
                    return 0.0;

                // Longueur de la traînée
                float lenRand    = hash(cell + 13.37);
                float halfLength = 0.5 * lerp(_CloudLengthMin, _CloudLengthMax, lenRand);

                // Coordonnée le long de la traînée
                float s = fx - 0.5;
                float u = s / halfLength;
                if (abs(u) > 1.0)
                    return 0.0;

                // Épaisseur : fin début/fin, épais milieu
                float edge      = pow(abs(u), _CloudEdgeSharpness);
                float thickness = lerp(_CloudThicknessMax, _CloudThicknessMin, edge);

                // Varier un peu l'épaisseur par cellule
                float sizeRand = hash(cell + 91.77);
                thickness     *= lerp(0.7, 1.3, sizeRand);

                // --- tout le reste de ta fonction comme avant ---
                float layers      = max(_CloudLayerCount, 1.0);
                float layerOffset = (layerIndex - 0.5 * (layers - 1.0)) * _CloudLayerSpacing;
                float jitter      = (hash(cell + 45.89) - 0.5) * _CloudVerticalJitter;
                float centerY     = _CloudBaseHeight + layerOffset + jitter;

                float v = (uv.y - centerY) / thickness;

                float d = sqrt(u * u + v * v);
                float w = fwidth(d);
                float cloud = 1.0 - smoothstep(1.0 - w, 1.0 + w, d);

                cloud = pow(saturate(cloud), _CloudSoftness);

                return cloud;
            }

            float ComputeCloud(float3 dir)
            {
                // Dir -> UV sphériques
                float2 uv;
                uv.x = atan2(dir.z, dir.x) / (2.0 * UNITY_PI) + 0.5;
                uv.y = asin(dir.y) / UNITY_PI + 0.5;

                float cloud = 0.0;

                int layerCount = (int)_CloudLayerCount;
                layerCount = clamp(layerCount, 1, 4);

                [unroll]
                for (int i = 0; i < 4; i++)
                {
                    if (i >= layerCount)
                        break;

                    cloud += ComputeCloudLayer(uv, (float)i);
                }

                // On évite de dépasser 1, sinon ça sature trop
                return saturate(cloud);
            }

            float3 ComputeAurora(float3 dir)
            {
                 // On applique d'abord une rotation pour incliner le "pôle" de l'aurore
                float3 axis = _AuroraTiltAxis.xyz;
                float3 dirTilted = RotateAroundAxis(dir, axis, _AuroraTiltAngle);

                // Direction inclinée -> UV sphériques (uniquement pour l'aurore)
                float2 uv;
                uv.x = atan2(dirTilted.z, dirTilted.x) / (2.0 * UNITY_PI) + 0.5;
                uv.y = asin(dirTilted.y) / UNITY_PI + 0.5;

                // ----- COURBE SINUSOÏDALE -----

                // phase le long de X (on boucle autour du ciel)
                float phase = uv.x * (2.0 * UNITY_PI) * _AuroraFrequency
                            + _Time.y * _AuroraScrollSpeed;

                // position verticale de la "ligne centrale" de l'aurore
                float centerY = _AuroraHeight + sin(phase) * _AuroraAmplitude;

                // distance verticale normalisée par l'épaisseur
                float thickness = max(_AuroraThickness, 1e-4);
                float dy = (uv.y - centerY) / thickness;   // 0 au centre, ±1 au bord
                float dist = abs(dy);

                // masque principal (bande : fin au bord, plein au centre)
                float mask = saturate(1.0 - dist);
                mask = pow(mask, _AuroraSharpness);        // plus grand => plus fin

                if (mask <= 0.0)
                    return 0.0.xxx;

                // ----- FONDU VERS LE BAS DU CIEL -----

                // uv.y ~ 0 en bas, 1 en haut
                float bottomFactor = pow(saturate(uv.y), _AuroraBottomFade);
                mask *= bottomFactor;

                if (mask <= 0.0)
                    return 0.0.xxx;

                // ----- GRADIENT DE COULEURS EN 3 BANDES -----

                // tHeight : 0 = bas de l'aurore, 1 = haut de l'aurore
                float halfTh   = thickness;
                float bottomY  = centerY - halfTh;
                float topY     = centerY + halfTh;
                float tHeight  = saturate( (uv.y - bottomY) / max(topY - bottomY, 1e-4) );

                float3 auroraCol;

                // 0 -> 0.5 : Low -> Mid
                // 0.5 -> 1 : Mid -> High

                if (tHeight <= _AuroraGradientStop)
                {
                    float t2 = tHeight / _AuroraGradientStop; // 0..1
                    auroraCol = lerp(_AuroraColorLow.rgb, _AuroraColorMid.rgb, t2);
                }
                else if (tHeight<= _AuroraGradientStop2)
                {
                    auroraCol = _AuroraColorMid.rgb;
                }
                else
                {
                    float t2 = (tHeight - _AuroraGradientStop2) / (1.0 - _AuroraGradientStop2); // 0..1
                    auroraCol = lerp(_AuroraColorMid.rgb, _AuroraColorHigh.rgb, t2);
                }

                // On peut renforcer un peu le haut pour mieux voir la 3e couleur
                //float topBoost = lerp(1.0, 1.3, tHeight);
                //auroraCol *= topBoost;

                return auroraCol * mask * _AuroraIntensity;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float3 dir = normalize(i.dir);

                // Appliquer la rotation utilisateur
                dir = RotateY(dir, _SkyRotation);

                // Couleur de fond (ciel)
                float3 col = ComputeBackground(dir);

                // Intensité des étoiles
                float star = ComputeStars(dir);

                // Ajouter les étoiles turquoise néon
                float3 starCol = _StarColor.rgb * star * _StarIntensity;

                col += starCol;

                // Nuages stylisés en traînées
                float cloudMask = ComputeCloud(dir);

                if (cloudMask > 0.0)
                {
                    float3 cloudCol = _CloudColor.rgb;
                    // on ajoute les nuages par dessus le ciel
                    col = lerp(col, col + cloudCol, cloudMask * _CloudIntensity);
                }

                // Aurore boréale
                float3 auroraCol = ComputeAurora(dir);
                col += auroraCol;   // addition, comme une lumière

                return float4(col, 1.0);
            }
            ENDCG
        }
    }

    Fallback Off
}