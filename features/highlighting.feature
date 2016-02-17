Feature: Syntax Highlighting
  In order to see what I am doing
  As a user
  I want to have syntax highlighting

  Scenario: Selectors
    Given I am in buffer "my-file.css"
    And the buffer is empty
    And I call "xcss-mode"
    And I insert:
    """
    div {
        background-color: pink;
    }
    """
    And I go to beginning of buffer
    Then current point should have the css-selector face

  Scenario: Properties
    Given I am in buffer "my-file.css"
    And the buffer is empty
    And I call "xcss-mode"
    And I insert:
    """
    div {
        background-color: pink;
    }
    """
    And I go to word "background"
    Then current point should have the css-property face
    
