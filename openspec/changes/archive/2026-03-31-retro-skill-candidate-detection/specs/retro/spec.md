## MODIFIED Requirements

### Requirement: Retro analysis steps include skill candidate detection
The `/retro` skill SHALL include a skill candidate detection step after existing friction analysis steps and before presenting findings.

#### Scenario: Skill candidates detected
- **WHEN** the retro skill runs and user messages contain candidate patterns
- **THEN** a "Skill Candidates" table is included in the output alongside the existing Approval Friction and Missed Tooling tables

#### Scenario: No skill candidates detected
- **WHEN** the retro skill runs and no candidate patterns are found
- **THEN** the skill candidate section is omitted; existing tables are unaffected

### Requirement: Retro follow-up questions include skill candidate questions
The post-analysis follow-up questions SHALL include the three skill candidate questions (placement, interest, calibration) when candidates were found.

#### Scenario: Candidates found, follow-up extended
- **WHEN** the skill candidate table has one or more rows
- **THEN** the three skill candidate questions are appended to the existing follow-up questions

#### Scenario: No candidates, follow-up unchanged
- **WHEN** no candidates were found
- **THEN** the existing follow-up questions are asked without the skill candidate additions
