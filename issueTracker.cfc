<cfcomponent displayName="IssueTracker" output="false">

    <!-- List all issues -->
    <cffunction name="listIssues" access="public" returnType="array">
        <cfset var issues = []>
        <cfif FileExists("issues.csv")>
            <cfset var rows = ListToArray(FileRead("issues.csv"), Chr(10))>
            <cfset var headers = ListToArray(rows[1], ",")>

            <cfloop from="2" to="#ArrayLen(rows)#" index="i">
                <cfset var values = ListToArray(rows[i], ",")>
                <cfset var issue = StructNew()>
                <cfloop from="1" to="#ArrayLen(headers)#" index="j">
                    <cfset issue[headers[j]] = values[j]>
                </cfloop>
                <cfset ArrayAppend(issues, issue)>
            </cfloop>
        </cfif>
        <cfreturn issues>
    </cffunction>

    <!-- Create a new issue -->
    <cffunction name="createIssue" access="public" returnType="struct">
        <cfargument name="title" type="string" required="true">
        <cfargument name="description" type="string" required="true">
        <cfargument name="priority" type="string" required="true">
        <cfargument name="created_by" type="string" required="true">

        <cfset var issues = listIssues()>
        <cfset var newId = ArrayLen(issues) + 1>
        <cfset var createdAt = DateFormat(Now(), "yyyy-mm-dd") & " " & TimeFormat(Now(), "HH:mm:ss")>

        <cfset var newIssue = {
            id = newId,
            title = arguments.title,
            description = arguments.description,
            status = "open",
            priority = arguments.priority,
            created_by = arguments.created_by,
            created_at = createdAt,
            updated_at = createdAt
        }>

        <cfset ArrayAppend(issues, newIssue)>
        <cfset writeCSV(issues)>
        <cfreturn newIssue>
    </cffunction>

    <!-- Update an issue -->
    <cffunction name="updateIssue" access="public" returnType="struct">
        <cfargument name="id" type="numeric" required="true">
        <cfargument name="updates" type="struct" required="true">

        <cfset var issues = listIssues()>
        <cfset var issueFound = false>
        <cfset var updatedIssue = {}>

        <cfloop array="#issues#" index="issue">
            <cfif issue.id EQ arguments.id>
                <cfset issueFound = true>
                <cfset StructAppend(issue, arguments.updates)>
                <cfset issue.updated_at = DateFormat(Now(), "yyyy-mm-dd") & " " & TimeFormat(Now(), "HH:mm:ss")>
                <cfset updatedIssue = issue>
                <cfbreak>
            </cfif>
        </cfloop>

        <cfif NOT issueFound>
            <cfthrow message="Issue not found!" errorCode="404">
        </cfif>

        <cfset writeCSV(issues)>
        <cfreturn updatedIssue>
    </cffunction>

    <!-- Delete an issue -->
    <cffunction name="deleteIssue" access="public" returnType="boolean">
        <cfargument name="id" type="numeric" required="true">

        <cfset var issues = listIssues()>
        <cfset var issueFound = false>
        <cfset var updatedIssues = []>

        <!-- Filter out the issue to delete -->
        <cfloop array="#issues#" index="issue">
            <cfif issue.id EQ arguments.id>
                <cfset issueFound = true>
            <cfelse>
                <cfset ArrayAppend(updatedIssues, issue)>
            </cfif>
        </cfloop>

        <cfif NOT issueFound>
            <cfthrow message="Issue not found!" errorCode="404">
        </cfif>

        <!-- Rewrite the CSV file -->
        <cfset writeCSV(updatedIssues)>
        <cfreturn true>
    </cffunction>

    <!-- Write issues to CSV -->
    <cffunction name="writeCSV" access="private" returnType="void">
        <cfargument name="issues" type="array" required="true">
        <cfset var csvContent = "id,title,description,status,priority,created_by,created_at,updated_at#Chr(10)#">
        <cfloop array="#arguments.issues#" index="issue">
            <cfset csvContent &= "#issue.id#, #issue.title#, #issue.description#, #issue.status#, #issue.priority#, #issue.created_by#, #issue.created_at#, #issue.updated_at##Chr(10)#">
        </cfloop>
        <cfset FileWrite("issues.csv", csvContent)>
    </cffunction>
    
</cfcomponent>
