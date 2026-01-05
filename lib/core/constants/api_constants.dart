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
}
