void main()
{
    float stretchFactor = 0.82;
    float stretchedX = clamp((TexCoord.x - 0.5) * stretchFactor + 0.5, 0.0, 1.0);
    vec2 stretchedTexCoord = vec2(stretchedX, TexCoord.y);
    vec4 src = texture(InputTexture, stretchedTexCoord);
    FragColor = src;
}
