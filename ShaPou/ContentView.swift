//
//  ContentView.swift
//  ShaPou
//
//  Created by Tihon Shkel on 12.11.25.
//

import SwiftUI
import UIKit
import AVFoundation

// Менеджер для воспроизведения музыки (синглтон)
class MusicManager {
    static let shared = MusicManager()
    
    private var audioPlayer: AVAudioPlayer?
    private var isAudioSessionConfigured = false
    
    private init() {
        configureAudioSession()
    }
    
    private func configureAudioSession() {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try audioSession.setActive(true)
            isAudioSessionConfigured = true
            print("Аудиосессия настроена успешно")
        } catch {
            print("Ошибка настройки аудиосессии: \(error.localizedDescription)")
        }
    }
    
    func playMusic(fileName: String, fileExtension: String = "mp3") {
        // Если музыка уже играет, не запускаем снова
        if audioPlayer != nil && audioPlayer?.isPlaying == true {
            print("Музыка уже играет")
            return
        }
        
        // Настраиваем аудиосессию, если еще не настроена
        if !isAudioSessionConfigured {
            configureAudioSession()
        }
        
        // Пробуем разные пути к файлу
        var url: URL?
        
        // Попытка 1: Стандартный путь через Bundle
        url = Bundle.main.url(forResource: fileName, withExtension: fileExtension)
        
        // Попытка 2: Путь с учетом папки Sounds
        if url == nil {
            url = Bundle.main.url(forResource: "Sounds/\(fileName)", withExtension: fileExtension)
        }
        
        // Попытка 3: Прямой путь к файлу
        if url == nil {
            let filePath = Bundle.main.path(forResource: fileName, ofType: fileExtension)
            if let filePath = filePath {
                url = URL(fileURLWithPath: filePath)
            }
        }
        
        guard let musicURL = url else {
            print("❌ Не удалось найти файл музыки: \(fileName).\(fileExtension)")
            print("Проверьте, что файл добавлен в проект Xcode и включен в Target")
            return
        }
        
        print("✅ Файл музыки найден: \(musicURL.path)")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: musicURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.numberOfLoops = -1 // Бесконечное повторение
            audioPlayer?.volume = 0.5 // Громкость 50%
            
            let played = audioPlayer?.play() ?? false
            if played {
                print("✅ Музыка начала воспроизведение")
            } else {
                print("❌ Не удалось начать воспроизведение музыки")
            }
        } catch {
            print("❌ Ошибка воспроизведения музыки: \(error.localizedDescription)")
        }
    }
    
    func stopMusic() {
        audioPlayer?.stop()
        audioPlayer = nil
    }
    
    func setVolume(_ volume: Float) {
        audioPlayer?.volume = volume
    }
    
    func isPlaying() -> Bool {
        return audioPlayer?.isPlaying ?? false
    }
}

struct ContentView: View {
    @State private var showGame = false
    
    var body: some View {
        if showGame {
            GameView(showGame: $showGame)
        } else {
            MainMenuView(showGame: $showGame)
        }
    }
}

struct MainMenuView: View {
    @Binding var showGame: Bool
    
    var body: some View {
        ZStack {
            // Фоновое изображение
            Image("main-game")
                .resizable()
                .scaledToFill()
                .frame(width: UIScreen.main.bounds.width)
                .frame(height: UIScreen.main.bounds.height)
                .clipped()
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Spacer()
                
                // Кнопки меню
                VStack(spacing: 20) {
                    MenuButton(
                        title: "Играть",
                        icon: "play.fill",
                        action: {
                            // Переключение на экран игры
                            withAnimation {
                                showGame = true
                            }
                        }
                    )
                    
                    MenuButton(
                        title: "Настройки",
                        icon: "gearshape.fill",
                        action: {
                            // Действие для кнопки "Настройки"
                            print("Настройки нажата")
                        }
                    )
                    
                    MenuButton(
                        title: "Выход",
                        icon: "xmark.circle.fill",
                        action: {
                            // Действие для кнопки "Выход"
                            exit(0)
                        }
                    )
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            MusicManager.shared.playMusic(fileName: "music-game", fileExtension: "mp3")
        }
    }
}

struct MenuButton: View {
    let title: String
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Анимация нажатия
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action() 
            }
        }) {
            ZStack {
                // Изображение кнопки
                if let uiImage = UIImage(named: "button") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                        .clipped()
                } else {
                    // Fallback цвет, если изображение не найдено
                    Color.orange
                        .frame(maxWidth: .infinity)
                        .frame(height: 80)
                }
                
                // Контент кнопки
                HStack(spacing: 15) {
                    Image(systemName: icon)
                        .font(.system(size: 24, weight: .semibold))
                    
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                }
                .foregroundColor(Color(red: 0.4, green: 0.25, blue: 0.15)) // Более темный коричневый
            }
            .frame(maxWidth: .infinity)
            .frame(height: 80)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// Типы одежды
