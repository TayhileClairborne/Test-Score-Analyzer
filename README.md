# Test Score Analyzer

This project is a complete LC-3 Assembly program that allows the user to input five test scores (0–100), calculates the **minimum**, **maximum**, and **average**, and determines the corresponding **letter grade (A–F)** based on the average score.

---

## Features

- Prompts user for five test scores using keyboard input (GETC)
- Handles ASCII to integer conversion (0–99 range)
- Computes:
  - Minimum score
  - Maximum score
  - Average score (integer division)
  - Letter grade (A–F)
- Displays results using TRAP x22 (PUTS)
- Implements:
  - Subroutines for modular design
  - Stack usage for temporary register storage
  - Control flow with loops and branching
  - Clean and readable ASCII output
