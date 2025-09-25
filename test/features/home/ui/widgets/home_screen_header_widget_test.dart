import 'dart:convert';

import 'package:bookapp_customer/app/assets_path.dart';
import 'package:bookapp_customer/features/home/data/models/home_models.dart';
import 'package:bookapp_customer/features/home/providers/home_provider.dart';
import 'package:bookapp_customer/features/home/ui/widgets/home_screen_header_widget.dart';
import 'package:bookapp_customer/features/vendors/models/admin_model.dart';
import 'package:bookapp_customer/network_service/core/home_network_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

class _FakeHomeNetworkService extends HomeNetworkService {
  _FakeHomeNetworkService(this.section);
  final SectionContent section;

  @override
  Future<HomeResponse> getHome() async {
    return HomeResponse(
      admin: AdminModel.empty(),
      sectionContent: section,
      categories: const [],
      featuredServices: const [],
      latestServices: const [],
      featuredVendors: const [],
      processes: const [],
      testimonials: const [],
    );
  }
}

class _StubHomeProvider extends HomeProvider {
  _StubHomeProvider(this._section) : super(_FakeHomeNetworkService(_section));
  final SectionContent _section;
  @override
  SectionContent? get sections => _section;
}

Future<void> _mockHomeHeaderAssets() async {
  // Minimal valid SVG payload to satisfy flutter_svg in tests
  const svg =
      '<svg viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><circle cx="12" cy="12" r="10"/></svg>';
  final svgBytes = Uint8List.fromList(utf8.encode(svg));

  // 1x1 transparent PNG
  final pngBytes = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO2N0NcAAAAASUVORK5CYII=',
  );

  // Asset manifest (.bin) with our png listed
  final manifestMap = <String, List<Map<String, Object?>>>{
    AssetsPath.topBGPng: <Map<String, Object?>>[
      <String, Object?>{'asset': AssetsPath.topBGPng, 'dpr': 1.0},
    ],
  };
  final manifestBin = const StandardMessageCodec().encodeMessage(manifestMap) as ByteData;
  final manifestJson = jsonEncode({
    AssetsPath.topBGPng: [AssetsPath.topBGPng],
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (message == null) return null;
    final key = utf8.decode(message.buffer.asUint8List());
    if (key == 'AssetManifest.bin') {
      return manifestBin;
    }
    if (key == 'AssetManifest.json') {
      final bytes = Uint8List.fromList(utf8.encode(manifestJson));
      return ByteData.sublistView(bytes);
    }
    if (key == AssetsPath.searchIconSvg) {
      return ByteData.sublistView(svgBytes);
    }
    if (key == AssetsPath.topBGPng) {
      return ByteData.sublistView(pngBytes);
    }
    return null; // fall back for others
  });
}

Widget _wrapWithProviders(Widget child, HomeProvider home) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<HomeProvider>.value(value: home),
    ],
    child: MaterialApp(
      home: Scaffold(
        body: Center(
          // Constrain to ensure Positioned search bar fits
          child: SizedBox(height: 240, child: child),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('HomeScreenHeaderWidget', () {
    testWidgets('renders hero title, subtitle, and text', (tester) async {
      await _mockHomeHeaderAssets();

      final section = SectionContent(
        categorySectionTitle: 'Categories',
        latestServiceSectionTitle: 'Latest',
        featuredServiceSectionTitle: 'Featured',
        vendorSectionTitle: 'Vendors',
        // Force local asset branch so header content is built immediately
        heroBackgroundImg: '',
        heroTitle: 'Welcome to BookApp',
        heroSubtitle: 'Find and book services',
        heroText: 'BookApp Platform',
      );

      final homeProvider = _StubHomeProvider(section);

      await tester.pumpWidget(
        _wrapWithProviders(const HomeScreenHeaderWidget(), homeProvider),
      );
      // Allow CachedNetworkImage to resolve to errorWidget and build header content
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      // Subtitle and body text should render
      expect(find.text('Find and book services'), findsOneWidget);
      expect(find.text('BookApp Platform'), findsOneWidget);

      // Search field and button present
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byTooltip('Search'), findsOneWidget);
    });

    testWidgets('does not navigate on empty search', (tester) async {
      await _mockHomeHeaderAssets();

      final section = SectionContent(
        categorySectionTitle: 'Categories',
        latestServiceSectionTitle: 'Latest',
        featuredServiceSectionTitle: 'Featured',
        vendorSectionTitle: 'Vendors',
        // Use network URL so CachedNetworkImage shows errorWidget which includes content
        heroBackgroundImg: 'https://example.invalid/bg.png',
        heroTitle: 'Hero',
        heroSubtitle: 'Sub',
        heroText: 'Text',
      );

      final homeProvider = _StubHomeProvider(section);

      final navObserver = _RecordingNavigatorObserver();

      final app = MultiProvider(
        providers: [
          ChangeNotifierProvider<HomeProvider>.value(value: homeProvider),
        ],
        child: MaterialApp(
          navigatorObservers: [navObserver],
          home: const Scaffold(body: HomeScreenHeaderWidget()),
        ),
      );

      await tester.pumpWidget(app);
      await tester.pump();
      // Ignore the initial route push by MaterialApp
      navObserver.pushedRoutes.clear();

      // Tap search without entering text
      await tester.tap(find.byTooltip('Search'));
      await tester.pump();

      expect(navObserver.pushedRoutes, isEmpty);
    });
  });
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  final List<Route<dynamic>> pushedRoutes = <Route<dynamic>>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route);
    super.didPush(route, previousRoute);
  }
}
