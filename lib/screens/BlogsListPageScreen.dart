import 'package:bold_portfolio/screens/BlogDetailsScreen.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import 'package:html/parser.dart' as html; // For stripping HTML tags
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BlogListPage extends StatefulWidget {
  BlogListPage({super.key});

  @override
  State<BlogListPage> createState() => _BlogListPageState();
}

class _BlogListPageState extends State<BlogListPage> {
  final String baseUrl = dotenv.env['API_URL']!;
  String selectedBlogType = 'blogs'; // ✅ initial
  int currentPage = 1;
  int totalPages = 0; // 🔥 IMPORTANT

  Future<BlogPageResult> fetchBlogsList(int pageNumber, String blogType) async {
    print('Fetching blogs: type=$blogType, page=$pageNumber');
    final Uri url;
    if (blogType == 'industryNews') {
      url = Uri.parse(
        '$baseUrl/UI/GetBPMNews?newsType=$blogType&page=$pageNumber',
      );
    } else {
      url = Uri.parse(
        '$baseUrl/UI/GetBPMBlogs?BlogType=$blogType&page=$pageNumber',
      );
    }
    print("url: $url");
    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load blogs');
    }

    final Map<String, dynamic> jsonResponse = json.decode(response.body);

    final items = blogType == 'industryNews'
        ? jsonResponse['data']
        : jsonResponse['data']['items'];
    final List list = items['dataList'];
    final int totalElements = items['page']['totalElements'] ?? 0;

