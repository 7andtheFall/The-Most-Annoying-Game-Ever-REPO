STEPS TO USE GLOW ON ITEM:

1. Drag all glow items into res folder.

2. Double click glow_outline.tres and select shader and use glow_outline.gdshader

2. Right click on imported model, click New Inherited Scene, in that scene go to the mesh(es) and make them unique by pressing the arrow then making unique at the bottom of list.

3. Right click main node and click clear inheritance.

3. Right click main node of model, change type, then click staticbody3d.

4. Put a material on the object and put it on layer two on the mesh node, on main node make layer and mask 2.

5. Right click the main node, add child node, add collision shape3d, boxshape3d in inspector menu on the right for shape.

6. Create new script in the mesh child and paste in glow_script code inside and replace name with the meshbody child of the object.
