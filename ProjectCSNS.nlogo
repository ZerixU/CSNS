;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Project of CSNS 2017-2018 / Eduart Uzeir (ID: 0000843961) ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;; PART A : DECLARATIONS

; definition of global variables to use in the interface for plots and monitors
; numberOfImitations -> represent the total number of imitations, this number is shown on a monitor in the interface
; numberOfMovements -> represent the total number of moves, this number is shown on a monitor in the interface
; occupied -> is a costant that has the value 1, represents the status of a site
; free -> is a costant that hase the value 0, represents the free status of a site
; haltCondition -> a boolean variable that stops the model if there are no imitations or moves
; numberOfEmptySites -> a variable that shows in a monitor the number of empty sites at the start of the simulation
; movesOnTick -> a curve on the plot that shows the number of moves/tick
; imitateOnTick -> a curve on the plot that shows the number of imitations/tick
; mytimer -> used to show the time passed in seconds in the interface
; myNumberOfClusters -> used to show the number of clusters formed at the end of the simulation
; myListOfClusters ->

globals [ numberOfImitations numberOfMovements occupied free haltCondition numberOfEmptySites moveOnTick imitateOnTick mytimer myNumberOfClusters myListOfClusters]

; create a new breed to represent the nodes of the network, our sites

breed [sites site]


; every site has the following four attributes :
; myStatus -> controls the status of a site, if it is occupied or empty
; myCulturalCode -> represent the length of the vector F (in this simulation the maximum length is 10)
; myCulturalTrait -> represents the possible values of each trait, (in this simulation the maximum length is 10)
; myCulturalColor -> represents the color of the site (node), in other words a single population
; myShape -> represents the shape of the site (node), we show the empty sites with the "target" shape and the occupied sites with the "circle" shape
; myTolerance -> represents the Tolerance threshhold of individuals towards other cultures (T)

sites-own [myStatus myCulturalCode myCulturalTrait myCulturalColor myShape myTolerance]

; setMyValues ==> a procedure that initialize the variables and the costants of the program

to setMyValues

  set haltCondition true
  set occupied 1
  set free 0
  set numberOfMovements 0
  set numberOfImitations 0
  set numberOfEmptySites 0
  set moveOnTick 0
  set imitateOnTick 0
  set mytimer 0
  set myNumberOfClusters 0
  set myListOfClusters []

end


;;; PART B : NETWORK SETUP

;;; The free sites are shown as green stars
;;; The occupied sites are shown as circles with different colors

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup of the RANDOM NETWORK model
to random-network

  clear-all                                     ;;; clear all the previous networks and simulations
  ask patches [ set pcolor white ]              ;;; color the world in white for a better visualization
  setMyValues                                   ;;; calling the procedure for the initialisation of the variables

  create-sites number-of-sites [                ;;; create the number of sites based on the global costant "number-of-sites" that is the slider in the interface
    set myStatus free                           ;;; set the free sites with shape "star" and with the color "green"
    set shape "star"
    set myShape shape                           ;;; setting sites-own attribute myShape to shape
    set color green
    set myCulturalColor color                   ;;; setting sites-own attribute myCulturalColor to color
    setxy random-pxcor random-pycor             ;;; ask for the sites to be distributed in a random manner giving them random coordinates

    if random 100 < (1 - empty-prob) * 100 [    ;;; at this point we decide the number of the occupied sites based on the global variable "empty-prob", shown in the interface as a slider
      set myStatus occupied                     ;;; based on this probability we create the occupied sites and set the myStatus attributes of the sites
      set shape "circle"                        ;;; we change the shape of the sites to "circle"
      set myShape shape                         ;;; and the color to a random color instead to a green color
      set myTolerance tolerance                 ;;; setting the myTolerance attribute to the global variable 'tolerance', shown as a slider in the interface
    ]
  ]

  ask sites [                                   ;;; creatino of the links
    create-link-with one-of other sites         ;;; ask the sites to create a link with one of the others sites
    if (count link-neighbors)  = 0  [           ;;; if there are sites that have not a least a neighbor here we create them
      ask sites
      [create-link-with one-of other sites]
    ]
  ]

  ask sites [if myStatus = occupied [           ;;; ask the sites that are occupied to set their attributes
    set myCulturalCode  n-values cultural-code [random cultural-traits]
    set myCulturalTrait cultural-traits
    set color myColor                           ;;; sets the color of occupied sites to the value calculated by the reporter "myColor"
    set myCulturalColor color

    ]
  ]
  layout                                        ;;; call the procedure "layout" that sets the layout of the network
  let emptySites count sites with [myShape = "star"]  ;;; asign at the variable "emptySites" the number of sites that have shape "star". Recall that we show the empty sites as green stars
  set numberOfEmptySites emptySites             ;;; asign the value of emptySite to the variable numberOfEmptySites that is showed as a monitor in the interface
  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup of the PREFERENTIAL ATTACHMENT model

