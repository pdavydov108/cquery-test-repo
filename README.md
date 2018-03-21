### Test repo to show cquery error
## Compile

```shell
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug -DCMAKE_EXPORT_COMPILE_COMMANDS=1 ../
make
cp compile_commands.json ../
cd ../
$EDITOR main.cpp
```
