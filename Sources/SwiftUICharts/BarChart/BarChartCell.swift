//
//  ChartCell.swift
//  ChartView
//
//  Created by András Samu on 2019. 06. 12..
//  Copyright © 2019. András Samu. All rights reserved.
//

import SwiftUI

public struct BarChartCell : View {
    var value: Double
    var verbose: String
    var index: Int = 0
    var width: Float
    var numberOfDataPoints: Int
    var cellWidth: Double {
        return Double(width)/(Double(numberOfDataPoints) * 1.5)
    }
    var accentColor: Color
    var columnColor: String
    var gradient: GradientColor?
    
    @State var scaleValue: Double = 0
    @Binding var touchLocation: CGFloat
    
    func getColumnGradient() -> LinearGradient{
        if(self.verbose.contains("bottle")){
            return LinearGradient(gradient: GradientColors.blue.getGradient(), startPoint: .bottom, endPoint: .top)
        }else if(self.verbose.contains("right")){
            return LinearGradient(gradient: GradientColors.green.getGradient(), startPoint: .bottom, endPoint: .top)
        }else{
            return LinearGradient(gradient: GradientColors.orange.getGradient(), startPoint: .bottom, endPoint: .top)
        }
    }
    
    public var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(getColumnGradient())
            }
            .frame(width: CGFloat(self.cellWidth))
            .scaleEffect(CGSize(width: 1, height: self.scaleValue), anchor: .bottom)
            .onAppear(){
                self.scaleValue = self.value
            }
        .animation(Animation.spring().delay(self.touchLocation < 0 ?  Double(self.index) * 0.04 : 0))
    }
}

#if DEBUG
struct ChartCell_Previews : PreviewProvider {
    static var previews: some View {
        BarChartCell(value: Double(0.75), verbose: "", width: 320, numberOfDataPoints: 12, accentColor: Colors.OrangeStart, columnColor: "blue", gradient: nil, touchLocation: .constant(-1))
    }
}
#endif
