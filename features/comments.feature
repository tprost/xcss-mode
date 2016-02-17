Feature: Comments
  In order insert a comment into a CSS file
  As a user
  I want to use some commands and stuff

  Scenario: Indenting a single line of CSS
    Given I am in buffer "my-file.css"
    And the buffer is empty
    And I call "xcss-mode"
    And I insert:
    """
    div {
        background-color: pink;
    }
    """
    When I go to line "2"
    And I call "comment-line"
    Then the buffer should contain:
    """
    div {
        /* background-color: pink; */
    }
    """

  @skip
  Scenario: Indenting a region
    Given I am in buffer "my-file.css"
    And the buffer is empty
    And I call "xcss-mode"
    And I insert:
    """
    div {
        background-color: pink;
    }
    """
    When I call "mark-whole-buffer"
    And I call "comment-region"
    Then the buffer should contain:
    """
    /* div {
           background-color: pink;
    } */
    """
