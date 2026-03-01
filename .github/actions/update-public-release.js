const core = require('@actions/core');
const github = require('@actions/github');

const repo_name = process.env['repo_name'];
const repo_owner = process.env['repo_owner'];
const changelog = process.env['changelog'];
const github_token = process.env['github_token']; // Add GitHub token for API authentication
const version = process.env['version'];

// Check if the required environment variables are set
if (!repo_name || !github_token || !changelog) {
    core.setFailed('Required environment variables are not set: repo_name, github_token, changelog');
    process.exit(1);
}

// Check if the secret is empty
if (repo_name === '') {
    core.setFailed('The secret is empty.');
    process.exit(1);
}

// Check if the GitHub token is empty or invalid
if (!github_token || github_token.trim() === '') {
    core.setFailed('The GitHub token is missing or invalid.');
    process.exit(1);
}

(async () => {
    try {
        // Initialize GitHub client
        const octokit = github.getOctokit(github_token.trim(), { userAgent: 'red40_pubrelease v1.0.0' });


        // Prepare the new README content
        const newReadmeContent = `# ${repo_name}\n\nLatest version: ${version}`;

        // Get the default branch reference
        const { data: repo } = await octokit.rest.repos.get({
            owner: repo_owner,
            repo: repo_name,
        });
        const defaultBranch = repo.default_branch;

        // Get the current README file's SHA
        const { data: readme } = await octokit.rest.repos.getContent({
            owner: repo_owner,
            repo: repo_name,
            path: 'README.md',
        });

        // Create or update the README file
        await octokit.rest.repos.createOrUpdateFileContents({
            owner: repo_owner,
            repo: repo_name,
            path: 'README.md',
            message: `chore: Release version: ${version}`,
            content: Buffer.from(newReadmeContent).toString('base64'),
            sha: readme.sha, // Use the current file's SHA for updates
            branch: defaultBranch,
        });

        // Create a new release
        await octokit.rest.repos.createRelease({
            owner: repo_owner,
            repo: repo_name,
            tag_name: version,
            name: `${version}`,
            body: changelog,
            draft: false,
            prerelease: false,
        });

        core.info(`README updated successfully with version ${version}`);
    } catch (error) {
        core.setFailed(`An error occurred: ${error.message}`);
        console.error(error); // Log the full error for debugging
    }
})();