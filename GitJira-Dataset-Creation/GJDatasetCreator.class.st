Class {
	#name : 'GJDatasetCreator',
	#superclass : 'Object',
	#instVars : [
		'gitlabImporter',
		'jiraImporter',
		'releaseOrBranchName',
		'fromProjectID',
		'outputPath'
	],
	#category : 'GitJira-Dataset-Creation',
	#package : 'GitJira-Dataset-Creation'
}

{ #category : 'as yet unclassified' }
GJDatasetCreator >> creationTraceabilityMatrix [
	| project tags releases commits links commits2 links2 |
	project := gitlabImporter importProject: fromProjectID.
	tags := gitlabImporter importTagsForProject: project.
	tags := tags select: [:tag | tag isReleaseTag].
	releases := self selectIdAndNext: tags.

	commits := gitlabImporter importCommitsOfProject: project since: (releases at: 'previous') created_at until: (releases at:'current') created_at.
	"commits do: [ :commit | gitlabImporter importDiffOfCommit: commit ]."
	links := self jiraLinks: commits.
	self writeAllTickets: links inFolder: 'ticket1'.
	self writeLocalMatrix: links withName: 'firstMatrix'.
	
	commits2 := gitlabImporter importCommitsOfProject: project since: (releases at:'current') created_at until: ((releases at: 'next') isDictionary
    ifTrue: [ (releases at: 'next') at: 'created_at' ]
    ifFalse: [ (releases at: 'next') created_at ]).
	commits2 do: [ :commit | gitlabImporter importDiffOfCommit: commit ].
	links2 := self jiraLinks: commits2.
	self writeAllTickets: links2 inFolder: 'ticket2'.
	self writeLocalMatrix: links2 withName: 'secondMatrix'.
	
	^'Done'
]

{ #category : 'accessing' }
GJDatasetCreator >> fromProjectID [
	^fromProjectID

	
]

{ #category : 'accessing' }
GJDatasetCreator >> fromProjectID: anObject [
	fromProjectID:=anObject 

	
]

{ #category : 'accessing' }
GJDatasetCreator >> gitlabImporter [
	^gitlabImporter
]

{ #category : 'accessing' }
GJDatasetCreator >> gitlabImporter: anObject [
	gitlabImporter := anObject 
]

{ #category : 'accessing' }
GJDatasetCreator >> jiraImporter [
	^jiraImporter
]

{ #category : 'accessing' }
GJDatasetCreator >> jiraImporter: anObject [
	jiraImporter:= anObject
]

{ #category : 'as yet unclassified' }
GJDatasetCreator >> jiraLinks: commits [
	| issues commitsWithTickets matrix |
	issues := (((commits collect: [ :commit | commit committer_email ])
	reject: [ :user | user isNil ]) asSet)
	flatCollect: [ :user |
		jiraImporter importAllCurrentAndPastIssuesOf: user.
		].
	
	GPJCConnector new
  		gpModel: gitlabImporter glhModel;
  		jiraModel: jiraImporter model;
  		connect.
	
	commitsWithTickets :=  commits asOrderedCollection select: [ :commit | commit jiraIssue isNotNil ].
	matrix := Dictionary new.
	commitsWithTickets do: [ :commit |
    commit diffs ifNotNil: [ :diffs |
        diffs do: [ :diff |
            | newPath |
            newPath := diff new_path.
            (newPath isString and: [ newPath notNil ]) ifTrue: [matrix at: newPath put: commit jiraIssue]]]].
	^matrix
]

{ #category : 'accessing' }
GJDatasetCreator >> outputPath [
	^outputPath
]

{ #category : 'accessing' }
GJDatasetCreator >> outputPath: anObject [
	outputPath := anObject
]

{ #category : 'accessing' }
GJDatasetCreator >> releaseOrBranchName [
	^releaseOrBranchName
]

{ #category : 'accessing' }
GJDatasetCreator >> releaseOrBranchName: anObject [
	releaseOrBranchName := anObject 
]

{ #category : 'as yet unclassified' }
GJDatasetCreator >> selectIdAndNext: tags [
    | index target previousId result |
    target := tags detect: [ :tag | tag name = releaseOrBranchName ] ifNone: [ nil ].

    target ifNotNil: [
        index := tags indexOf: target.
        previousId := (index > 1)
            ifTrue: [ tags at: index - 1 ]
            ifFalse: [
                Dictionary new
                    at: 'created_at' put: DateAndTime now;
                    yourself
            ].
        (index < tags size)
            ifTrue: [
                result := {
                    'next' -> previousId.
                    'current' -> target.
                    'previous' -> (tags at: index + 1)
                } asDictionary.
            ]
            ifFalse: [
                self error: 'First release can''t be selected to create a dataset'.
            ]
    ] ifNil: [
        self error: 'Release not valid'.
    ].

    ^result
]

{ #category : 'writing' }
GJDatasetCreator >> writeAllTickets: links inFolder: folderName [
	| outputDirectory |
	outputDirectory := (outputPath,'/',folderName) asFileReference ensureCreateDirectory.
	links do: [ :link |
		| file |
		file := (outputDirectory, '/', (link key, '.txt')) asFileReference.
		file writeStreamDo: [ :stream |
			   stream
            nextPutAll: link key;
				cr;
            nextPutAll: 'Summary : ';
            nextPutAll: link summary;
            cr;
            nextPutAll: 'Description : ';
            nextPutAll: link description;
            cr.
		].
	].
	
	^'Done'
]

{ #category : 'writing' }
GJDatasetCreator >> writeLocalMatrix: links withName: name [
    | filePath matrixAsDictionary jsonString |

    matrixAsDictionary := Dictionary new.
    links associationsDo: [ :link |
        | commit jira |
        commit := link key.
        jira := link value.
        matrixAsDictionary at: commit put: jira key.
    ].
    jsonString := NeoJSONWriter toString: matrixAsDictionary.

    outputPath asFileReference ensureCreateDirectory.
    filePath := (outputPath, '/', name, '.json') asFileReference.
    filePath writeStreamDo: [ :file |
        file nextPutAll: jsonString.
    ].

]
