Class {
	#name : 'EmbeedingsCreator',
	#superclass : 'Object',
	#instVars : [
		'apiKey',
		'embeddingModel'
	],
	#category : 'GitJira-Dataset-Creation',
	#package : 'GitJira-Dataset-Creation'
}

{ #category : 'accessing' }
EmbeedingsCreator >> apiKey [ 
	^apiKey
]

{ #category : 'accessing' }
EmbeedingsCreator >> apiKey: anObject [

	apiKey := anObject
]

{ #category : 'accessing' }
EmbeedingsCreator >> embeddingModel [
	^embeddingModel
]

{ #category : 'accessing' }
EmbeedingsCreator >> embeddingModel: anObject [
	embeddingModel := anObject 
]

{ #category : 'as yet unclassified' }
EmbeedingsCreator >> getEmbeddingsFromOpenAI: text [
	| url data client response json |

	url := 'https://api.openai.com/v1/embeddings'.

	data := Dictionary new
		at: 'model' put: embeddingModel;
		at: 'input' put: text;
		at: 'encoding_format' put: 'float';
		yourself.

	client := ZnClient new.
	client
		url: url;
		headerAt: 'Authorization' put: 'Bearer ', apiKey;
		entity: (ZnEntity text: (NeoJSONWriter toString: data));
		contentType: 'application/json'.

	response := client post.
	json := NeoJSONReader fromString: response contents.

	^ json
]
