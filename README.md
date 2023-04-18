# Ludoscope Mini

This repo contains the work of my Master Thesis where I implemented a PCG grammar-based tool called Ludoscope Mini.
The project is developped in [Rascal](https://github.com/usethesource/rascal) and uses [Salix](https://github.com/usethesource/salix/tree/master/src/salix) for the visualisation.

## Demo
See my presentation on this project that also contains a live demo: [Presentation w/ Live Demo](https://docs.google.com/presentation/d/1387RVi-5UTOrVJuMibAJQ46U77o3A0rIzPalEXBfpY8/edit?usp=share_link)

## How to run
Download and install Eclipse 2021-06 following the instructions in the Rascal page [see here](https://www.rascal-mpl.org/start/).
After having set up eclipse import the project.
The Language support can be booted up with:
```
import main;
main();
```
Ludoscope Mini supports file with the extension _.lm_. To run a specific file from the Eclipse terminal:
```
runProjectFromLoc(|project://LM/src/tests/test0.lm|);
``` 
 
To boot up the visual interface simply run:
```
import visual::IDE::IDE;
ldWebApp();
```
###### _Note:_ Salix is still under development therefore certain features might not work as expected. CodeMirror which is visualising code in the web app doesnt work properly as of now so all the .lm files can only be edited through Eclipse (with nice highlighting!) or a text editor.
