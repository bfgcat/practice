$env:branch = Get-Content result.txt

echo env:branch:$env:branch

$branch = Get-Content result.txt

echo branch:$branch

$branch.Trim()

echo branchT:$branch
