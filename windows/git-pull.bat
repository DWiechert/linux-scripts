@echo off

rem This batch file does a "git pull" in all sub-directories of a specified directory
rem Usage: GitPull.bat <parent directory of Git projects>

pushd %1
for /D %%i in (*) do (
	cd %%i
	echo "%%i"
	git pull
	cd ..
)
popd