to preferential-attachment

  clear-all                                                                        ;;; clear all the previous simulations
  ask patches [ set pcolor white ]                                                 ;;; set the patches to white for a better visualization of the world
  setMyValues                                                                      ;;; call the procedure of the initialization of costants "setMyValues"

  create-sites 2 [                                                                 ;;; use the standard PA model, first create 2 nodes and then the others until number-of-sites

    set myStatus free                                                              ;;; creation and initialization of the empty sites
    set shape "star"
    set myShape shape
    set color green
    set myCulturalColor color

    if random 100 < (1 - empty-prob) * 100 [                                       ;;; creation and initalization of the occupied sites
      set myStatus occupied
      set myCulturalCode  n-values cultural-code [random cultural-traits]
      set myCulturalTrait cultural-traits
      set shape "circle"
      set myShape "circle"
      set color myColor                                                            ;;; calling the reporter "myColor" to get a value and to set the color of the occupied sites
      set myCulturalColor color                                                    ;;; setting the attribute myCulturalColor to the value calculated by "myColor"
      set myTolerance tolerance
    ]

    forward 1                                                                      ;;; move 1 position forward for a better visualization of the sites
  ]
  ask site 0 [ create-link-with site 1 ]                                           ;;; link the two sites just created

  repeat (number-of-sites - 2) [                                                   ;;; create the specified number of sites
    let myNewBuddy one-of [ both-ends ] of one-of links

    create-sites 1 [                                                               ;;; create one sites and set it's status to free
      set myStatus free
      set shape "star"
      set myShape shape
      set color green
      set myCulturalColor color
      create-link-with myNewBuddy
      if random 100 < (1 - empty-prob) * 100 [                                     ;;; here we use the probability of empty sites to create the occupied sites, once created initialize it
        set myStatus occupied
        set myCulturalCode  n-values cultural-code [random cultural-traits]
        set myCulturalTrait cultural-traits
        set shape "circle"
        set myShape "circle"
        set color myColor                                                           ;;; assign the color to the sites
        set myCulturalColor color
        set myTolerance tolerance

        move-to myNewBuddy
        forward 1
        create-link-with myNewBuddy
    ]]

    layout                                                                          ;;; call the layout procedure for a better visualization of the network
  ]

  let emptySites count sites with [myShape = "star"]                                ;;; calculate the number of empty sites at the start of the simulation
  set numberOfEmptySites emptySites

  reset-ticks
end


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup of the LATTICE model (here each agent has 4 neighbors)

