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

struct TripMapView: View {
    @Environment(LocationManager.self) var locationManager
    @State private var cameraPosition: MapCameraPosition = .userLocation(fallback: .automatic)
    @Query private var listPlacemarks: [MTPlacemark]

    var body: some View {
        Map(position: $cameraPosition) {
            UserAnnotation {
                Image(systemName: "location")
                    .imageScale(.large)
                    .foregroundColor(.blue)
            }
            ForEach(listPlacemarks) { placemark in
                Marker(coordinate: placemark.coordinate) {
                    Label(placemark.name, systemImage: "star")
                }
                .tint(.yellow)
            }
            
        }
        .onAppear {
            updateCameraPosition()
        }
        .mapControls { MapUserLocationButton() }
    }
    
    func updateCameraPosition() {
        if let userLocation = locationManager.userLocation {
            let userRegioin = MKCoordinateRegion(
                center: userLocation.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.15, longitudeDelta: 0.15)
            )
            withAnimation {
                cameraPosition = .region(userRegioin)
            }
        }
    }
}

#Preview {
    TripMapView()
}
