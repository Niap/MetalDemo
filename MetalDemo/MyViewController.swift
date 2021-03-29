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

class MyViewController:UIViewController,MTKViewDelegate{
    var vetices : [Float] = [
        0,0,0,
        -1,-1,0,
        1,-1,0
    ]
    var metalView:MTKView{
        return view as! MTKView
    }
    var device:MTLDevice!
    var commandQueue:MTLCommandQueue!
    var vetextBuffer:MTLBuffer!
    var piplineState:MTLRenderPipelineState!
    override func viewDidLoad() {
        super.viewDidLoad()
        metalView.device = MTLCreateSystemDefaultDevice()// 创建设备
        device = metalView.device //设置到controller的成员变量中
        metalView.clearColor = Colors.wenderlichGreen //设置背景颜色
        commandQueue = device.makeCommandQueue() //为gpu准备指令队列
        vetextBuffer = device.makeBuffer(bytes: vetices, length: vetices.count * MemoryLayout<Float>.size, options: [])
        let library = device.makeDefaultLibrary()
        let vertex_shader = library?.makeFunction(name: "vertex_shader")
        let fragment_shader = library?.makeFunction(name: "fragment_shader")
        let piplineDescriptor = MTLRenderPipelineDescriptor();
        piplineDescriptor.vertexFunction = vertex_shader
        piplineDescriptor.fragmentFunction = fragment_shader
        piplineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        do {
            piplineState = try device.makeRenderPipelineState(descriptor: piplineDescriptor)
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
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vetices.count)
        commandEncoder?.endEncoding()//停止编码
        commandBuffer?.present(metalView.currentDrawable as! MTLDrawable) //绘制图像
        commandBuffer?.commit() //提交给gpu
    }
}