    totalPages = (totalElements / 12).ceil();
    return BlogPageResult(
      blogs: list.map((e) => Blog.fromJson(e)).toList(),
      totalPages: totalPages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Blogs"), backgroundColor: Colors.black),
      body: Column(
        children: [
          /// 🔘 TOP BUTTONS
          Padding(
            padding: const EdgeInsets.all(5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _blogTypeButton('Blogs', 'blogs'),
                const SizedBox(width: 5),
                _blogTypeButton('Coin Guide', 'coin-guide'),
                const SizedBox(width: 5),
                _blogTypeButton('Coin Value', 'coin-value'),
                const SizedBox(width: 5),
                _blogTypeButton('News', 'industryNews'),
              ],
            ),
          ),

          /// 📦 BLOG GRID
          Expanded(
            child: FutureBuilder<BlogPageResult>(
              future: fetchBlogsList(currentPage, selectedBlogType),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError ||
                    snapshot.data == null ||
                    snapshot.data!.blogs.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text.rich(
                          TextSpan(
                            text:
                                'No Blogs Found', // First part of the message (bold)
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors
                                  .error, // Set color for error message
                            ),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              fetchBlogsList(currentPage, selectedBlogType);
                            });
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                final result = snapshot.data!;
                final blogList = result.blogs;

                totalPages = result.totalPages;

                // final blogList = snapshot.data!.blogs;
                return Column(
                  children: [
                    /// 🔢 PAGINATION
                    buildPagination(),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              MediaQuery.of(context).size.width > 600 ? 2 : 1,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          mainAxisExtent: 495, // ✅ card height
                        ),
                        itemCount: blogList.length,
                        itemBuilder: (context, index) {
                          return BlogListItem(blog: blogList[index]);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPagination() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// ◀ PREVIOUS
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: currentPage > 1
              ? () {
                  setState(() => currentPage--);
                }
              : null,
        ),

        /// PAGE NUMBERS
        ...List.generate(totalPages, (index) {
          int page = index + 1;

          // show first, last, current, and neighbors
          if (page == 1 ||
              page == totalPages ||
              (page >= currentPage - 1 && page <= currentPage + 1)) {
            return _pageButton(page);
          }

          // show dots
          if (page == currentPage - 2 || page == currentPage + 2) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Text("..."),
            );
          }

          return const SizedBox.shrink();
        }),

        /// ▶ NEXT
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: currentPage < totalPages
              ? () {
                  setState(() => currentPage++);
                }
              : null,
        ),
      ],
    );
  }

  Widget _pageButton(int page) {
    bool isActive = page == currentPage;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: InkWell(
        onTap: () {
          setState(() => currentPage = page);
        },
        child: Container(
          width: 36,
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black),
            color: isActive ? Colors.black : Colors.white,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            page.toString(),
            style: TextStyle(
              color: isActive ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔘 BUTTON BUILDER
  Widget _blogTypeButton(String label, String type) {
    final isSelected = selectedBlogType == type;

    return SizedBox(
      width: 89, // ✅ same width for all buttons
      height: 54, // optional: consistent height
      child: ElevatedButton(
        onPressed: () {
          setState(() {
            selectedBlogType = type;
            currentPage = 1;
          });
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isSelected ? Colors.teal : Colors.grey.shade200,
          foregroundColor: isSelected ? Colors.white : Colors.teal,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(label, textAlign: TextAlign.center),
      ),
    );
  }
}

String formatDate(String date) {
  try {
    return DateFormat('MM/dd/yyyy').format(DateTime.parse(date));
  } catch (_) {
    return '-';
  }
}

class BlogListItem extends StatelessWidget {
  final Blog blog;

  BlogListItem({required this.blog});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BlogDetailsPage(
                title: blog.newsTitleWithHypen,
                type: blog.type,
              ),
            ),
          );
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(blog.image),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Published on ${formatDate(blog.publishDate)}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                blog.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),

            // 👇 fixed-height description (IMPORTANT)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: SizedBox(
                height: 60,
                child: BlogListDescription(newText: blog.description),
              ),
            ),

            const Divider(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // link: '/blog/${blog.newsTitleWithHypen}'
                  BlogShareComponent(title: blog.title, showShareText: true),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlogDetailsPage(
                            title: blog.newsTitleWithHypen,
                            type: blog.type,
                          ),
                        ),
                      );
                    },

                    child: const Text("Read more"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class BlogListDescription extends StatelessWidget {
  final String newText;

  const BlogListDescription({required this.newText});

  String stripHtmlTags(String htmlString) {
    final document = html.parse(htmlString);
    return document.body?.text ?? '';
  }

  String truncateByWords(String text, int wordLimit) {
    final words = text.split(RegExp(r'\s+'));
    if (words.length <= wordLimit) {
      return text;
    }
    return words.take(wordLimit).join(' ') + '...';
  }

  @override
  Widget build(BuildContext context) {
    final cleanText = stripHtmlTags(newText);

    return Text(
      truncateByWords(cleanText, 100), // ✅ 100 WORDS
      style: const TextStyle(
        color: Colors.grey,
        fontSize: 14,
        height: 1.4, // nicer web-like spacing
      ),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}

class BlogShareComponent extends StatelessWidget {
  BlogShareComponent({super.key, required this.title, this.showShareText});
  final String title;
  final String redirectionUrl = dotenv.env['URL_Redirection'] ?? '';
  final bool? showShareText;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 3,
      children: [
        if (showShareText == true)
          const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.facebookF,
            color: Color(0xFF1877F2),
            size: 18,
          ),
          onPressed: () {
            Share.share(
              'https://www.facebook.com/sharer/sharer.php?u=$redirectionUrl',
            );
          },
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.xTwitter,
            size: 18,
            color: Colors.black,
          ),
          onPressed: () {
            Share.share(
              'https://twitter.com/intent/tweet?url=$redirectionUrl&text=$title',
            );
          },
        ),
        IconButton(
          icon: const FaIcon(
            FontAwesomeIcons.linkedinIn,
            size: 18,
            color: Color(0xFF0077B5),
          ),
          onPressed: () {
            Share.share(
              'https://www.linkedin.com/sharing/share-offsite/?url=$redirectionUrl',
            );
          },
        ),
      ],
    );
  }
}

class BlogPageResult {
  final List<Blog> blogs;
  final int totalPages;

  BlogPageResult({required this.blogs, required this.totalPages});
}

class Blog {
  final String title;
  final String description;
  final String image;
  final String newsTitleWithHypen;
  final String publishDate;
  final String type;

  Blog({
    required this.title,
    required this.description,
    required this.image,
    required this.newsTitleWithHypen,
    required this.publishDate,
    required this.type,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      newsTitleWithHypen: json['newsTitleWithHypen'] ?? '',
      publishDate: json['publishDate'] ?? '',
      type: json['type'] ?? '',
    );
  }
}
