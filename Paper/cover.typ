
#let cover(
paperTitle: [A zero-cost dependency injection system],
firstSupervisor: [Atze van der Ploeg],
dailySupervisor: [Atze van der Ploeg],
secondSupervisor: [TBD],
studentName: [Tiziano Coroneo],
studentId: $[2736905]$,
isResearchProposal: true,
) = {

context align(center)[
  #set par(justify: false)
  #set page(margin: auto)
  #image("vu-griffioen.svg", height: 28mm)
  #v(1.5cm)
  #text(1.5em)[
    #if isResearchProposal [
      #strike[Bachelor Thesis] Research Proposal  
    ] else [
      Bachelor Thesis
    ]
  ]
  #v(1.5cm)
  #line(length: 100%)
  #v(0.4cm)
  #text(1.75em)[*#text(paperTitle)*]
  #v(0.4cm)
  #line(length: 100%)
  #v(1.5cm)
  #let renderedStudentId = text(size: super.size, studentId)
  #text(1.5em, grid(
    columns: (measure(renderedStudentId).width + 10pt, 2.5cm, 8cm, 2.5cm),
    rows: (auto,),
    align: (left, left, center, right),
    gutter: 5pt,
    grid.cell[],
    grid.cell[*Author*:],
    grid.cell[#text(studentName) #super(studentId)],
    grid.cell[],
  ))
  #grid(
    columns: (auto,) * 3,
    rows: (auto,) * 3,
    align: (left, center, center),
    gutter: 1em,
    grid.cell[_1st supervisor_:],
    grid.cell[#text(firstSupervisor)],
    grid.cell[],

    grid.cell[_daily supervisor:_],
    grid.cell[#text(dailySupervisor)],
    grid.cell[],

    grid.cell[_2nd reader:_],
    grid.cell[#text(secondSupervisor)],
    grid.cell[],
  )
  #v(2cm)

  #if isResearchProposal [
    #strike[_A thesis submitted in fulfillment of the requirements for\
  the VU Bachelor of Science degree in Computer Science_]  
  ] else [
    _A thesis submitted in fulfillment of the requirements for\
  the VU Bachelor of Science degree in Computer Science_
  ]
  
  #v(1cm)
  #datetime.today().display("[month repr:long] [day padding:none], [year]")
]

pagebreak()  
}
