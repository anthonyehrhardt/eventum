<cfset tracker = CreateObject("component", "issueTracker")>

<h1>Eventum Issue Tracker</h1>

<!-- Handle Form Submissions -->
<cfif IsDefined("FORM.action")>
    <cfif FORM.action EQ "Login">
        <cfif FORM.username EQ "admin" AND FORM.password EQ "password">
            <cfset Session.loggedIn = true>
            <cfset Session.username = FORM.username>
           <cfoutput> <p>Login Successful! Welcome, #Session.username#.</p></cfoutput>
        <cfelse>
            <p>Invalid Username or Password!</p>
        </cfif>
    <cfelseif FORM.action EQ "Logout">
        <cfset StructClear(Session)>
        <p>You have been logged out.</p>
    <cfelseif FORM.action EQ "Create">
        <cfif StructKeyExists(Session, "loggedIn") AND Session.loggedIn>
            <cftry>
                <cfset tracker.createIssue(
                    FORM.title,
                    FORM.description,
                    FORM.priority,
                    Session.username
                )>
                <p>Issue Created Successfully by #Session.username#!</p>
            <cfcatch>
                <p>Error: <cfoutput>#cfcatch.message#</cfoutput></p>
            </cfcatch>
            </cftry>
        <cfelse>
            <p>Error: You must be logged in to create issues!</p>
        </cfif>
    <cfelseif FORM.action EQ "Edit">
        <cfif NOT StructKeyExists(Session, "loggedIn") OR NOT Session.loggedIn>
            <p>Error: You must be logged in to edit issues!</p>
        <cfelse>
            <cfset tracker.updateIssue(FORM.edit_id, {
                title = FORM.edit_title,
                description = FORM.edit_description,
                status = FORM.edit_status,
                priority = FORM.edit_priority
            })>
            <p>Issue Updated Successfully!</p>
        </cfif>
    <cfelseif FORM.action EQ "Delete">
        <cfif NOT StructKeyExists(Session, "loggedIn") OR NOT Session.loggedIn>
            <p>Error: You must be logged in to delete issues!</p>
        <cfelse>
            <cftry>
                <cfset tracker.deleteIssue(FORM.delete_id)>
                <p>Issue Deleted Successfully!</p>
            <cfcatch>
                <p>Error: <cfoutput>#cfcatch.message#</cfoutput></p>
            </cfcatch>
            </cftry>
        </cfif>
    </cfif>
</cfif>

<!-- Show Login Form -->
<cfif NOT StructKeyExists(Session, "loggedIn") OR NOT Session.loggedIn>
    <h3>Login</h3>
    <form method="post" action="">
        <label>Username: <input type="text" name="username" required></label><br>
        <label>Password: <input type="password" name="password" required></label><br>
        <input type="submit" name="action" value="Login">
    </form>
<cfelse>
    <cfoutput><p>Welcome! You are logged in as #Session.username#.</p>
    <form method="post" action="">
        <input type="submit" name="action" value="Logout">
        </cfoutput>
    </form>
</cfif>

<!-- List Issues -->
<h3>All Issues</h3>
<table border="1">
    <tr>
        <th>ID</th>
        <th>Title</th>
        <th>Description</th>
        <th>Status</th>
        <th>Priority</th>
        <th>Created By</th>
        <th>Created At</th>
        <th>Updated At</th>
        <th>Actions</th>
    </tr>
    <cfoutput>
    <cfloop array="#tracker.listIssues()#" index="issue">
        <tr>
            <td>#issue.id#</td>
            <td>#issue.title#</td>
            <td>#issue.description#</td>
            <td>#issue.status#</td>
            <td>#issue.priority#</td>
            <td>#issue.created_by#</td>
            <td>#issue.created_at#</td>
            <td>#issue.updated_at#</td>
            <td>
                <cfif StructKeyExists(Session, "loggedIn") AND Session.loggedIn>
                    <form method="post" action="" style="display:inline-block;">
                        <input type="hidden" name="edit_id" value="#issue.id#">
                        <input type="submit" name="action" value="Edit">
                    </form>
                    <form method="post" action="" style="display:inline-block;">
                        <input type="hidden" name="delete_id" value="#issue.id#">
                        <input type="submit" name="action" value="Delete">
                    </form>
                <cfelse>
                    <p>Login to Edit/Delete</p>
                </cfif>
            </td>
        </tr>
    </cfloop></cfoutput>
</table>

<!-- Create Form -->
<h3>Create a New Issue</h3>
<form method="post" action="">
    <label>Title: <input type="text" name="title" required></label><br>
    <label>Description: <textarea name="description" required></textarea></label><br>
    <label>Priority:
        <select name="priority">
            <option value="low">Low</option>
            <option value="medium">Medium</option>
            <option value="high">High</option>
        </select>
    </label><br>
    <input type="submit" name="action" value="Create">
</form>