enum ClothingType {
    case hat
    case glasses
}

struct GameView: View {
    @Binding var showGame: Bool
    @State private var currentRoomIndex = 0
    @State private var isOutside = false // Флаг для отслеживания, находимся ли на улице
    @State private var showFeedingGame = false // Флаг для показа мини-игры кормления
    @State private var showWashingGame = false // Флаг для показа мини-игры мытья
    @State private var showNotHungryDialog = false // Флаг для показа диалога "не голоден"
    @State private var showWashDialog = false // Флаг для показа диалога "я чистый"
    @State private var showWearingInterface = false // Флаг для показа интерфейса выбора одежды
    @State private var selectedClothing: ClothingType? = nil // Выбранная одежда
    
    // Значения прогресс-баров (0.0 - 1.0) - начинаем с максимума
    @State private var emotionValue: Double = 1.0
    @State private var hungerValue: Double = 1.0
    @State private var washingValue: Double = 1.0
    
    // Таймер для уменьшения значений
    @State private var gameTimer: Timer?
    
    // Анимация перекатывания
    @State private var isRolling = false
    @State private var rollDirection: CGFloat = 1.0 // 1.0 для вправо, -1.0 для влево
    
    // Скорость уменьшения значений (в секундах)
    private let decreaseRate: Double = 0.01 // Уменьшение на 1% каждую секунду
    private let timerInterval: TimeInterval = 1.0 // Обновление каждую секунду
    
    // Список комнат: главная (0), кухня (1), ванная (2), гардероб (3)
    private let rooms = ["background-game", "kitchen-game", "bathroom-game", "wear-game"]
    
    // Проверка, можно ли перейти влево
    private var canGoLeft: Bool {
        if currentRoomIndex == 0 { // Из главной можно влево в ванную
            return true
        } else if currentRoomIndex == 1 { // Из кухни можно влево в главную
            return true
        } else if currentRoomIndex == 2 { // Из ванной можно влево в гардероб
            return true
        } else if currentRoomIndex == 3 { // Из гардероба нельзя влево
            return false
        }
        return false
    }
    
    // Проверка, можно ли перейти вправо
    private var canGoRight: Bool {
        if currentRoomIndex == 0 { // Из главной можно вправо в кухню
            return true
        } else if currentRoomIndex == 1 { // Из кухни нельзя вправо
            return false
        } else if currentRoomIndex == 2 { // Из ванной можно вправо в главную
            return true
        } else if currentRoomIndex == 3 { // Из гардероба можно вправо в ванную
            return true
        }
        return false
    }
    
    // Получить индекс следующей комнаты влево
    private func getLeftRoomIndex() -> Int? {
        if currentRoomIndex == 0 { // Из главной влево -> ванная (2)
            return 2
        } else if currentRoomIndex == 1 { // Из кухни влево -> главная (0)
            return 0
        } else if currentRoomIndex == 2 { // Из ванной влево -> гардероб (3)
            return 3
        }
        return nil
    }
    
    // Получить индекс следующей комнаты вправо
    private func getRightRoomIndex() -> Int? {
        if currentRoomIndex == 0 { // Из главной вправо -> кухня (1)
            return 1
        } else if currentRoomIndex == 2 { // Из ванной вправо -> главная (0)
            return 0
        } else if currentRoomIndex == 3 { // Из гардероба вправо -> ванная (2)
            return 2
        }
        return nil
    }
    
