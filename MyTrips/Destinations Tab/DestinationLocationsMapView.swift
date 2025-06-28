//
// Created for MyTrips
// by  Stewart Lynch on 2023-12-31
//
// Follow me on Mastodon: @StewartLynch@iosdev.space
// Follow me on Threads: @StewartLynch (https://www.threads.net)
// Follow me on X: https://x.com/StewartLynch
// Subscribe on YouTube: https://youTube.com/@StewartLynch
// Buy me a ko-fi:  https://ko-fi.com/StewartLynch

import SwiftUI
import MapKit
import SwiftData

struct DestinationLocationsMapView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var visibleRegion: MKCoordinateRegion?
    @State private var searchText = ""
    @FocusState private var searchFieldFocus: Bool  // used for dismissing the search
    @Query(filter: #Predicate<MTPlacemark> {$0.destination == nil}) private var searchPlacemarks: [MTPlacemark]
    private var listPlacemarks: [MTPlacemark] {
        searchPlacemarks + destination.placemarks
    }
    var destination: Destination
    @State private var selectedPlacemark: MTPlacemark?
    @State private var isManualMarker = false
    
    var body: some View {
        @Bindable var destination = destination
        VStack {
            LabeledContent {
                TextField("Enter destination name", text: $destination.name)
                    .textFieldStyle(.roundedBorder)
                    .foregroundStyle(.primary)
            } label: {
                Text("Name")
            }
            HStack {
                Text("Adjust the map to set the region for your destination.")
                    .foregroundStyle(.secondary)
                Spacer()
                Button("Set region") {
                    if let visibleRegion {
                        destination.latitude = visibleRegion.center.latitude
                        destination.longitude = visibleRegion.center.longitude
                        destination.latitudeDelta = visibleRegion.span.latitudeDelta
                        destination.longitudeDelta = visibleRegion.span.longitudeDelta
                    }
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding(.horizontal)
        // MapReader The map reader’s content builder receives a MapProxy instance. You can use this instance to get the information you’ll need to convert between a MapCamera and a MKMapRect or MKCoordinateRegion.

        MapReader { proxy in  // proxy - A proxy for accessing sizing information about a given map view.
            Map(position: $cameraPosition, selection: $selectedPlacemark) {
                ForEach(listPlacemarks) { placemark in
                    if isManualMarker {
                        if placemark.destination != nil {
                            Marker(coordinate: placemark.coordinate) {
                                Label(placemark.name, systemImage: "star")
                            }
                            .tint(.yellow)
                        } else {
                            Marker(placemark.name, coordinate: placemark.coordinate)   // generic marker
                        }
                    } else {
                        Group {
                            if placemark.destination != nil {
                                Marker(coordinate: placemark.coordinate) {
                                    Label(placemark.name, systemImage: "star")
                                }
                                .tint(.yellow)
                            } else {
                                Marker(placemark.name, coordinate: placemark.coordinate)   // generic marker
                            }
                        }.tag(placemark)  // causes placemark Marker to be enlarged showing it has been selected
                    }
               }
            }
            .onTapGesture { position in
                
                if isManualMarker {
                    if let coordinate = proxy.convert(position, from: .local) {
                        let mtPlacemark = MTPlacemark(
                            name: "",
                            address: "",
                            latitude: coordinate.latitude,
                            longitude: coordinate.longitude
                        )
                   //     print(coordinate)
                        modelContext.insert(mtPlacemark)
                        selectedPlacemark = mtPlacemark
                    }
                }
            }
        }
        .sheet(item: $selectedPlacemark, onDismiss: {
            if isManualMarker {
                MapManager.removeSearchResults(modelContext)
            }
        }) { selectedPlacemark in
            LocationDetailView(
                destination: destination,
                selectedPlacemark: selectedPlacemark
            )
                .presentationDetents([.height(450)])
        }
       
        .safeAreaInset(edge: .bottom) {
            VStack {
                Toggle(isOn: $isManualMarker) {
                   Label("Tap marker placement in: \(isManualMarker ? "On" : "OFF")",
                         systemImage: isManualMarker ? "mappin.circel" : "mappin.slash.circel")
                }
                .fontWeight(.bold)
                .toggleStyle(.button)
                .background(.ultraThinMaterial)
                .onChange(of: isManualMarker) {
                    MapManager.removeSearchResults(modelContext)
                }
                if !isManualMarker {
                    HStack {
                        TextField("Search...", text: $searchText)
                            .textFieldStyle(.roundedBorder)
                            .autocorrectionDisabled()
                            .textInputAutocapitalization(.never)
                            .focused($searchFieldFocus)
                            .overlay(alignment: .trailing) {
                                if searchFieldFocus {
                                    Button {
                                        searchText = ""
                                        searchFieldFocus = false
                                    } label: {
                                        Image(systemName: "xmark.circle.fill")
                                    }
                                    .offset(x: -3)
                                }
                            }
                            .onSubmit {
                                Task {
                                    await MapManager.searchPlaces(
                                        modelContext,
                                        searchText: searchText,
                                        visibleRegion: visibleRegion
                                    )
                                    searchText = ""
                                    cameraPosition = .automatic
                                }
                            }
                        if !searchPlacemarks.isEmpty {
                            Button {
                                MapManager.removeSearchResults(modelContext)
                            } label: {
                                Image(systemName: "mappin.slash.circle.fill")
                                    .imageScale(.large)
                            }
                            .foregroundStyle(.white)
                            .padding(8)
                            .background(.red)
                            .clipShape(.circle)
                        }
                    }
                }
                
            }
            .padding()
        }
        .navigationTitle("Destination")
        .navigationBarTitleDisplayMode(.inline)
        .onMapCameraChange(frequency: .onEnd){ context in
            visibleRegion = context.region
        }
        .onAppear {
            MapManager.removeSearchResults(modelContext)
            if let region = destination.region {
                cameraPosition = .region(region)
            }
        }
        .onDisappear {
            MapManager.removeSearchResults(modelContext)
        }
    }
}

#Preview {
    let container = Destination.preview
    let fetchDescriptor = FetchDescriptor<Destination>()
    let destination = try! container.mainContext.fetch(fetchDescriptor)[0]
    return NavigationStack {
        DestinationLocationsMapView(destination: destination)
    }
    .modelContainer(Destination.preview)
}