to lattice4

  clear-all                                                                   ;;; clear the previous settings
  ask patches [set pcolor white]                                              ;;; set the color of the world to white
  setMyValues                                                                 ;;; initialization of the costants

  let myx round (sqrt number-of-sites)                                        ;;; define myx as the approximate value of the square root of the number of sites (900)
  set number-of-sites (myx * myx)                                             ;;; reset the number of sites as the approximate value in order to feet it in the grid

  let myHorizontal-int (world-width / myx)                                    ;;; set two integer variables one for the horizontal and one for the vertical dimensions of the grid
  let myVertical-int (world-height / myx)


  let myHorizontal-vals ( range ( min-pxcor + myHorizontal-int / 10 ) max-pxcor myHorizontal-int )   ;;; Get a range of horizontal and vertical coordinates, starting at half
  let myVertical-vals ( range ( min-pycor + myVertical-int / 10 ) max-pycor myVertical-int )


  let myPossibleCoordinates []                                                      ;;; Create an empty list to hold the possible coordinates

  foreach myVertical-vals [                                                         ;;; For each possible vertical value, map all horizontal values in order and
    v ->                                                                            ;;; combine these into an ordered list starting at the lowest px and py coords
    set myPossibleCoordinates ( sentence myPossibleCoordinates map [ i -> (list i v) ] myHorizontal-vals )
  ]


  let use-coords sublist myPossibleCoordinates 0 number-of-sites                    ;;; Use the number-of-sites to sublist the possible coordinates, and create a site at each of the coordinate combinations left
  foreach use-coords [
    coords ->
    create-sites 1 [
      setxy item 0 coords item 1 coords
    set myStatus free                           ;;; set the free sites with shape "star" and with the color "green"
    set shape "star"
    set myShape shape
    set color green
    set myCulturalColor color

    if random 100 < (1 - empty-prob) * 100 [    ;;; at this point we decide the number of the occupied sites based on the global variable "empty-prob", shown in the interface as a slider
      set myStatus occupied                     ;;; based on this probability we create the occupied sites and set the myStatus attributes of the sites
      set shape "circle"                        ;;; we change the shape of the sites to "circle"
      set myShape shape                         ;;; and the color to a random color instead to a green color
    set myCulturalCode  n-values cultural-code [random cultural-traits]
    set myCulturalTrait cultural-traits
    set myTolerance tolerance
    set color myColor                           ;;; set the color of the site calling the reporter myColor
    set myCulturalColor color
      ]
    ]
  ]

  set myHorizontal-int ( myHorizontal-int + myHorizontal-int / 10 )                 ;;; link together the sites that are close (in the radius that i calculate by adding myHorizonta-int with one tenth of it)
  ask sites [ create-links-with other sites in-radius (myHorizontal-int)  ]

  let emptySites count sites with [myShape = "star"]                                ;;; shows in the monitor in the interface the number of empty sites at the begining of the simulation
  set numberOfEmptySites emptySites

  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; Setup of the LATTICE model (here each agent has 8 neighbors)

to lattice8

  clear-all                                                                   ;;; clear the previous settings
  ask patches [set pcolor white]                                              ;;; set the color of the world to white
  setMyValues                                                                 ;;; initialization of the costants

  let myx round (sqrt number-of-sites)                                        ;;; define myx as the approximate value of the square root of the number of sites (900)
  set number-of-sites (myx * myx)                                             ;;; reset the number of sites as the approximate value in order to feet it in the grid

  let myHorizontal-int (world-width / myx)                                    ;;; set two integer variables one for the horizontal and one for the vertical dimensions of the grid
  let myVertical-int (world-height / myx)


  let myHorizontal-vals ( range ( min-pxcor + myHorizontal-int / 10 ) max-pxcor myHorizontal-int )   ;;; Get a range of horizontal and vertical coordinates, starting at half
  let myVertical-vals ( range ( min-pycor + myVertical-int / 10 ) max-pycor myVertical-int )


  let myPossibleCoordinates []                                                      ;;; Create an empty list to hold the possible coordinates

  foreach myVertical-vals [                                                         ;;; For each possible vertical value, map all horizontal values in order and
    v ->                                                                            ;;; combine these into an ordered list starting at the lowest px and py coords
    set myPossibleCoordinates ( sentence myPossibleCoordinates map [ i -> (list i v) ] myHorizontal-vals )
  ]


  let use-coords sublist myPossibleCoordinates 0 number-of-sites                    ;;; Use the number-of-sites to sublist the possible coordinates, and create a site at each of the coordinate combinations left
  foreach use-coords [
    coords ->
    create-sites 1 [
      setxy item 0 coords item 1 coords
    set myStatus free                           ;;; set the free sites with shape "star" and with the color "green"
    set shape "star"
    set myShape shape
    set color green
    set myCulturalColor color

    if random 100 < (1 - empty-prob) * 100 [    ;;; at this point we decide the number of the occupied sites based on the global variable "empty-prob", shown in the interface as a slider
      set myStatus occupied                     ;;; based on this probability we create the occupied sites and set the myStatus attributes of the sites
      set shape "circle"                        ;;; we change the shape of the sites to "circle"
      set myShape shape                         ;;; and the color to a random color instead to a green color
    set myCulturalCode  n-values cultural-code [random cultural-traits]
    set myCulturalTrait cultural-traits
    set myTolerance tolerance
    set color myColor                           ;;; set the color of the site calling the reporter myColor
    set myCulturalColor color
      ]
    ]
  ]

  set myHorizontal-int ( myHorizontal-int + myHorizontal-int / 2 )                 ;;; link together the sites that are close (in the radius that i calculate by adding myHorizonta-int with one tenth of it)
  ask sites [ create-links-with other sites in-radius (myHorizontal-int)  ]

  let emptySites count sites with [myShape = "star"]                                ;;; shows in the monitor in the interface the number of empty sites at the begining of the simulation
  set numberOfEmptySites emptySites

  reset-ticks
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; PART C : EXECUTION of the simulations

