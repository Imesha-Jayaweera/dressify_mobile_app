import 'package:flutter/material.dart';

class FashionTipsPage extends StatelessWidget {
  final String gender;
  final String skinColor;
  final String bodyType;

  const FashionTipsPage({
    Key? key,
    required this.gender,
    required this.skinColor,
    required this.bodyType,
  }) : super(key: key);

  // Color recommendations based on skin tone
  Map<String, Map<String, dynamic>> get skinToneColors => {
    "very light": {
      "name": "Fair",
      "bestColors": ["Soft Pink", "Lavender", "Baby Blue", "Mint Green", "Peach"],
      "avoidColors": ["Neon Colors", "Very Dark Brown"],
      "description": "Your porcelain skin glows with soft, pastel colors",
      "gradient": [Color(0xFFFFE5E5), Color(0xFFFFCCE5)],
    },
    "light": {
      "name": "Light",
      "bestColors": ["Coral", "Turquoise", "Light Purple", "Cream", "Soft Yellow"],
      "avoidColors": ["Very Pale Colors", "Harsh Black"],
      "description": "Warm and cool tones both complement your skin beautifully",
      "gradient": [Color(0xFFFFE0CC), Color(0xFFFFD4B8)],
    },
    "light to medium": {
      "name": "Light-Medium",
      "bestColors": ["Emerald Green", "Navy Blue", "Wine Red", "Golden Yellow", "Olive"],
      "avoidColors": ["Washed Out Pastels"],
      "description": "Rich, vibrant colors enhance your natural glow",
      "gradient": [Color(0xFFFFD4A3), Color(0xFFFFC285)],
    },
    "medium": {
      "name": "Medium",
      "bestColors": ["Royal Blue", "Deep Purple", "Forest Green", "Burgundy", "Orange"],
      "avoidColors": ["Very Light Pastels"],
      "description": "Bold, saturated colors look stunning on you",
      "gradient": [Color(0xFFE5B299), Color(0xFFD4A574)],
    },
    "tan": {
      "name": "Tan",
      "bestColors": ["Teal", "Coral", "Mustard", "Chocolate Brown", "Terracotta"],
      "avoidColors": ["Pale Yellow", "Washed Beige"],
      "description": "Earthy and warm tones complement your golden skin",
      "gradient": [Color(0xFFD4A373), Color(0xFFC4915C)],
    },
    "dark": {
      "name": "Deep",
      "bestColors": ["Bright White", "Electric Blue", "Hot Pink", "Gold", "Crimson"],
      "avoidColors": ["Dull Browns", "Muddy Greens"],
      "description": "Vibrant, bold colors pop against your rich skin tone",
      "gradient": [Color(0xFFA67C52), Color(0xFF8B6B4F)],
    },
    "very dark": {
      "name": "Very Deep",
      "bestColors": ["Pure White", "Fuchsia", "Cobalt Blue", "Bright Yellow", "Ruby Red"],
      "avoidColors": ["Dark Brown", "Black on Black"],
      "description": "Bold, high-contrast colors showcase your beautiful complexion",
      "gradient": [Color(0xFF6B4423), Color(0xFF4A2F1A)],
    },
  };

