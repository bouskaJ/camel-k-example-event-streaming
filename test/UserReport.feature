Feature: User report component test

  Background:
    Given integration user-report-system should be running
    And URL: http://user-report-system.camel-k-event-streaming.svc.cluster.local
    And variable user is "user1"

  Scenario: Crime report is send to crime-data topic
    And Kafka connection
      | url       | event-streaming-kafka-cluster-kafka-bootstrap.event-streaming-kafka-cluster:9092 |
      | topic     | crime-data |
    And variable location is "citrus:randomString(10)"
    And HTTP request body
    """
      {
        "user": {
          "name": "${user}"
        },
        "report": {
          "type": "crime",
          "alert": "true",
          "measurement": "g",
          "location": "${location}"
        }
      }
    """
    When send PUT /report/new
    And receive HTTP 200
    And expect HTTP response body: OK
    And verify message in Kafka with body
    """
      {
        "type" : "crime",
        "alert" : "@ignore@",
        "measurement" : "@ignore@",
        "location" : "${location}"
      }
    """

   Scenario: Health report is send to health-data topic
    Given Kafka connection
      | url       | event-streaming-kafka-cluster-kafka-bootstrap.event-streaming-kafka-cluster:9092 |
      | topic     | health-data |
    And variable location is "citrus:randomString(10)"
    And HTTP request body
    """
      {
        "user": {
          "name": "${user}"
        },
        "report": {
          "type": "health",
          "alert": "true",
          "measurement": "g",
          "location": "${location}"
        }
      }
    """
    When send PUT /report/new
    Then integration user-report-system should be running
    And receive HTTP 200
    And expect HTTP response body: OK
    And verify message in Kafka with body
    """
      {
        "type" : "health",
        "alert" : "@ignore@",
        "measurement" : "@ignore@",
        "location" : "${location}"
      }
    """ 