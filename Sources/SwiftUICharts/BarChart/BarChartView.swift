//
//  ChartView.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartView: View {
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    private var data: ChartData
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize: CGSize
    public var dropShadow: Bool
    public var valueSpecifier: String

    @State private var touchLocation: CGFloat = -1.0
    @State private var showValue: Bool = false
    @State private var showLabelValue: Bool = false
    @State private var currentValue: Double = 0 {
        didSet {
            if oldValue != self.currentValue && self.showValue {
                HapticFeedback.playSelection()
            }
        }
    }

    var isFullWidth: Bool {
        return formSize == ChartForm.large
    }

    public init(data: ChartData, title: String, legend: String? = nil, style: ChartStyle = Styles.barChartStyleOrangeLight, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true, cornerImage _: Image? = Image(systemName: "waveform.path.ecg"), valueSpecifier: String? = "%.1f") {
        self.data = data
        self.title = title
        self.legend = legend
        self.style = style
        darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        formSize = form!
        self.dropShadow = dropShadow!
        self.valueSpecifier = valueSpecifier!
    }

    public var body: some View {
        ZStack {
            Rectangle()
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
            VStack(alignment: .leading) {
                HStack {
                    if !showValue {
                        Text(self.title)
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    } else {
                        Text(self.legend!)
                            .font(.headline)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    if self.formSize == ChartForm.large && self.legend != nil && !showValue {
                        Text(self.legend!)
                            .font(.callout)
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor)
                            .transition(.opacity)
                            .animation(.easeOut)
                    }
                }.padding()
                BarChartRow(data: data.points.map { $0.1 },
                            accentColor: self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor,
                            gradient: self.colorScheme == .dark ? self.darkModeStyle.gradientColor : self.style.gradientColor,
                            touchLocation: self.$touchLocation)
                if self.legend != nil && self.formSize == ChartForm.medium && !self.showLabelValue {
                    Text(self.legend!)
                        .font(.headline)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                        .padding()
                } else if self.data.valuesGiven && self.getCurrentValue() != nil {
                    LabelView(arrowOffset: self.getArrowOffset(touchLocation: self.touchLocation),
                              title: .constant(self.getCurrentValue()!.0))
                        .offset(x: self.getLabelViewOffset(touchLocation: self.touchLocation), y: -6)
                        .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.legendTextColor : self.style.legendTextColor)
                }
            }
        }.frame(minWidth: self.formSize.width,
                maxWidth: self.isFullWidth ? .infinity : self.formSize.width,
                minHeight: self.formSize.height,
                maxHeight: self.formSize.height)
            .gesture(DragGesture()
                .onChanged { value in
                    self.touchLocation = value.location.x / self.formSize.width
                    self.showValue = true
                    self.currentValue = self.getCurrentValue()?.1 ?? 0
                    self.legend = self.getCurrentValue()!.0
                    if self.data.valuesGiven, self.formSize == ChartForm.medium {
                        self.showLabelValue = true
                    }
                }
                .onEnded { _ in
                    self.showValue = false
                    self.showLabelValue = false
                    self.touchLocation = -1
                }
            )
            .gesture(TapGesture()
            )
    }

    func getArrowOffset(touchLocation _: CGFloat) -> Binding<CGFloat> {
        let realLoc = (touchLocation * formSize.width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        } else if realLoc > formSize.width - 110 {
            return .constant((formSize.width - 110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }

    func getLabelViewOffset(touchLocation _: CGFloat) -> CGFloat {
        return min(formSize.width - 110, max(10, (touchLocation * formSize.width) - 50))
    }

    func getCurrentValue() -> (String, Double)? {
        guard data.points.count > 0 else { return nil }
        let index = max(0, min(data.points.count - 1, Int(floor((touchLocation * formSize.width) / (formSize.width / CGFloat(data.points.count))))))
        return data.points[index]
    }
}

#if DEBUG
    struct ChartView_Previews: PreviewProvider {
        static var previews: some View {
            BarChartView(data: TestData.values,
                         title: "Model 3 sales",
                         legend: "Quarterly",
                         valueSpecifier: "%.0f")
        }
    }
#endif
