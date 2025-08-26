import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/cards.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  String _selectedPeriod = 'Today';
  final List<String> _periods = [
    'Today',
    'This Week',
    'This Month',
    'This Year'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          PopupMenuButton<String>(
            initialValue: _selectedPeriod,
            onSelected: (value) {
              setState(() {
                _selectedPeriod = value;
              });
            },
            itemBuilder: (context) => _periods.map((period) {
              return PopupMenuItem(
                value: period,
                child: Text(period),
              );
            }).toList(),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _selectedPeriod,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, color: Colors.white),
                ],
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Key Metrics
              Text(
                'Overview',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Total Sales',
                      value: '\$2,847',
                      subtitle: '+12% from yesterday',
                      icon: Icons.attach_money,
                      color: AppColors.success,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Orders',
                      value: '24',
                      subtitle: '+3 from yesterday',
                      icon: Icons.shopping_cart,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Customers',
                      value: '18',
                      subtitle: '2 new customers',
                      icon: Icons.people,
                      color: AppColors.info,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AnalyticsCard(
                      title: 'Avg Order',
                      value: '\$118.63',
                      subtitle: '+5% from yesterday',
                      icon: Icons.trending_up,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Sales Chart
              Text(
                'Sales Trend',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 250,
                        child: LineChart(_buildSalesChart()),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem('Sales', AppColors.primary),
                          _buildLegendItem('Orders', AppColors.accent),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Category Performance
              Text(
                'Category Performance',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 200,
                        child: PieChart(_buildCategoryChart()),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildLegendItem('Electronics', Colors.blue),
                          _buildLegendItem('Groceries', Colors.green),
                          _buildLegendItem('Clothing', Colors.orange),
                          _buildLegendItem('Books', Colors.purple),
                          _buildLegendItem('Home & Garden', Colors.red),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Top Products
              Text(
                'Top Selling Products',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _buildTopProductItem(
                        'Wireless Headphones', '\$129.99', '15 sold', 1),
                    const Divider(height: 1),
                    _buildTopProductItem(
                        'Fresh Apples', '\$4.99', '12 sold', 2),
                    const Divider(height: 1),
                    _buildTopProductItem(
                        'Cotton T-Shirt', '\$19.99', '8 sold', 3),
                    const Divider(height: 1),
                    _buildTopProductItem('Smartphone', '\$699.99', '3 sold', 4),
                    const Divider(height: 1),
                    _buildTopProductItem(
                        'Garden Tools Set', '\$45.99', '2 sold', 5),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Recent Activity
              Text(
                'Recent Activity',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 16),
              Card(
                child: Column(
                  children: [
                    _buildActivityItem(
                      'New order received',
                      'Order #ORD123 - \$45.99',
                      '2 minutes ago',
                      Icons.shopping_cart,
                      AppColors.success,
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      'Product updated',
                      'Wireless Headphones stock updated',
                      '15 minutes ago',
                      Icons.inventory,
                      AppColors.info,
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      'Low stock alert',
                      'Fresh Apples (5 remaining)',
                      '1 hour ago',
                      Icons.warning,
                      AppColors.warning,
                    ),
                    const Divider(height: 1),
                    _buildActivityItem(
                      'Order completed',
                      'Order #ORD122 picked up',
                      '2 hours ago',
                      Icons.check_circle,
                      AppColors.success,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  LineChartData _buildSalesChart() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        drawHorizontalLine: true,
        verticalInterval: 1,
        horizontalInterval: 500,
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: AppColors.borderColor,
            strokeWidth: 1,
          );
        },
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: AppColors.borderColor,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: 1,
            getTitlesWidget: (value, meta) {
              const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
              if (value.toInt() >= 0 && value.toInt() < days.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    days[value.toInt()],
                    style: AppTextStyles.caption,
                  ),
                );
              }
              return const Text('');
            },
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            interval: 500,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toInt()}',
                style: AppTextStyles.caption,
              );
            },
            reservedSize: 42,
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: AppColors.borderColor),
      ),
      minX: 0,
      maxX: 6,
      minY: 0,
      maxY: 3000,
      lineBarsData: [
        LineChartBarData(
          spots: const [
            FlSpot(0, 2000),
            FlSpot(1, 1500),
            FlSpot(2, 2500),
            FlSpot(3, 1800),
            FlSpot(4, 2800),
            FlSpot(5, 2200),
            FlSpot(6, 2847),
          ],
          isCurved: true,
          color: AppColors.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.primary,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
          belowBarData: BarAreaData(
            show: true,
            color: AppColors.primary.withOpacity(0.1),
          ),
        ),
        LineChartBarData(
          spots: const [
            FlSpot(0, 15),
            FlSpot(1, 12),
            FlSpot(2, 18),
            FlSpot(3, 14),
            FlSpot(4, 22),
            FlSpot(5, 19),
            FlSpot(6, 24),
          ],
          isCurved: true,
          color: AppColors.accent,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) {
              return FlDotCirclePainter(
                radius: 4,
                color: AppColors.accent,
                strokeWidth: 2,
                strokeColor: Colors.white,
              );
            },
          ),
        ),
      ],
    );
  }

  PieChartData _buildCategoryChart() {
    return PieChartData(
      pieTouchData: PieTouchData(
        touchCallback: (FlTouchEvent event, pieTouchResponse) {
          // Handle touch events
        },
      ),
      borderData: FlBorderData(show: false),
      sectionsSpace: 2,
      centerSpaceRadius: 40,
      sections: [
        PieChartSectionData(
          color: Colors.blue,
          value: 35,
          title: '35%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.green,
          value: 25,
          title: '25%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.orange,
          value: 20,
          title: '20%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.purple,
          value: 12,
          title: '12%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        PieChartSectionData(
          color: Colors.red,
          value: 8,
          title: '8%',
          radius: 60,
          titleStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String title, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          title,
          style: AppTextStyles.caption,
        ),
      ],
    );
  }

  Widget _buildTopProductItem(
      String name, String price, String sales, int rank) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rank <= 3 ? AppColors.accent : AppColors.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rank <= 3
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.image,
              color: AppColors.textLight,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  sales,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            price,
            style: AppTextStyles.price.copyWith(fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(
    String title,
    String description,
    String time,
    IconData icon,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.subtitle2,
                ),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTextStyles.caption,
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    // Simulate data refresh
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      // Refresh data here
    });
  }
}
