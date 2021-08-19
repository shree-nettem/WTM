//
//  Constant.swift
//  Copped
//
//  Created by Tarun Sachdeva on 05/12/17.
//  Copyright © 2017 Tsss. All rights reserved.
//

import Foundation
import UIKit

struct Color{
    static var logoColor = UIColor(red: 78/255, green: 217/255, blue: 57/255, alpha: 1.0)
    static let selectedLineColor = UIColor(red: 240/255, green: 152/255, blue: 72/255, alpha: 1.0)
    static let unSelectedLineColor = UIColor(red: 224/255, green: 237/255, blue: 241/255, alpha: 1.0)
    
    //Cell Background Color
    static let firstColor = UIColor(red: 39/255, green: 174/255, blue: 96/255, alpha: 0.7)
    static let secondColor = UIColor(red: 235/255, green: 87/255, blue: 87/255, alpha: 0.7)
    static let thirdColor = UIColor(red: 218/255, green: 212/255, blue: 45/255, alpha: 0.7)
    static let fourthColor = UIColor(red: 47/255, green: 128/255, blue: 237/255, alpha: 1.0)
    static let fifthColor = UIColor(red: 142/255, green: 220/255, blue: 252/255, alpha: 1.0)
    static let sixthColor = UIColor(red: 247/255, green: 223/255, blue: 137/255, alpha: 1.0)
    
    
    
}

struct AdUnit {
   // Testing
    
   // 2764174042161135
    
    static var APPID = "ca-app-pub-2764174042161135~9710525483"
    static var BannerID = "ca-app-pub-3940256099942544/6300978111"
    static var InterstitateID = "ca-app-pub-3940256099942544/1033173712"
    static var RewardID = "ca-app-pub-3940256099942544/1712485313"
    static var NativeID = "ca-app-pub-3940256099942544/1712485313"
 
    
    
    /*
    //Live
    static var APPID = "ca-app-pub-2764174042161135/3140413551"
    static var BannerID = "ca-app-pub-3617610196646343/1682029719"
    static var InterstitateID = "ca-app-pub-3617610196646343/3925049674"
    static var RewardID = "ca-app-pub-2764174042161135/3145117137"
    static var NativeID = "ca-app-pub-3617610196646343/6168069635"
    */
}

struct BibleKey {
    static let LiveAPIKey = "3045821887a895fafc280fb8444fa5ea"
}

struct FacebookAdUnit {
   
    //Live
       static var FBBannerID = "2386339534997454_2386339798330761"
       static var FBFullScreenID = "2386339534997454_2386340691664005"
      
    //static var FBNativeID = "2977984842283546_2977992778949419"
    //   static var FBNativeBannerID = "2977984842283546_2977988722283158"
    
}

struct PaymentKey {
    
    // Testing
    static let PublisherKey = "pk_test_z6Z4zJV8Ni36PJqtOos6abnz00NpfGlrSn"
    static let SecretKey = "sk_test_hUHka5hhXBxA045U9B46EHct00QFodoIP0"
    
    // Live
   // static let PublisherKey = "ca-app-pub-3940256099942544/5224354917"
   // static let SecretKey = "ca-app-pub-3940256099942544/6300978111"
    
}

/*
struct AppUtility {
    
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
        
        if let delegate = UIApplication.shared.delegate as? AppDelegate {
            print("He;;p")
            delegate.orientationLock = orientation
        }
    }
    
    /// OPTIONAL Added method to adjust lock and rotate to the desired orientation
    static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
        
        self.lockOrientation(orientation)
        
        UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        UINavigationController.attemptRotationToDeviceOrientation()
    }
    
}*/


enum UIUserInterfaceIdiom : Int {
    case unspecified
    
    case phone // iPhone and iPod touch style UI
    case pad // iPad style UI
}

enum SwiftAlertType : Int {
    case success
    case warning
    case error
    case info
}

//struct ScreenSize{
//    static let SCREEN_WIDTH  = UIScreen.main.bounds.size.width
//    static let SCREEN_HEIGHT = UIScreen.main.bounds.size.width
//}

