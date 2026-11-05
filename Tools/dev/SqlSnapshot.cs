using System;
using System.IO;
using System.Text.RegularExpressions;

// Extract only schema from the canonical mysqldump; never import its accounts/data.
internal static class SqlSnapshot
{
    internal static string Read(string repositoryRoot)
    {
        return File.ReadAllText(Path.Combine(repositoryRoot, "Database/mth_clean.sql"));
    }

    internal static string Table(string snapshot, string name, bool ifMissing = false)
    {
        var match = Regex.Match(snapshot, "^CREATE TABLE `" + Regex.Escape(name)
            + "`\\s*\\([\\s\\S]*?^\\) ENGINE=[^\\r\\n]*;\\r?$",
            RegexOptions.Multiline | RegexOptions.IgnoreCase);
        if (!match.Success) throw new InvalidOperationException("Snapshot table not found: " + name);
        return ifMissing ? match.Value.Replace("CREATE TABLE ", "CREATE TABLE IF NOT EXISTS ") : match.Value;
    }

    internal static string Column(string snapshot, string table, string name)
    {
        var match = Regex.Match(Table(snapshot, table), "^\\s*`" + Regex.Escape(name) + "`[^\\r\\n]*", RegexOptions.Multiline);
        if (!match.Success) throw new InvalidOperationException("Snapshot column not found: " + table + "." + name);
        return match.Value.Trim().TrimEnd(',');
    }

    internal static string Procedure(string snapshot, string name)
    {
        var match = Regex.Match(snapshot, "^CREATE(?: DEFINER=[^\\r\\n]*?)? PROCEDURE `" + Regex.Escape(name)
            + "`[\\s\\S]*?^END\\s*;;\\s*$", RegexOptions.Multiline | RegexOptions.IgnoreCase);
        if (!match.Success) throw new InvalidOperationException("Snapshot procedure not found: " + name);
        string statement = match.Value.Trim();
        statement = statement.Substring(0, statement.Length - 2).TrimEnd();
        return Regex.Replace(statement, "^CREATE DEFINER=[^\\r\\n]*? PROCEDURE", "CREATE PROCEDURE", RegexOptions.IgnoreCase);
    }
}
