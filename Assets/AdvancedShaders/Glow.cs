using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Glow : MonoBehaviour {
    public Material copyMat;
    public Material blurHorzMat;
    public Material blurVertMat;
    public Material brightPassMat;
    public Material addMat;

    public RenderTexture bright;
    public RenderTexture scaled1;
    public RenderTexture scaled2;
    public RenderTexture gausian1;
    public RenderTexture gausian2;

    // the glow post process effect is a nice example of how multiple post process effect shaders can work together.
    // the first we apply a bright pass filter to filter out the brightest parts of the rendered scene (to these area's we apply our glow effect)
    // in the second phase we blur the result of the bright pass filter to produce the glow effect of a black background
    // in the last phase we add the glow to the original frame
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        // if the source size changes, recreate the render targets
        if ((bright == null) || (bright.height != source.height) || (bright.width != source.width))
        {
            bright = new RenderTexture(source.width, source.height, 0);
            scaled1 = new RenderTexture(source.width / 2, source.height / 2, 0);
            scaled2 = new RenderTexture(source.width / 4, source.height / 4, 0);
            gausian1 = new RenderTexture(source.width / 4, source.height / 4, 0);
            gausian2 = new RenderTexture(source.width / 4, source.height / 4, 0);
        }

        // 1. bright pass, a single shader effect
        Graphics.Blit(source, bright, brightPassMat);

        // 2. the blur shader consists of a number of down sampled textures, the bilinear texture filtering will make sure the colors are mixed if the resulting texture is half the size
        // this is effectively a box filter taking the average pixel color from 4 texels (pixels). and reduces the size for our final gausian blur
        // we apply the blur filter effect in two stages to reduce the computational cost
        Graphics.Blit(bright, scaled1, copyMat);
        Graphics.Blit(scaled1, scaled2, copyMat);
        Graphics.Blit(scaled2, gausian1, blurHorzMat);
        Graphics.Blit(gausian1, gausian2, blurVertMat);
        // repeat for better results
        //Graphics.Blit(gausian2, gausian1, blurHorzMat);
        //Graphics.Blit(gausian1, gausian2, blurVertMat);

        // 3. add the result to the original
        addMat.SetTexture("OtherTex", gausian2);
        Graphics.Blit(source, destination, addMat);
    }
}
