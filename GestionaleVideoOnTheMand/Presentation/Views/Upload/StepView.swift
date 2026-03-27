//
//  StepView.swift
//  GestionaleVideoOnTheMand
//
//  Created by Michele Manniello on 17/01/26.
//

import SwiftUI

struct StepView: View {
   @EnvironmentObject var loadFilmHomeViewModel: LoadFilmHomeViewModel

    
    var body: some View {
        VStack {
            HStack(spacing: 10) {
                Image(systemName: "play.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 40,height: 40)
                    .foregroundStyle(.secondary)
                    .foregroundStyle(.green)
                
                ForEach(0..<loadFilmHomeViewModel.steps.count, id:\.self) { index in
                    let step = loadFilmHomeViewModel.steps[index]
                    
                    ProgressView(value: step.progress, total: 100)
                        .frame(width: 60)
                    stepCircle(done: step.isComplete)
                }
            }
            
            
            HStack {
                Text(loadFilmHomeViewModel.stato.rawValue)
                    .font(.title2)
                 
                
                Text("\(Int(loadFilmHomeViewModel.progress)) %")
                    .font(.title2)
                    .padding(.leading,10)
            }
            .padding()
           
            
            
            
        }
    }
    
    
    private  func stepCircle(done: Bool) -> some View {
        
        ZStack {
            Circle()
                .stroke(.gray.opacity(0.3), lineWidth: 4)
            
            Circle()
                .trim(from: 0, to: done ? 1 : 0)
                .stroke(
                    .blue,
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(270))
                .animation(.easeInOut(duration: 0.8), value: done)
        }
        .frame(width: 30, height: 30)
    }
}

#Preview {
    StepView()
        .environmentObject(PreviewDependecyInjection.shared.makeLoadFilmHomeViewModel())
        .frame(width: 500, height: 400)
}

