namespace Play.Catalog.Service
{
    /// <summary>
    /// Mapped policies - ensure to configure these on Startup.cs
    /// </summary>
    public static class Policies
    {
        public const string Read = "read_access";
        public const string Write = "write_access";
    }
}