struct QuestionType {
    static let singleChoice = "single_choice"
    static let multipleChoice = "MCQ"
    static let fillUps = "fill_up"
}



struct SharedData {
    
    static let firstTime = "firstTime"
    static let totalQuiz = "totalQuiz"
    static let bestTime = "bestTime"
    static let userName = "userName"
    static let totalWin = "totalWin"
    static let userType = "userType"
    static let quizNotCompleted = "quizNotCompleted"
    static let level = "level"
    
      static let fontSize = "fontSize"
      static let fontName = "fontName"
      static let isVoiceOn = "isVoiceOn"
      static let voiceSpeed = "voiceSpeed"
      static let voicePitch = "voicePitch"
      static let voiceLang = "voiceLang"
      static let isMeditationVoice = "isMeditationVoice"
    
    
    static let bookName = "bookName"
    static let chapterNumber = "chapterNumber"
    static let versesNumber = "versesNumber"
    static let userHistory = "userHistory"
    static let currentLang = "currentLang"
    static let userNotes = "userNotes"
    
     static let brushWidth = "brushWidth"
     
    static let isRepeatON = "isRepeatON"
    
    static let isAlreadyLogin = "isAlreadyLogin"
    
    static let totalSwipeCount = "totalSwipeCount"
    
    static let isPinOn = "isPinOn"
    
    
    
}

struct Tag{
    static let indicatorTag = 100
    static let blurviewTag = 101
}

struct LimitCount{
    static let JapJiShahib = 37
    static let Rehraas = 33
    static let story = 25
    static let commentCount = 500
    static let likeCount = 1000
}

struct AdsCount{
    static let Normal = 9
    static let Express = 6
}

struct AdsTime {
    static let Normal = 140
    static let Express = 100
}

struct NameConstant{
    static let LoginResponse = "LoginResponse"
}



class Constant: NSObject {
    
    static var  currentUserFlow : String = ""
    static var  dailySwipeLimit : Int = 15
    static var  isRangeUpdated : Bool = false
    static var  totalSwipeCount : Int = 0
    static var  latString : String = ""
    static var  lonString : String = ""
    
    static var  currentMatchedID : String = ""
    static var  brushWidth : Int = 10
    static var  currentUserColor : UIColor = UIColor.black
    static var  isRepeatON : Bool = true
    
    static var  bookName : String = "Genesis"
    static var  chapterNumber : Int = 0
    static var  versesNumber : Int = 0
    static var  currentTitle : String = "";
    static var  currentLimit : Int = 0
    
    static var isDarkModeOn : Bool = false
    static var voicePitch : CGFloat = 1.0
    static var voiceSpeed : CGFloat = 0.4
    static var fontName : String = "Helvetica"
    static var voiceLang : String = "English"
    static var fontSize : CGFloat = 24
    static var isVoiceOn : Bool = false
    static var isMeditationVoice : Bool = false
    static var videoDataArray = [AnyObject]()
    static var isAdmobFirst : Bool = false
    static var isAdLoaded : Bool = false
    static var appLoadFirstTime : Bool = true
    static var firstTime : Bool = false
    static var isAlreadyLogin : Bool = false
    
    
    static var youTubeKey : String = "AIzaSyCaR_mXCgOntiLYi1KDHJnHIo9jxs1iLt4"
    static var currentLanguage : String = "";
   
   static var currentUserID : String = "";
    static var currentPath : String = "";
   static var  counterTimer : Int = 20
   static var level : Int = 0
   static var expenseNumber : String = "";
   static let termsAndConditionsURL : String = "";
   static let privacyURL        : String    = "Privacy Policy";
    
    static var UserImage                                                : UIImage!
    
    static var syncNextQuestionID                                                = String()
    static var lastOrientation                                                = String()
    static var fromLogin : Bool = false
    static let window  = AppDelegate().window
    static var ShareUrl : URL                                           = URL(string: "https://developer.apple.com/documentation/uikit/uiview/1622574-transitionwithview")!
    static let BASE_URL: String                                         = "http://codeoptimalsolutions.com/introducer/index.php/"
    
