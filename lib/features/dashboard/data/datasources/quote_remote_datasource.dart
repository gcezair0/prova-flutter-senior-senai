import 'package:dio/dio.dart';

import '../models/quote_model.dart';

abstract class QuoteRemoteDataSource {
  Future<QuoteModel> getRandomQuote();
}

class QuoteRemoteDataSourceImpl implements QuoteRemoteDataSource {
  final Dio _dio;

  QuoteRemoteDataSourceImpl(this._dio);

  @override
  Future<QuoteModel> getRandomQuote() async {
    final response = await _dio.get('/quotes/random');
    return QuoteModel.fromJson(response.data);
  }
}