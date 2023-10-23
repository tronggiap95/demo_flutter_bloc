import 'package:octo360/presentation/navigation/navigation_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

//Enter the command below to generate new Strings
//flutter gen-l10n
class StringsApp {
  static AppLocalizations getLocalization() {
    // fixme, to many null check operators
    return AppLocalizations.of(NavigationApp.navigatorKey.currentContext!)!;
  }

  ///
  ///OTHER TEXT
  ///
  static String replaceValue = '#value#';
  static String get perDay => getLocalization().perDay;
  static String get oneDayAgo => getLocalization().oneDayAgo;
  static String get valueDaysAgo => getLocalization().valueDaysAgo;
  static String get oneHourAgo => getLocalization().oneHourAgo;
  static String get valueHoursAgo => getLocalization().valueHoursAgo;
  static String get oneMinuteAgo => getLocalization().oneMinuteAgo;
  static String get valueMinutesAgo => getLocalization().valueMinutesAgo;
  static String get activeValueHAgo => getLocalization().activeValueHAgo;
  static String get activeValueMAgo => getLocalization().activeValueMAgo;
  static String get oneHourAgoShort => getLocalization().oneHourAgoShort;
  static String get valueHoursAgoShort => getLocalization().valueHoursAgoShort;
  static String get oneMinuteAgoShort => getLocalization().oneMinuteAgoShort;
  static String get valueMinutesAgoShort =>
      getLocalization().valueMinutesAgoShort;
  static String get today => getLocalization().today;
  static String get yesterday => getLocalization().yesterday;
  static String get justNow => getLocalization().justNow;
  static String get day => getLocalization().day;
  static String get day_ => getLocalization().day_;
  static String get week => getLocalization().week;
  static String get month => getLocalization().month;
  static String get year => getLocalization().year;
  static String get h => getLocalization().h;
  static String get m => getLocalization().m;