    static var iconSize : CGFloat = 35
    static var stackSize : CGFloat = 200
    static var logoSize : CGFloat = 140
    static var txtViewSize : CGFloat = 45
    static var gameViewTopSize : CGFloat = 45
    static var resultStackWidthSize : CGFloat = 45
    static var resultStackHeightSize : CGFloat = 45
    
    
    //MARK:- Global Variables
    static let kAppDelegate                                             = UIApplication.shared.delegate
    static let AppWindow                                                : UIWindow = Constant.kAppDelegate!.window!!
    static let MainStoryboard                                           : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
    static let SlideMenuStoryboard                                      : UIStoryboard = UIStoryboard(name: "SlideMenu", bundle: nil)
    static let MapStoryboard                                            : UIStoryboard = UIStoryboard(name: "Map", bundle: nil)
    static let FriendsModuleStoryboard                                  : UIStoryboard = UIStoryboard(name: "FriendsModule", bundle: nil)
    static let NoUserImage                                              = UIImage.init(named: "no_user_image")!
    
    // GOOGLE CLIENT KEY
    static let GOOGLE_CLIENT_ID: String                                 = "523195447660-3af0jgc70ou6leso05rd19evd0hap105.apps.googleusercontent.com"
    static let GOOGLE_REVERSED_CLIENT_ID: String                        = "com.googleusercontent.apps.523195447660-3af0jgc70ou6leso05rd19evd0hap105"
    
    // FACEBOOK APP ID
    static let FACEBOOK_APP_ID: String                                  = "fb1338000882904457"
    
    // TWITTER INFORMATION
    static let TWITTER_CONSUMER_KEY: String                             = "pWOt9edXK89yRKXjYJBMY6E6N"
    static let TWITTER_CONSUMER_SECRET_KEY: String                      = "WUYXQmSpWnom0tN6kXLbSnXUhFKLJrsFeLPAvMBnYTaujWrUp5"
    
    // DEVICE INFORMATION
    static let DEVICE_ID: String                                        = UIDevice.current.identifierForVendor!.uuidString
    static var DEVICE_TOKEN: String                                     = ""
    static var SessionID                                                = ""
    static var UserID                                                   = ""
    static var currentAddress                                           = ""
    
    
    static var RalewayThinFont                                          = "Raleway-Thin"
    static var LoggedInUserData                                         = "loggedInUserData"
    static var AutoLogin                                                = "autoLogin"
    static var OpenSansSemiboldFont                                     = "OpenSans-Semibold"
    
    
    //MARK:- Web Service Actions
    
    //getPartyGamesDetails
    
    static let LoginApi      : String = "api/login"
    static let registerApi  : String = "api/addIntroducer"
    static let forgotApi: String = "api/recoveryPassword"
    
