//
//  SettingsView.swift
//  AppEnvironmentSettings
//
//  Created by Ganesh Shinde on 06/12/20.
//

import SwiftUI

struct Constants {
    static let title = "Environment Settings"
    static let theme = LocalizedStringKey("Light or Dark")
    static let locale = LocalizedStringKey("Locale")
    static let text = LocalizedStringKey("Text")
    static let layout = LocalizedStringKey("Inverse Layout")
    static let accessibility = LocalizedStringKey("Accessibility")
    static let screenShot = "Take Screenshot"
}

@available(iOS 13.0, *)
extension SettingsView {
    struct Params {
        let locales: [Locale]
        let locale: Binding<Locale>
        let colorScheme: Binding<ColorScheme>
        let textSize: Binding<ContentSizeCategory>
        let layoutDirection: Binding<LayoutDirection>
        let accessibilityEnabled: Binding<Bool>
    }
}

@available(iOS 13.0, *)
struct SettingsView: View {
    
    private let params: Params
    @Binding private var isHidden: Bool
    @State private var controlWidth: CGFloat = ControlWidth.defaultValue
    
    init(params: Params, isHidden: Binding<Bool>) {
        self.params = params
        _isHidden = isHidden
    }
    
    var body: some View {
        VStack {
            title.edgePadding()
            Divider()
            Group {
                themeToggle
                localeSelector.disabled(params.locales.count < 2)
                textSizeSlider
                layoutDirectionToggle
                accessibilityToggle
                screenshotButton.disabled(EnvironmentValues.isMac)
            }.edgePadding()
        }.padding([.top, .bottom], 10)
        .onPreferenceChange(ControlWidth.self) {
            self.controlWidth = $0
        }
    }
}

@available(iOS 13.0.0, *)
private extension SettingsView {
    
    var title: some View {
        Text(Constants.title).font(.subheadline).bold()
    }
    
    var themeToggle: some View {
        SettingsView.Toggle(title: Constants.theme,
                            value: params.colorScheme
            .map(toValue: { $0 == .dark },
                 fromValue: { $0 ? .dark : .light })
        )
    }
    
    var localeSelector: some View {
        SettingsView.Picker(
            title: Constants.locale, pickerWidth: controlWidth, value: params.locale,
            values: params.locales, valueTitle: { $0.identifier })
    }
    
    var textSizeSlider: some View {
        SettingsView.Slider(
            title: Constants.text, sliderWidth: controlWidth,
            value: params.textSize.map(
                toValue: { $0.floatValue },
                fromValue: { ContentSizeCategory(floatValue: $0) }),
            stride: ContentSizeCategory.stride) {
                self.params.textSize.wrappedValue.name
            }
    }
    
    var layoutDirectionToggle: some View {
        SettingsView.Toggle(title: Constants.layout,
                            value: params.layoutDirection
            .map(toValue: { $0 == .rightToLeft },
                 fromValue: { $0 ? .rightToLeft : .leftToRight })
        )
    }
    
    var accessibilityToggle: some View {
        SettingsView.Toggle(title: Constants.accessibility,
                            value: params.accessibilityEnabled)
    }
    
    var screenshotButton: some View {
        Button(action: {
            self.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                if ScreenshotGenerator.takeScreenshot() {
                    Haptic.successFeedback()
                } else {
                    Haptic.errorFeedback()
                }
                self.isHidden = false
            }
        }, label: { Text(Constants.screenShot) })
    }
}

// MARK: - Styling

@available(iOS 13.0, *)
extension Text {
    func settingsStyle() -> Text {
        font(.footnote).bold()
    }
}

@available(iOS 13.0.0, *)
private extension View {
    func edgePadding() -> some View {
        padding([.leading, .trailing], 8)
    }
}

#if DEBUG

@available(iOS 13.0.0, *)
extension SettingsView.Params {
    static func preview() -> SettingsView.Params {
        SettingsView.Params(
            locales: [
                Locale(identifier: "en"),
                Locale(identifier: "ru"),
                Locale(identifier: "fr")
            ],
            locale: Binding<Locale>(wrappedValue: Locale(identifier: "en")),
            colorScheme: Binding<ColorScheme>(wrappedValue: .dark),
            textSize: Binding<ContentSizeCategory>(wrappedValue: .medium),
            layoutDirection: Binding<LayoutDirection>(wrappedValue: .leftToRight),
            accessibilityEnabled: Binding<Bool>(wrappedValue: false))
    }
}

@available(iOS 13.0.0, *)
struct SettingsView_Previews: PreviewProvider {

    static var previews: some View {
        Group {
            ZStack {
                bgView
                SettingsView(params: .preview(), isHidden: Binding<Bool>(wrappedValue: false))
            }
            .colorScheme(.light)
            ZStack {
                bgView
                SettingsView(params: .preview(), isHidden: Binding<Bool>(wrappedValue: false))
            }
            .colorScheme(.dark)
        }
        .previewLayout(.fixed(width: 200, height: 300))
    }
    
    private static var bgView: some View {
        #if os(macOS)
        return Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
        #else
        return Color(UIColor.tertiarySystemBackground)
        #endif
    }
}

#endif
