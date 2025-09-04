Class {
	#name : 'BaselineOfGitJiraDatasetCreation',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfGitJiraDatasetCreation',
	#package : 'BaselineOfGitJiraDatasetCreation'
}

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> baseline: spec [
"donne l'ensmebe des package requis pour la baseline (à inclure dans l'archive définis par Iceberg)"
   <baseline>
   spec for: #common do: [ 
   	self defineDependencies: spec.
   	self definePackages: spec.
   	self defineGroups: spec ]
   
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> defineDependencies: spec [
"donne les ref vers le projet qui se trouve sur un depot distance (je crois)"
   spec
   	baseline: '<DEPENDENCY_PROJECT_NAME>'
   	with: [ spec repository: '<URL:GIT_PROJET_DEP>' ]
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> defineGroups: spec [
  "optional if you want to create specifc configuration of your baseline"
]

{ #category : 'baselines' }
BaselineOfGitJiraDatasetCreation >> definePackages: spec [
   "mentionne l'ensemble des packages requis (ici 4 packages )"
   spec
   	package: '<YOUR_MAIN_PACKAGE>' with: [ spec requires: #( '<DEPENDENCY_PROJECT_NAME>' ) ]; "le même que dans defineDependencies"
   	package: '<PACKAGE2>';
   	package: '<PACKAGE_N>'
   	with: [ spec requires: #( '<main_package_name>' ) ]
]
