---
name: sdd-ddd-architecture
description: Use for Specification-Driven Development with DDD, hexagonal architecture, Clean Architecture, clean code reviews, and architecture refactoring decisions.
compatibility: opencode
---

# SDD DDD Architecture

Use this skill when implementing or reviewing software through Specification-Driven Development, Domain-Driven Design, hexagonal architecture, Clean Architecture, or clean code principles.

## Operating Mode

Start from the specification before code. If the specification is missing, ambiguous, or too implementation-focused, ask for or draft a concise specification first.

Treat tests as verification of the specification, not as the primary design driver. Use examples, acceptance criteria, and domain invariants to drive implementation choices.

Prefer small, explicit changes that preserve boundaries. Avoid broad rewrites unless the current structure prevents the requested behavior or hides critical domain rules.

## Specification-Driven Development

Before implementation, identify:

- The user-visible behavior or business capability.
- The domain language and key terms.
- Preconditions, postconditions, and invariants.
- Acceptance criteria and edge cases.
- Failure modes and expected error behavior.
- Integration boundaries and external dependencies.

When reviewing a change, check whether the implementation satisfies the specification directly and whether the spec is still discoverable from code, tests, and docs.

## DDD Guidance

Model the domain explicitly:

- Use entities for objects with identity and lifecycle.
- Use value objects for immutable concepts defined by their attributes.
- Use aggregates to protect invariants and transactional consistency.
- Keep domain services focused on domain behavior that does not naturally belong to one entity or value object.
- Keep repositories as collection-like abstractions for aggregate persistence.
- Keep application services focused on orchestration, transactions, authorization, and interaction with ports.

Flag these issues:

- Anemic domain models where business rules live mostly in controllers, handlers, or persistence code.
- Leaking database schemas, framework types, or transport DTOs into the domain model.
- Aggregates that are too large, too chatty, or unclear about consistency boundaries.
- Domain services used as procedural dumping grounds.
- Generic names like `Manager`, `Helper`, `Utils`, or `Processor` when a domain concept exists.

## Hexagonal Architecture

Keep the domain and application core independent from delivery mechanisms and infrastructure.

Use ports for operations the core needs from the outside world. Use adapters for concrete implementations such as databases, HTTP clients, queues, filesystems, and third-party APIs.

Review dependency direction:

- Domain must not depend on application, infrastructure, UI, or framework code.
- Application may depend on domain and port interfaces.
- Infrastructure should implement ports and translate external models.
- Delivery adapters should translate requests into application commands or queries.

Flag direct calls from domain/application code to concrete infrastructure, global clients, framework request objects, or persistence-specific APIs.

## Clean Architecture

Apply the dependency rule: source code dependencies point inward toward policy, not outward toward mechanisms.

Separate concerns:

- Entities and value objects contain enterprise/domain rules.
- Use cases/application services contain application-specific workflows.
- Interface adapters translate between external formats and internal models.
- Frameworks and drivers remain replaceable details.

Prefer explicit input and output models at boundaries. Do not force domain models to match API payloads, ORM records, or UI view models.

## Clean Code Review Checklist

When reviewing or refactoring, prioritize:

- Correctness of domain behavior and invariants.
- Clear names based on the ubiquitous language.
- High cohesion and low coupling.
- Simple control flow and explicit side effects.
- Boundary validation and consistent error handling.
- Transaction boundaries that match aggregate consistency needs.
- Tests or executable examples that verify specification behavior.
- Minimal framework leakage across layers.

Avoid cosmetic refactors that do not improve behavior, clarity, or boundary integrity.

## Expected Output

For implementation tasks, produce:

- A short statement of the inferred specification.
- The smallest design that satisfies it.
- Code changes that preserve inward dependencies.
- Verification focused on acceptance criteria and invariants.

For review tasks, produce findings first. Include file and line references, describe the architectural risk, and suggest the smallest corrective change.
