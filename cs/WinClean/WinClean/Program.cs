using Microsoft.Win32;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.RegularExpressions;

namespace WinClean {
    class Program {
        private static readonly Regex RX = new Regex("\\.ms[p]$", RegexOptions.Compiled | RegexOptions.IgnoreCase);

        private static HashSet<string> NameInstalledPatches() {
            //Must do this to read the right registry values for a 64-bit machine. The 32-bit view is default.
            RegistryKey regBase = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, RegistryView.Registry64);
            RegistryKey patchKey = regBase.OpenSubKey(@"SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Patches", false);

            HashSet<string> patchSet = new HashSet<string>();
            foreach(string subKeyName in patchKey.GetSubKeyNames()) {
                RegistryKey subKey = patchKey.OpenSubKey(subKeyName);
                object localPackage = subKey.GetValue("LocalPackage");
                if (localPackage is string path) {
                    if (RX.IsMatch(path)) {
                        patchSet.Add(path.ToUpperInvariant());
                    }
                }
            }
            return patchSet;
        }

        private static HashSet<string> NamePatchFiles() {
            HashSet<string> fileSet = new HashSet<string>();
            foreach (string file in Directory.EnumerateFiles("c:/windows/installer")) {
                if (RX.IsMatch(file)) {
                    fileSet.Add(file.ToUpperInvariant());
                }
            }
            return fileSet;
        }

        static void Main(string[] args) {
            HashSet<string> installedPatches = NameInstalledPatches();
            HashSet<string> fileSet = NamePatchFiles();

            double totalBytes = 0;
            int discrepencyCount = 0;
            foreach (string fileName in fileSet) {
                if (!installedPatches.Contains(fileName)) {
                    FileInfo fi = new FileInfo(fileName);
                    totalBytes += fi.Length;
                    discrepencyCount++;

                    //Console.WriteLine("unacounted for patch file: {0}; size is {1} bytes", fileName, fi.Length);
                }
            }
            double kiloBytes = totalBytes / 1024;
            double megaBytes = kiloBytes / 1024;
            double gigaBytes = megaBytes / 1024;
            Console.WriteLine("Total size is {0:F2}GB or {1:F2}KB spread over {2} files.", gigaBytes, megaBytes, discrepencyCount);
            Console.WriteLine();

            Console.Write("Move 50 files (Y/N)? ");
            string ans = Console.ReadLine();
            if (ans == "Y" || ans == "y") {
                Regex rx = new Regex("[/\\\\]([^/\\\\]+)$");

                int cnt = 50;
                foreach (string filePath in fileSet) {
                    Match m = rx.Match(filePath);
                    string fileName = m.Groups[1].Value;

                    string destName = "C:/backup/installer/" + fileName;

                    Directory.Move(filePath, destName);
                    Console.WriteLine("Moved {0} to {1}", filePath, destName);

                    if (--cnt == 0) {
                        break;
                    }
                }

                //Console.ReadLine();
            }
        }
    }
}

// C:\Windows\Installer\66c55b.msp
//Computer\HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Patches\C8F73E60EC895C64BB4DB43EE7722CCD