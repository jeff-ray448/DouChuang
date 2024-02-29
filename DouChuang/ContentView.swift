//
//  ContentView.swift
//  DouChuang
//
//  Created by jeffery on 2023/12/7.
//
import SwiftUI

struct User: Identifiable, Hashable {
    var id = UUID()
    var name: String
    var score: Float
}


class UserData: ObservableObject {
    @Published var users: [User] = [
        User(name: "Walter", score: 0),
        User(name: "Lee", score: 0),
        User(name: "Chu", score: 0)
    ]
}

struct ContentView: View {
    @StateObject private var userData = UserData()
    @State private var inputText: String = ""
    @State private var selectedPlayers: [User] = []
    @State private var isGameStarted: Bool = false
    @State private var alertType: AlertType?

        enum AlertType: Identifiable {
            case alertNeedmorepeople
            case alertReset

            var id: AlertType { self }
        }

    var body: some View
    {
        NavigationView
        {
            
            VStack {
                ZStack
                {
                    Text("      大床主  ")
                        .font(.system(size: 20))
                        .foregroundColor(.red)
                    +
                    Text("小床主  ")
                    .font(.system(size: 20))
                    .foregroundColor(.yellow)
                    +
                    Text("農民  ")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    +
                    Text("流浪漢       ")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
                    
                }
                .padding(14)
                .background(
                    RoundedRectangle(cornerRadius: 50)
                        .fill(Color.black)
                        .frame(height: 50)
                )
                .frame(width: 800, height: 50)
                List {
                    ForEach($userData.users) { $user in
                        HStack {
                            TextField("Player Name", text: $user.name)
                                .padding(.vertical, 0)
                                .font(.system(size: 16))
                                .onTapGesture {
                                    print("名稱編輯模式")
                                }

                            TextField("Score", text: Binding(
                                get: {
                                       let formatter = NumberFormatter()
                                       formatter.minimumFractionDigits = 0
                                       formatter.maximumFractionDigits = 1
                                       return formatter.string(from: NSNumber(value: user.score)) ?? ""
                                   },
                                   set: { newValue in
                                       user.score = Float(newValue) ?? 0
                                   }
                            ))
                            .font(.system(size: 16))
                            .padding(.vertical, 0)
                        }
                        .background(
                            user.score >= 3 && user.score < 6 ? Color.yellow :
                            user.score >= 6 ? Color.red :
                                user.score <= -3 && user.score > -6 ? Color.blue :
                                user.score <= -6 ? Color.gray :
                                Color.clear
                        )
                    }
                    .onDelete { indexSet in
                            // Delete the player at the specified index
                            userData.users.remove(atOffsets: indexSet)
                    }
                }
                if let highestScore = userData.users.map({ $0.score }).max() {
                    let playersWithHighestScore = userData.users.filter { $0.score == highestScore }

                    if highestScore != 0 {
                        if highestScore >= 3 {
                            Text("目前的大床主: \(playersWithHighestScore.map { $0.name }.joined(separator: ", ")) 持有 \(String(format: "%.1f", highestScore)) 分")
                                .padding()
                                .font(.system(size: 18))
                        } else {
                            Text("目前最高分: \(playersWithHighestScore.map { $0.name }.joined(separator: ", ")) 持有 \(String(format: "%.1f", highestScore)) 分")
                                .padding()
                                .font(.system(size: 18))
                            Text("還沒有人搶到大床")
                        }
                    }
                }
                VStack {

                          
                       }
                    .alert(item: $alertType) { type in
                            switch type {
                            case .alertNeedmorepeople:
                                return Alert(
                                    title: Text("需要更多人"),
                                    message: Text("\n請邀請更多人加入!"),
                                    dismissButton: .default(Text("好的"))
                                    {
                                    // 当用户点击 "好的" 按钮时执行的代码
                                    // 可以在这里重置 needMorePeople 的值
                                    }
                                )
                            case .alertReset:
                                return Alert(
                                    title: Text("確定重設分數?"),
                                    primaryButton: .default(Text("是"))
                                    {
                                    // 处理是的情况
                                        print("是")
                                        for index in userData.users.indices {
                                            userData.users[index].score = 0
                                        }
                                    },
                                    secondaryButton: .cancel(Text("取消"))
                                    {
                                    // 处理取消的情况
                                        print("取消")
                                    }
                                )
                            }
                        }
//                       .alert(isPresented: $alert1)
//                        {
//                            Alert
//                            (
//                                title: Text("需要更多人"),
//                                message: Text("請邀請更多人加入!"),
//                                dismissButton: .default(Text("好的")) {
//                                    // 当用户点击 "好的" 按钮时执行的代码
//                                    // 可以在这里重置 needMorePeople 的值
//                                    alert1 = false
//                                }
//                            )
//                        }
//                        .alert(isPresented: $alert2)
//                        {
//                            Alert(
//                                            title: Text("確定重設分數?"),
//                                            primaryButton: .default(Text("是")) {
//                                                // 处理是的情况
//                                                print("是")
//                                            },
//                                            secondaryButton: .cancel(Text("取消")) {
//                                                // 处理取消的情况
//                                                print("取消")
//                                            }
//                                        )
//                        }
                HStack
                {
                    Button(action: {
                        // 選擇三個隨機玩家進入遊戲
                        selectedPlayers = Array(userData.users.shuffled().prefix(3))
                        if(selectedPlayers.count < 3 )
                        {
                            alertType = .alertNeedmorepeople
                        }else {
                            isGameStarted = true
                        }
                    }) {
                        Text("開始遊戲")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                    
                    Button(action: {
                        // 新增一個玩家到 userData.users 中
                        userData.users.append(User(name: "New Player", score: 0))
                    }) {
                        Text("新增玩家")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    Button(action: {
                        alertType = .alertReset
                    }) {
                        Text("重設分數")
                            .font(.headline)
                            .padding()
                            .foregroundColor(.red)
                        
                    }
                }
                
                if isGameStarted {
                    NavigationLink(
                        destination: GamePage(userData: userData, inputText: $inputText, selectedPlayers: selectedPlayers),
                        isActive: $isGameStarted
                    ) {
                        EmptyView()
                    }
                }
            }
            .navigationTitle("首頁")
        }
    }
}


struct GamePage: View {
    @Environment(\.presentationMode) var presentationMode
    @ObservedObject var userData: UserData
    @Binding var inputText: String
    var selectedPlayers: [User]
    @State private var selectedPlayerIndex: Int?
    @State private var landlord: User? = nil
    @State private var bidAmount: Float = 0
    @State private var isGameFinished: Bool = false
    var body: some View {
        VStack {
            Text("準備好鬥大床主了嗎?")
                .font(.system(size: 24))
                .padding()

            List {
                ForEach(selectedPlayers, id: \.id) { player in
                    HStack {
                        Text(player.name)
                            .padding(.vertical, 0)
                            .font(.system(size: 18))
                        Text("擁有")
                            .font(.system(size: 18))
                            .padding(.vertical, 0)
                        
                        Text("\(String(format:  "%.1f", player.score))分")
                            .font(.system(size: 18))
                            .padding(.vertical, 0)
                            .multilineTextAlignment(.trailing)
                    }
                    
                }
                
            }
            .frame(height: 200)

            if landlord == nil {
                            // 如果地主還未確定，顯示叫分界面
                VStack {
                    
                    Text("選擇地主並叫分")
                        .font(.system(size: 20))
                        .padding()
                        .frame(height: 30)
                        Form {
                            Picker(selection: $selectedPlayerIndex) {
                                Text("未選擇").tag(nil as Int?)
                                ForEach(selectedPlayers.indices, id: \.self) { index in
                                    Text(selectedPlayers[index].name).tag(index as Int?)
                            }
                            
                        } label:  {
                            Text("地主")
                        
                        }
                       // .pickerStyle(WheelPickerStyle())
                        .onChange(of: selectedPlayerIndex) { newIndex in
                        // 在這裡處理地主選擇的邏輯
                        print("選擇了地主: \(selectedPlayers[newIndex ?? 0].name)")
                    }
                }
                                
                            

                                TextField("請輸入叫的分數", text: $inputText)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .keyboardType(.numberPad)
                                    .foregroundColor(.red)
                                    .toolbar {
                                            ToolbarItem(placement: .keyboard) {
                                                Button(action: {
                                                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                                                }) {
                                                    Text("                                                         Done")
                                                    .foregroundColor(.blue)
                                                }
                                                
                                                
                                            }
                                    }
                                    
                                    

                                Button(action: {
                                    // 叫分按鈕被點擊時的動作
                                    if let selectedLandlordIndex = selectedPlayerIndex {
                                        let selectedLandlord = selectedPlayers[selectedLandlordIndex]
                                        bidAmount = Float(inputText) ?? 0
                                        print("\(selectedLandlord) called \(inputText)")
                                        landlord = selectedLandlord
                                        // 進行相應的叫分處理
                                                                }
                                }) {
                                    Text("叫分")
                                        .font(.headline)
                                        .padding()
                                        .foregroundColor(.white)
                                        .background(Color.blue)
                                        .cornerRadius(10)
                                    
                                }
                                
                                
                            }
            } else {
                HStack
                {
                    
                    
                    VStack
                    {
                        Button(action: {
                            if let selectedLandlordIndex = selectedPlayerIndex {
                                let selectedLandlord = selectedPlayers[selectedLandlordIndex]
                                
                                for user in selectedPlayers
                                {
                                    if user.id == selectedLandlord.id
                                    {
                                        if let userIndexInUserData = userData.users.firstIndex(where: { $0.id == user.id })
                                        {
                                            userData.users[userIndexInUserData].score += bidAmount
                                        }
                                    } else {
                                        if let userIndexInUserData = userData.users.firstIndex(where: { $0.id == user.id })
                                        {
                                            userData.users[userIndexInUserData].score -= bidAmount / 2
                                        }
                                    }
                                }
                                
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("贏")
                                .font(.system(size: 60))
                                .padding(23)
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        
                        Button(action:
                        {
                            print(selectedPlayers)
                            if let selectedLandlordIndex = selectedPlayerIndex
                            {
                                let selectedLandlord = selectedPlayers[selectedLandlordIndex]
                                
                                for (index, user) in selectedPlayers.enumerated()
                                {
                                    if user.id == selectedLandlord.id
                                    {
                                        if let userIndexInUserData = userData.users.firstIndex(where: { $0.id == user.id })
                                        {
                                            userData.users[userIndexInUserData].score -= bidAmount
                                        }
                                    } else {
                                        if let userIndexInUserData = userData.users.firstIndex(where: { $0.id == user.id })
                                        {
                                            userData.users[userIndexInUserData].score += bidAmount / 2
                                        }
                                    }
                                }
                                
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }) {
                            Text("輸")
                                .font(.system(size: 60))
                                .padding(23)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                        
                        
                    }
                    
                    VStack
                    {
                        Button(action: {
                            bidAmount *= 2
                        }) {
                            Text("X2")
                                .font(.headline)
                                .padding(20)
                                .foregroundColor(.white)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            bidAmount *= 3
                        }) {
                            Text("X3")
                                .font(.headline)
                                .padding(20)
                                .foregroundColor(.white)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                        Button(action: {
                            bidAmount *= 5
                        }) {
                            Text("X5")
                                .font(.headline)
                                .padding(20)
                                .foregroundColor(.white)
                                .background(Color.cyan)
                                .cornerRadius(10)
                        }
                        Spacer()
                            .frame(height: 8)
                    }
                    
                    
                }
                VStack
                {
                    Text("\(landlord?.name ?? "") 已經叫了\(String (format: "%1.f", bidAmount))分")
                        .font(.headline)
                        .padding()
                }
                
                
            }
            
        }
      //  .navigationTitle("遊戲頁面")
        .onAppear {
            // 在這裡添加遊戲頁面出現後的相應操作
            print("GamePage appeared")
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}








