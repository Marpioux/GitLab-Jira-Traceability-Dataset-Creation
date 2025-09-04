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
	| project tags releases commits links |
	project := gitlabImporter importProject: fromProjectID.
	tags := gitlabImporter importTagsForProject: project.
	tags := tags select: [:tag | tag isReleaseTag].
	releases := self selectIdAndNext: tags.
	commits := gitlabImporter importCommitsOfProject: project since: releases second created_at until: releases first created_at.
	commits do: [ :commit | gitlabImporter importDiffOfCommit: commit ].
	links := self jiraLinks: commits.
	self writeLocalMatrix: links withName: 'firstMatrixe.txt'.
	^links
	
		
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
	| index target |
	target := tags detect: [ :tag | tag name = releaseOrBranchName ] ifNone: [ nil ].
	target ifNotNil: [
		index := tags indexOf: target.
		(index < tags size)
			ifTrue: [ ^{target.  tags at: index + 1}. ]
        ifFalse: [ self error: 'First release can t be selected to create a dataset'.].
] ifNil: [
    self error: 'Release not valid'
].
]

{ #category : 'writing' }
GJDatasetCreator >> writeLocalMatrix: links withName: name [
	| filePath |

	outputPath asFileReference ensureCreateDirectory.
	filePath := (outputPath, '/', name) asFileReference.
	filePath writeStreamDo: [ :file |
		links associationsDo: [ :link |
			| commit jira line |
			commit := link key.
    		jira := link value.
			line := commit, '=>', jira id.
			file nextPutAll: line; cr. 
			]
].
	
]
