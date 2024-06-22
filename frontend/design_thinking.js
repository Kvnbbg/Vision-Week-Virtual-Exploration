function openDesignThinkingQuiz() {
  // Create the pop-up window content
  const content = `
    <h2>Design Thinking Quiz</h2>
    <p>Test your knowledge of design thinking!</p>
    <ol>
      <li>What is the first stage of design thinking that focuses on understanding users?</li>
      <ul>
	<li><input type="radio" name="q1" value="A. Design"> (A) Design</li>
	<li><input type="radio" name="q1" value="B. Empathize"> (B) Empathize</li>
	<li><input type="radio" name="q1" value="C. Prototype"> (C) Prototype</li>
      </ul>
    </ol>
    <ol>
      <li>What does the process of brainstorming ideas involve?</li>
      <ul>
	<li><input type="radio" name="q2" value="A. User testing"> (A) User testing</li>
	<li><input type="radio" name="q2" value="B. Ideate"> (B) Ideate</li>
	<li><input type="radio" name="q2" value="C. Define"> (C) Define</li>
      </ul>
    </ol>
    <button onclick="submitAnswers()">Submit Answers</button>`;

  // Create a new pop-up window
  const popup = window.open("", "designThinkingQuiz", "width=400,height=300");
  popup.document.write(content);
  popup.document.close();
}

function submitAnswers() {
  // Get user's answers from the pop-up window
  const answer1 = popup.document.querySelector('input[name="q1"]:checked').value;
  const answer2 = popup.document.querySelector('input[name="q2"]:checked').value;

  // Create or access the JSON data
  let designThinkingData;
  try {
    designThinkingData = JSON.parse(localStorage.getItem("design_thinking"));
  } catch (error) {
    designThinkingData = {};
  }

  // Store user's answers in the JSON object
  designThinkingData.quizResults = {
    question1: answer1,
    question2: answer2,
  };

  // Save the JSON data in local storage
  localStorage.setItem("design_thinking", JSON.stringify(designThinkingData));

  // Close the pop-up window
  popup.close();

  alert("Thank you for taking the quiz! Your answers have been stored.");
}