    var body: some View {
        ZStack {
            if showFeedingGame {
                FeedingGameView(
                    showFeedingGame: $showFeedingGame,
                    hungerValue: $hungerValue,
                    emotionValue: $emotionValue
                )
            } else if showWashingGame {
                WashingGameView(
                    showWashingGame: $showWashingGame,
                    washingValue: $washingValue
                )
            } else {
                gameContentView
            }
            
            // Диалоги показываются поверх игрового экрана
            if showNotHungryDialog {
                NotHungryDialogView(showDialog: $showNotHungryDialog)
                    .transition(.opacity)
            }
            
            if showWashDialog {
                WashDialogView(showDialog: $showWashDialog)
                    .transition(.opacity)
            }
        }
    }
    
    private var gameContentView: some View {
        ZStack {
            // Фоновое изображение - улица или текущая комната
            if isOutside {
                // Фон улицы
                if let uiImage = UIImage(named: "outside-game") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    Color.green.opacity(0.3)
                        .ignoresSafeArea()
                }
            } else {
                // Фон текущей комнаты
                if let uiImage = UIImage(named: rooms[currentRoomIndex]) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: UIScreen.main.bounds.width)
                        .frame(height: UIScreen.main.bounds.height)
                        .clipped()
                        .ignoresSafeArea()
                } else {
                    Color.blue.opacity(0.3)
                        .ignoresSafeArea()
                }
            }
            
            VStack(spacing: 0) {
                // Верхняя панель с иконками и прогресс-барами
                HStack(spacing: 20) {
                    StatBar(
                        iconName: "icon-emotion",
                        value: emotionValue,
                        color: Color(red: 1.0, green: 0.6, blue: 0.2) // Оранжевый для эмоций
                    )
                    
                    StatBar(
                        iconName: "icon-hunger",
                        value: hungerValue,
                        color: Color(red: 0.8, green: 0.3, blue: 0.2) // Красно-коричневый для голода
                    )
                    
                    StatBar(
                        iconName: "icon-washing",
                        value: washingValue,
                        color: Color(red: 0.2, green: 0.6, blue: 0.9) // Голубой для чистоты
                    )
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Персонаж (меняется в зависимости от параметров) - показывается везде
                ZStack {
                    Group {
                        let minValue = min(emotionValue, hungerValue, washingValue)
                        let hasZero = emotionValue == 0 || hungerValue == 0 || washingValue == 0
                        
                        if hasZero {
                            // Злой персонаж - когда хотя бы один параметр на нуле
                            Image("angry-shapou")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.bottom, 20)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        } else if minValue <= 0.5 {
                            // Грустный персонаж - когда параметры ухудшились
                            Image("sad-shapou")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.bottom, 20)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        } else {
                            // Нормальный персонаж - когда все параметры в норме
                            Image("normal-shapou")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 300, height: 300)
                                .padding(.bottom, 20)
                                .transition(.scale(scale: 0.8).combined(with: .opacity))
                        }
                    }
                    .rotationEffect(.degrees(isRolling && !isOutside ? rollDirection * 360 : 0))
                    .offset(x: isRolling && !isOutside ? rollDirection * UIScreen.main.bounds.width * 0.3 : 0)
                    .scaleEffect(isRolling && !isOutside ? 0.8 : 1.0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: emotionValue)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: hungerValue)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: washingValue)
                    .animation(.easeInOut(duration: 0.6), value: isRolling)
                    .animation(.easeInOut(duration: 0.6), value: rollDirection)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: isOutside)
                    
                    // Одежда на персонаже (показывается когда выбрана, даже если интерфейс закрыт)
                    if let clothing = selectedClothing {
                        // Шляпа сверху
                        if clothing == .hat {
                            Image("hat-wear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 200, height: 200)
                                .offset(y: -120)
                                .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Очки
                        if clothing == .glasses {
                            Image("glases-wear")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 180, height: 180)
                                .offset(y: -50)
                                .transition(.scale.combined(with: .opacity))
                        }
                    }
                    
                    // Стрелки для выбора одежды (только в гардеробной и когда показывается интерфейс)
                    if currentRoomIndex == 3 && showWearingInterface {
                        // Стрелка вверх для шляпы (сверху от персонажа)
                        Button(action: {
                            withAnimation {
                                selectedClothing = .hat
                                emotionValue = min(1.0, emotionValue + 0.1)
                            }
                        }) {
                            Image(systemName: "chevron.up.circle.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.orange)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .offset(y: -180)
                        
                        // Стрелка вниз для очков (снизу от персонажа)
                        Button(action: {
                            withAnimation {
                                selectedClothing = .glasses
                                emotionValue = min(1.0, emotionValue + 0.1)
                            }
                        }) {
                            Image(systemName: "chevron.down.circle.fill")
                                .font(.system(size: 50, weight: .bold))
                                .foregroundColor(.orange)
                                .background(Color.white.opacity(0.8))
                                .clipShape(Circle())
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                        }
                        .offset(y: 180)
                    }
                }
                
                // Кнопки переключения комнат и действий
                if isOutside {
                    // На улице - показываем только кнопку "Назад"
                    HStack {
                        Spacer()
                        
                        ActionButton(
                            imageName: "back-button",
                            action: {
                                // Возврат в главную комнату
                                withAnimation {
                                    isOutside = false
                                    currentRoomIndex = 0
                                }
                                print("Назад нажата")
                            }
                        )
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                } else {
                    // В комнатах - показываем кнопки переключения и действий
                    HStack(spacing: 15) {
                        // Кнопка "Назад" (влево) - показывается только если можно перейти влево
                        if canGoLeft {
                            Button(action: {
                                rollDirection = -1.0 // Перекатывание влево
                                isRolling = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        if let leftIndex = getLeftRoomIndex() {
                                            currentRoomIndex = leftIndex
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    isRolling = false
                                }
                            }) {
                                if let uiImage = UIImage(named: "left-button") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                } else {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.brown)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        } else {
                            // Пустое место, если стрелка не показывается
                            Color.clear
                                .frame(width: 60, height: 60)
                        }
                        
                        // Кнопки действий в зависимости от комнаты
                        Group {
                            // В ванной комнате - кнопка "Мыть"
                            if currentRoomIndex == 2 { // bathroom-game
                                ActionButton(
                                    imageName: "wash-button",
                                    action: {
                                        // Проверяем уровень чистоты
                                        if washingValue > 0.5 {
                                            // Если чистота больше половины - показываем диалог
                                            withAnimation {
                                                showWashDialog = true
                                            }
                                        } else {
                                            // Если чистота меньше половины - открываем мини-игру
                                            withAnimation {
                                                showWashingGame = true
                                            }
                                        }
                                        print("Мыть нажата")
                                    }
                                )
                            }
                            
                            // В главной комнате - кнопка "На улицу"
                            if currentRoomIndex == 0 && !isOutside { // background-game
                                ActionButton(
                                    imageName: "walk-button",
                                    action: {
                                        // Переход на улицу
                                        withAnimation {
                                            isOutside = true
                                            emotionValue = min(1.0, emotionValue + 0.2)
                                        }
                                        print("На улицу нажата")
                                    }
                                )
                            }
                            
                            // На кухне - кнопка "Кормить"
                            if currentRoomIndex == 1 { // kitchen-game
                                ActionButton(
                                    imageName: "kitchen-button",
                                    action: {
                                        // Проверяем уровень голода
                                        if hungerValue > 0.5 {
                                            // Если голод больше половины - показываем диалог
                                            withAnimation {
                                                showNotHungryDialog = true
                                            }
                                        } else {
                                            // Если голод меньше половины - открываем мини-игру
                                            withAnimation {
                                                showFeedingGame = true
                                            }
                                        }
                                        print("Кормить нажата")
                                    }
                                )
                            }
                            
                            // В гардеробной - кнопка "Одевать"
                            if currentRoomIndex == 3 { // wear-game
                                ActionButton(
                                    imageName: "wear-button",
                                    action: {
                                        // Показываем интерфейс выбора одежды
                                        withAnimation {
                                            showWearingInterface.toggle()
                                            if !showWearingInterface {
                                                // Если закрываем интерфейс, увеличиваем эмоции за выбранную одежду
                                                if selectedClothing != nil {
                                                    emotionValue = min(1.0, emotionValue + 0.1)
                                                }
                                            }
                                        }
                                        print("Одевать нажата")
                                    }
                                )
                            }
                        }
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentRoomIndex)
                        
                        // Кнопка "Вперед" (вправо) - показывается только если можно перейти вправо
                        if canGoRight {
                            Button(action: {
                                rollDirection = 1.0 // Перекатывание вправо
                                isRolling = true
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                        if let rightIndex = getRightRoomIndex() {
                                            currentRoomIndex = rightIndex
                                        }
                                    }
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                                    isRolling = false
                                }
                            }) {
                                if let uiImage = UIImage(named: "right-button") {
                                    Image(uiImage: uiImage)
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60)
                                } else {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 30, weight: .bold))
                                        .foregroundColor(.brown)
                                        .frame(width: 60, height: 60)
                                }
                            }
                        } else {
                            // Пустое место, если стрелка не показывается
                            Color.clear
                                .frame(width: 60, height: 60)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .onChange(of: currentRoomIndex) { newIndex in
            // Закрываем интерфейс выбора одежды при выходе из гардеробной
            if newIndex != 3 && showWearingInterface {
                withAnimation {
                    showWearingInterface = false
                }
            }
        }
        .onAppear {
            startGameTimer()
            // Музыка продолжает играть, если еще не запущена
            MusicManager.shared.playMusic(fileName: "music-game", fileExtension: "mp3")
        }
        .onDisappear {
            stopGameTimer()
            // Музыка не останавливается при переходе между экранами
        }
    }
    
    // Запуск таймера игры
    private func startGameTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: timerInterval, repeats: true) { _ in
            // Уменьшаем значения в главном потоке, но не ниже 0.0
            DispatchQueue.main.async {
                emotionValue = max(0.0, emotionValue - decreaseRate)
                hungerValue = max(0.0, hungerValue - decreaseRate)
                washingValue = max(0.0, washingValue - decreaseRate)
            }
        }
    }
    
    // Остановка таймера игры
    private func stopGameTimer() {
        gameTimer?.invalidate()
        gameTimer = nil
    }
}

