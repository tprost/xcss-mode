Feature: Existing
  In order to edit a CSS file
  As a user
  I want to run XCSS mode

  Scenario: With a buffer open
    Given I am in buffer "my-buffer"
    And I turn on xcss-mode
    Then I should be in major mode "xcss-mode"
