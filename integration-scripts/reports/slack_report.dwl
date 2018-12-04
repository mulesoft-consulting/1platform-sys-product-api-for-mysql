%dw 2.0
output application/json
---
{
  channel: "#workshop-se-provision",
  message: "This is a report test " ++ payload.name
}