using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Linq;

namespace BackupRestore
{
    public class BackupRestore
    {
        public static void MoveBackupFile(string copyToLocation, string fileLocation = null, bool isDelete = false)
        {
            try
            {
                if (isDelete == false)
                {
                    var backupFileDirectory = new DirectoryInfo(fileLocation);
                    var backupFileName = backupFileDirectory.GetFiles("*.bak")
                                 .OrderByDescending(f => f.LastWriteTime)
                                 .First();

                    var fullBackupFileName = backupFileDirectory + "\\" + backupFileName;
                    
                    File.Copy(fullBackupFileName, copyToLocation, true);
                }
                else
                {
                    File.Delete(copyToLocation);
                }
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }

        public static void RestoreBackup(string databaseName, string fileToRestoreFrom)
        {
            var connectionString = ConfigurationManager.ConnectionStrings["SetupDB"].ConnectionString;
            var myConnection = new SqlConnection(connectionString);

            try
            {
                using (myConnection)
                {
                    using (SqlCommand cmd = new SqlCommand("dbo.RestoreBackup", myConnection))
                    {
                        cmd.CommandType = CommandType.StoredProcedure;

                        cmd.Parameters.Add("@DatabaseName", SqlDbType.VarChar).Value = databaseName;
                        cmd.Parameters.Add("@FileLocationToRestoreFrom", SqlDbType.VarChar).Value = fileToRestoreFrom;

                        myConnection.Open();
                        cmd.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Logger.Error(ex);
            }
        }
    }
}