    //MARK:- Segue identifiers
    static let NavigationControllerIdentifier                           : String = "navigationController"
    static let LoginVCToHomeVCSegueIdentifier                           : String = "LoginVCToHomeVC"
    static let SignUpVCToHomeVCSegueIdentifier                          : String = "SignUpVCToHomeVC"
    static let LoginVCToForgotPasswordSegueIdentifier                   : String = "LoginVCToForgotPasswordVC"
    static let LoginVCToSignUpVCSegueIdentifier                         : String = "LoginVCToSignUpVC"
    static let HomeVCToProfileBaseVCSegueIdentifier                     : String = "HomeVCToProfileBaseVC"
    static let LoginVCToForgotPasswordVCSegueIdentifier                 : String = "LoginVCToForgotPasswordVC"
    static let HomeVCToUserProfileVCSegueIdentifier                     : String = "HomeVCToUserProfileVC"
    static let HomeVCToMapVCSegueIdentifier                             : String = "HomeVCToMapVC"
    static let HomeVCToFbarVCSegueIdentifier                            : String = "FbarVcIdsegue"
    static let HomeVCToProfileRatingVCSegueIdentifier                   : String = "profileRatingSegueID"
    static let ProfileBaseVCToReviewsVCSegueIdentifier                  : String = "ProfileBaseVCToReviewsVC"
    static let UserProfileVCToReviewsVCSegueIdentifier                  : String = "UserProfileVCToReviewsVC"
    static let UserProfileVCToChangePasswordVCSegueIdentifier           : String = "UserProfileVCToChangePasswordVC"
    static let ForgotPasswordVCToLoginVCSegueIdentifier                 : String = "ForgotPasswordVCToLoginVC"
    static let HomeCreateAlertVCToPartyDetailVCSegueIdentifier          : String = "HomeCreateAlertVCToPartyDetailVC"
    static let PartyDetailVCToUpdatePartyVC                             : String = "PartyDetailVCToUpdatePartyVC"
    static let CreatePartyVCToAddFriendsVCSegueIdentifier               : String = "CreatePartyVCToAddFriendsVC"
    static let UpdatePartyVCToAddFriendsVCSegueIdentifier               : String = "UpdatePartyVCToAddFriendsVC"
    static let PartyDetailVCToGroupChatVCSegueIdentifier                : String = "PartyDetailVCToGroupChatVC"
    static let PartyDetailVCToFriendRequestVCSegueIdentifier            : String = "PartyDetailVCToFriendRequestVC"
    static let PartyHistoryToPlayerReviewVCSegueIdentifier              : String = "PartyHistoryToPlayerReviewVCSegueID"
    static let PartyHistoryVCToGameHistorySegueIdentifier               : String = "PartyHistoryVCToGameHistoryVC"
    static let GameHistoryVCToStartPlayVCSegueIdentifier                : String = "GameHistoryVCToStartPlayVC"
    //MARK:-
    //MARK:- Table view cell identifier
    static let cellMenuIdentifier                                       : String = "cellMenuIdentifier"
    static let leaderBoardCellIdentifier                                : String = "cellIdentifier"
    static let friendsTableViewCellID                                   : String = "friendCellID"
    static let NotificationCellIdentifier                               : String = "notificationCellIdentifier"
    static let AddFriendsTableViewCellIdentifier                        : String = "AddFriendsTableViewCell"
    static let IncomingMsgCellIdentifier                                : String = "incomingMsgCellIdentifier"
    static let OutMsgCellIdentifier                                     : String = "outMsgCellIdentifier"
    static let PartyHistoryTableViewCellIdentifier                      : String = "PartyHistoryTableViewCell"
    static let GameHistoryTableViewCellIdentifier                       : String = "GameHistoryTableViewCell"
    static let PlayerReviewTableViewCellIdentifier                      : String = "PlayerReviewCellIdentifier"
    static let FriendsRequestTableViewCellCellIdentifier                : String = "FriendsRequestTableViewCellIdentifier"
    
    //MARK:- Storyboard ID
    static let LoginViewController                                      : String = "LoginVC"
    static let ProfileBaseVCStoryboardID                                : String = "ProfileBaseVCID"
    static let HomeViewControllerStoryboardID                           : String = "HomeViewControllerID"
    static let MapViewControllerStoryboardID                            : String = "MapViewControllerID"
    static let SuggestLocationVC                                        : String = "SuggestLocationVC"
    static let UserProfileViewControllerStoryboardID                    : String = "UserProfileViewControllerID"
    static let ReviewViewControllerID                                   : String = "ReviewViewControllerID"
    static let FriendsViewControllerID                                  : String = "FriendsViewControllerID"
    static let ChatVCStoryboardID                                       : String = "ChatVCStoryboardID"
    static let SuggestALocationVCStoryboardID                           : String = "SuggestLocationViewControllerID"
    static let ProfileBaseViewController                                : String = "ProfileBaseVCID"
    static let MyFriendsTableviewID                                     : String = "MyFriendsTableviewID"
    static let GroupChatVCStoryboardID                                  : String = "GroupChatVCStoryboardID"
    static let ForgotPasswordVCID                                       : String = "ForgotPasswordVCID"
    static let TeamSelectionVCStoryboardID                              : String = "TeamSelectionVCStoryboardID"
    static let PartyDetailVCStoryBoardID                                : String = "PartyDetailVCStoryBoardID"
    static let HomeCreateAlertVCStoryBoardID                            : String = "HomeCreateAlertVCStoryBoardID"
    static let PlayerReviewVCStoryBoardID                               : String = "PlayerReviewVCID"
    static let PagingVCStorboardID                                      : String = "PagingVCStorboardID"
    enum Default_Constants :String {
        
