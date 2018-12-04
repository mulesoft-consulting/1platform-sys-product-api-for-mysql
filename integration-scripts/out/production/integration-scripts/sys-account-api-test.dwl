import * from bat::BDD
import * from bat::Assertions

var context = bat::Mutable::HashMap() // <--- First, the HashMap
var app_client_id = '76a81264c2464d30bb777494f778378a'
var app_client_secret = 'c361203e7e8d48419B81BF2AbAC7645B'
var customer_email = 'jim@king.com'
var api_endpoint = 'http://account-api-sfdc-v1.us-e2.cloudhub.io/api'
fun header() = {
      "headers": {
            "Accept": "application/json",
            "Content-Type": "application/json",
            "client_id":"$(app_client_id)",
            "client_secret":"$(app_client_secret)"
          }
    }
---
suite("Account System API - CRUD Black Box Testing") in [
// Test Account CREATE
  POST `$(api_endpoint)/accounts`
  with {
    headers: header().headers,
    "body":
      [
        {
          "name": "Jim King",
          "phone": [
            {
              "phoneNumber": "(310) 555-0100",
              "type": "Work"
            }
          ],
          "email": [{
            "address": "$(customer_email)",
            "type": "Work"
            }],
          "postalAddresses": [
            {
              "type": "billing",
              "addressLines": ["1351 Palisades Beach Road"],
              "city": "Santa Monica",
              "state": "CA",
              "postalCode": "90401",
              "countryCode": "USA"
            },
            {
              "type": "shipping",
              "addressLines": ["1351 Palisades Beach Road"],
              "city": "Santa Monica",
              "state": "CA",
              "postalCode": "90401",
              "countryCode": "USA"
            }
          ]
        }
      ]
    }
  assert [
    $.response.status mustEqual 202, // <--- Then a status assertion
    $.response.mime mustEqual "application/json" // <--- And a MIME type assertion
  ] execute [
    log($.response)
  ],
  //Get User by Email and Save Id
  GET `$(api_endpoint)/accounts?accountName=$(customer_email)&maxResults=25`
  with header()
   assert [
    $.response.status mustEqual 200, // <--- Then a status assertion
    $.response.mime mustEqual "application/json" // <--- And a MIME type assertion
  ] execute [
    context.set('old_array_size', sizeOf($.response.body.accounts as Array)),
    context.set('accountId', $.response.body.accounts[0].id),
    log("length: " ++ context.get('old_array_size')) // <--- Then we’ll log the response
    log("AccountID: " ++ context.get("accountId"))
  ],
  //Update Account
  PUT `$(api_endpoint)/accounts/$(context.get("accountId"))`
  with {
    headers: header().headers,
    body:{
      "name": "Jim Kong",
      "phone": [
        {
          "phoneNumber": "(310) 555-0100",
          "type": "Work"
        }
      ],
      "email": [{
        "address": "jimmy@kingston.com",
        "type": "Work"
        }],
      "postalAddresses": [
        {
          "type": "billing",
          "addressLines": ["1351 Palisades Beach Road"],
          "city": "Santa Monica",
          "state": "CA",
          "postalCode": "90401",
          "countryCode": "USA"
        },
        {
          "type": "shipping",
          "addressLines": ["1351 Palisades Beach Road"],
          "city": "Santa Monica",
          "state": "CA",
          "postalCode": "90401",
          "countryCode": "USA"
        }
      ]
    }
  } assert [
    $.response.status mustEqual 202, // <--- Then a status assertion
    $.response.mime mustEqual "application/json" // <--- And a MIME type assertion
  ] execute [
    log($.response)
  ],
  //Remove Account
  DELETE `$(api_endpoint)/accounts/$(context.get("accountId"))`
  with header()
  assert [
    $.response.status mustEqual 202
  ]
]
