# Agent Script Recipe README Ruleset

This document defines the standard structure and formatting for README files in the Agent Script recipes repository. All recipe READMEs must follow this structure to ensure consistency and high-quality documentation.

## 1. File Structure

Every README must include the following sections in this order:

1. **Title** (`# <RecipeName>`)
2. **Overview** (`## Overview`)
3. **Agent Flow** (`## Agent Flow`)
4. **Key Concepts** (`## Key Concepts`)
5. **How It Works** (`## How It Works`)
6. **Key Code Snippets** (`## Key Code Snippets`)
7. **Try It Out** (`## Try It Out`)
8. **What's Next** (`## What's Next`)
9. **Testing** (Optional but recommended) (`## Testing`)
10. **Notes** (Optional) (`## Notes`)

## 2. Section Details

### Title

- Format: `# <RecipeName>` or `# <AgentName> Agent`
- Should match the directory name or the main agent file name.

### Overview

- A concise paragraph (2-3 sentences) explaining:
    - What the recipe demonstrates.
    - Why it is useful.
    - The specific problem it solves or concept it teaches.

### Agent Flow

- Must contain a Mermaid diagram visualizing the agent's logic.
- Syntax:

    ```mermaid
    %%{init: {'theme':'neutral'}}%%
    graph TD
        A[Start] --> B[Step]
        ...
    ```

- Always use `theme: neutral` and `graph TD`.
- Nodes should represent key states, decisions, or actions.

### Key Concepts

- A bulleted list of the specific features, patterns, or syntax elements demonstrated.
- Format: `- **Concept Name**: Brief description`

### How It Works

- The core educational section.
- Break down the implementation into logical subsections using H3 (`###`).
- Explain _why_ things are done a certain way, not just _what_ is done.
- Use code blocks with `agentscript` language tagging for inline examples.
- Connect the code to the concepts listed in the previous section.

### Key Code Snippets

- Highlight the most important blocks of code from the agent file.
- Use H3 (`###`) to title each snippet.
- Use `agentscript` code blocks.
- Ensure snippets are complete enough to be understood in context.

### Try It Out

- Explain how to interact with the agent.
- **Mandatory**: Include an "Example Interaction" subsection.
- Format the conversation transcript using a `text` code block:

    ```text
    Agent: Hello!

    User: Hi there.

    Agent: How can I help?
    ```

- Optionally explain what is happening "Behind the Scenes" for specific turns.

### What's Next

- A bulleted list of related recipes or advanced concepts to explore next.
- Format: `- **RecipeName**: Description of relation`

### Testing (Optional)

- Instructions on how to verify the agent's behavior.
- List specific test cases or inputs and expected outputs.

## 3. Formatting Rules

- **Code Blocks**:
    - Use `agentscript` for all Agent Script code.
    - Use `text` for console output or conversation transcripts.
    - Use `json` or other languages as appropriate for data.
- **Headings**:
    - Top level: `#`
    - Sections: `##`
    - Subsections: `###`
- **Emphasis**:
    - Use **bold** for key terms, variable names in text, or UI elements.
    - Use `code` style for file names, specific values, or short syntax elements.

## 4. Tone and Style

- **Educational**: The primary goal is to teach. Explain _why_, not just _how_.
- **Clear**: Use simple, direct language. Avoid jargon unless defined.
- **Consistent**: Use the same terminology as the official documentation.
- **Action-Oriented**: Encourage the user to run the code and experiment.
