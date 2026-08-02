# Brazillian-Olist-Marketplace-Delivery-performance-Recommendation-Analysis-
This is a business-recommendation-focused analysis of 96,478 delivered orders from Olist, a Brazilian e-commerce marketplace, built to answer one decision: where should the business fix delivery reliability first, and why?

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
<img width="1716" height="1302" alt="Screenshot 2026-08-02 162702" src="https://github.com/user-attachments/assets/83ec2551-3f99-4c0b-a936-fc251b2241ee" />


**RECOMMENDATIONS:**

- Fix Rio de Janeiro first. It has a lot of orders and a high late rate, so improving it fixes more late deliveries than any other single state.
- Treat the far Northeast routes (São Paulo to Alagoas, Maranhão,.) as a slower, separate project. They have the worst late rates, but too few orders to matter as much as Rio de Janeiro right now.
- Audit carrier performance for February-March 2018. The sharp spike that month points to a specific, fixable cause, likely a carrier or capacity issue, rather than a spread out problem across the year. 
- Cross-check cancellations against the late delivery states. If cancellations cluster in the same high-late-rate states, customers are likely cancelling because they expect delays, which makes this a downstream effect of the same delivery problem. 
- Loosen the promised delivery window slightly. With deliveries taking 12days on average, a small adjustment to the estimated delivery date would reduce how many orders count as "late"

**DASHBOARD**

<img width="1650" height="1275" alt="Olist_Ecomerce_report_page-0001" src="https://github.com/user-attachments/assets/d5c0ab7f-f7e0-4350-be72-9cb80bb21b89" />

**Link to interact with the report:**

https://app.powerbi.com/view?r=eyJrIjoiMDEyNmYzNzQtM2UxZC00Y2FkLWE1NjQtMjc5ZGZmMGIzNmYwIiwidCI6ImRmODY3OWNkLWE4MGUtNDVkOC05OWFjLWM4M2VkN2ZmOTVhMCJ9