        case RemeberMe                                                  = "RememberMe"
        case user_info                                                  = "UserInfo"
        case EnglishLang                                                = "EnglishLang"
        case ArabicLang                                                 = "ArabicLang"
        case NotificationSettings                                       = "NotificationSettings"
        case UserDetails                                                = "UserDetails"
        case UserPhotos                                                 = "UserPhotos"
        
    }
    
    // MARK: - Image Constants
    
    static let RookieRankImage                                          = "rookie"
    static let ExperienceRankImage                                      = "experienced"
    static let MasterRankImage                                          = "master"
    static let VeteranRankImage                                         = "veteran"
    
    // MARK: - Dummy Strings
    static let PartyHistoryString = "{\"response\":{\"code\":200,\"status\":\"PARTIES_HISTORY_OF_USER_RETRIEVED_SUCCESSFULLY\",\"message\":\"SUCCESS\",\"result\":[{\"partyId\":172,\"partyName\":\"checkinglist\",\"partyLocationId\":104,\"partyLocationName\":\"dummyLocation123\",\"partyLocationAddress\":\"Chd\",\"locationRating\":\"0\",\"partyTime\":\"27-05-2017 04:59 PM\",\"partyGamesList\":[{\"gameId\":38,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/126_1495780649882.jpg\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Image\":\"N/A\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamA\",\"player1\":139,\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player2\":173,\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\"}},{\"gameId\":37,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/126_1495780649882.jpg\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Image\":\"N/A\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamA\",\"player1\":139,\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player2\":173,\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\"}},{\"gameId\":36,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/126_1495780649882.jpg\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Image\":\"N/A\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamB\",\"player1\":126,\"player1Name\":\"mamta\",\"player1Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/126_1495780649882.jpg\",\"player2\":140,\"player2Name\":\"xcxzc\",\"player2Image\":\"N/A\"}}]}]}}"
    static let GameHistoryString  = "{\"response\":{\"code\":200,\"status\":\"PARTY_GAMES_LIST_RETRIEVED_SUCCESSFULLY\",\"message\":\"SUCCESS\",\"result\":{\"partyGamesList\":[{\"hostId\":173,\"hostName\":\"FinalTest\",\"gameId\":36,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamB\",\"player1\":126,\"player1Name\":\"mamta\",\"player1Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/126_1495780649882.jpg\",\"player2\":140,\"player2Name\":\"xcxzc\",\"player2Image\":\"N/A\"}},{\"hostId\":173,\"hostName\":\"FinalTest\",\"gameId\":37,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamA\",\"player1\":139,\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player2\":173,\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\"}},{\"hostId\":173,\"hostName\":\"FinalTest\",\"gameId\":38,\"teams\":[{\"player1Id\":139,\"player2Id\":173,\"teamName\":\"TeamA\",\"player1Name\":\"MohdBilalHussain\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"FinalTest\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"},{\"player1Id\":126,\"player2Id\":140,\"teamName\":\"TeamB\",\"player1Name\":\"mamta\",\"player1Rating\":\"0\",\"player1Review\":\"Good!!\",\"player2Name\":\"xcxzc\",\"player2Rating\":\"0\",\"player2Review\":\"Good1!!\"}],\"winnerTeam\":{\"teamName\":\"TeamA\",\"player1\":139,\"player1Name\":\"MohdBilalHussain\",\"player1Image\":\"N/A\",\"player2\":173,\"player2Name\":\"FinalTest\",\"player2Image\":\"http://localhost:8080/balootSocialNetworkapp/ProfileImages/173_1495695240822.jpg\"}}]}}}"
    
    enum BackgroundColor :Int {
        
        case NoColor          = 0
        case DarkGreenColor   = 1
        case LightGreenColor  = 2
        case WhiteColor       = 3
    }
    
}
