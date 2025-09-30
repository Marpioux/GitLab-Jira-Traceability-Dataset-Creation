Baseline : 
```smalltalk
Metacello new
  githubUser: 'Marpioux' project: 'GitLab-Jira-Traceability-Dataset-Creation' commitish: 'master' path: 'src';
  baseline: 'GitJiraDatasetCreation';
  onConflict: [ :ex | ex useIncoming ];
  onUpgrade: [ :ex | ex useIncoming ];
  onDowngrade: [ :ex | ex useLoaded ];
  load
```
Dont forget to go load the Jira baseline of MSR to make it work

Example :
```smalltalk
glphModel := GLHModel new.

"Configuration de l'API GitLab"
glphApi := GitlabApi new
    privateToken: '<YOUR_GITLAB_TOKEN>';
    hostUrl: 'https://gitlab.example.com/api/v4';
    yourself.

glhImporter := GitlabModelImporter new
    repoApi: glphApi;
    glhModel: glphModel;
    withFiles: false;
    withCommitsSince: 0 day;
    withCommitDiffs: true.

"Configuration de l'API Jira"
jpAPI := JiraPharoAPI new
    endpoint: 'your-org.atlassian.net';
    basePath: 'rest/api/latest';
    beHttps;
    user: 'user@example.com';
    apiToken: '<YOUR_JIRA_API_TOKEN>';
    yourself.

"Setup du Jira Importer"
jpImporter := JiraPharoImporter new
    model: glphModel;
    api: jpAPI;
    yourself.

"Création du dataset"
dataset := GJDatasetCreator new
    gitlabImporter: glhImporter;
    releaseOrBranchName: 'vX.Y.Z';
    jiraImporter: jpImporter;
    fromProjectID: 1234;
    outputPath: 'C:/path/to/output/Dataset'.
    
dataset creationTraceabilityMatrix.

"Création des embeddings"
embedder := EmbeedingsCreator new
    apiKey: '<YOUR_OPENAI_API_KEY>';
    embeddingModel: 'text-embedding-3-small'.

embedder getEmbeddingsFromOpenAI: 'Ceci est un texte d''exemple'.

```
