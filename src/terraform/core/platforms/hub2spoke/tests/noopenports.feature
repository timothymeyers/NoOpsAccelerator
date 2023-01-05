Feature: Test Security Group compliance

Scenario: No publicly open ports
    Given I have Azure Security Group defined
    When it has ingress
    Then it must have ingress
    Then it must not have tcp protocol and port 1024-65535 for 0.0.0.0/0
