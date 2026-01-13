class ApiConstants {
  static const String baseUrl = 'https://api.canvas701.com/c701/v1.0.0/';

  // Basic Auth
  static const String apiUsername = 'C71VAhHsnC8HJN8nlvp9K5ycPoyMJM';
  static const String apiPassword = 'pRPa7vCAqHxtRsI17I1FBpPH57Edl0';

  // Auth
  static const String login = 'service/auth/login';
  static const String loginSocial = 'service/auth/loginSocial';
  static const String register = 'service/auth/register';
  static const String checkCode = 'service/auth/code/checkCode';
  static const String authSendCode = 'service/auth/code/authSendCode';
  static const String forgotPassword = 'service/auth/forgotPassword';
  static const String forgotPasswordUpdate = 'service/auth/forgotPassword/updatePass';

  // User
  static String getUser(int userId) => 'service/user/id/$userId';
  static String updateUser(int userId) => 'service/user/update/$userId/account';
  static const String updatePassword = 'service/user/update/password';
  static const String getFavorites = 'service/user/account/favorites/list';
  static const String addDeleteFavorite =
      'service/user/account/favorites/addDelete';

  // Products
  static const String getCategories = 'service/products/category/list/0';
  static const String allProducts = 'service/products/product/list/all';
  static const String filterList = 'service/products/product/list/filterList';
  static String getProductDetail(int productId) =>
      'service/products/product/detail/$productId';

  // Address
  static const String addAddress = 'service/user/account/address/add';
  static const String updateAddress = 'service/user/account/address/update';
  static const String deleteAddress = 'service/user/account/address/delete';
  static const String getUserAddresses = 'service/user/account/address/list';
  static const String getUserCoupons = 'service/user/account/coupon/list';
  static const String getCities = 'service/general/general/cities/all';
  static const String getSizeList = 'service/general/general/sizes/list';
  static String getDistrictsByCity(int cityId) =>
      'service/general/general/$cityId/districts';

  // General
  static const String kvkkAgreement =
      'service/general/general/contracts/kvkkAgreement';
  static const String bannerList = 'service/general/general/banner/list';
  static const String getSpecials = 'service/general/general/specials/list';

  // Basket
  static const String addBasket = 'service/user/account/basket/add';
  static const String updateBasket = 'service/user/account/basket/update';
  static const String deleteBasket = 'service/user/account/basket/delete';
  static const String clearBasket = 'service/user/account/basket/clear';
  static const String getUserBaskets = 'service/user/account/basket/list';
  static const String useCoupon = 'service/user/account/coupon/use';
  static const String cancelCoupon = 'service/user/account/coupon/cancel';

  // Orders
  static const String getUserOrders = 'service/user/account/order/list';
  static const String getOrderStatusList = 'service/general/general/order/statusList';
  static const String getOrderDetail = 'service/user/account/order/detail';

  // Special Table
  static const String addSpecialTable = 'service/user/account/special/add';

  // Tickets
  static const String getTickets = 'service/user/account/tickets/list';
  static const String getTicketDetail = 'service/user/account/tickets/detail';
  static const String addTicket = 'service/user/account/tickets/create';
  static const String sendTicketMessage = 'service/user/account/tickets/sendMessage';
  static const String getTicketSubjects = 'service/general/general/contact/subjects';
}
