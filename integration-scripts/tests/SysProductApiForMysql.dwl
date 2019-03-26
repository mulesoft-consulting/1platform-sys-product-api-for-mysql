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
  it should 'run complete test in dev Environment' when (config.env == 'devx') in [
    POST `$(api_endpoint)/products` with {
        headers: header().headers,
        body: readUrl('classpath://data/products.json', 'application/json')
        }
    assert [
        $.response.status mustEqual 201 ,
        $.response.body.messages[0].code == "201" ,
        $.response.body.messages[1].code mustEqual "409"
    ]
    execute [
        context.set('product_number', $.response.body.messages[0].itemId)
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