struct StatBar: View {
    let iconName: String
    let value: Double // Значение от 0.0 до 1.0
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            // Иконка с темным фоном
            ZStack {
                // Темный фон за иконкой
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.6))
                    .frame(width: 60, height: 60)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                
                // Иконка
                if let uiImage = UIImage(named: iconName) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                } else {
                    Image(systemName: "questionmark.circle")
                        .font(.system(size: 35))
                        .foregroundColor(color)
                        .frame(width: 50, height: 50)
                }
            }
            .frame(width: 60, height: 60)
            
            // Прогресс-бар
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Фон прогресс-бара
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.black.opacity(0.4))
                        .frame(height: 10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.3), lineWidth: 1)
                        )
                    
                    // Заполненная часть прогресс-бара
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color)
                        .frame(width: geometry.size.width * CGFloat(value), height: 10)
                        .shadow(color: color.opacity(0.5), radius: 3, x: 0, y: 1)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
                }
            }
            .frame(height: 10)
        }
        .frame(width: 90)
    }
}

// Мини-игра кормления
struct FeedingGameView: View {
    @Binding var showFeedingGame: Bool
    @Binding var hungerValue: Double
    @Binding var emotionValue: Double
    
    @State private var playerPosition: CGFloat = 0.5 // Позиция игрока (0.0 - 1.0)
    @State private var foods: [FallingFood] = []
    @State private var gameTimer: Timer?
    @State private var gameSpeed: Double = 1.0
    @State private var isMovingLeft = false
    @State private var isMovingRight = false
    
