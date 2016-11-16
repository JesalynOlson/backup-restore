using System.Configuration;
using System.IO;

namespace BackupRestore
{
    class Program
    {
        static void Main(string[] args)
        {
            string fileLocation = ConfigurationManager.AppSettings["BackupFileSource"];
            string copyToLocation = ConfigurationManager.AppSettings["BackupFileDestination"];
            string databaseName = args[0];

            BackupRestore.MoveBackupFile(copyToLocation, fileLocation);

            BackupRestore.RestoreBackup(databaseName, copyToLocation);

            BackupRestore.MoveBackupFile(copyToLocation, null, true);
        }
    }
}
