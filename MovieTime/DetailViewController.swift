//
//  DetailViewController.swift
//  MovieTime
//
//  Created by Brandon Sanchez on 1/20/17.
//  Copyright © 2017 Brandon Sanchez. All rights reserved.
//

import UIKit
import ChameleonFramework

class DetailViewController: UIViewController {
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var baseView: UIView!
    @IBOutlet var backdropImageView: UIImageView!
    @IBOutlet var posterImageView: UIImageView!
    @IBOutlet var voteCountLabel: UILabel!
    @IBOutlet var voteAverageLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var youtubeWebView: MaterialWebView!
    @IBOutlet var recommendedCollectionView: UICollectionView!
    var recommendedMovies = [Movie]()
    
    var movie: Movie! {
        didSet {
            print(movie)
            youtube(movieID: String(movie.id))
            getRecommendedMovies(movieID: String(movie.id)) { (result) in
                switch result {
                case .success(let movies):
                    self.recommendedMovies = movies
                    self.recommendedCollectionView.reloadData()
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.automaticallyAdjustsScrollViewInsets = false
        self.scrollView.bounces = false
        self.view.backgroundColor = colorSheet().alabaster
        self.baseView.backgroundColor = colorSheet().alabaster
        self.scrollView.backgroundColor = colorSheet().alabaster
        self.baseView.translatesAutoresizingMaskIntoConstraints = false
        
        // UI
        setLabelColors(color: colorSheet().stoneCold!)
        setMovieDetails()
        configureViews()
            
        // CollectionView
        recommendedCollectionView.register(GridCell.self)
        recommendedCollectionView.delegate = self
        recommendedCollectionView.dataSource = self
        recommendedCollectionView.backgroundColor = UIColor.clear

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setMovieDetails() {
        if let movie = movie {
            titleLabel.text = movie.title
            descriptionLabel.text = movie.overview
            //print(descriptionLabel.text)
            voteCountLabel.text = String(movie.voteCount)
            voteAverageLabel.text = String(movie.voteAverage)
            
            posterImageView.af_setImage(withURL: URL(string: movie.posterPath)!)
            //backdropImageView.af_setImage(withURL: URL(string: movie.backdropPath)!)
            //backdropImageView.contentMode = .scaleAspectFill
            let url = URL(string: movie.backdropPath)!
            let data = try! Data(contentsOf: url)
            let image = UIImage(data: data)
            let test = CGSize(width: 500, height: 600)
            let resizedImage = image?.af_imageAspectScaled(toFill: test)
            //image?.resizedImageWithinRect(rectSize: test)
            
            backdropImageView.image = image
            backdropImageView.contentMode = .scaleAspectFill
        }
    }
    
    func configureViews() {
        var gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.frame
        gradient.colors = [UIColor.clear.cgColor, colorSheet().alabaster?.cgColor]
        gradient.locations = [0.1, 0.4]
        backdropImageView.layer.insertSublayer(gradient, at: 0)
    
    }
        
    
    func setLabelColors(color: UIColor) {
        titleLabel.textColor = color
        titleLabel.font = UIFont.boldSystemFont(ofSize: 25)
        descriptionLabel.textColor = color
        voteCountLabel.textColor = color
        voteAverageLabel.textColor = color
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension UIImage {
    
    /// Returns a image that fills in newSize
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
    /// Returns a resized image that fits in rectSize, keeping it's aspect ratio
    /// Note that the new image size is not rectSize, but within it.
    func resizedImageWithinRect(rectSize: CGSize) -> UIImage {
        let widthFactor = size.width / rectSize.width
        let heightFactor = size.height / rectSize.height
        
        var resizeFactor = widthFactor
        if size.height > size.width {
            resizeFactor = heightFactor
        }
        
        let newSize = CGSize(width: size.width/resizeFactor, height: size.height/resizeFactor)
        let resized = resizedImage(newSize: newSize)
        return resized
    }
    
}



// Tests
//guard let url = NSURL(string: "http://placehold.it/300x150") else { fatalError("Bad URL") }
//guard let data = NSData(contentsOfURL: url) else { fatalError("Bad data") }
//guard let img = UIImage(data: data) else { fatalError("Bad data") }
//
//let outImageFit = img.resizedImageWithinRect(CGSize(width: 200, height: 200))
//let outImageFill = img.resizedImage(CGSize(width: 200, height: 200))