    private let screenWidth = UIScreen.main.bounds.width
    private let playerSize: CGFloat = 100 // Увеличено с 80 до 100
    private let moveSpeed: CGFloat = 0.02
    
    var body: some View {
        ZStack {
            // Фон мини-игры
            Image("game-kitchen")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Верхняя панель с полоской голода
                HStack {
                    Spacer()
                    
                    // Большая полоска голода
                    HStack(spacing: 15) {
                        // Иконка голода (увеличенная)
                        if let uiImage = UIImage(named: "icon-hunger") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 90, height: 90)
                                )
                        }
                        
                        // Прогресс-бар (большой)
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Фон прогресс-бара
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.4))
                                    .frame(height: 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                // Заполненная часть прогресс-бара
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.8, green: 0.3, blue: 0.2))
                                    .frame(width: geometry.size.width * CGFloat(hungerValue), height: 20)
                                    .shadow(color: Color(red: 0.8, green: 0.3, blue: 0.2).opacity(0.5), radius: 4, x: 0, y: 2)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: hungerValue)
                            }
                        }
                        .frame(height: 20)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 100)
                .padding(.bottom, 20)
                
                GeometryReader { geometry in
                    ZStack {
                        // Падающая еда
                        ForEach(foods) { food in
                            Text(food.emoji)
                                .font(.system(size: 40))
                                .position(
                                    x: food.x * geometry.size.width,
                                    y: food.y * geometry.size.height
                                )
                        }
                        
                        // Игрок (яйцо)
                        Image("normal-shapou")
                            .resizable()
                            .scaledToFit()
                            .frame(width: playerSize, height: playerSize)
                            .position(
                                x: playerPosition * geometry.size.width,
                                y: geometry.size.height - 50 // Опущено ниже (было -100)
                            )
                    }
                }
                
                // Кнопки управления
                HStack(spacing: 50) {
                    // Кнопка влево
                    Button(action: {}) {
                        if let uiImage = UIImage(named: "left-button") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        } else {
                            Image(systemName: "arrow.left")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(40)
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isMovingLeft = true
                            }
                            .onEnded { _ in
                                isMovingLeft = false
                            }
                    )
                    
                    // Кнопка вправо
                    Button(action: {}) {
                        if let uiImage = UIImage(named: "right-button") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.system(size: 40, weight: .bold))
                                .foregroundColor(.white)
                                .frame(width: 80, height: 80)
                                .background(Color.black.opacity(0.5))
                                .cornerRadius(40)
                        }
                    }
                    .simultaneousGesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { _ in
                                isMovingRight = true
                            }
                            .onEnded { _ in
                                isMovingRight = false
                            }
                    )
                }
                .padding(.bottom, 40)
            }
            
            // Кнопка закрытия
            VStack {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation {
                            showFeedingGame = false
                        }
                    }) {
                        if let uiImage = UIImage(named: "close-button") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 60, height: 60)
                        } else {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 40))
                                .foregroundColor(.white)
                                .background(Color.black.opacity(0.5))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.top, 50)
                    .padding(.trailing, 20)
                }
                Spacer()
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        // Таймер для игрового цикла (60 FPS)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Движение игрока
            if isMovingLeft {
                playerPosition = max(0.1, playerPosition - moveSpeed)
            }
            if isMovingRight {
                playerPosition = min(0.9, playerPosition + moveSpeed)
            }
            
            // Движение еды вниз
            for i in foods.indices {
                foods[i].y += 0.005 * gameSpeed
            }
            
            // Удаление еды, которая упала вниз
            foods.removeAll { $0.y > 1.0 }
            
            // Проверка столкновений
            checkCollisions()
            
            // Добавление новой еды случайным образом
            if Int.random(in: 0..<60) == 0 {
                addNewFood()
            }
        }
    }
    
    private func addNewFood() {
        // Определяем, будет ли еда хорошей (70% вероятность хорошей еды)
        let isGood = Double.random(in: 0...1) < 0.7
        
        let emoji: String
        if isGood {
            // Разные типы хорошей еды: фрукты, овощи, сладости
            let goodFoods = [
                "🍎", "🍌", "🍇", "🍊", "🍓", "🍑", "🥝", "🍉", // Фрукты
                "🥕", "🥒", "🥦", "🌽", "🍅", "🥔", "🥬", "🫑", // Овощи
                "🍰", "🍪", "🍩", "🍭", "🍬", "🧁", "🍫", "🍯"  // Сладости
            ]
            emoji = goodFoods.randomElement() ?? "🍎"
        } else {
            // Плохая еда - бомбы
            emoji = "💣"
        }
        
        let newFood = FallingFood(
            id: UUID(),
            x: Double.random(in: 0.1...0.9),
            y: 0.0,
            isGood: isGood,
            emoji: emoji
        )
        foods.append(newFood)
    }
    
    private func checkCollisions() {
        let playerX = Double(playerPosition)
        let playerY = 0.92 // Позиция игрока по Y (обновлено для нового положения)
        let collisionRadius: Double = 0.08 // Радиус столкновения
        
        var foodsToRemove: [UUID] = []
        
        for food in foods {
            let distanceX = abs(food.x - playerX)
            let distanceY = abs(food.y - playerY)
            
            // Проверка столкновения (круговая область)
            let distance = sqrt(distanceX * distanceX + distanceY * distanceY)
            
            if distance < collisionRadius {
                foodsToRemove.append(food.id)
                
                DispatchQueue.main.async {
                    if food.isGood {
                        // Хорошая еда - восстанавливаем голод
                        withAnimation {
                            self.hungerValue = min(1.0, self.hungerValue + 0.1)
                        }
                    } else {
                        // Плохая еда - ухудшаем настроение
                        withAnimation {
                            self.emotionValue = max(0.0, self.emotionValue - 0.1)
                        }
                    }
                }
            }
        }
        
        // Удаляем пойманную еду
        foods.removeAll { foodsToRemove.contains($0.id) }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        foods.removeAll()
    }
}

