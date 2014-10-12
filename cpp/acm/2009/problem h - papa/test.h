// test.h: Simple but effective automated test scaffolding

#ifndef TEST_H
#define TEST_H

#include <iostream>

// Test Scaffolding
namespace {
   size_t nPass = 0;
   size_t nFail = 0;
   void do_test(const char* condText, bool cond, const char* fileName, long lineNumber) {
      if (!cond) {
         std::cout << "FAILURE: " << condText << " in file " << fileName
                   << " on line " << lineNumber << std::endl;
         ++nFail;
      } else
         ++nPass;
   }
   void do_fail(const char* text, const char* fileName, long lineNumber) {
      std::cout << "FAILURE: " << text << " in file " << fileName
                << " on line " << lineNumber << std::endl;
      ++nFail;
   }
   void succeed_() {
      ++nPass;
   }
   void do_report() {
      std::cout << "\nTest Report:\n\n";
      std::cout << "\tNumber of Passes = " << nPass << std::endl;
      std::cout << "\tNumber of Failures = " << nFail << std::endl;
   }
}
#define test_(cond) do_test(#cond, cond, __FILE__, __LINE__)
#define fail_(text) do_fail(text, __FILE__, __LINE__)

#endif
