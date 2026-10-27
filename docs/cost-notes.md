# AWS Cost Notes

## 1. Estimate shown in AWS Pricing Calculator

The estimate is based on the provided screenshot. The selected Region is **US East (N. Virginia) — `us-east-1`**.

| AWS service                         | Estimated monthly cost |
| ----------------------------------- | ---------------------: |
| Amazon DynamoDB                     |                  $0.32 |
| Amazon S3                           |                  $0.34 |
| AWS Systems Manager Parameter Store |                  $0.00 |
| Amazon CloudWatch                   |                  $2.52 |
| **Total**                           |        **$3.18/month** |

The calculator summary shows:

- **Upfront cost:** $0.00
- **Monthly cost:** $3.18
- **Estimated 12-month cost:** $38.16

The 12-month figure matches `$3.18 × 12 = $38.16`.

## 2. Estimated weekly cost

Using 52 weeks per year:

`$3.18 × 12 ÷ 52 = $0.7338`

**Estimated weekly cost: about $0.73 per week.**

This is an average derived from the monthly estimate, not a separate weekly quote from AWS.

## 3. Estimated cost for 12 hours

AWS Pricing Calculator uses **730 hours per month** for its monthly estimate. Using that convention, the proportional estimate for 12 hours is:

`$3.18 ÷ 730 × 12 = $0.0523`

**Estimated 12-hour cost: about $0.05.**

### Does 12 hours exceed the $5 limit?

**No — based on this simple proportional calculation, $0.05 is below $5.00**, leaving approximately **$4.95** of the budget.

However, this is only a rough time-prorated estimate. It assumes the $3.18 monthly total scales evenly with time. Some costs depend on stored data, requests, log ingestion, or other usage rather than simply the number of hours the resources exist. Therefore, the actual cost for a 12-hour deployment may differ. A monthly calculator estimate does not guarantee the bill for a short test will be exactly five cents.

## 4. Cost-control plan for the Terraform assignment

- Apply the **dev** environment only for the required test.
- Run plans for **staging** and **prod** without applying them.
- Keep the optional EC2 instance disabled unless it is specifically needed.
- Avoid NAT Gateways, load balancers, RDS, EKS, OpenSearch, and Elastic IPs for this low-cost exercise.
- Capture the required evidence and destroy the dev resources as soon as testing is complete.
- Check for leftover resources after destroying the Terraform-managed dev environment, including S3 objects and any separately created backend resources.
- Review **AWS Billing and Cost Management** after the test; billing information can be delayed.

## 5. Important assumptions and limitations

This estimate covers only the services and configuration visible in the provided calculator screenshot. It may not include resources or usage that were not entered into the calculator, taxes, or other account-level charges. AWS pricing varies by Region and can change. The calculator is an estimate, not a guarantee of actual charges.