;;; go procedure

to go

  reset-timer                                                                      ;;; reset the timer
  if haltCondition = false [

    ask sites [                                                                    ;;; here we use a subrutine to compute the number of clusters based in the color of sites
      let x color                                                                  ;;; this is helpful in the cases where the the color of different clusters is the same
      let myNewRule true
      foreach myListOfClusters [ c -> if ( color = c ) [ set myNewRule false ] ]
      if(myNewRule = true) [ set myListOfClusters lput color myListOfClusters set myNumberOfClusters ( myNumberOfClusters + 1 ) ]

    ]
    stop ]                                                                         ;;; setting the variables that monitors the simulation
  set haltCondition false
  set moveOnTick 0
  set imitateOnTick 0

  ask sites [

    if myStatus = occupied [                                                       ;;; if the site i am considering is occupied and has neighbors that are occupied proceed
      ifelse (count link-neighbors with [myStatus = occupied] > 0)
      [
        let oneOfMyNeighbors one-of link-neighbors with [myStatus = occupied]      ;;; take one of the occupied neighbor sites
        let neighborsCulturalCode []
        ask oneOfMyNeighbors [set neighborsCulturalCode myCulturalCode]
        ifelse (random-float 1 < culturalOverlap myCulturalCode neighborsCulturalCode)   ;;; evaluate the culturalOverlap between me and my neighbor and if this is bigger that a random number
        [
          let listaN []
          let numberM 0
          set listaN (map [[?1 ?2] -> ?1 = ?2] myCulturalCode neighborsCulturalCode)     ;;; computes the number of similar elements in our F vectors (culturl code)
          set numberM length filter [? -> ? = true] listaN
          if (numberM < length myCulturalCode) [let tempList doCulturalImitation myCulturalCode neighborsCulturalCode  ;;; if the this number is less than the length of the vector F, do imitation
          set myCulturalCode tempList]


        ]
        [if averageCulturalOverlap self < myTolerance [makeMyMove self]]            ;;; if the average cultural overlap between me and my neighbors is less than myTolerance i move

      ]
      [makeMyMove self]

    ]
  ]

  ask sites [  if myStatus = occupied [ set color myColor set myCulturalColor color] ]    ;;; set the color of the sites calling myColor
  set mytimer (mytimer + timer)                                                           ;;; set the timer

  tick
end



;;; report ::: averageCulturalOverlap

to-report averageCulturalOverlap [myOwnSite]                ;;; a report procedure that computes the average cultural overlap between a site and its neighbors
  let myPartialValue 0
  let myCounter 0
  ask myOwnSite [
    let myCulturalCodeList myCulturalCode
    ask link-neighbors with [myStatus = occupied] [set myPartialValue ( myPartialValue + ( culturalOverlap myCulturalCodeList myCulturalCode ) ) ]
    set myCounter  count link-neighbors with [myStatus = occupied]

  ]
  report (myPartialValue / myCounter)                       ;;; the result is the sum of the cultural overlap between me and my neighbors divided by the number of neighbors (occupied sites, free sites not counted)
end


;;; report ::: culturalOverlap

to-report culturalOverlap [myListA myListB]                 ;;; this report cumputes the cultural overlap between two sites (reports the number of similarities in the F vector)

  let resultOfDelta deltaOfKronecker myListA myListB
  let myOmega (resultOfDelta / cultural-code)
  report myOmega

end

;;; report ::: deltaOfKronecker

