import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api_constants.dart';
import '../model/special_models.dart';
import 'base_service.dart';

class SpecialService extends BaseService {
  static final SpecialService _instance = SpecialService._internal();
  factory SpecialService() => _instance;
  SpecialService._internal();

  Future<SpecialTableResponse> addSpecialTable(SpecialTableRequest request) async {
    final url = Uri.parse('${ApiConstants.baseUrl}${ApiConstants.addSpecialTable}');

    logRequest('POST', url.toString(), request.toJson());

    try {
      final response = await http.post(
        url,
        headers: getHeaders(),
        body: jsonEncode(request.toJson()),
      );

      logResponse(response.statusCode, response.body);

      if (response.statusCode == 403) {
        // Token expired handled by TokenManager if needed
        return SpecialTableResponse(
          error: true,
          success: false,
          data: SpecialTableData(status: 'error', message: 'Oturum süresi doldu (403)'),
        );
      }

      final responseData = jsonDecode(response.body);
      final specialResponse = SpecialTableResponse.fromJson(responseData);

      return specialResponse;
    } catch (e) {
      return SpecialTableResponse(
        error: true,
        success: false,
        data: SpecialTableData(status: 'error', message: e.toString()),
      );
    }
  }
}
