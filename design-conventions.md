# Design Conventions

This file defines the **design process** — how a defined problem becomes an interface someone else can build. It is loaded into AI context when a task designs a flow or screen, produces a mockup or prototype, reviews a design, or hands a design to implementation.

Scope split: `ui-conventions.md` owns the craft — the usability principles, states, and layout rules a design must satisfy. `accessibility-conventions.md` sets the bar it must clear. This file owns the sequence: what gets designed when, at what fidelity, reviewed by whom, and what has to be true before anyone writes code against it.

---

## Design the Flow Before the Screen

- **Start from the problem and the evidence** (`discovery-conventions.md`), not from a screen you've already pictured. A design that starts at the screen inherits assumptions nobody wrote down.
- **Map the whole path first** — where the user comes from, what they're trying to finish, what they do next, and where they are when they get interrupted. Most usability failures live between screens, not on one.
- **Design the unhappy path in the same pass**: no permission, no data, no network, bad input, a half-finished task resumed tomorrow. Designed later, these become whatever the implementer improvised.
- **Design against real content and real volumes** — the longest real name, the empty account, the account with 40,000 records, the field that's null for a third of the rows. A design proven on tidy placeholder data has been proven against nothing.

## Fidelity Matches the Question

Pick the cheapest artifact that answers the open question, and no more:

| Question | Artifact |
|---|---|
| Is this the right flow? | Boxes and arrows, a whiteboard, a diagram |
| Does the structure work? | Low-fidelity wireframe, greyscale |
| Can people complete it? | Clickable prototype, real copy, no visual polish |
| Does it hold up in the product? | High-fidelity comp on the design system |

**Fidelity is read as commitment.** A polished mockup shown to a stakeholder stops being a question and becomes a promise, in their mind if not in yours — so raise fidelity deliberately, and label anything exploratory as exploratory. The same warning as `discovery-conventions.md`: an interactive prototype is built to answer a question and thrown away, never promoted into the product.

## Reuse Before You Invent

- **If the design system has the component, use it** (`ui-conventions.md`). A one-off variant is a permanent maintenance cost paid by everyone after you, and it is almost never worth the difference it makes.
- **A genuinely new component is a decision**, not a drawing: it needs a name, all its states, its accessibility behavior, and a home in the system. Design it once and contribute it back, or you have started a second design system by accident.
- **Consistency beats local optimality.** A slightly worse pattern used everywhere beats a slightly better one used here (Jakob's Law, `ui-conventions.md`).

## Accessibility Is Designed, Not Retrofitted

Roughly half of accessibility failures are decided before implementation starts, and they are the expensive half:

- **Colour and contrast, focus order, target sizes, and text alternatives are design decisions** — checked at design time against `accessibility-conventions.md`, not discovered in a pre-launch audit.
- **Never carry meaning in colour alone**, and specify the visible focus state — implementers inherit whatever the design omits.
- **Specify the semantics**, not just the appearance: is that a button or a link, a heading or bold text, a list or lines that look like one. An implementer building from a picture has to guess, and guesses become markup.

## Design Review Has Criteria

A review is a check against the definition and the conventions, not an opinion round. Before it's handed over, the design answers:

- Does it deliver the **outcome** in the definition, and does it stay inside the **non-goals** (`product-definition-conventions.md`)?
- Are **all states** present — empty, loading, error, partial, populated, and the permission-denied case (`ui-conventions.md`)?
- Does it clear **accessibility** (`accessibility-conventions.md`)?
- Does it **reuse** the system, and is anything new justified?
- What does it **assume about the data** — volumes, optional fields, formats — and is that assumption true?
- Is anything here a **security or authorization decision in disguise**? A design that hides a control the server still allows is not a permission model (`security-conventions.md`).

Aesthetic preference is the last thing discussed, not the first.

## Handoff Specifies Behavior, Not Just Appearance

A picture is an incomplete specification. The handoff carries:

- **Every state** of every interactive element, including focus, disabled, loading, and error.
- **Behavior** — what happens on submit, on failure, on slow response, on back, on resize, on paste of something unexpected.
- **Tokens, not values** — spacing, colour, and type refer to the system's tokens so the build can't drift from the design (`ui-conventions.md`).
- **Content rules** — what happens when text is longer than drawn, and the actual copy, not lorem ipsum. Real copy routinely changes a layout.
- **The open questions**, marked as open. An unmarked guess in a handoff becomes a decision nobody made.

## Design QA Before Launch, Not After

- **The designer checks the built thing** against the design and the definition before it's released — on a real device, with keyboard only, with real data.
- **Discrepancies are fixed or accepted explicitly.** A silently accepted discrepancy is design debt that the next feature copies.
- This is a distinct gate from code review and from the launch readiness check (`launch-conventions.md`); it catches a different class of defect than either.

## Design Debt Is Tracked Like Any Other Debt

Inconsistencies, one-off components, and patterns superseded but not migrated are recorded where the team's other debt lives — not carried in someone's head. Untracked, it is only ever discovered by a user or by the third person to copy the wrong pattern.

## What AI Does and Doesn't Do Here

- **Does:** generate flow diagrams and layout options fast, enumerate the states and edge cases a design is missing, check a design against the heuristics in `ui-conventions.md` and the rules in `accessibility-conventions.md`, produce throwaway clickable prototypes, and write first-draft microcopy.
- **Doesn't:** own the brand, invent the design system, or make the taste call (`ui-conventions.md` — AI implements a system, it doesn't invent one).
- **AI-generated interfaces skip the same things every time** — empty states, error states, focus management, long content, and real data volumes. Review for those specifically; they will not be volunteered.

## By Collaboration Mode

- **Solo:** you are the designer, and the risk is skipping the artifact entirely and designing in code — where changing your mind is 50× more expensive. A sketch and a states checklist take ten minutes and are not optional ceremony.
- **Collaborative:** design review is a named step with a named reviewer before build starts, and design QA is a named step before release.

## Company & Project Overrides

Design tooling, file organization, the design system itself, brand and voice, and whether a formal research or design-review board sign-off is required are company-specific (see `companies/_template.md`) and are **preferences**. Designing all states, meeting accessibility, and specifying behavior at handoff are principles.
