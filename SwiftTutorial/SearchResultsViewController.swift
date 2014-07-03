//
//  ViewController.swift
//  SwiftTutorial
//
//  Created by mogmet on 2014/06/26.
//

import UIKit

class SearchResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, APIControllerProtocol {
    @IBOutlet var appsTableView: UITableView
    @lazy var api: APIController = APIController(delegate: self)
    var albums: Album[] = []

    let kSearchWord:String = "BUMP OF CHICKEN"
    let kCellIdentifier: String = "SearchResultCell"
    var imageCache = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        api.searchItunesFor(self.kSearchWord)
    }
    
    func didReceiveAPIResults(results: NSDictionary) {
        // Store the results in our table data array
        if results.count<=0 {
            return
        }
        let allResults: NSDictionary[] = results["results"] as NSDictionary[]
        // Sometimes iTunes returns a collection, not a track, so we check both for the 'name'
        for result: NSDictionary in allResults {
            var name: String? = result["trackName"] as? String
            if !name? {
                name = result["collectionName"] as? String
            }
            // Sometimes price comes in as formattedPrice, sometimes as collectionPrice.. and sometimes it's a float instead of a string. Hooray!
            var price: String? = self._getPrice(result)
            let thumbnailURL: String? = result["artworkUrl60"] as? String
            let imageURL: String? = result["artworkUrl100"] as? String
            var artistURL: String? = result["artistViewUrl"] as? String
            if !artistURL? {
                artistURL = ""
            }
            var itemURL: String? = result["collectionViewUrl"] as? String
            if !itemURL? {
                itemURL = result["trackViewUrl"] as? String
            }
            var newAlbum = Album(name: name!, price: price!, thumbnailImageURL: thumbnailURL!, largeImageURL: imageURL!, itemURL: itemURL!, artistURL: artistURL!)
            albums.append(newAlbum)
        }
        dispatch_async(dispatch_get_main_queue(), {
            self.appsTableView.reloadData()
            })
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func _getPrice(result: NSDictionary) -> String
    {
        var price: String? = result["formattedPrice"] as? String
        if price? {
            return price!
        }
        price = result["collectionPrice"] as? String
        if price? {
            return price!
        }
        var priceFloat: Float? = result["collectionPrice"] as? Float
        var nf: NSNumberFormatter = NSNumberFormatter()
        nf.maximumFractionDigits = 2;
        price = "$"
        if priceFloat? {
            price = price!+nf.stringFromNumber(priceFloat)
        }
        return price!
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject) {
        var detailsViewController: DetailsViewController = segue.destinationViewController as DetailsViewController
        var albumIndex = appsTableView.indexPathForSelectedRow().row
        var selectedAlbum = self.albums[albumIndex]
        detailsViewController.album = selectedAlbum
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return albums.count
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier(self.kCellIdentifier) as UITableViewCell
        let album = self.albums[indexPath.row]
        cell.text = album.title
        cell.image = UIImage(named: "Blank88")
        cell.detailTextLabel.text = album.price

        dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
            // Jump in to a background thread to get the image for this item
            // Grab the artworkUrl60 key to get an image URL for the app's thumbnail
            let urlString = album.thumbnailImageURL
            // Check our image cache for the existing key. This is just a dictionary of UIImages
            var image: UIImage? = self.imageCache.valueForKey(urlString) as? UIImage
            if( image? ) {
                cell.image = image
                return
            }
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)
            // Download an NSData representation of the image at the URL
            var request: NSURLRequest = NSURLRequest(URL: imgURL)
            var urlConnection: NSURLConnection = NSURLConnection(request: request, delegate: self)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error? {
                    println("Error: \(error.localizedDescription)")
                    return
                }
                //var imgData: NSData = NSData(contentsOfURL: imgURL)
                image = UIImage(data: data)
                // Store the image in to our cache
                self.imageCache[urlString!] = image
                // Sometimes this request takes a while, and it's possible that a cell could be re-used before the art is done loading.
                // Let's explicitly call the cellForRowAtIndexPath method of our tableView to make sure the cell is not nil, and therefore still showing onscreen.
                // While this method sounds a lot like the method we're in right now, it isn't.
                // Ctrl+Click on the method name to see how it's defined, including the following comment:
                /** // returns nil if cell is not visible or index path is out of range **/
                if let albumArtsCell: UITableViewCell? = tableView.cellForRowAtIndexPath(indexPath) {
                    albumArtsCell!.image = image
                }
            })
        })
        return cell
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!)
    {
        // Get the row data for the selected row
        let album: Album = self.albums[indexPath.row]
        var alert: UIAlertView = UIAlertView()
        alert.title = album.title
        alert.message = album.price
        alert.addButtonWithTitle("Ok")
        alert.show()

    }

    
    
}

