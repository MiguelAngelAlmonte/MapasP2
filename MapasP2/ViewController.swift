import MapKit
import UIKit
import CoreLocation


class ViewController: UIViewController, MKMapViewDelegate, UISearchBarDelegate{

    @IBOutlet weak var buscadorSB: UISearchBar!
    
    @IBOutlet weak var MapaMK: MKMapView!
    var latitud: CLLocationDegrees?
    var longitud: CLLocationDegrees?
    var altitud: CLLocationDegrees?
    var manager = CLLocationManager()
    let localizacion = CLLocationCoordinate2D()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MapaMK.delegate = self
        buscadorSB.delegate = self
        manager.delegate = self
        manager.requestWhenInUseAuthorization()
        manager.requestLocation()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.startUpdatingLocation()
        
        // Do any additional setup after loading the view.
    }
     //MARK:-Calcular ubicacion por nombre
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("ubicacion encontrada")
        buscadorSB.resignFirstResponder()
        let geocoder = CLGeocoder()
        if let direccion = buscadorSB.text{
            geocoder.geocodeAddressString(direccion) { (lugares: [CLPlacemark]?,error: Error?) in
                //crear el destino
                guard let destinoRuta = lugares?.first?.location else{
                    return
                }
                if error == nil{
                    let lugar = lugares?.first
                    let anotacion = MKPointAnnotation()
                    anotacion.coordinate = (lugar?.location?.coordinate)!
                    anotacion.title = direccion
                    let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    let region = MKCoordinateRegion(center: anotacion.coordinate, span: span)
                    self.MapaMK.setRegion(region, animated: true)
                    self.MapaMK.addAnnotation(anotacion)
                    self.MapaMK.selectAnnotation(anotacion, animated: true)
                    self.trazarRuta(coordenadasDestino: destinoRuta.coordinate)
                    let origendistance = CLLocation(latitude: self.latitud ?? 0, longitude: self.longitud ?? 0)
                
                    let destinodistance:CLLocation = CLLocation(latitude: destinoRuta.coordinate.latitude, longitude: destinoRuta.coordinate.longitude)
                    let latitudfinal = destinodistance.coordinate.latitude
                    let longitudfinal = destinodistance.coordinate.longitude
                    let final: CLLocation =  CLLocation(latitude: latitudfinal, longitude: longitudfinal)
                    
                    
                    let distance = origendistance.distance(from: destinodistance)
                    let kmdistance = Measurement(value: distance, unit: UnitLength.meters)
                    let distancekilometros = kmdistance.converted(to: UnitLength.kilometers).value
                    let distanciatotal = String(format: "%.2f",distancekilometros)
                    
                    let alerta = UIAlertController(title: "La distancia entre los dos puntos", message: "La distancia es : \(distanciatotal ) Kilometros", preferredStyle: .alert)
                    let accionAceptar = UIAlertAction(title: "Entiendo", style: .default, handler: nil)
                    alerta.addAction(accionAceptar)
                    self.present(alerta, animated: true)
                    
                    
                    print("Posicion 2 solos: \(final)")
                    print("punto origen: \(origendistance)")
                        print("distancia es: \(distancekilometros)")
                    
                }else{
                    print("Error al encontrar la direccon: \(error?.localizedDescription)")
                }
            }
        }
        
    }
     //MARK:-trazar ruta
    func trazarRuta(coordenadasDestino: CLLocationCoordinate2D)  {
        guard let coordOrigen = manager.location?.coordinate else {
            return
        }
        //crear lugar de origen-destno
        let origenPlaceMark = MKPlacemark(coordinate: coordOrigen)
        let destinoPlaceMark = MKPlacemark(coordinate: coordenadasDestino)
        
        //crear objeto mapkit item
        
        let origenItem = MKMapItem(placemark: origenPlaceMark)
        let destinoItem = MKMapItem(placemark: destinoPlaceMark)
        // solicitud de ruta
        let solicitudDestino = MKDirections.Request()
        solicitudDestino.source = origenItem
        solicitudDestino.destination = destinoItem
        // como viajar
        solicitudDestino.transportType = .automobile
        solicitudDestino.requestsAlternateRoutes = true
   
        let direcciones = MKDirections(request: solicitudDestino)
        direcciones.calculate { (respuesta, error) in
            guard let respuestaSegura = respuesta else{
                if let error = error {
                    print("Error al calcular la ruta\(error.localizedDescription)")
                }
                return
            }
            print(respuestaSegura.routes.count)
            let ruta = respuestaSegura.routes[0]
            // Agregar al mapa una superposicion
            self.MapaMK.addOverlay(ruta.polyline)
            self.MapaMK.setVisibleMapRect(ruta.polyline.boundingMapRect, animated: true)
        }
    }
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderizado = MKPolylineRenderer(overlay: overlay as! MKPolyline)
        renderizado.strokeColor = .purple
        return renderizado
    }
    
    
    
    
    @IBAction func UbicacionButton(_ sender: UIBarButtonItem) {
        
        let alerta = UIAlertController(title: "Ubicacion", message: "Las coordenadas son: \(latitud ?? 0) \(longitud ?? 0) \(altitud ?? 0)", preferredStyle: .alert)
        let accionAceptar = UIAlertAction(title: "Aceptar", style: .default, handler: nil)
        alerta.addAction(accionAceptar)
        present(alerta, animated: true)
        let localizacion = CLLocationCoordinate2D(latitude: latitud ?? 0, longitude: longitud ?? 0)
        let spanMapa = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: localizacion, span: spanMapa)
        print("Localizacion 1: \(localizacion)")
       
        MapaMK.setRegion(region, animated: true)
        MapaMK.showsUserLocation = true
        
        
    }
    
}
extension ViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("numero de ubicaciones\(locations.count)")
        guard let ubicacion = locations.first else{
            return
        }
         latitud = ubicacion.coordinate.latitude
         longitud = ubicacion.coordinate.longitude
         altitud = ubicacion.altitude
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error al obtener ubicacion \(error.localizedDescription)")
    }
  
}





