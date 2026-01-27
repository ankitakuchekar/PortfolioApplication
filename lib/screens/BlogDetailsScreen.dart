import 'dart:convert';
import 'package:bold_portfolio/screens/BlogsListPageScreen.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_html_table/flutter_html_table.dart'; // Import this
// import 'package:flutter_html_iframe/flutter_html_iframe.dart'; // Import this

class BlogDetailsPage extends StatelessWidget {
  final String title;

  const BlogDetailsPage({super.key, required this.title});

  String formatDate(String date) {
    try {
      return DateFormat('MM/dd/yyyy').format(DateTime.parse(date));
    } catch (_) {
      return '-';
    }
  }

  Future<Blog> fetchBlogDetails(String title) async {
    final baseUrl = dotenv.env['API_URL']!;
    print("title ${title}");
    final url = Uri.parse('$baseUrl/UI/GetBPMBlogs?title=$title');

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load blog details');
    }
    print("url ${url}");
    final jsonResponse = json.decode(response.body);
    final list = jsonResponse['data']['items']['dataList'] as List;
    print("list ${list}");
    return Blog.fromJson(list.first);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Blog Details"),
        backgroundColor: Colors.black,
      ),
      body: FutureBuilder<Blog>(
        future: fetchBlogDetails(title),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text.rich(
                    TextSpan(
                      text:
                          ' Blog Not Found', // First part of the message (bold)
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.error, // Set color for error message
                      ),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      fetchBlogDetails(title);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final blogData = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// 🟢 TITLE
                Text(
                  blogData.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                /// 🖼 IMAGE
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    blogData.image,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(height: 5),

                /// 📅 DATE + SHARE
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Published on ${formatDate(blogData.publishDate)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                    BlogShareComponent(
                      title: blogData.title,
                      showShareText: false,
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                /// 👤 AUTHOR
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://res.cloudinary.com/bold-pm/image/upload/Graphics/Ryan-Cochran.webp',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Chip(label: Text('Author')),
                        Text(
                          'Ryan Cochran',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 5),

                /// 📄 HTML CONTENT
                // 2. The Widget Implementation
                Html(
                  data: blogData.description,
                  extensions: [
                    // 1. The Table Extension (Makes your data table visible)
                    const TableHtmlExtension(),

                    // 2. The Iframe Extension (Makes the YouTube video visible)
                    // const IframeHtmlExtension(),

                    // 3. Your custom vline extension from earlier
                    MatcherExtension(
                      matcher: (context) => context.classes.contains('vline'),
                      builder: (context) {
                        final String titleText =
                            context.element?.text.trim() ?? "";
                        return Row(
                          children: [
                            Container(
                              width: 11,
                              height: 25,
                              color: Colors.black,
                            ),
                            Container(
                              width: 11,
                              height: 25,
                              color: const Color(0xFF008E86),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                titleText,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                  style: {
                    "table": Style(
                      backgroundColor: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      margin: Margins.symmetric(vertical: 10),
                    ),
                    "td": Style(
                      padding: HtmlPaddings.all(8),
                      border: Border(
                        bottom: BorderSide(color: Colors.grey.shade200),
                        left: BorderSide(color: Colors.grey.shade200),
                      ),
                      fontSize: FontSize(16),
                    ),
                    // "b": Style(fontWeight: FontWeight.bold),
                  },
                ),

                // Html(
                //   data: blogData.description,
                //   // onLinkTap: (url, context, attributes, element) {
                //   //   if (url != null) launchUrl(Uri.parse(url));
                //   // },
                //   style: {
                //     // Body / paragraphs
                //     "body": Style(
                //       fontFamily: 'GothamLight',
                //       // fontSize: FontSize(18),
                //       lineHeight: LineHeight(1.66),
                //       color: Colors.grey.shade800,
                //     ),

                //     // "p": Style(
                //     //   fontFamily: 'GothamLight',
                //     //   // fontSize: FontSize(18),
                //     //   lineHeight: LineHeight(1.66),
                //     //   margin: Margins.only(bottom: 10),
                //     //   color: Colors.grey.shade800,
                //     // ),

                //     // Headings
                //     "h1": Style(
                //       fontFamily: 'GothamBold',
                //       fontSize: FontSize(20),
                //       fontWeight: FontWeight.bold,
                //       margin: Margins.symmetric(vertical: 4),
                //       color: Colors.black,
                //     ),
                //     "h2": Style(
                //       fontFamily: 'GothamMedium',
                //       fontSize: FontSize(24),
                //       fontWeight: FontWeight.w600,
                //       margin: Margins.symmetric(vertical: 4),
                //       color: Colors.black,
                //     ),
                //     "h3": Style(
                //       fontFamily: 'GothamMedium',
                //       fontSize: FontSize(20),
                //       fontWeight: FontWeight.w600,
                //       margin: Margins.symmetric(vertical: 4),
                //       color: Color(0xFF181818),
                //     ),
                //     "h4": Style(
                //       fontFamily: 'GothamBold',
                //       fontSize: FontSize(26),
                //       fontWeight: FontWeight.w600,
                //       margin: Margins.symmetric(vertical: 4),
                //       color: Colors.black,
                //     ),
                //     "h5": Style(
                //       fontFamily: 'GothamMedium',
                //       fontSize: FontSize(16),
                //       fontWeight: FontWeight.w600,
                //       lineHeight: LineHeight(1.5),
                //       color: Color(0xFF181818),
                //     ),

                //     // Strong / bold text
                //     "strong": Style(
                //       fontFamily: 'GothamMedium',
                //       fontSize: FontSize(16),
                //       fontWeight: FontWeight.w600,
                //       color: Color(0xFF181818),
                //     ),
                //     "b": Style(fontWeight: FontWeight.bold),

                //     // Links
                //     "a": Style(
                //       color: Color(0xFF007BFF),
                //       textDecoration: TextDecoration.underline,
                //     ),

                //     // Lists
                //     "ul": Style(
                //       padding: HtmlPaddings.only(left: 24),
                //       margin: Margins.only(bottom: 16),
                //     ),
                //     "ol": Style(
                //       padding: HtmlPaddings.only(left: 24),
                //       margin: Margins.only(bottom: 16),
                //     ),
                //     "li": Style(
                //       fontSize: FontSize(16),
                //       lineHeight: LineHeight(1.66),
                //       color: Color(0xFF181818),
                //     ),

                //     // Tables
                //     "table": Style(
                //       // width: double.infinity,
                //       border: Border.all(color: Colors.grey.shade400),
                //       margin: Margins.symmetric(vertical: 10),
                //     ),
                //     "th": Style(
                //       padding: HtmlPaddings.all(8),
                //       backgroundColor: Color(0xFF008E86),
                //       color: Colors.white,
                //       textAlign: TextAlign.start,
                //     ),
                //     "td": Style(
                //       padding: HtmlPaddings.all(8),
                //       border: Border.all(color: Colors.grey.shade400),
                //     ),

                //     // Iframes
                //     "iframe": Style(
                //       display: Display.block,
                //       // width: double.infinity,
                //     ),

                //     // Special custom classes
                //     ".concl-color": Style(
                //       backgroundColor: Color(0xFFFDF0C2),
                //       padding: HtmlPaddings.all(32),
                //       margin: Margins.symmetric(vertical: 30),
                //       // decoration: BoxDecoration(
                //       //   color: Color(0xFFFDF0C2),
                //       //   borderRadius: BorderRadius.circular(12),
                //       // ),
                //     ),

                //     ".dotted-line": Style(
                //       border: Border(
                //         top: BorderSide(
                //           color: Colors.black,
                //           style: BorderStyle.solid,
                //         ),
                //       ),
                //     ),
                //     ".vline": Style(
                //       border: Border(
                //         left: BorderSide(width: 11, color: Color(0xFF008E86)),
                //         right: BorderSide(width: 11, color: Colors.black),
                //       ),
                //       padding: HtmlPaddings.only(left: 16),
                //       // leave space for "line"
                //       margin: Margins.symmetric(vertical: 8),
                //     ),

                //     ".timeline ol li": Style(
                //       padding: HtmlPaddings.only(left: 20, bottom: 10),
                //       border: Border(
                //         left: BorderSide(color: Color(0xFF008E86)),
                //       ),
                //     ),

                //     // Images
                //     "img": Style(
                //       display: Display.block,
                //       // width: double.infinity,
                //       margin: Margins.only(top: 10, bottom: 10),
                //     ),
                //   },
                //   // customRender: {
                //   //   tagMatcher('div'): CustomRender.widget(
                //   //     widget: (context, buildChildren) {
                //   //       final classes = context.tree.element?.classes ?? [];
                //   //       if (classes.contains('rounded-side')) {
                //   //         return Container(
                //   //           decoration: BoxDecoration(
                //   //             color: Color(0xFFFDF0C2),
                //   //             borderRadius: BorderRadius.horizontal(
                //   //               right: Radius.circular(100),
                //   //             ),
                //   //           ),
                //   //           padding: EdgeInsets.all(32),
                //   //           child: Column(children: buildChildren()),
                //   //         );
                //   //       }
                //   //       return null;
                //   //     },
                //   //   ),
                //   // },
                // ),
              ],
            ),
          );
        },
      ),
    );
  }
}
