# Brazillian-Olist-Marketplace-Delivery-performance-Recommendation-Analysis-
A business-recommendation-focused analysis of 96,478 delivered orders from Olist, a Brazilian e-commerce marketplace, built to answer one decision: where should the business fix delivery reliability first, and why?

**Business Context**

Late deliveries are one of the clearest levers a last-mile or marketplace operator has over customer trust and repeat purchase and one of the most expensive to fix blindly. A typical first instinct is to treat “late delivery” as a distance problem and pour resources into the longest, most remote routes. This analysis tests that instinct against the data and reframes the decision around where the business actually loses the most delivery reliability at scale, not just where the percentage looks worst.
This framing mirrors the kind of problem a Decision Analyst is asked to solve in a delivery-network business: given limited operational budget, which single intervention returns the most reliability improvement per unit of effort.

**Data & Methodology**
**Data Source**

Brazilian E-Commerce Public Dataset by Olist approximately 100,000 orders placed between 2016 and 2018 across multiple Brazilian marketplaces, including order status and timestamps, customer and seller geography, product categories, pricing, and freight cost. The full 9-table release is used, including the geolocation dataset (1,000,163 zip-code-level lat/lng points), which was aggregated to state-level centroids to place each state's delivery performance on an actual map rather than a state-code axis.

**Scope & Filtering**

●	Analysis restricted to orders with status = “delivered” (96,478 of 99,441 total orders) so that delivery-time and lateness metrics are measured on completed journeys only.
●	“Late” is defined as order_delivered_customer_date later than order_estimated_delivery_date, the delivery promise shown to the customer at checkout, not an internal SLA target.
●	States and routes with fewer than 150–200 orders were excluded from headline comparisons to avoid small-sample noise driving the ranking.

**Data Model**
Built as a star schema for Power BI: a fact table at order-item grain (OrderItems) connected to Customer, Seller, Product, Geolocation, and a standard Date table. Geolocation is pre-aggregated from 1M+ raw zip-code pings down to one centroid per zip prefix (or per state, for this project's grain) before loading, to avoid an oversized, many-to-many relationship. 




