import * from bat::BDD
import * from bat::Assertions
---
suite("Basic dev-nto-product-api-for-mysql-v1.us-e1.cloudhub.io test") in [
  it must 'answer 200' in [
    GET `https://dev-nto-product-api-for-mysql-v1.us-e1.cloudhub.io` with {} assert [
      $.response.status mustEqual 200 /*Ok*/
    ]
  ]
]