struct FallingFood: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    let isGood: Bool
    let emoji: String
}

// Мини-игра мытья
struct WashingGameView: View {
    @Binding var showWashingGame: Bool
    @Binding var washingValue: Double
    
    @State private var bubbles: [Bubble] = []
    @State private var gameTimer: Timer?
    @State private var characterPosition: CGPoint = CGPoint(x: 0.5, y: 0.5) // Позиция персонажа по центру экрана
    
    private let bubbleSpawnRate: Double = 0.3 // Вероятность появления пузыря за кадр
    private let maxBubbles: Int = 10 // Максимальное количество пузырей на экране
    
    var body: some View {
        ZStack {
            // Фон мини-игры
            Image("game-wash")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                ZStack {
                    // Персонаж (яйцо) - увеличенный и по центру
                    Image("normal-shapou")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 250, height: 250)
                        .position(
                            x: characterPosition.x * geometry.size.width,
                            y: characterPosition.y * geometry.size.height
                        )
                    
                    // Пузыри (эмодзи)
                    ForEach(bubbles) { bubble in
                        Text("🫧")
                            .font(.system(size: CGFloat(bubble.size)))
                            .position(
                                x: bubble.x * geometry.size.width,
                                y: bubble.y * geometry.size.height
                            )
                            .onTapGesture {
                                // Лопаем пузырь при нажатии
                                popBubble(bubble.id)
                            }
                    }
                }
            }
            
