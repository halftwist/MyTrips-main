//
//  LocationDetailView.swift
//  MyTrips
//
//  Created by John Kearon on 6/25/25.
//

import SwiftUI
import MapKit
import SwiftData

struct LocationDetailView: View {
    @Environment(\.dismiss) private var dismiss
    var destination: Destination?
    var selectedPlacemark: MTPlacemark?
    
    @State private var name = ""
    @State private var address = ""
    
    @State private var lookaroundScene: MKLookAroundScene?
    
    var isChanged: Bool {
        guard let selectedPlacemark else { return false }
        return (name != selectedPlacemark.name || address != selectedPlacemark.address)
    }
    
    var body: some View {
        VStack {
            HStack {
                VStack(alignment: .leading) {
                    TextField("Name", text: $name)
                        .font(.title)
                    TextField("Address", text: $address, axis: .vertical)
                    if isChanged {
                        Button("Update") {
                            selectedPlacemark?.name = name
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                            selectedPlacemark?.address = address
                                .trimmingCharacters(in: .whitespacesAndNewlines)
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .imageScale(.large)
                        .foregroundStyle(.gray)
                }
            }
            
            if let lookaroundScene {
                LookAroundPreview(initialScene: lookaroundScene)
                    .frame(height: 200)
                    .padding()
            } else {
                ContentUnavailableView("No preview available", systemImage: "eye.slash")
            }
            
            HStack {
                Spacer()
                if let destination {
                    let inList = (selectedPlacemark != nil && selectedPlacemark?.destination != nil)
                    Button {
                        if let selectedPlacemark {
                            if selectedPlacemark.destination == nil {
                                destination.placemarks.append(selectedPlacemark)
                            } else {
                                selectedPlacemark.destination = nil
                            }
                            dismiss()
                        }
                    } label: {
                        Label(inList ? "Remove" : "Add", systemImage: inList ? "minus.circle" : "plus.circle")
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(inList ? .red : .green)
                    .disabled((name.isEmpty || isChanged))
                    
                }
            }
            Spacer()
        }
        .task(id: selectedPlacemark) {  // occurs on launch of this struct
            await fetchLookaroundPreview()
        }
        .onAppear {
            if let selectedPlacemark, destination != nil {
                name = selectedPlacemark.name
                address = selectedPlacemark.address
            }
        }
    }
    
    func fetchLookaroundPreview() async {
        if let selectedPlacemark {
            lookaroundScene = nil
            let lookaroundRequest = MKLookAroundSceneRequest(coordinate: selectedPlacemark.coordinate)
            lookaroundScene = try? await lookaroundRequest.scene
        }
    }
}

//#Preview {
//    let container = Destination.preview
//    let fetchDescriptor = FetchDescriptor<Destination>()
//    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
//    let selectedPlacemark = destination.placemarks[0]
//    return LocationDetailView(
//        destination: destination,
//        selectedPlacemark: selectedPlacemark
//    )
//}
