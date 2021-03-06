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
    private var colors: [Int]
    public var title: String
    public var legend: String?
    public var style: ChartStyle
    public var darkModeStyle: ChartStyle
    public var formSize: CGSize
    public var dropShadow: Bool
    
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
    
    public init(data: ChartData, colors: [Int], title: String, legend: String? = nil, style: ChartStyle = Styles.barChartStyleOrangeLight, form: CGSize? = ChartForm.medium, dropShadow: Bool? = true) {
        self.data = data
        self.colors = colors
        self.title = title
        self.legend = legend
        self.style = style
        darkModeStyle = style.darkModeStyle != nil ? style.darkModeStyle! : Styles.barChartStyleOrangeDark
        formSize = form!
        self.dropShadow = dropShadow!
    }
    
    public var body: some View {
        ZStack {
            Rectangle()
                .fill(self.colorScheme == .dark ? self.darkModeStyle.backgroundColor : self.style.backgroundColor)
            VStack(alignment: .leading) {
                HStack{
                    if(!showValue){
                        Text(self.title)
                            .font(.system(size: 20))
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }else{
                        Text("\(Int(self.currentValue))")
                            .font(.system(size: 20))
                            .foregroundColor(self.colorScheme == .dark ? self.darkModeStyle.textColor : self.style.textColor)
                    }
                    Spacer()
                }.padding()
                
                BarChartRow(data: data.points.map { $0.1 },
                            values: data.points.map { $0.0 },
                            colors: colors,
                            accentColor: self.colorScheme == .dark ? self.darkModeStyle.accentColor : self.style.accentColor,
                            gradient: self.colorScheme == .dark ? self.darkModeStyle.gradientColor : self.style.gradientColor,
                            touchLocation: self.$touchLocation
                )
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
    
    func getArrowOffset(touchLocation:CGFloat) -> Binding<CGFloat> {
        let realLoc = (self.touchLocation * self.formSize.width) - 50
        if realLoc < 10 {
            return .constant(realLoc - 10)
        }else if realLoc > self.formSize.width-110 {
            return .constant((self.formSize.width-110 - realLoc) * -1)
        } else {
            return .constant(0)
        }
    }
    
    func getLabelViewOffset(touchLocation:CGFloat) -> CGFloat {
        return min(self.formSize.width-110,max(10,(self.touchLocation * self.formSize.width) - 50))
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
        BarChartView(data: TestData.values, colors: [],
                     title: "Model 3 sales",
                     legend: "Quarterly")
    }
}
#endif
