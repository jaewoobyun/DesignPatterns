/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import MapKit
import YelpAPI

public class ViewController: UIViewController {
  
  // MARK: - Properties
	public var filter: Filter!
  public let annotationFactory = AnnotationFactory()
  public var businesses: [Business] = []
  private let client = YLPClient(apiKey: YelpAPIKey)
  private let locationManager = CLLocationManager()
  
  // MARK: - Outlets
  @IBOutlet public var mapView: MKMapView! {
    didSet {
      mapView.showsUserLocation = true
    }
  }
  
  // MARK: - View Lifecycle
  public override func viewDidLoad() {
    super.viewDidLoad()

    DispatchQueue.main.async { [weak self] in
      self?.locationManager.requestWhenInUseAuthorization()
    }
  }
  
  // MARK: - Actions
  @IBAction func businessFilterToggleChanged(_ sender: UISwitch) {
		if sender.isOn {
			filter = Filter.starRating(atLeast: 4.75)
		} else {
			filter = Filter.starRating(atLeast: 0.0)
		}
		
		for business in businesses {
			filter.businesses.append(business)
		}
		
		addAnnotations()
		
  }
}

// MARK: - MKMapViewDelegate
extension ViewController: MKMapViewDelegate {
  
  public func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
    centerMap(on: userLocation.coordinate)
  }
  
  private func centerMap(on coordinate: CLLocationCoordinate2D) {
    let regionRadius: CLLocationDistance = 3000
    let coordinateRegion = MKCoordinateRegionMakeWithDistance(coordinate,
                                                              regionRadius,
                                                              regionRadius)
    mapView.setRegion(coordinateRegion, animated: true)
    searchForBusinesses()
  }
  
  private func searchForBusinesses() {
    let coordinate = mapView.userLocation.coordinate
    guard coordinate.latitude != 0,
      coordinate.longitude != 0 else {
        return
    }
    
    let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude,
                                       longitude: coordinate.longitude)
    
    client.search(with: yelpCoordinate, term: "coffee", limit: 35, offset: 0, sort: .bestMatched) {
      [weak self] (searchResult, error) in
      guard let strongSelf = self else {
        return
      }

      guard let searchResult = searchResult?.adaptSearchResultsFromYLP(),
        error == nil else {
          print("Search failed: \(String(describing: error))")
          return
      }

      strongSelf.businesses = searchResult.businesses
			strongSelf.filter = Filter.identity()
			for business in strongSelf.businesses {
				strongSelf.filter.businesses.append(business)
			}
      DispatchQueue.main.async {
        strongSelf.addAnnotations()
      }
    }
  }
  
  public func addAnnotations() {
		//1
		mapView.removeAnnotations(mapView.annotations)
		
		//2
		filter.businesses = filter.filterBusinesses()
		
		//3
    for business in businesses {
      guard let viewModel = annotationFactory.createBusinessMapViewModel(for: business) else {
        continue
      }

      mapView.addAnnotation(viewModel)
    }
  }
  
  public func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    guard let viewModel = annotation as? BusinessMapViewModel else {
      return nil
    }

    let identifier = "business"
    let annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) ??
      MKAnnotationView(annotation: viewModel, reuseIdentifier: identifier)
    viewModel.configure(annotationView)
    return annotationView
  }
}
