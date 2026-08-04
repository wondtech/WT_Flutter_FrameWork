// ************************************************************
// * WT Flutter FrameWork — Example
// * @version : 1.4
// * @copyright : 2026 WondTech for Integrated Digital Solutions
// * @link : http://www.wondtech.com
// ************************************************************
//
// A tour of the framework: MVC (controller + view + model), the animation
// layer, WtI18n bilingual/RTL, WtTheme, WtValidator, and page transitions.

import 'package:flutter/material.dart';
import 'package:wt_framework/wt.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await WtSession.init(); // session_start()

  WtConfig.init(WtConfig(
    appName: 'WT Example',
    baseUrl: 'https://jsonplaceholder.typicode.com',
    secretKey: 'wt_demo_secret',
    theme: WtTheme.light(),
    pageTransition: WtTransition.fade, // default transition for all routes
    maxRetries: 2, // GET requests retry transient failures
  ));

  await WtI18n.instance.init(translations: _translations);

  runApp(const ExampleApp());
}

final WtRouter _router = WtRouter(
  initialRoute: '/',
  routes: [
    WtRoute(path: '/', builder: HomeController.new),
    WtRoute(
      path: '/form',
      builder: FormController.new,
      transition: WtTransition.slideRight,
    ),
    WtRoute(
      path: '/posts',
      builder: PostsController.new,
      transition: WtTransition.slideUp,
    ),
  ],
);

/// Root: rebuilds on language change and applies text direction correctly.
class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return WtI18n.instance.app(
      (context) => MaterialApp(
        title: 'WT Example',
        debugShowCheckedModeBanner: false,
        theme: WtTheme.light(),
        locale: WtI18n.instance.locale,
        builder: WtI18n.instance.applyDirection,
        onGenerateRoute: _router.dispatch,
        initialRoute: _router.initialRoute,
      ),
    );
  }
}

// ── Home ────────────────────────────────────────────────────────────────────

class HomeController extends WtController {
  HomeController(super.settings);

  @override
  WtView view(BuildContext context) {
    final v = _HomeView();
    v.assign('title', WtI18n.tr('app_title'));
    v.assign('onForm', () => navigate(context, '/form'));
    v.assign('onPosts', () => navigate(context, '/posts'));
    return v;
  }
}

class _HomeView extends WtView {
  @override
  Widget build(BuildContext context) {
    final onForm = get<VoidCallback>('onForm')!;
    final onPosts = get<VoidCallback>('onPosts')!;
    return scaffold(
      context: context,
      actions: [
        TextButton(
          onPressed: WtI18n.instance.toggle,
          child: Text(WtI18n.instance.isRtl ? 'EN' : 'ع'),
        ),
      ],
      body: Padding(
        padding: WtTheme.all(WtTheme.lg),
        child: WtStagger(
          children: [
            Text(
              WtI18n.tr('welcome'),
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            WtTheme.vGap(WtTheme.lg),
            _MenuCard(
              icon: Icons.edit_outlined,
              label: WtI18n.tr('form_demo'),
              onTap: onForm,
            ),
            WtTheme.vGap(WtTheme.md),
            _MenuCard(
              icon: Icons.cloud_download_outlined,
              label: WtI18n.tr('posts_demo'),
              onTap: onPosts,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  const _MenuCard(
      {required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(label),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ── Form (WtValidator) ───────────────────────────────────────────────────────

class FormController extends WtController {
  FormController(super.settings);

  @override
  WtView view(BuildContext context) => _FormView();
}

class _FormView extends WtView {
  @override
  Widget build(BuildContext context) => const _LoginForm();
}

class _LoginForm extends StatefulWidget {
  const _LoginForm();

  @override
  State<_LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<_LoginForm> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(WtI18n.tr('form_demo'))),
      body: Padding(
        padding: WtTheme.all(WtTheme.lg),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: WtI18n.tr('email')),
                validator: WtValidator.compose([
                  WtValidator.required(),
                  WtValidator.email(),
                ]),
              ).wtFadeIn(),
              WtTheme.vGap(WtTheme.md),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(labelText: WtI18n.tr('password')),
                validator: WtValidator.minLength(6),
              ).wtFadeIn(delay: const Duration(milliseconds: 120)),
              WtTheme.vGap(WtTheme.xl),
              FilledButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    WtHelper.flash(context, WtI18n.tr('form_ok'));
                  }
                },
                child: Text(WtI18n.tr('submit')),
              ).wtSlideUp(delay: const Duration(milliseconds: 240)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Posts (WtModel + WtAsyncView) ────────────────────────────────────────────

class Post {
  Post({required this.title, required this.body});

  factory Post.fromJson(Map<String, dynamic> j) => Post(
      title: j['title'] as String? ?? '', body: j['body'] as String? ?? '');

  final String title;
  final String body;
}

class PostModel extends WtModel<Post> {
  @override
  String get endpoint => '/posts';

  @override
  Post fromJson(Map<String, dynamic> json) => Post.fromJson(json);
}

class PostsController extends WtController {
  PostsController(super.settings);

  @override
  WtView view(BuildContext context) => _PostsView();
}

class _PostsView extends WtAsyncView<List<Post>> {
  @override
  Future<List<Post>> loadData() => PostModel().fetchAll();

  @override
  Widget buildData(BuildContext context, List<Post> posts) {
    return Scaffold(
      appBar: AppBar(title: Text(WtI18n.tr('posts_demo'))),
      body: ListView.builder(
        itemCount: posts.length.clamp(0, 15),
        itemBuilder: (context, i) => Card(
          child: ListTile(
            title: Text(posts[i].title,
                maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(posts[i].body,
                maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
        ).wtStagger(index: i),
      ),
    );
  }
}

// ── Translations ─────────────────────────────────────────────────────────────

const Map<String, Map<String, String>> _translations = {
  'en': {
    'app_title': 'WT Framework',
    'welcome': 'Welcome to the WT Flutter Framework',
    'form_demo': 'Form & validation',
    'posts_demo': 'Fetch posts (WtModel)',
    'email': 'Email',
    'password': 'Password',
    'submit': 'Submit',
    'form_ok': 'Looks good!',
  },
  'ar': {
    'app_title': 'إطار WT',
    'welcome': 'مرحباً بك في إطار WT لفلاتر',
    'form_demo': 'النماذج والتحقّق',
    'posts_demo': 'جلب المنشورات (WtModel)',
    'email': 'البريد الإلكتروني',
    'password': 'كلمة المرور',
    'submit': 'إرسال',
    'form_ok': 'ممتاز!',
  },
};
