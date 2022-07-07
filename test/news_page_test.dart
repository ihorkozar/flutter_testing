import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
import 'package:flutter_testing/news_change_notifier.dart';
import 'package:flutter_testing/news_page.dart';
import 'package:flutter_testing/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late MockNewsService mockNewsService;

  setUp(() {
    mockNewsService = MockNewsService();
  });

  final articles = [
    Article(title: 'title1', content: 'content1'),
    Article(title: 'title2', content: 'content2'),
    Article(title: 'title3', content: 'content3'),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async => articles);
  }

  void arrangeNewsServiceReturns3ArticlesWith3SecondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer((_) async {
      await Future.delayed(const Duration(seconds: 3));
      return articles;
    });
  }

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets('title is displayed', (widgetTester) async {
    arrangeNewsServiceReturns3Articles();
    await widgetTester.pumpWidget(createWidgetUnderTest());
    expect(find.text('News'), findsOneWidget);
  });

  testWidgets('loading indicator is displayed', (widgetTester) async {
    arrangeNewsServiceReturns3ArticlesWith3SecondWait();
    await widgetTester.pumpWidget(createWidgetUnderTest());
    await widgetTester.pump(const Duration(seconds: 1));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await widgetTester.pumpAndSettle();
  });

  testWidgets('articles are displayed', (widgetTester) async {
    arrangeNewsServiceReturns3Articles();
    await widgetTester.pumpWidget(createWidgetUnderTest());
    await widgetTester.pump();
    for (final article in articles) {
      expect(find.text(article.title), findsOneWidget);
      expect(find.text(article.content), findsOneWidget);
    }
  });
}