  static String get connecting => getLocalization().connecting;
  static String get studyPaused => getLocalization().studyPaused;
  static String get left => getLocalization().left;
  static String get goodContact => getLocalization().goodContact;
  static String get badContact => getLocalization().badContact;
  static String get partialContact => getLocalization().partialContact;
  static String get electrodes => getLocalization().electrodes;
  static String get settingUp => getLocalization().settingUp;
  static String get studyProgress => getLocalization().studyProgress;
  static String get paused => getLocalization().paused;
  static String get dataUploading => getLocalization().dataUploading;
  static String get dataUploaded => getLocalization().dataUploaded;
  static String get completed => getLocalization().completed;
  static String get fullyCharged => getLocalization().fullyCharged;
  static String get untilFull => getLocalization().untilFull;
  static String get remaining => getLocalization().remaining;
  static String get pairNow => getLocalization().pairNow;
  static String get scanningForDevice => getLocalization().scanningForDevice;
  static String get makeSureDeviceDiscoverableOctobeat =>
      getLocalization().makeSureDeviceDiscoverableOctobeat;
  static String get deviceNotFound => getLocalization().deviceNotFound;
  static String get tapToConnect => getLocalization().tapToConnect;
  static String get scanAgain => getLocalization().scanAgain;
  static String get connectSuccessfully =>
      getLocalization().connectSuccessfully;
  static String get pairSuccessfully => getLocalization().pairSuccessfully;
  static String get home => getLocalization().home;
  static String get connectYourDevice => getLocalization().connectYourDevice;
  static String get explore => getLocalization().explore;
  static String get bluetoothIsNotAvailable =>
      getLocalization().bluetoothIsNotAvailable;
  static String get toConnectWithOctobeatDevice =>
      getLocalization().toConnectWithOctobeatDevice;
  static String get goToSettings => getLocalization().goToSettings;
  static String get cancel => getLocalization().cancel;
  static String get failedToConnectDevice =>
      getLocalization().failedToConnectDevice;
  static String get somethingWentWrongPleaseMakeSure =>
      getLocalization().somethingWentWrongPleaseMakeSure;
  static String get tryAgain => getLocalization().tryAgain;
  static String get failedToStartStudy => getLocalization().failedToStartStudy;
  static String get pleaseTryConnecting =>
      getLocalization().pleaseTryConnecting;
  static String get studyAborted => getLocalization().studyAborted;
  static String get okay => getLocalization().okay;
  static String get octo360WouldLikeToAccessBluetooth =>
      getLocalization().octo360WouldLikeToAccessBluetooth;
  static String get octo360WouldLikeToAccessLocation =>
      getLocalization().octo360WouldLikeToAccessLocation;
  static String get pleaseEnableTheBluetooth =>
      getLocalization().pleaseEnableTheBluetooth;
  static String get pleaseEnableTheLocation =>
      getLocalization().pleaseEnableTheLocation;
  static String get openSettings => getLocalization().openSettings;
  static String get connectOctobeatDevice =>
      getLocalization().connectOctobeatDevice;
  static String get connectingToOctobeatPleaseWait =>
      getLocalization().connectingToOctobeatPleaseWait;
  static String get charging => getLocalization().charging;
  static String get online => getLocalization().online;
  static String get offline => getLocalization().offline;
  static String get percent => getLocalization().percent;
  static String get userManual => getLocalization().userManual;
  static String get quickGuide => getLocalization().quickGuide;
  static String get quickGuideVideos => getLocalization().quickGuideVideos;
  static String get troubleshooting => getLocalization().troubleshooting;
  static String get contactSupport => getLocalization().contactSupport;
  static String get quickGuideToUseDevice =>
      getLocalization().quickGuideToUseDevice;
  static String get commonIssuesLead => getLocalization().commonIssuesLead;
  static String get commonIssuesServer => getLocalization().commonIssuesServer;
  static String get commonIssuesStudy => getLocalization().commonIssuesStudy;
  static String get study => getLocalization().study;
  static String get progress => getLocalization().progress;
  static String get battery => getLocalization().battery;
  static String get deviceConnection => getLocalization().deviceConnection;
  static String get selectYourIssueToView =>
      getLocalization().selectYourIssueToView;
  static String get leadConnection => getLocalization().leadConnection;
  static String get serverConnection => getLocalization().serverConnection;
  static String get theDeviceIsOfflineThisOccurs =>
      getLocalization().theDeviceIsOfflineThisOccurs;
  static String get ensureThatTheDeviceIsPoweredOcto =>
      getLocalization().ensureThatTheDeviceIsPoweredOcto;
  static String get wirelessSignalLevel =>
      getLocalization().wirelessSignalLevel;
  static String get ifYouHaveTriedTheSuggestedSolutions =>
      getLocalization().ifYouHaveTriedTheSuggestedSolutions;
  static String get yourStudyPausesAutomatically =>
      getLocalization().yourStudyPausesAutomatically;
  static String get theDeviceMightNotBe =>
      getLocalization().theDeviceMightNotBe;
  static String get confirmTheDeviceIsPowered =>
      getLocalization().confirmTheDeviceIsPowered;
  static String get pleaseWait => getLocalization().pleaseWait;
  static String get deviceDisconnectedPleaseMakeSure =>
      getLocalization().deviceDisconnectedPleaseMakeSure;
  static String get yourDeviceHasBeenOffline =>
      getLocalization().yourDeviceHasBeenOffline;
  static String get oneOrMoreElectrodesSeem =>
      getLocalization().oneOrMoreElectrodesSeem;
  static String get leaveMonitoring => getLocalization().leaveMonitoring;
  static String get leaveMonitoringMsg => getLocalization().leaveMonitoringMsg;
  static String get areYouSureYouWishRemove =>
      getLocalization().areYouSureYouWishRemove;
  static String get remove => getLocalization().remove;
  static String get noInternetConnection =>
      getLocalization().noInternetConnection;
  static String get noInternetConnectionTitle =>
      getLocalization().noInternetConnectionTitle;
  static String get settings => getLocalization().settings;
  static String get somethingWentWrong => getLocalization().somethingWentWrong;
  static String get waitingForTheStudyTo =>
      getLocalization().waitingForTheStudyTo;
  static String get detailIssueWarning => getLocalization().detailIssueWarning;
  static String get viewSolution => getLocalization().viewSolution;
  static String get attentionNeeded => getLocalization().attentionNeeded;
  static String get oneOrMoreElectrodesHave =>
      getLocalization().oneOrMoreElectrodesHave;
  static String get yourDeviceBatterySeemsLow =>
      getLocalization().yourDeviceBatterySeemsLow;
  static String get bluetoothIsDisabledPleaseEnableIt =>
      getLocalization().bluetoothIsDisabledPleaseEnableIt;
  static String get yourDeviceHasBeenOfflineFor =>
      getLocalization().yourDeviceHasBeenOfflineFor;
  static String get connectionTroubleshoot =>
      getLocalization().connectionTroubleshoot;
  static String get proceedWithAssistance =>
      getLocalization().proceedWithAssistance;
  static String get learnMore => getLocalization().learnMore;
  static String get viewGuide => getLocalization().viewGuide;
  static String get unifieldMaleAndFemaleApplication =>
      getLocalization().unifieldMaleAndFemaleApplication;
  static String get alternativePlacementOption =>
      getLocalization().alternativePlacementOption;
  static String get thingNotToDo => getLocalization().thingNotToDo;
  static String get dontPowerOff => getLocalization().dontPowerOff;
  static String get octobeatDevice => getLocalization().octobeatDevice;
  static String get back => getLocalization().back;
  static String get next => getLocalization().next;
  static String get gotIt => getLocalization().gotIt;
  static String get raFirstPageContent => getLocalization().raFirstPageContent;
  static String get llFirstPageContent => getLocalization().llFirstPageContent;
  static String get laFirstPageContent => getLocalization().laFirstPageContent;
  static String get raSecondPageContent =>
      getLocalization().raSecondPageContent;
  static String get llSecondPageContent =>
      getLocalization().llSecondPageContent;
  static String get laSecondPageContent =>
      getLocalization().laSecondPageContent;
  static String get connectToYourOctobeatFor =>
      getLocalization().connectToYourOctobeatFor;
  static String get connectNow => getLocalization().connectNow;
  static String get weCantFindAnythingHere =>
      getLocalization().weCantFindAnythingHere;
  static String get itSeemsLikeThereIsNo =>
      getLocalization().itSeemsLikeThereIsNo;
  static String get pleaseMakeSureTheSignIn =>
      getLocalization().pleaseMakeSureTheSignIn;
  static String get weAreCompletingTheNecessary =>
      getLocalization().weAreCompletingTheNecessary;
  static String get palpitations => getLocalization().palpitations;
  static String get shortnessOfBreath => getLocalization().shortnessOfBreath;
  static String get chestPainOrPressure =>
      getLocalization().chestPainOrPressure;
  static String get dizziness => getLocalization().dizziness;
  static String get other => getLocalization().other;
  static String get close => getLocalization().close;
  static String get submit => getLocalization().submit;
  static String get selectSymptoms => getLocalization().selectSymptoms;
  static String get theEventWillBeSent => getLocalization().theEventWillBeSent;
  static String get byContinuingYouAgree =>
      getLocalization().byContinuingYouAgree;
  static String get continue_ => getLocalization().continue_;
  static String get privacyPolicy => getLocalization().privacyPolicy;
  static String get termsAndConditions => getLocalization().termsAndConditions;
  static String get understood => getLocalization().understood;
  static String get confirm => getLocalization().confirm;
  static String get youCantReceiveCode => getLocalization().youCantReceiveCode;
  static String get resendAfterSecond => getLocalization().resendAfterSecond;
  static String get resendRightAway => getLocalization().resendRightAway;
  static String get invalidPhoneNumber => getLocalization().invalidPhoneNumber;
  static String get startWithYourPhoneNumber =>
      getLocalization().startWithYourPhoneNumber;
  static String get trackingHealthPhysicAndLife =>
      getLocalization().trackingHealthPhysicAndLife;
  static String get enterOtpSentToPhoneNumber =>
      getLocalization().enterOtpSentToPhoneNumber;
  static String get enterOtp => getLocalization().enterOtp;
  static String get start => getLocalization().start;
  static String get welcome1 => getLocalization().welcome1;
  static String get pleaseFillInYourFullName =>
      getLocalization().pleaseFillInYourFullName;
  static String get lastNameExample => getLocalization().lastNameExample;
  static String get fillYourLastName => getLocalization().fillYourLastName;
  static String get middleAndFirstNameExample =>
      getLocalization().middleAndFirstNameExample;
  static String get fillYourMiddleAndFirstName =>
      getLocalization().fillYourMiddleAndFirstName;
  static String get complete => getLocalization().complete;
  static String get contactInformation => getLocalization().contactInformation;
  static String get customerSupport => getLocalization().customerSupport;
  static String get email => getLocalization().email;
  static String get phoneNumber => getLocalization().phoneNumber;
  static String get done => getLocalization().done;
  static String get manualEventTriggered =>
      getLocalization().manualEventTriggered;
  static String get sessionIsExpired => getLocalization().sessionIsExpired;
  static String get somethingWentWrongTryAgain =>
      getLocalization().somethingWentWrongTryAgain;
  static String get noInternetConnectionTryAgain =>
      getLocalization().noInternetConnectionTryAgain;
  static String get otpCodeIncorrect => getLocalization().otpCodeIncorrect;
  static String get completedStudy => getLocalization().completedStudy;
  static String get yourStudyOnOctobeatHas =>
      getLocalization().yourStudyOnOctobeatHas;
  static String get hour => getLocalization().hour;
  static String get minute => getLocalization().minute;
  static String get lowBaterry => getLocalization().lowBaterry;
}
