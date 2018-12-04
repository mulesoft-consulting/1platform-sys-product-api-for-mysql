%dw 2.0
import * from bat::BDD
import * from bat::Assertions

var app_client_id = 'bd4b93e0a2b5423385f48306ead4df4c'
var app_client_secret = '2f4Fe278c7404dE3B84402F21E50a4b6'
var api_endpoint = 'https://dev-product-api-for-mysql-v1.us-e1.cloudhub.io/api'
fun header() = {
      "headers": {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "client_id":"$(app_client_id)",
            "client_secret":"$(app_client_secret)"
          }
    }
---
suite("Product System API - CRUD Black Box Testing") in [
  it must 'answer 200' in [
    GET `$(api_endpoint)/products` with {
        headers: header().headers,
        queryParams: {
            maxResults: 5,
            pagingOffset: 0
        }
    } assert [
      $.response.status mustEqual 200 /*Ok*/
    ] execute [
      log($.response.payload)
    ],
    GET `$(api_endpoint)/products/502100` with header()
    assert [
        $.response.status mustEqual 200
    ] execute [
      log($.response.payload)
    ]
  ],

  it must 'answer 404' in [
    GET `$(api_endpoint)/products/5021000` with header()
    assert [
        $.response.status mustEqual 404
    ] execute [
      log($.response.payload)
    ],
    DELETE `$(api_endpoint)/products/5021000` with header()
    assert [
        $.response.status mustEqual 404
    ] execute [
      log($.response.payload)
    ],
    PUT `$(api_endpoint)/products/5021000` with header()
    assert [
        $.response.status mustEqual 404
    ] execute [
      log($.response.payload)
    ]
  ]
]