  // Clothing recommendations based on body type
  Map<String, Map<String, dynamic>> get bodyTypeStyles {
    if (gender.toLowerCase() == "male") {
      return {
        "oval": {
          "displayName": "Oval",
          "icon": Icons.circle_outlined,
          "description": "Vertical stripes and structured fits work best",
          "tips": [
            "Shirts: Vertical stripes, darker tones",
            "T-Shirts: V-neck or structured fit",
            "Trousers/Jeans: Straight-cut, mid-rise",
            "Jackets: Single-breasted, structured shoulders",
            "Suits: Dark, slim-lapel with longer jacket length",
          ],
        },
        "rectangle": {
          "displayName": "Rectangle",
          "icon": Icons.crop_square,
          "description": "Add dimension with patterns and layers",
          "tips": [
            "Shirts: Checked or patterned to add shape",
            "T-Shirts: Crew necks, layered with jackets",
            "Trousers/Jeans: Slightly tapered",
            "Jackets: Padded or structured shoulders",
            "Suits: Fitted at waist for silhouette",
          ],
        },
        "trapezoid": {
          "displayName": "Trapezoid",
          "icon": Icons.hexagon_outlined,
          "description": "Emphasize your athletic build",
          "tips": [
            "Shirts: Fitted, emphasize shoulders",
            "T-Shirts: Polo or athletic cut",
            "Trousers/Jeans: Slim-fit",
            "Jackets: Tailored blazers",
            "Suits: Standard slim-fit two-piece",
          ],
        },
        "inverted trapezoid": {
          "displayName": "Inverted Trapezoid",
          "icon": Icons.change_history,
          "description": "Balance proportions with relaxed fits",
          "tips": [
            "Shirts: Stretch fabrics for chest fit",
            "T-Shirts: Raglan or V-neck to reduce shoulder width look",
            "Trousers/Jeans: Straight or relaxed fit",
            "Jackets: No shoulder padding, simple collars",
            "Suits: Slightly relaxed fit to balance proportions",
          ],
        },
      };
    } else {
      return {
        "round": {
          "displayName": "Round (Apple)",
          "icon": Icons.circle,
          "description": "Empire waist and V-necklines are your best friends",
          "tips": [
            "Frocks: Empire waist, wrap dresses, V-neckline styles",
            "Tops/Blouses: Peplum, flowy, or V-neck blouses",
            "Skirts: A-line or knee-length",
            "Trousers/Pants: Straight-leg or high-rise pants",
            "Jackets/Coats: Open-front, longline coats to elongate body",
          ],
        },
        "hourglass": {
          "displayName": "Hourglass",
          "icon": Icons.hourglass_bottom,
          "description": "Show off your balanced proportions with fitted styles",
          "tips": [
            "Frocks: Bodycon, wrap, belted or fit-and-flare",
            "Tops/Blouses: Fitted, tucked-in blouses",
            "Skirts: Pencil or high-waist styles",
            "Trousers/Pants: Slim-fit or bootcut",
            "Jackets/Coats: Tailored blazers emphasizing waist",
          ],
        },
        "inverted triangle": {
          "displayName": "Inverted Triangle",
          "icon": Icons.change_history,
          "description": "Balance your shoulders with A-line and flared styles",
          "tips": [
            "Frocks: A-line or flared skirts",
            "Tops/Blouses: V-neck, simple shoulders (avoid puff sleeves)",
            "Skirts: Patterned or pleated",
            "Trousers/Pants: Wide-leg, palazzo, or cargo",
            "Jackets/Coats: Short and waist-fitted styles",
          ],
        },
        "rectangle": {
          "displayName": "Rectangle",
          "icon": Icons.crop_square,
          "description": "Create curves with belted and ruched styles",
          "tips": [
            "Frocks: Belted or ruched mid section",
            "Tops/Blouses: Ruffled or layered",
            "Skirts: Flared or pleated to add curves",
            "Trousers/Pants: Bootcut or flared",
            "Jackets/Coats: Cropped or peplum to shape waist",
          ],
        },
        "triangle": {
          "displayName": "Triangle (Pear)",
          "icon": Icons.details,
          "description": "Draw attention upward with embellished tops",
          "tips": [
            "Frocks: Fit-and-flare or off-shoulder",
            "Tops/Blouses: Boat-neck or puff-sleeve",
            "Skirts: A-line or light-colored",
            "Trousers/Pants: Straight or slightly flared",
            "Jackets/Coats: Structured shoulder line",
          ],
        },
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    final skinData = skinToneColors[skinColor.toLowerCase()] ?? skinToneColors["medium"]!;
    final bodyData = bodyTypeStyles[bodyType.toLowerCase()] ?? bodyTypeStyles["rectangle"]!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF8E2DE2).withOpacity(0.1),
              const Color(0xFFF6F0FA),
            ],
          ),
        ),
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 120,
                floating: false,
                pinned: true,
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF8E2DE2)),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Your Style Guide',
                    style: TextStyle(
                      color: Color(0xFF8E2DE2),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  centerTitle: true,
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Greeting Card
                      _buildGreetingCard(skinData),

                      const SizedBox(height: 30),

                      // Skin Tone Section
                      _buildSectionTitle("Perfect Colors for You", Icons.palette),
                      const SizedBox(height: 16),
                      _buildColorPalette(skinData),

                      const SizedBox(height: 30),

                      // Body Type Section
                      _buildSectionTitle("Your Style Recommendations", Icons.checkroom),
                      const SizedBox(height: 16),
                      _buildBodyTypeCard(bodyData),

                      const SizedBox(height: 30),

                      // Shopping CTA
                      _buildShoppingCTA(context),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGreetingCard(Map<String, dynamic> skinData) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: skinData["gradient"] as List<Color>,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (skinData["gradient"] as List<Color>)[0].withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Text(
            gender == "male" ? "👔 Welcome, Sir!" : "👗 Welcome, Miss!",
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            skinData["description"],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Skin Tone: ${skinData['name']}",
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: Colors.white, size: 24),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8E2DE2),
          ),
        ),
      ],
    );
  }

  Widget _buildColorPalette(Map<String, dynamic> skinData) {
    final bestColors = skinData["bestColors"] as List<String>;
    final avoidColors = skinData["avoidColors"] as List<String>;

    return Column(
      children: [
        // Best Colors
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.green, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Colors That Love You",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: bestColors.map((color) => _buildColorChip(color, true)).toList(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Colors to Avoid
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.block, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    "Colors to Use Sparingly",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: avoidColors.map((color) => _buildColorChip(color, false)).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorChip(String colorName, bool isRecommended) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        gradient: isRecommended
            ? const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
        )
            : null,
        color: isRecommended ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(20),
        boxShadow: isRecommended
            ? [
          BoxShadow(
            color: const Color(0xFF8E2DE2).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ]
            : null,
      ),
      child: Text(
        colorName,
        style: TextStyle(
          color: isRecommended ? Colors.white : Colors.grey[700],
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildBodyTypeCard(Map<String, dynamic> bodyData) {
    final tips = bodyData["tips"] as List<String>;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Body Type Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  bodyData["icon"] as IconData,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bodyData["displayName"],
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8E2DE2),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bodyData["description"],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Style Tips
          ...tips.map((tip) => _buildStyleTip(tip)).toList(),
        ],
      ),
    );
  }

  Widget _buildStyleTip(String tip) {
    final parts = tip.split(": ");
    final category = parts[0];
    final recommendations = parts.length > 1 ? parts[1] : "";

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: const Color(0xFF8E2DE2).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.check_circle,
              color: Color(0xFF8E2DE2),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF8E2DE2),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  recommendations,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShoppingCTA(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to shopping page or show message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Opening shopping section..."),
            backgroundColor: Color(0xFF8E2DE2),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8E2DE2), Color(0xFFEC008C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF8E2DE2).withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Ready to Shop?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Find clothes that match your style",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.shopping_bag,
              color: Colors.white,
              size: 48,
            ),
          ],
        ),
      ),
    );
  }
}