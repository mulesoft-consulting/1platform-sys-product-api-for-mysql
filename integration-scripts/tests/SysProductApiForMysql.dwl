%dw 2.0
import * from bat::BDD
import * from bat::Assertions

var context = bat::Mutable::HashMap()
var app_client_id = 'ce61a67b09f1440baa6ce66d97bb7f90'
var app_client_secret = '61c1E689Eb77485dbEAeDd6b0266399d'
var api_endpoint = config.api_endpoint


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
  it should 'answer 200' in [
    GET `$(api_endpoint)/products` with {
        headers: header().headers,
        queryParams: {
            maxResults: 5,
            pagingOffset: 0
        }
    } assert [
      $.response.status mustEqual 200 /*Ok*/
    ],
    GET `$(api_endpoint)/products/502100` with header()
    assert [
        $.response.status mustEqual 200
    ]
  ],

  it should 'answer 404' in [
    GET `$(api_endpoint)/products/5021000` with header()
    assert [
        $.response.status mustEqual 404
    ],
    DELETE `$(api_endpoint)/products/5021000` with header()
    assert [
        $.response.status mustEqual 404
    ],
    PUT `$(api_endpoint)/products/5021000` with {
        headers: header().headers,
        body: readUrl('classpath://data/single_product.json', 'application/json')
        }
    assert [
        $.response.status mustEqual 404
    ],
  ],
    GET `$(api_endpoint)/products/$(context.get('product_number'))` with header()
    assert [
        $.response.status mustEqual 200
    ],
    PUT `$(api_endpoint)/products/$(context.get('product_number'))` with {
        headers: header().headers,
        body: readUrl('classpath://data/single_product.json', 'application/json')
        }
     assert [
        $.response.status mustEqual 204,
    ],
    DELETE `$(api_endpoint)/products/$(context.get('product_number'))` with header()
    assert [
        $.response.status mustEqual 204
    ]

  ]
]
