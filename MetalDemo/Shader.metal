//
//  Shader.metal
//  MetalDemo
//
//  Created by VislaNiap on 2021/3/29.
//

#include <metal_stdlib>
using namespace metal;

struct Constants{
    float animate_by;
};

vertex float4 vertex_shader(const device packed_float3 *vertices [[buffer(0)]] ,
                            constant Constants &constants [[buffer(1)]],
                            uint vertexId [[vertex_id]] ){
    float4 pos = float4(vertices[vertexId],1);
    pos.x += constants.animate_by;
    return pos;
}

fragment half4 fragment_shader(){
    return half4(1,0,0,1);
}
