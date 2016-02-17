Feature: Indentation
  In order to indent a CSS file
  As a user
  I want to use default emacs commands

  Scenario: Indenting a simple block of CSS
    Given I am in buffer "my-file.css"
    And the buffer is empty
    When I insert:
    """
    div {
    background-color: pink;
    }
    """
    Then I should be in buffer "my-file.css"
    When I call "xcss-mode"
    And I call "mark-whole-buffer"
    And I call "indent-region"
    Then the buffer should contain:
    """
    div {
        background-color: pink;
    }
    """

