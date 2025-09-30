Class {
	#name : 'BaselineOfGitJiraDatasetCreation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGitJiraDatasetCreation',
	#package : 'BaselineOfGitJiraDatasetCreation'
}

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> baseline: spec [
   <baseline>
   spec for: #common do: [ 
   	self defineDependencies: spec.
   	self definePackages: spec.
   	self defineGroups: spec ]
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> defineDependencies: spec [
"donne les ref vers le projet qui se trouve sur un depot distance (je crois)"
	spec baseline: 'GitLabHealth' with: [ spec repository: 'github://moosetechnology/GitProjectHealth:main/src' ].
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> defineGroups: spec [
  "optional if you want to create specifc configuration of your baseline"
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> definePackages: spec [

   spec
   	package: 'GitJira-Dataset-Creation' with: [ spec requires: #( 'GitLabHealth' ) ].
]
