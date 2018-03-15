class Publication {
  Publication(String photo, String title, String detail, String price,
      String paymentMethod,String url) {
    this.photo = photo;
    this.title = title;
    this.detail = detail;
    this.price = price;
    this.paymentMethod = paymentMethod;
    this.url=url;

  }

  String photo;
  String title;
  String detail;
  String price;
  String paymentMethod;
  String url;

  bool get isValid => photo != null && title != null && detail != null;
}
