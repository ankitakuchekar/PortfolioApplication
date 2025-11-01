import 'package:bold_portfolio/screens/main_screen.dart';
import 'package:bold_portfolio/utils/app_colors.dart';
import 'package:bold_portfolio/widgets/common_app_bar.dart';
import 'package:bold_portfolio/widgets/common_drawer.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class BullionPortfolioGuideScreen extends StatelessWidget {
  BullionPortfolioGuideScreen({super.key});

  void _launchURL(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 12.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget sectionSubtitle(String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        subtitle,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget bulletList(List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("• ", style: TextStyle(fontSize: 18)),
                  Expanded(
                    child: Text(item, style: const TextStyle(fontSize: 18)),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }

  Widget fullWidthImage(String url, {double? height}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Image.network(
        url,
        width: double.infinity,
        height: height,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget getStartedStepsCard() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border.all(color: Colors.teal),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Steps to follow to get started:",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          numberedStep(
            "Login/Register as a new user or click on “Manage Portfolio” to log in/register.",
          ),
          numberedStep(
            "Add gold and silver bullion by clicking on “Add new holdings.”",
          ),
          numberedStep(
            "Select the dealer you have purchased from (or are going to purchase from) - either “BOLD Precious Metals” OR “Not Purchased from BOLD.”",
          ),
          numberedStep(
            "Enter the Product name and select your product from the drop-down list.",
          ),
          numberedStep(
            "Enter the purchase metal value, quantity, and date of purchase.",
          ),
          numberedStep(
            "Select “Save and Close” to add your asset to your holding.",
          ),
        ],
      ),
    );
  }

  Widget numberedStep(String text) {
    int stepNumber = _stepCounter++;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Text("$stepNumber) $text", style: const TextStyle(fontSize: 16)),
    );
  }

  // Declare this at the top of your widget (stateful or stateless scope)
  int _stepCounter = 1;

  Widget didYouKnowSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFDE8B0), // Light yellow background
        borderRadius: BorderRadius.circular(6),
      ),
      child: IntrinsicHeight(
        // Added to constrain height properly
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Changed to stretch
          children: [
            Container(
              width: 8,
              // Removed height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(6),
                  bottomLeft: Radius.circular(6),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Did You Know?",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    _stepCounter = 1; // Reset step counter before building steps
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      appBar: const CommonAppBar(title: 'Portfolio Charts'),
      drawer: const CommonDrawer(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextButton.icon(
              onPressed: () {
                final mainState = context
                    .findAncestorStateOfType<MainScreenState>();
                mainState?.onNavigationTap(0);
              },
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              label: const Text(
                'Back',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                foregroundColor: Colors.black87,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero, // To prevent default min button size
                tapTargetSize:
                    MaterialTapTargetSize.shrinkWrap, // Compact tap area
              ),
            ),
            // Breadcrumb imitation
            // Text(
            //   "Home > Bullion Portfolio Guide",
            //   style: TextStyle(color: Colors.grey[600], fontSize: 14),
            // ),
            const SizedBox(height: 12),

            const Text(
              "Revolutionary Portfolio Management - Making BOLD a Magical Bullion Platform!",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            const Text(
              "We take pride and honor in being the first revolutionary and innovative bullion dealer in the market. Understanding and solving customer problems is what we do effectively!",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "Portfolio management as a bullion investor is crucial and necessary. Thus, to solve this problem, we have brought you our new Portfolio feature that helps you build, manage, and track your investments effortlessly.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "Let’s get you acquainted with the features of the portfolio and how you can benefit from them!",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Note: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text:
                          "This Portfolio is for informational use only and does not provide financial, investment, legal, or tax advice.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 8,
              height: 24,
              color: Colors.teal[900], // dark teal color
              margin: const EdgeInsets.only(right: 8),
            ),
            sectionTitle("Why is Managing Your Portfolio necessary?"),
            const Text(
              "Surely, investing doesn’t just require money; it also requires being updated with the market while tracking the value of your investment. When you get a platform to add all your precious metals holdings while tracking the P&L and market fluctuations; everything seems to line up effortlessly!",
              style: TextStyle(fontSize: 18),
            ),

            // 📷 Image 1
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/bullion-investment.webp",
            ),
            const Text(
              "Here are some other reasons for Why your precious metals portfolio needs to be managed:",
              style: TextStyle(fontSize: 18),
            ),
            bulletList([
              "Risk management",
              "Effective diversification of assets",
              "Safeguarding assets during market volatility",
              "Hedge against macro-environmental events and turmoil",
            ]),

            sectionTitle("What is this Portfolio feature of BOLD?"),
            const Text(
              "A portfolio is a place where you can add the bullion you hold, check its value, track the market, and check your P&L.",
              style: TextStyle(fontSize: 18),
            ),
            bulletList([
              "In this portfolio, you can monitor the live value of your assets and analyze growth trends.",
              "You can also build your portfolio with all your assets regardless of whether they are bought from us or not!",
              "You can check the market trends of your assets with our comprehensive trend chart for all bullion.",
              "You can buy, sell, remove, and exit your bullion whenever you feel like with ease!",
            ]),

            sectionTitle("Here’s how to actually use the portfolio!"),
            const Text(
              "If you are a new customer",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const Text(
              "If you are a new BOLD customer, the portfolio will still benefit you! "
              "You can get a head start on your investment journey.",
              style: TextStyle(fontSize: 18),
            ),
            sectionSubtitle("Here’s how:"),
            bulletList([
              "Regardless of whether you have bought from BOLD yet or not, you can still add the bullion that you wish to buy.",
              "To get started with your portfolio, all your need is a simple Login or Registration.",
              "Whenever the time’s right, you can buy bullion easily from your portfolio.",
            ]),
            const SizedBox(height: 24),
            getStartedStepsCard(), // <- Add this line to include the steps card

            sectionTitle("If Your Bullion is purchased from BOLD!"),
            const Text(
              "You can enjoy various benefits if your bullion is purchased from us! "
              "You can directly list the bullion bought from us. With this, you can also:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            bulletList([
              'Buy more quantities directly from the portfolio with the “Buy” button.',
              'Sell your bullion to us at optimal prices with the “Sell” button.',
              'We will take care of the process of buying back; all you need to do is confirm the sale.',
              'Bullion bought from BOLD Precious Metals will be directly added to your portfolio once shipped.',
              'You can also add bullion that you are planning to buy from BOLD!',
            ]),
            const SizedBox(height: 16),

            // Existing asset holdings image
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/asset-holdings-by-product-3.webp",
            ),

            const SizedBox(height: 24),
            // New Steps Info Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "To enjoy these above benefits, follow these steps:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "1) Click on “Add new holdings” to add bullion.",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "2) Click on “Buy” to add more quantities of the product.",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "3) Click on “Sell” to Sell to Us.",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "4) Click on “More” to Exit or Remove the assets.",
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Add the image below the list
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/add-holdings-by-products-2.webp",
            ),

            // Insert the new Did You Know section here
            didYouKnowSection(context),
            sectionTitle("If your Bullion is Not Purchased from BOLD!"),
            const Text(
              "Even if your bullion is not purchased from BOLD, you can still add the product to your portfolio. Additionally, you can also sell your bullion to us from our Sell To Us page; however, the product should be listed on the website.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "Here’s how you can use the portfolio if your bullion is not purchased from us:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            bulletList([
              "You can add bullion purchased from any dealer.",
              "Selling bullion directly from the portfolio is disabled to avoid chaos and misunderstandings.",
              "If you sell your assets elsewhere, you can exit with the quantity sold to keep your portfolio updated.",
              "You can also remove the product from holdings completely by clicking on “Remove”.",
            ]),

            const SizedBox(height: 16),

            // Add the image below the list
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/asset-holdings-by-product-2.webp",
            ),

            // Steps to Follow Box
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade100,
              ),
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Steps to Follow:\n\n",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const TextSpan(
                      text:
                          "1) Click on “Add new holdings” to update your portfolio.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "2) In the dialog box, select “Not Purchased From BOLD,” to add your assets.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "3) Enter the name of the dealer that you have purchased from.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "4) Enter the product name and select the product from the dropdown list.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "5) Select the quantity and the purchase metal value.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "6) Enter the Ounce per unit and the date of purchase.\n\n",
                    ),
                    const TextSpan(
                      text:
                          "7) Select “Save and close” or “Save & Add More” to add more products.\n",
                    ),
                  ],
                ),
              ),
            ),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/add-holdings-by-products.webp",
            ),
            const SizedBox(height: 16),
            const Text(
              "Can’t find your product?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "For bullion that is not purchased from BOLD and not listed in the suggestions list, you can add the details of the product and add to your holdings.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/add-holdings-by-products.webp",
            ),
            // Keep in mind section
            const Text(
              "Here are some things you need to keep in mind:",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            bulletList([
              "Your bullion added will be considered in the P&L calculations and portfolio valuation."
                  "You need to select the metal of the bullion while adding."
                  "You can exit from a certain quantity or remove the product completely, if necessary.",
            ]),
            SizedBox(width: 8),
            Text(
              "What is Remove and Exit?",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            RichText(
              text: const TextSpan(
                style: TextStyle(fontSize: 18, color: Colors.black),
                children: [
                  TextSpan(text: "Let’s make things more transparent: "),
                  TextSpan(
                    text: "remove ≠ exit.",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Here’s how they differ:",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            bulletList([
              "Remove: When you click on remove, the product and all its quantities are removed from the portfolio. This action cannot be undone.",
              "Exit: Clicking on Exit means you can select the quantity of bullion that you have sold. Accordingly, your portfolio will be updated with the remaining quantity.",
            ]),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/asset-holdings-by-product.webp",
            ),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/exit-holdings.webp",
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.teal),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "To enjoy these above benefits, follow these steps:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(height: 12),
                  Text(
                    "1) To remove or exit from your holdings, click on “More.”",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "2) Select “Exit” to exit with a specific quantity.",
                    style: TextStyle(fontSize: 18),
                  ),
                  Text(
                    "3) Select “Remove” to remove the asset completely from your total holdings.",
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            sectionTitle("How do you track your Asset Value?"),
            const Text(
              "The Assets Allocation and Valuation tab on the portfolio is divided into four cards. Each one carries data that helps you make better investment decisions.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: RichText(
                text: const TextSpan(
                  style: TextStyle(fontSize: 16, color: Colors.black),
                  children: [
                    TextSpan(
                      text: "Please Note: ",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    TextSpan(
                      text:
                          "All values are calculated based on the Spot prices. Hence, premiums or shipping charges are excluded.",
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/asset-allocation-and-valuation-1.webp",
            ),
            sectionTitle("Profit & Loss Statements"),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/total-profit-_-loss-2.webp",
            ),
            sectionTitle("Total Profit and Loss"),
            const Text(
              "The total P&L is calculated by considering all your assets (silver and gold). It is the net gain (positive value) or loss (negative value) from your bullion investments.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),

            const Text(
              "It is calculated as the difference between the current value and metal purchase cost.",
              style: TextStyle(fontSize: 18),
            ),

            sectionTitle("Day Profit and Loss"),
            const Text(
              "The Day P&L, as the moniker, is the value change in the last 24 hours. It shows the net daily gain (positive value) or loss (negative value) from your bullion investments.",
              style: TextStyle(fontSize: 18),
            ),
            sectionTitle("All Assets:"),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/total-assets-2.webp",
            ),
            sectionTitle("Total Assets"),
            const Text(
              " Current value: This is the current value of total holdings based on the spot prices.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "Purchase Metal Value: This is the spot price of the metals at the time of your purchase.",
              style: TextStyle(fontSize: 18),
            ),
            sectionTitle("Silver Holdings:"),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/total-assets-silver.webp",
            ),
            const Text(
              "Current Value: The current value of your silver holdings is displayed here.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              "Purchase value: Understand this with an example: the spot for silver on January 20, 2025 was \$30.6 and you have 2 quantities of a certain product. Hence, the purchase metal value would be \$61.2.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "P&L: This will display the profit and loss statement of your silver holdings since your date of purchase.",
              style: TextStyle(fontSize: 18),
            ),
            sectionTitle("Gold Holdings:"),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/total-assets-gold.webp",
            ),
            const Text(
              "Current Value: The current price of all your gold holdings will be displayed here.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            Text(
              "Purchase value: This is the purchase value of the bullion, it will only include the spot price of the metal. Meaning, the calculation is: gold spot price at purchase date x quantity.",
              style: TextStyle(fontSize: 18),
            ),
            const Text(
              "P&L: This will display the profit and loss statement of your gold holdings since your date of purchase.",
              style: TextStyle(fontSize: 18),
            ),
            sectionTitle("How is P&L Calculated?"),
            const Text(
              "If you want to know how to calculate your Profit and Loss for your assets, here’s how we do it:",
              style: TextStyle(fontSize: 18),
            ),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: bulletList([
                "P&L is calculated considering only the spot price of the metal.",
                "It includes the total silver assets and gold assets to give a total overview of your portfolio.",
                "Total P&L calculation: current value of assets - purchase metal value.",
              ]),
            ),
            sectionTitle("How can you Sell to Us?"),
            const Text(
              "Selling your bullion is extremely easy, if your assets are purchased from us. We practically take care of everything; all you need to do is click “Confirm Sell” and confirm the quantity.",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            fullWidthImage(
              "https://res.cloudinary.com/bold-pm/image/upload/Graphics/sell-to-us-1.webp",
            ),
            const Text(
              "BOLD makes sure you get the most optimal prices for your bullion in few simple steps.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 12),
            const Text(
              "If your bullion is not purchased from us, Please visit the Sell to us page to initiate the process. Make sure that the bullion you like to sell is listed on BOLD, otherwise the request cannot be accepted. However, if you have sold the bullion elsewhere, you can easily update your portfolio by clicking on “Exit.”",
              style: TextStyle(fontSize: 18),
            ),

            Container(
              margin: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF3CD), // Light yellow background
                borderRadius: BorderRadius.circular(6.0),
              ),
              child: IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      width: 8,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(6),
                          bottomLeft: Radius.circular(6),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Wrapping up!",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "With BOLD, it is actually easier done than said! Your course of action is minimal and precise. Once your portfolio is ready and updated, you can track live market trends of your holdings as well as the overall precious metals market.",
                              style: TextStyle(fontSize: 18),
                            ),
                            SizedBox(height: 12),
                            Text(
                              "For any assistance, please reach out to us. Our dedicated customer service team will be ready to solve your concerns with ease.",
                              style: TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                'Back',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
