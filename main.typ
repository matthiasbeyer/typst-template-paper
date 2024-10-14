#import "@preview/charged-ieee:0.1.2": ieee
#import "@preview/cetz:0.2.2": canvas, draw, tree

#show: ieee.with(
  title: [A typesetting system to untangle the scientific writing process],
  abstract: [
    The process of scientific writing is often tangled up with the intricacies
    of typesetting, leading to frustration and wasted time for researchers. In
    this paper, we introduce Typst, a new typesetting system designed
    specifically for scientific writing. Typst untangles the typesetting
    process, allowing researchers to compose papers faster. In a series of
    experiments we demonstrate that Typst offers several advantages, including
    faster document creation, simplified syntax, and increased ease-of-use.
  ],
  authors: (
    (
      name: "Martin Haug",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "haug@typst.app"
    ),
    (
      name: "Laurenz Mädje",
      department: [Co-Founder],
      organization: [Typst GmbH],
      location: [Berlin, Germany],
      email: "maedje@typst.app"
    ),
  ),
  index-terms: ("Scientific writing", "Typesetting", "Document creation", "Syntax"),
  bibliography: bibliography("refs.bib"),
)

= Introduction

Scientific writing is a crucial part of the research process, allowing
researchers to share their findings with the wider scientific community.
However, the process of typesetting scientific documents can often be a
frustrating and time-consuming affair, particularly when using outdated tools
such as LaTeX. Despite being over 30 years old, it remains a popular choice for
scientific writing due to its power and flexibility. However, it also comes with
a steep learning curve, complex syntax, and long compile times, leading to
frustration and despair for many researchers. @netwok2020

== Paper overview

In this paper we introduce Typst, a new typesetting system designed to
streamline the scientific writing process and provide researchers with a fast,
efficient, and easy-to-use alternative to existing systems. Our goal is to shake
up the status quo and offer researchers a better way to approach scientific
writing.

By leveraging advanced algorithms and a user-friendly interface, Typst offers
several advantages over existing typesetting systems, including faster document
creation, simplified syntax, and increased ease-of-use.

To demonstrate the potential of Typst, we conducted a series of experiments
comparing it to other popular typesetting systems, including LaTeX. Our findings
suggest that Typst offers several benefits for scientific writing, particularly
for novice users who may struggle with the complexities of LaTeX. Additionally,
we demonstrate that Typst offers advanced features for experienced users,
allowing for greater customization and flexibility in document creation.

Overall, we believe that Typst represents a significant step forward in the
field of scientific writing and typesetting, providing researchers with a
valuable tool to streamline their workflow and focus on what really matters:
their research. In the following sections, we will introduce Typst in more
detail and provide evidence for its superiority over other typesetting systems
in a variety of scenarios.

= Methods
#lorem(90)

$ a + b = gamma $

#lorem(20)

#let data = (
  [A], ([B], [C], [D]), ([E], [F])
)

= Figures

@some-things shows a graph of things.

#figure(
    canvas(length: 1cm, {
      import draw: *

      set-style(content: (padding: .2),
        fill: gray.lighten(70%),
        stroke: gray.lighten(70%))

      tree.tree(data, spread: 2.5, grow: 1.5, draw-node: (node, ..) => {
        circle((), radius: .45, stroke: none)
        content((), node.content)
      }, draw-edge: (from, to, ..) => {
        line((a: from, number: .6, b: to),
             (a: to, number: .6, b: from), mark: (end: ">"))
      }, name: "tree")

      // Draw a "custom" connection between two nodes
      let (a, b) = ("tree.0-0-1", "tree.0-1-0",)
      line((a, .6, b), (b, .6, a), mark: (end: ">", start: ">"))
    }),

    caption: [A Graph of some things.],
) <some-things>

= Some code examples

Some code examples go here.

```python
def foo():
    print(1)
```

Or lets do the same thing in `Rust`:

```rust
fn foo() -> () {
    println!("1")
}
```
