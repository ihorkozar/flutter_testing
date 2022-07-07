import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing/article.dart';
import 'package:flutter_testing/article_page.dart';
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

  Widget createWidgetUnderTest() {
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: const NewsPage(),
      ),
    );
  }

  testWidgets('open detail screen', (widgetTester) async {
    arrangeNewsServiceReturns3Articles();
    await widgetTester.pumpWidget(createWidgetUnderTest());
    await widgetTester.pump();
    await widgetTester.tap(find.text('content1'));
    await widgetTester.pumpAndSettle();
    expect(find.byType(NewsPage), findsNothing);
    expect(find.byType(ArticlePage), findsOneWidget);
    expect(find.text('title1'), findsOneWidget);
    expect(find.text('content1'), findsOneWidget);
  });
}