to-report deltaOfKronecker [myList1 myList2]                ;;; cumputes the delta between lists in this case; used to get the number of similar elements in the F vector between two sites

  let myFirstTemp []
  let mySecondTemp 0                                          ;;; the new version of the map function has to be managed carefully* <--- suggestion by Eduart
  set myFirstTemp  (map [[?1 ?2] -> ?1 = ?2] myList1 myList2) ;;; here i use the map function to map the position in the two lists
  set mySecondTemp length filter [? -> ? = true] myFirstTemp  ;;; then filter the number of "true" items in my list and then call the length fuction to get the length of the list
  report mySecondTemp                                         ;;; report the computed number

end

;;; to move procedure

to makeMyMove [mySite]                                        ;;; computes the conditions and the actual move of a occupied site towards an free site

  set haltCondition true
  let myNewSite one-of sites with [myStatus = free]           ;;; select a new free site
  ask myNewSite [                                             ;;; define temporal attributes of the new site
    let temporalCulturalCode 0
    let temporalCulturalTrait 0
    let temporalCulturalColor 0
    let temporalTolerance 0
    let temporalShape 0
    ask mySite [                                              ;;; exchnge the attributes between the occupied and the free site

        set temporalCulturalCode myCulturalCode
        set temporalCulturalTrait myCulturalTrait
        set temporalCulturalColor myCulturalColor
        set temporalShape myShape
        set temporalTolerance myTolerance
        set myCulturalCode []                                 ;;; set to 0 or [] the attributes of the ex-occupied site
        set myCulturalTrait 0
        set myStatus free
        set shape "star"
        set myShape "star"
        set color green
        set myCulturalColor color
        set myTolerance 0
      ]

      set myCulturalCode temporalCulturalCode                 ;;; exchange the attributes between temporal and real variables (attributes)
      set myCulturalTrait temporalCulturalTrait
      set myCulturalColor temporalCulturalColor
      set color myCulturalColor
      set myShape temporalShape
      set shape temporalShape
      set myStatus occupied
      set myTolerance temporalTolerance

    ]

  set numberOfMovements ( numberOfMovements + 1 )             ;;; increment the number of movements in the variable "numberOfMovements" that is shown in the monitor in the interface
  set moveOnTick  ( moveOnTick + 1)                           ;;; increment the number of moves per tick shown in the plot

end

;;; report ::: doCulturalImitation

to-report doCulturalImitation [listA listB]                   ;;; procedure that perform the cumtural imitation

  set haltCondition true
  let myRandomNumber random cultural-code                     ;;; find a random between 0 and cultural-code
  let myNewTemp item myRandomNumber ListB                     ;;; select the element given by the random number in a list
  set listA replace-item myRandomNumber ListA myNewTemp       ;;; replace that random element
  set color sum myCulturalCode                                ;;; set the colors
  set myCulturalColor color

  set numberOfImitations numberOfImitations + 1               ;;; increment the number of imitations
  set imitateOnTick (imitateOnTick + 1)                       ;;; increment the number of imitations per tick
  report listA
end

;;; procedure layout
to layout                                                     ;;; create the layout for the networks, that looks better

  layout-spring sites links 0.2 3.0 0.5

  ask sites [
    ;; stay away from the edges of the world; the closer I
    ;; get to the edge, the more I try to get away from it.
    facexy 0 0
    fd (distancexy 0 0) / 100
  ]
end

;;; report ::: myColors