            VStack {
                // Прогресс-бар чистоты сверху
                HStack {
                    Spacer()
                    
                    HStack(spacing: 15) {
                        // Иконка чистоты
                        if let uiImage = UIImage(named: "icon-washing") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 80, height: 80)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.black.opacity(0.6))
                                        .frame(width: 90, height: 90)
                                )
                        }
                        
                        // Прогресс-бар (большой)
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                // Фон прогресс-бара
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.black.opacity(0.4))
                                    .frame(height: 20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(Color.white.opacity(0.3), lineWidth: 2)
                                    )
                                
                                // Заполненная часть прогресс-бара
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(red: 0.2, green: 0.6, blue: 0.9))
                                    .frame(width: geo.size.width * CGFloat(washingValue), height: 20)
                                    .shadow(color: Color(red: 0.2, green: 0.6, blue: 0.9).opacity(0.5), radius: 4, x: 0, y: 2)
                                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: washingValue)
                            }
                        }
                        .frame(height: 20)
                    }
                    .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                    
                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.top, 50)
                .padding(.bottom, 20)
                
                Spacer()
                
                // Кнопка "Назад" снизу по центру
                HStack {
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            showWashingGame = false
                        }
                    }) {
                        if let uiImage = UIImage(named: "back-button") {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 60)
                        } else {
                            Text("Назад")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundColor(.brown)
                                .padding()
                                .background(Color.orange)
                                .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                }
                .padding(.bottom, 40)
            }
        }
        .onAppear {
            startGame()
        }
        .onDisappear {
            stopGame()
        }
    }
    
    private func startGame() {
        // Таймер для игрового цикла
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in
            // Движение пузырей вверх
            for i in bubbles.indices {
                bubbles[i].y -= 0.002
                bubbles[i].size += 0.5 // Пузыри растут
                bubbles[i].lifetime += 0.016 // Увеличиваем время жизни пузыря
            }
            
            // Уменьшение чистоты за каждый пузырь на экране
            let bubblesCount = Double(bubbles.count)
            if bubblesCount > 0 {
                let decreaseAmount = bubblesCount * 0.0001 // Уменьшение за кадр
                DispatchQueue.main.async {
                    withAnimation {
                        self.washingValue = max(0.0, self.washingValue - decreaseAmount)
                    }
                }
            }
            
            // Удаление пузырей, которые улетели вверх, стали слишком большими или живут слишком долго
            bubbles.removeAll { $0.y < -0.1 || $0.size > 100 || $0.lifetime > 5.0 }
            
            // Добавление новых пузырей рядом с персонажем
            if bubbles.count < maxBubbles && Double.random(in: 0...1) < bubbleSpawnRate {
                spawnBubble()
            }
        }
    }
    
    private func spawnBubble() {
        // Создаем пузырь рядом с персонажем
        let angle = Double.random(in: 0...(2 * .pi))
        let distance = Double.random(in: 0.1...0.2)
        
        let newBubble = Bubble(
            id: UUID(),
            x: characterPosition.x + cos(angle) * distance,
            y: characterPosition.y + sin(angle) * distance,
            size: Double.random(in: 30...50)
        )
        
        // Проверяем, чтобы пузырь был в пределах экрана
        if newBubble.x > 0.1 && newBubble.x < 0.9 && newBubble.y > 0.2 && newBubble.y < 0.9 {
            bubbles.append(newBubble)
        }
    }
    
    private func popBubble(_ bubbleId: UUID) {
        // Удаляем пузырь
        if let index = bubbles.firstIndex(where: { $0.id == bubbleId }) {
            bubbles.remove(at: index)
            
            // Увеличиваем значение чистоты
            withAnimation {
                washingValue = min(1.0, washingValue + 0.05)
            }
        }
    }
    
    private func stopGame() {
        gameTimer?.invalidate()
        gameTimer = nil
        bubbles.removeAll()
    }
}

