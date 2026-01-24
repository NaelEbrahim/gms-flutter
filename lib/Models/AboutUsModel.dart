class AboutUsModel {
  final String gymName;
  final String gymDescription;
  final String ourMission;
  final String ourVision;
  final String? facebookLink;
  final String? twitterLink;
  final String? instagramLink;

  AboutUsModel({
    required this.gymName,
    required this.gymDescription,
    required this.ourMission,
    required this.ourVision,
    required this.facebookLink,
    required this.twitterLink,
    required this.instagramLink,
  });

  factory AboutUsModel.fromJson(json) {
    return AboutUsModel(
      gymName: json['gymName'],
      gymDescription: json['gymDescription'],
      ourMission: json['ourMission'],
      ourVision: json['ourVision'],
      facebookLink: json['facebookLink'],
      twitterLink: json['twitterLink'],
      instagramLink: json['instagramLink'],
    );
  }

}
