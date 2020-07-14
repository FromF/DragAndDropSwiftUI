//
//  ContentView.swift
//  DragAndDrop
//
//  Created by 藤 治仁 on 2020/07/14.
//

import SwiftUI
import MobileCoreServices

struct ContentView: View {
    
    var body: some View {
        
        NavigationView {
            DragAndDropView()
                .navigationTitle("Drag Images")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct DragAndDropView: View {
    
    var columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
    @ObservedObject var delegate = ImageData()
    
    var body: some View {
        VStack(spacing: 15.0) {
            
            DragView()
            
            DropView()
        } //VStackはここまで
        .background(Color.black.opacity(0.05))
        .edgesIgnoringSafeArea(.bottom)
    }
}

struct DragView: View {
    var columns = Array(repeating: GridItem(.flexible(), spacing: 15), count: 2)
    @ObservedObject var delegate = ImageData()
    
    var body: some View {
        // すべての画像を表示するエリア
        ScrollView {
            LazyVGrid(columns: columns, alignment: .center, spacing: 20) {
                ForEach(delegate.totalImages) {image in
                    Image(image.image)
                        .resizable()
                        .frame(height: 150)
                        .cornerRadius(15)
                        // ドラッグしたときに実行される
                        .onDrag {
                            // ここで選択画像の情報を送信する
                            // URLを画像名とする
                            NSItemProvider(item: .some(URL(string: image.image)! as NSSecureCoding), typeIdentifier: String(kUTTypeURL))
                        } // .onDragはここまで
                } // ForEachはここまで
            } // LazyVGridはここまで
            .padding(.all, 10)
        } // ScrollViewはここまで
    }
}

struct DropView: View {
    @ObservedObject var delegate = ImageData()
    
    var body: some View {
        // ドラッグ＆ドロップしたエリア
        ZStack {
            if delegate.selectImages.isEmpty {
                Text("ここにドラッグ＆ドロップ")
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    
                    ForEach(delegate.selectImages, id: \.image) {image in
                        if image.image != "" {
                            ZStack(alignment: Alignment(horizontal: .trailing, vertical: .top), content: {
                                Image(image.image)
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .cornerRadius(15)
                                
                                //削除ボタン
                                Button(action: {
                                    // アニメーションを追加する
                                    withAnimation(.easeOut) {
                                        // 選択された画像を削除する
                                        self.delegate.selectImages.removeAll { (check) -> Bool in
                                            if check.image == image.image {
                                                return true
                                            } else {
                                                return false
                                            }
                                        }

                                    }
                                }) {
                                    Image(systemName: "xmark")
                                        .foregroundColor(.white)
                                        .padding(.all, 10)
                                        .background(Color.black)
                                        .clipShape(Circle())
                                }

                            }) // ZStackはここまで
                        } // if文はここまで
                    } // ForEachはここまで
                    
                    Spacer(minLength: 0)
                } //HStackはここまで
            } // ScrollViewはここまで
            .padding(.horizontal, 10)
        } // ZStackはここまで
        .padding(.bottom, UIApplication.shared.windows.first?.safeAreaInsets.bottom)
        .padding(.top, 10)
        // 画像がない場合は高さ０にして隠す
        .frame(height: delegate.selectImages.isEmpty ? 100 : nil)
        // ドラッグ＆ドロップを登録する
        .contentShape(Rectangle())
        .background(Color.white)
        // ドロップした情報を受け取る
        // .onDrag内と同じにする
        .onDrop(of: [String(kUTTypeURL)], delegate: delegate)
    }
}

struct ImageAsset: Identifiable {
    var id :Int
    var image : String
}


class ImageData : ObservableObject , DropDelegate{
    @Published var totalImages :[ImageAsset] = [
        ImageAsset(id: 0, image: "image01"),
        ImageAsset(id: 1, image: "image02"),
        ImageAsset(id: 2, image: "image03"),
        ImageAsset(id: 3, image: "image04"),
        ImageAsset(id: 4, image: "image05"),
        ImageAsset(id: 5, image: "image06"),
        ImageAsset(id: 6, image: "image07"),
        ImageAsset(id: 7, image: "image08"),
        ImageAsset(id: 8, image: "image09"),
        ImageAsset(id: 9, image: "image10"),
        ImageAsset(id: 10, image: "image11"),
        ImageAsset(id: 11, image: "image12"),
        ImageAsset(id: 12, image: "image13"),
        ImageAsset(id: 13, image: "image14"),
        ImageAsset(id: 14, image: "image15"),
        ImageAsset(id: 15, image: "image16"),
        ImageAsset(id: 16, image: "image17"),
        ImageAsset(id: 17, image: "image18"),
        ImageAsset(id: 18, image: "image19"),
    ]
    
    @Published var selectImages :[ImageAsset] = []
    
    // ドロップしたときに実行される
    func performDrop(info: DropInfo) -> Bool {
        // ここでドラッグした時の情報を選択画像として扱う
        for provider in info.itemProviders(for: [String(kUTTypeURL)]) {
            // 情報がURLなのかチェックする
            if provider.canLoadObject(ofClass: URL.self) {
                let _ = provider.loadObject(ofClass: URL.self) { (url, error) in
                    let imageName = "\(url!)"
                    print(imageName)
                    
                    //すでに選択画像だったら選択画像に登録しない
                    let status = self.selectImages.contains { (check) -> Bool in
                        if check.image == imageName {
                            // 一致する
                            return true
                        } else {
                            // 一致しない
                            return false
                        }
                    }
                    if !status {
                        // アニメーション効果を追加する
                        DispatchQueue.main.async {
                            withAnimation(.easeOut) {
                                //選択画像に追加する
                                self.selectImages.append(ImageAsset(id: self.selectImages.count, image: imageName))
                            }
                        }
                    }
                }
            } else {
                print("URLがロードできない")
            }
        }
        
        return true
    }
}