struct Bubble: Identifiable {
    let id: UUID
    var x: Double
    var y: Double
    var size: Double
    var lifetime: Double = 0.0 // Время жизни пузыря в секундах
}

// Диалог "не голоден"
struct NotHungryDialogView: View {
    @Binding var showDialog: Bool
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showDialog = false
                    }
                }
            
            // Диалог
            VStack {
                Spacer()
                
                if let uiImage = UIImage(named: "nothungry-dialog") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                } else {
                    // Fallback, если изображение не найдено
                    VStack(spacing: 20) {
                        Text("Спасибо, я не голоден")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.brown)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.brown, lineWidth: 3)
                                    )
                            )
                    }
                    .padding()
                }
                
                Spacer()
            }
            .transition(.scale.combined(with: .opacity))
        }
        .onTapGesture {
            withAnimation {
                showDialog = false
            }
        }
    }
}

// Диалог "я чистый"
struct WashDialogView: View {
    @Binding var showDialog: Bool
    
    var body: some View {
        ZStack {
            // Полупрозрачный фон
            Color.black.opacity(0.5)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation {
                        showDialog = false
                    }
                }
            
            // Диалог
            VStack {
                Spacer()
                
                if let uiImage = UIImage(named: "wash-dialog") {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width * 0.8)
                        .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                } else {
                    // Fallback, если изображение не найдено
                    VStack(spacing: 20) {
                        Text("Я ЧИСТЫЙ!")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(.brown)
                            .multilineTextAlignment(.center)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color(red: 1.0, green: 0.8, blue: 0.6))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.brown, lineWidth: 3)
                                    )
                            )
                    }
                    .padding()
                }
                
                Spacer()
            }
            .transition(.scale.combined(with: .opacity))
        }
        .onTapGesture {
            withAnimation {
                showDialog = false
            }
        }
    }
}

struct ActionButton: View {
    let imageName: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            // Анимация нажатия
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            if let uiImage = UIImage(named: imageName) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            } else {
                Text("Button")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.brown)
                    .padding()
                    .background(Color.orange)
                    .cornerRadius(10)
                    .scaleEffect(isPressed ? 0.9 : 1.0)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ContentView()
}
