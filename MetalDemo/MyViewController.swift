//
//  MyViewController.swift
//  MetalDemo
//
//  Created by VislaNiap on 2021/3/26.
//

import UIKit
import MetalKit

enum Colors {
    static let wenderlichGreen = MTLClearColor(red:0.0,green: 0.4,blue: 0.21,alpha: 1.0)
}

struct Vertex {
    var position:float3
    var color:float4
}

class MyViewController:UIViewController,MTKViewDelegate{
    var vetices : [Vertex] = [
        Vertex(position: float3(-1,1,0), color: float4(1,0,0,1)),
        Vertex(position: float3(-1,-1,0), color: float4(0,1,0,1)),
        Vertex(position: float3(1,-1,0), color: float4(0,0,1,1)),
        Vertex(position: float3(1,1,0), color: float4(1,0,1,1))
    ]
    var indices:[UInt16] = [
        0,1,2,
        2,3,0
    ]
    var metalView:MTKView{
        return view as! MTKView
    }
    var device:MTLDevice!
    var commandQueue:MTLCommandQueue!
    var vetextBuffer:MTLBuffer!
    var indexBuffer:MTLBuffer!
    var piplineState:MTLRenderPipelineState!
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = MTLCreateSystemDefaultDevice()// 创建设备
        device = metalView.device //设置到controller的成员变量中
        metalView.clearColor = Colors.wenderlichGreen //设置背景颜色
        commandQueue = device.makeCommandQueue() //为gpu准备指令队列
        vetextBuffer = device.makeBuffer(bytes: vetices, length: vetices.count * MemoryLayout<Vertex>.stride, options: []) //定点存储的位置
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count * MemoryLayout<UInt16>.size, options: []) //定点存储的位置
        let library = device.makeDefaultLibrary()//框架会自动找到项目中的Metal文件
        let vertex_shader = library?.makeFunction(name: "vertex_shader")//编译vertex_shader函数
        let fragment_shader = library?.makeFunction(name: "fragment_shader")//编译fragment_shader函数
        let piplineDescriptor = MTLRenderPipelineDescriptor();//生成piplinDescriptor
        piplineDescriptor.vertexFunction = vertex_shader //设置vertex_shader函数
        piplineDescriptor.fragmentFunction = fragment_shader//设置fragment_shader函数
        piplineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm //设置颜色格式，这个应该是固定写法
        let vertexDescriptor = MTLVertexDescriptor();
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0;
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0;
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        piplineDescriptor.vertexDescriptor = vertexDescriptor
        do {
            piplineState = try device.makeRenderPipelineState(descriptor: piplineDescriptor)//通过piplineDescript生成piplineState
        } catch let error as NSError {
            print("error \(error.localizedDescription)")
        }
        metalView.delegate = self
    }
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    func draw(in view: MTKView) {
        guard let pState = piplineState else {
            return
        }
        let commandBuffer = commandQueue.makeCommandBuffer() //为指令队列设置缓冲区
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: metalView.currentRenderPassDescriptor!) //为缓冲区创建一个编码器
        commandEncoder?.setRenderPipelineState(pState);
        commandEncoder?.setVertexBuffer(vetextBuffer, offset: 0, index: 0)
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder?.endEncoding()//停止编码
        commandBuffer?.present(metalView.currentDrawable as! MTLDrawable) //绘制图像
        commandBuffer?.commit() //提交给gpu
    }
}
