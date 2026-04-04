vec4 Process(vec4 color)
{
    vec3 lightDir = normalize(vec3(0.5, 0.5, 1.0));
    float diffuse = dot(normalize(vWorldNormal.xyz), lightDir);
    float brightness = 0.4 + 0.5 * diffuse;
    return vec4(color.rgb * brightness, color.a);
}