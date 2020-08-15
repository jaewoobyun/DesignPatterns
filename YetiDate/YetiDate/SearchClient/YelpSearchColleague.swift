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


import CoreLocation
import YelpAPI

public class YelpSearchColleague {
	
	//1
	public let category: YelpCategory
	public private(set) var selectedBusiness: YLPBusiness?
	
	//2
	private var colleagueCoordinate: CLLocationCoordinate2D?
	private unowned let mediator: SearchColleagueMediating
	private var userCoordinate: CLLocationCoordinate2D?
	private let yelpClient: YLPClient
	
	//3
	private static let defaultQueryLimit = UInt(20)
	private static let defaultQuerySort = YLPSortType.bestMatched
	private var queryLimit = defaultQueryLimit
	private var querySort = defaultQuerySort
	
	//4
	public init(category: YelpCategory, mediator: SearchColleagueMediating) {
		self.category = category
		self.mediator = mediator
		self.yelpClient = YLPClient(apiKey: YelpAPIKey)
	}
	
}

// MARK: - SearchColleague
//1
extension YelpSearchColleague: SearchColleague {
	
	//2
	public func fellowColleauge(_ colleague: SearchColleague, didSelect business: YLPBusiness) {
		colleagueCoordinate = CLLocationCoordinate2D(business.location.coordinate)
		queryLimit /= 2
		querySort = .distance
		performSearch()
	}
	
	//3
	public func update(userCoordinate: CLLocationCoordinate2D) {
		self.userCoordinate = userCoordinate
		performSearch()
	}
	
	//4
	public func reset() {
		colleagueCoordinate = nil
		queryLimit = YelpSearchColleague.defaultQueryLimit
		querySort = YelpSearchColleague.defaultQuerySort
		selectedBusiness = nil
		performSearch()
	}
	
	private func performSearch() {
		//1
		guard selectedBusiness == nil, let coordinate = colleagueCoordinate ?? userCoordinate else { return }
		
		//2
		let yelpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
		let query = YLPQuery(coordinate: yelpCoordinate)
		query.categoryFilter = [category.rawValue]
		query.limit = queryLimit
		query.sort = querySort
		
		yelpClient.search(with: query) { [weak self] (search, error) in
			guard let strongSelf = self else { return }
			guard let search = search else {
				//3
				
				strongSelf.mediator.searchColleague(strongSelf, searchFailed: error)
				return
			}
			
			//4
			var set: Set<BusinessMapViewModel> = []
			for business in search.businesses {
				guard let coordinate = business.location.coordinate else { continue }
				let viewModel = BusinessMapViewModel(business: business, coordinate: coordinate, primaryCategory: strongSelf.category, onSelect: { [weak self](business) in
					guard let strongSelf = self else { return }
					strongSelf.selectedBusiness = business
					
					strongSelf.mediator.searchColleague(strongSelf, didSelect: business)
				})
				set.insert(viewModel)
			}
			
			//5
			DispatchQueue.main.async {
				strongSelf.mediator.searchColleague(strongSelf, didCreate: set)
			}
		}
	}
	
}