to-report myColor                                             ;;; is a long function, that in a series of if conditions try to approximate the best possible the colors

  let myFinalResult 0                                         ;;; this is the result of the report

  if length myCulturalCode <= 10 [
  if length myCulturalCode = 2 [                              ;;; i control all the possible values of the vector F (here 2)
    let x1 0
    let x2 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set myResult (((x1 * 1) + (x2 * 10)) mod 140)            ;;; i moltiplicate and then sum the items in each position and then use the module 140 of this sum
    set myFinalResult myResult
      report myFinalResult
  ]
  if length myCulturalCode = 3 [                             ;;; block in case of F = 3
    let x1 0
    let x2 0
    let x3 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set myResult (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myFinalResult myResult
      report myFinalResult
  ]

    if length myCulturalCode = 4 [                           ;;; case F = 4
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let myResultX 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResult myResultX + ((y1 * 1) mod 140)
    set myFinalResult myResult
      report myFinalResult
  ]

    if length myCulturalCode = 5 [                           ;;; case F = 5
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let y2 0
    let myResultX 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set y2 item 4 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResult myResultX + (((y1 * 1) + (y2 * 10)) mod 140)
    set myFinalResult myResult
      report myFinalResult
    ]

    if length myCulturalCode = 6 [                            ;;; case F = 6
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let y2 0
    let y3 0
    let myResultX 0
    let myResultY 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set y2 item 4 myCulturalCode
    set y3 item 5 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResultY (((y1 * 1) + (y2 * 10) + (y3 * 100)) mod 140)
    set myResult myResultX + myResultY
    set myFinalResult myResult
      report myFinalResult
  ]

    if length myCulturalCode = 7 [                           ;;; case F = 7
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let y2 0
    let y3 0
    let z1 0
    let myResultX 0
    let myResultY 0
    let myResultZ 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set y2 item 4 myCulturalCode
    set y3 item 5 myCulturalCode
    set z1 item 6 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResultY (((y1 * 1) + (y2 * 10) + (y3 * 100)) mod 140)
    set myResultZ ((z1 * 1) mod 139)
    set myResult (myResultX + myResultY + myResultZ)
    set myFinalResult myResult
      report myFinalResult
  ]

  if length myCulturalCode = 8 [                                 ;;; case F = 8
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let y2 0
    let y3 0
    let z1 0
    let z2 0
    let myResultX 0
    let myResultY 0
    let myResultZ 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set y2 item 4 myCulturalCode
    set y3 item 5 myCulturalCode
    set z1 item 6 myCulturalCode
    set z2 item 7 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResultY (((y1 * 1) + (y2 * 10) + (y3 * 100)) mod 140)
    set myResultZ (((z1 * 1) + (z2 * 10)) mod 140)
    set myResult (myResultX + myResultY + myResultZ)
    set myFinalResult myResult
      report myFinalResult
  ]

  if length myCulturalCode = 9 [                                    ;;; case F = 9
    let x1 0
    let x2 0
    let x3 0
    let y1 0
    let y2 0
    let y3 0
    let z1 0
    let z2 0
    let z3 0
    let myResultX 0
    let myResultY 0
    let myResultZ 0
    let myResult 0
    set x1 item 0 myCulturalCode
    set x2 item 1 myCulturalCode
    set x3 item 2 myCulturalCode
    set y1 item 3 myCulturalCode
    set y2 item 4 myCulturalCode
    set y3 item 5 myCulturalCode
    set z1 item 6 myCulturalCode
    set z2 item 7 myCulturalCode
    set z3 item 8 myCulturalCode
    set myResultX (((x1 * 1) + (x2 * 10) + (x3 * 100)) mod 140)
    set myResultY (((y1 * 1) + (y2 * 10) + (y3 * 100)) mod 140)
    set myResultZ (((z1 * 1) + (z2 * 10) + (z3 * 100)) mod 140)
    set myResult ((myResultX + myResultY + myResultZ) mod 140)
    set myFinalResult myResult
     report myFinalResult
  ]
  ]

end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;; end of the program :: Eduart Uzeir :: June 2018 :: Project of the corse of Complex Systems and Network Sciences :: University of Bologna ;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
@#$#@#$#@
GRAPHICS-WINDOW
931
34
1552
656
-1
-1
17.5143
1
10
1
1
1
0
1
1
1
-17
17
-17
17
0
0
1
ticks
30.0

SLIDER
10
69
182
102
number-of-sites
number-of-sites
0
900
225.0
1
1
NIL
HORIZONTAL

TEXTBOX
12
46
188
73
Number of sites [ N ]
18
35.0
1

SLIDER
186
69
358
102
cultural-code
cultural-code
3
9
9.0
1
1
NIL
HORIZONTAL

TEXTBOX
191
47
341
69
Cultural Code [ F ]
18
35.0
1

SLIDER
363
69
535
102
cultural-traits
cultural-traits
0
9
6.0
1
1
NIL
HORIZONTAL

TEXTBOX
364
46
519
77
Cultural Traits [ q ]
18
35.0
1

TEXTBOX
12
10
396
54
1. SET THE PARAMETERS OF THE MODEL\n   ********************************
18
95.0
1

BUTTON
9
187
132
220
random-network
random-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
543
45
681
66
Empty sites [ e ]
18
35.0
1

SLIDER
541
69
713
102
empty-prob
empty-prob
0
1.0
0.2
0.01
1
NIL
HORIZONTAL

TEXTBOX
725
44
845
66
Tolerance [ T ]
18
35.0
1

SLIDER
721
68
893
101
tolerance
tolerance
0
1.0
0.1
0.01
1
NIL
HORIZONTAL

TEXTBOX
11
124
551
168
2. SELECT THE NETWORK MODEL AND RUN IT\n   ************************************
18
95.0
1

TEXTBOX
1153
10
1415
28
Eduart Uzeir [ID: 0000843961]
14
15.0
1

BUTTON
162
187
326
220
preferential-attachment
preferential-attachment
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
686
188
749
221
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

MONITOR
25
285
157
330
Number of  Imitations
numberOfImitations
17
1
11

MONITOR
188
285
298
330
Number of Moves
numberOfMovements
17
1
11

TEXTBOX
16
170
136
198
Random Network Model
11
35.0
1

TEXTBOX
167
169
317
187
Preferential Attachment Model
11
35.0
1

TEXTBOX
707
170
728
188
Run
11
35.0
1

TEXTBOX
240
424
308
468
====>
18
0.0
1

TEXTBOX
8
233
247
277
3. OBSERVE THE DATA\n  ******************
18
95.0
1

PLOT
26
359
778
647
Imitations vs. Moves
ticks
NIL
0.0
10.0
0.0
10.0
true
true
"" ""
PENS
"Moves" 1.0 0 -16777216 true "" "plot moveOnTick"
"Imitations" 1.0 0 -5298144 true "" "plot imitateOnTick"

MONITOR
333
287
472
332
Number of Empty Sites
numberOfEmptySites
17
1
11

BUTTON
355
187
440
220
lattice (4)
lattice4
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
356
169
458
187
Lattice (4)
11
35.0
1

TEXTBOX
607
192
656
219
--->
22
0.0
1

MONITOR
506
286
626
331
Number of Seconds
mytimer
17
1
11

BUTTON
473
187
558
220
lattice (8)
lattice8
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
477
170
627
188
Lattice (8)
11
35.0
1

MONITOR
657
286
776
331
Number of Clusters
myNumberOfClusters - 1
17
1
11

@#$#@#$#@
## WHAT IS IT?

Project of the course, Complex Systems and Network Science for the year 2017-2018
The project contain a simulation in NetLogo of a mix of Axelrod and Schelling models.
This project and the paper related to it are create by Eduart Uzeir (ID: 0000843961).
*************************************************************************************
The model implemented studies the phenomenon of CULTURE DISSEMINATION and SELF-SEGREGATION within a given population.
An important concept in the whole model is HOMOPHILY, the tendency of the individuals to interact with people that are similar to them.

## HOW IT WORKS

The agents combine the Axelrod and Schelling model to create the world and their behavior is based in such models.

## HOW TO USE IT

First setup the main parameters, then choose the network model that you prefer and run the simulation. You can observe the results in the monitors.

## THINGS TO NOTICE

You can notice the different behaviors of the agents in different settings. 

## THINGS TO TRY

The most important thing to observe is the point of equilibrium, when no movements or imitations are observed.

## EXTENDING THE MODEL

The model can be further extended by adding more agents and different models of networks.

## NETLOGO FEATURES

The most important feature of this netlogo model is the fact that is visualized as a network of nodes and not like a grid.
## RELATED MODELS

Related model can be seen in the netlogo standard library.

## CREDITS AND REFERENCES

Eduart Uzeir - Universita di Studi di Bologna (June 2018)
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
1
Rectangle -7500403 true false 60 15 75 300
Polygon -7500403 true false 90 150 270 90 90 30
Line -7500403 false 75 135 90 135
Line -7500403 false 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

redflag
false
1
Rectangle -7500403 true false 60 15 75 300
Polygon -7500403 true false 90 150 270 90 90 30
Line -7500403 false 75 135 90 135
Line -7500403 false 75 45 90 45

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.0.3
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
