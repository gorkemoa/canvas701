class ApiConstants {
  static const String baseUrl = 'https://api.canvas701.com/c701/v1.0.0/';

  // Basic Auth
  static const String apiUsername = 'C71VAhHsnC8HJN8nlvp9K5ycPoyMJM';
  static const String apiPassword = 'pRPa7vCAqHxtRsI17I1FBpPH57Edl0';

  // Auth
  static const String login = 'service/auth/login';
  static const String register = 'service/auth/register';
  static const String checkCode = 'service/auth/code/checkCode';
  static const String authSendCode = 'service/auth/code/authSendCode';

  // User
  static String getUser(int userId) => 'service/user/id/$userId';
  static String updateUser(int userId) => 'service/user/update/$userId/account';
  static const String updatePassword = 'service/user/update/password';

  // Products
  static const String getCategories = 'service/products/category/list/0';
  static const String allProducts = 'service/products/product/list/all';
  static const String filterList = 'service/products/product/list/filterList';
  static String getProductDetail(int productId) =>
      'service/products/product/detail/$productId';

  // Address
  static const String addAddress = 'service/user/account/address/add';
  static const String updateAddress = 'service/user/account/address/update';
  static const String getUserAddresses = 'service/user/account/address/list';
  static const String getCities = 'service/general/general/cities/all';
  static String getDistrictsByCity(int cityId) =>
      'service/general/general/$cityId/districts';

  // General
  static const String kvkkAgreement =
      'service/general/general/contracts/kvkkAgreement';
}
