import 'package:chillfi/core/app_colors.dart';
import 'package:chillfi/features/product_details/widgets/similar_product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class SimilarProductsSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const SimilarProductsSection({
    super.key,
    this.title = "Similar Products",
    this.subtitle = "You may also like these products",
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12.sp,
                      color: AppColors.greyText,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      "View All",
                      style: GoogleFonts.poppins(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondaryPurple,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Icon(Icons.arrow_forward_rounded, color: AppColors.secondaryPurple, size: 16.sp),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        SizedBox(height: 16.h),

        // Product Carousel
        SizedBox(
          height: 310.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(left: 20.w),
            itemCount: _dummyProducts.length,
            itemBuilder: (context, index) {
              final product = _dummyProducts[index];
              return SimilarProductCard(
                title: product['title'],
                variant: product['variant'],
                price: product['price'],
                oldPrice: product['oldPrice'],
                discount: product['discount'],
                savings: product['savings'],
                rating: product['rating'],
                reviews: product['reviews'],
                isWishlisted: product['isWishlisted'],
              );
            },
          ),
        ),
      ],
    );
  }
}

final List<Map<String, dynamic>> _dummyProducts = [
  {
    'title': 'Samsung Galaxy S23',
    'variant': 'Phantom Black | 256GB',
    'price': '49,999',
    'oldPrice': '63,999',
    'discount': '22%',
    'savings': '14,000',
    'rating': 4.4,
    'reviews': '2.1k',
    'isWishlisted': false,
  },
  {
    'title': 'Google Pixel 7a',
    'variant': 'Sea | 128GB',
    'price': '32,999',
    'oldPrice': '39,999',
    'discount': '18%',
    'savings': '7,000',
    'rating': 4.3,
    'reviews': '1.2k',
    'isWishlisted': true,
  },
  {
    'title': 'OnePlus 11R 5G',
    'variant': 'Galactic Silver | 256GB',
    'price': '39,999',
    'oldPrice': '49,999',
    'discount': '20%',
    'savings': '10,000',
    'rating': 4.5,
    'reviews': '890',
    'isWishlisted': false,
  },
  {
    'title': 'iQOO Neo 7 Pro 5G',
    'variant': 'Dark Storm | 256GB',
    'price': '28,999',
    'oldPrice': '38,999',
    'discount': '25%',
    'savings': '10,000',
    'rating': 4.3,
    'reviews': '760',
    'isWishlisted': false,
  },
];
