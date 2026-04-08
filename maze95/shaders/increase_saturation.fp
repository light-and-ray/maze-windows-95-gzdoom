void main()
{
    float saturationFactor = 1.20;
    vec4 src = texture(InputTexture, TexCoord);
    vec3 color = src.rgb;
    float luminance = dot(color, vec3(0.2126, 0.7152, 0.0722));
    vec3 gray = vec3(luminance);
    vec3 saturatedColor = mix(gray, color, saturationFactor);
    FragColor = vec4(saturatedColor, src.a);
}
