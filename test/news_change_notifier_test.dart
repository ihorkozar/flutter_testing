import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
import 'package:flutter_testing/news_change_notifier.dart';
import 'package:flutter_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut;
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test('correct initial values', () {
    expect(sut.articles, []);
    expect(sut.isLoading, false);
  });

  group('getArticles', () {
    final articles = [
      Article(title: 'title1', content: 'content1'),
      Article(title: 'title2', content: 'content2'),
      Article(title: 'title3', content: 'content3'),
    ];

    void arrangeNewsServiceReturns3Articles() {
      when(() => mockNewsService.getArticles())
          .thenAnswer((_) async => articles);
    }

    test('getArticles using the NewsService', () async {
      when(() => mockNewsService.getArticles()).thenAnswer((_) async => []);
      await sut.getArticles();
      verify(() => mockNewsService.getArticles()).called(1);
    });

    test('''indicates loading of data
    sets articles to the ones from service
    indicates that data is not being loaded anymore''', () async {
      arrangeNewsServiceReturns3Articles();
      final future = sut.getArticles();
      expect(sut.isLoading, true);
      await future;
      expect(sut.isLoading, false);
      expect(sut.articles.length, 3);
      expect(sut.articles, articles);
    });
  });
}
