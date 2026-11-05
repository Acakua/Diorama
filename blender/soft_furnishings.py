# Builds the soft furnishings for Linh's house and exports them as one GLB.
# Run:  blender -b --factory-startup -P soft_furnishings.py -- out.glb
# Coordinates in this file are the house's own units (the page scales the house by 1.3),
# written as three.js (x, y-up, z-forward) and converted to Blender with B().
import bpy, bmesh, math, random, sys
from mathutils import Vector

out = sys.argv[sys.argv.index('--') + 1]
random.seed(11)
bpy.ops.wm.read_factory_settings(use_empty=True)
scene = bpy.context.scene
scene.frame_start, scene.frame_end = 1, 90
FLO = .3

def B(x, y, z):
    return Vector((x, -z, y))

def material(name, rgb):
    m = bpy.data.materials.new(name)
    try:
        m.use_nodes = True
    except Exception:
        pass
    try:
        m.node_tree.nodes['Principled BSDF'].inputs['Base Color'].default_value = (*rgb, 1)
    except Exception:
        m.diffuse_color = (*rgb, 1)
    return m

MAT = {n: material(n, c) for n, c in [('Quilt', (.6, .3, .25)), ('Pillow', (.9, .88, .82)), ('Blanket', (.55, .45, .35)), ('Runner', (.85, .8, .7)),
                                      ('Upholstery', (.45, .15, .12)), ('Wood', (.4, .25, .15)), ('Curtain', (.75, .7, .55)), ('Cushion', (.5, .35, .5))]}

def link(name, me, mat=None):
    for p in me.polygons:
        p.use_smooth = True
    ob = bpy.data.objects.new(name, me)
    scene.collection.objects.link(ob)
    if mat:
        ob.data.materials.append(mat)
    return ob

def planar_uv(bm, sx=1.0, sy=1.0, axes=(0, 1)):
    uv = bm.loops.layers.uv.verify()
    for f in bm.faces:
        for l in f.loops:
            co = l.vert.co
            l[uv].uv = (co[axes[0]] * sx, co[axes[1]] * sy)

def grid(name, w, d, nu, nv, center, mat):
    """A flat cloth sheet in the three.js xz plane (Blender XY), w along x, d along z."""
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=nu, y_segments=nv, size=.5)
    for v in bm.verts:
        v.co.x *= w
        v.co.y *= d
    planar_uv(bm, 1 / w, 1 / d)
    for v in bm.verts:
        v.co += center
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    return link(name, me, mat)

def box(name, size3, center3, mat=None):
    """Axis-aligned box from three.js size/centre."""
    sx, sy, sz = size3
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=1.0)
    for v in bm.verts:
        v.co = Vector((v.co.x * sx, v.co.y * sz, v.co.z * sy))
    planar_uv(bm, 2, 2, (0, 2))
    for v in bm.verts:
        v.co += B(*center3)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    return link(name, me, mat)

def collider(ob, thick=.006):
    ob.modifiers.new('Collision', 'COLLISION')
    try:
        ob.collision.thickness_outer = thick
        ob.collision.cloth_friction = 8
    except Exception:
        pass

def cloth(ob, mass=.25, bend=.5):
    m = ob.modifiers.new('Cloth', 'CLOTH')
    s = m.settings
    s.quality = 10
    s.mass = mass
    for k, v in [('tension_stiffness', 14), ('compression_stiffness', 14), ('shear_stiffness', 6), ('bending_stiffness', bend), ('air_damping', 1.5)]:
        try:
            setattr(s, k, v)
        except Exception:
            pass
    try:
        m.collision_settings.distance_min = .005
        m.collision_settings.use_self_collision = False
        m.collision_settings.collision_quality = 4
    except Exception:
        pass
    try:
        m.point_cache.frame_end = 90
    except Exception:
        pass
    return m

def freeze(ob, name, mods=()):
    """Evaluate modifiers/simulation into a plain mesh object called name."""
    for kind, opts in mods:
        m = ob.modifiers.new(kind, kind)
        for k, v in opts.items():
            setattr(m, k, v)
    dg = bpy.context.evaluated_depsgraph_get()
    me = bpy.data.meshes.new_from_object(ob.evaluated_get(dg))
    res = link(name, me)
    for s in ob.data.materials:
        pass
    if ob.data.materials and not res.data.materials:
        res.data.materials.append(ob.data.materials[0])
    return res

def soft_box(name, size3, center3, mat, puff=.35, rot=(0, 0, 0), wrinkle=.004, cuts=10):
    """A cushion/pillow: a subdivided box whose thickness thins towards the seams."""
    sx, sy, sz = size3
    bm = bmesh.new()
    bmesh.ops.create_cube(bm, size=2.0)
    bmesh.ops.subdivide_edges(bm, edges=bm.edges[:], cuts=cuts, use_grid_fill=True)
    for v in bm.verts:
        x, y, z = v.co  # Blender: x, y (= -three z), z (= three y)
        t = math.sqrt(max(0, 1 - x * x)) * math.sqrt(max(0, 1 - y * y))
        z *= (1 - puff) + puff * t
        n = math.sin(x * 9 + y * 5) * math.sin(y * 7 - x * 3)
        v.co = Vector((x * sx / 2, y * sz / 2, z * sy / 2 + n * wrinkle))
    planar_uv(bm, 1 / sx, 1 / sz)
    me = bpy.data.meshes.new(name + '_src')
    bm.to_mesh(me)
    bm.free()
    ob = link(name + '_src', me, mat)
    ob.rotation_euler = (rot[0], -rot[2], rot[1])
    ob.location = B(*center3)
    res = freeze(ob, name, [('SUBSURF', {'levels': 1, 'render_levels': 1})])
    res.location, res.rotation_euler = ob.location.copy(), ob.rotation_euler.copy()
    ob.hide_set(True)
    return res

keep = []

# ---------------- the bed and the table: colliders, pillows, then three cloths simulated together ----------------
# each cloth only collides with its own collection: the day quilt and the runner with the bare furniture,
# the night quilt with the bed, the pillow and Linh's sleeping body
bed_x0, bed_x1, bed_z0, bed_z1, mat_top = -2.47, -1.33, .64, 1.36, .62
bedcol = box('bedcol', (bed_x1 - bed_x0, mat_top - FLO, bed_z1 - bed_z0), ((bed_x0 + bed_x1) / 2, (mat_top + FLO) / 2, (bed_z0 + bed_z1) / 2))
collider(bedcol, .008)
tbl_x0, tbl_x1, tbl_z0, tbl_z1, tbl_top = -1.25, .15, .075, .825, FLO + .455
tabcol = box('tabcol', (tbl_x1 - tbl_x0, .05, tbl_z1 - tbl_z0), ((tbl_x0 + tbl_x1) / 2, tbl_top - .025, (tbl_z0 + tbl_z1) / 2))
collider(tabcol, .004)
# one pillow flat under her head, a second propped against the headboard
p1 = soft_box('Pillow1', (.24, .09, .42), (-2.22, mat_top + .05, 1.0), MAT['Pillow'], .55, (0, .04, .03))
p2 = soft_box('Pillow2', (.2, .08, .4), (-2.35, mat_top + .1, 1.0), MAT['Pillow'], .5, (0, -.03, -1.07))
keep += [p1, p2]
collider(p1, .006)
# her body as she sleeps: from the pillow (x -2.15) to her feet (x -1.45), about .12 above the mattress
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=24, v_segments=12, radius=1.0)
for v in bm.verts:
    v.co = Vector((v.co.x * .40, v.co.y * .15, v.co.z * .125))
me = bpy.data.meshes.new('bodycol')
bm.to_mesh(me)
bm.free()
body = link('bodycol', me)
body.location = B(-1.77, .735, 1.0)
collider(body, .01)
# her toes point up when she lies on her back
bm = bmesh.new()
bmesh.ops.create_uvsphere(bm, u_segments=16, v_segments=10, radius=1.0)
for v in bm.verts:
    v.co = Vector((v.co.x * .085, v.co.y * .13, v.co.z * .11))
me = bpy.data.meshes.new('feetcol')
bm.to_mesh(me)
bm.free()
feet = link('feetcol', me)
feet.location = B(-1.43, .785, 1.0)
collider(feet, .01)
# a floor so nothing can fall away, and enough friction that the night quilt hanging over the foot does not slide off
floor = box('floorcol', (6, .1, 6), (0, FLO - .05, 0))
collider(floor, .005)
for o in (bedcol, body, feet, p1, floor):
    o.collision.cloth_friction = 40
day, night = bpy.data.collections.new('DayCol'), bpy.data.collections.new('NightCol')
for c in (day, night):
    scene.collection.children.link(c)
for o in (bedcol, tabcol, floor):
    day.objects.link(o)
for o in (bedcol, body, feet, p1, floor):
    night.objects.link(o)
quilt = grid('quilt_src', 0.98, 1.06, 46, 50, B(-1.86, mat_top + .14, 1.0), MAT['Quilt'])
cloth(quilt, .3, .35).collision_settings.collection = day
runner = grid('runner_src', 1.9, .42, 70, 16, B(-.55, tbl_top + .08, .45), MAT['Runner'])
cloth(runner, .15, 1.2).collision_settings.collection = day
quilt2 = grid('quilt2_src', 0.98, 1.06, 46, 50, B(-1.6, .97, 1.0), MAT['Quilt'])
m2 = cloth(quilt2, .3, .35)
m2.collision_settings.collection = night
m2.collision_settings.friction = 40

for f in range(1, 76):
    scene.frame_set(f)
print('cloth settled')

q = freeze(quilt, 'Quilt', [('SOLIDIFY', {'thickness': .012, 'offset': 0.0})])
r = freeze(runner, 'Runner', [('SOLIDIFY', {'thickness': .004, 'offset': 0.0})])
q2 = freeze(quilt2, 'QuiltSleep', [('SOLIDIFY', {'thickness': .012, 'offset': 0.0})])
keep += [q, r, q2]
for o in (quilt, runner, quilt2, bedcol, tabcol, body, feet, floor):
    o.hide_set(True)
p1.modifiers.remove(p1.modifiers['Collision'])

keep.append(soft_box('Blanket', (.22, .05, .66), (-1.55, mat_top + .045, 1.0), MAT['Blanket'], .2, (0, .02, 0), .003, 8))
# a flat cushion on Linh's dining chair and one in Mun's basket by the hearth
keep.append(soft_box('ChairCushion', (.3, .045, .3), (-.55, .3 + .27 + .02, -.24), MAT['Cushion'], .45, (0, .1, 0), .002, 8))
keep.append(soft_box('CatCushion', (.32, .06, .32), (-1.68, .3 + .07, 0), MAT['Cushion'], .5, (0, .4, 0), .002, 8))

# ---------------- the armchair (built facing +z at the origin; the page places and turns it) ----------------
def rbx(name, size3, center3, mat, width=.03, seg=3, sub=0, rot=(0, 0, 0)):
    o = box(name + '_src', size3, center3, mat)
    o.rotation_euler = (rot[0], -rot[2], rot[1])
    mods = [('BEVEL', {'width': width, 'segments': seg, 'limit_method': 'NONE'})]
    if sub:
        mods.append(('SUBSURF', {'levels': sub, 'render_levels': sub}))
    res = freeze(o, name, mods)
    res.rotation_euler = o.rotation_euler.copy()
    o.hide_set(True)
    return res

parts = [
    rbx('a_base', (.68, .17, .62), (0, .155, 0), MAT['Upholstery'], .04, 3),
    rbx('a_armL', (.13, .32, .64), (.335, .31, 0), MAT['Upholstery'], .05, 3, 1),
    rbx('a_armR', (.13, .32, .64), (-.335, .31, 0), MAT['Upholstery'], .05, 3, 1),
    rbx('a_back', (.68, .58, .14), (0, .5, -.27), MAT['Upholstery'], .05, 3, 1, (-.18, 0, 0)),
    rbx('a_seat', (.54, .09, .52), (0, .275, .03), MAT['Upholstery'], .035, 3, 1),
    rbx('a_backc', (.52, .4, .08), (0, .5, -.19), MAT['Upholstery'], .035, 3, 1, (-.2, 0, 0)),
]
for (lx, lz) in [(.29, .25), (-.29, .25), (.29, -.25), (-.29, -.25)]:
    bm = bmesh.new()
    bmesh.ops.create_cone(bm, cap_ends=True, segments=10, radius1=.03, radius2=.022, depth=.08)
    planar_uv(bm)
    me = bpy.data.meshes.new('leg')
    bm.to_mesh(me)
    bm.free()
    leg = link('a_leg', me, MAT['Wood'])
    leg.location = B(lx, .04, lz)
    parts.append(leg)
# join the chair into one object with two materials
bpy.ops.object.select_all(action='DESELECT')
for p in parts:
    p.hide_set(False)
    p.select_set(True)
bpy.context.view_layer.objects.active = parts[0]
bpy.ops.object.join()
chair = bpy.context.view_layer.objects.active
chair.name = 'Armchair'
keep.append(chair)

# ---------------- curtains: pleated panels pulled to both sides of the front windows and the bed window ----------------
def curtain(name, u0, u1, ytop, ybot, plane, axis, pleats, flare):
    nu, nv = 40, 26
    bm = bmesh.new()
    bmesh.ops.create_grid(bm, x_segments=nu, y_segments=nv, size=.5)
    for v in bm.verts:
        u, t = v.co.x + .5, .5 - v.co.y          # u across, t down from the rod
        across = u0 + (u1 - u0) * u + flare * t * (u - .5)
        y = ytop + (ybot - ytop) * t
        depth = .022 * math.sin(u * pleats * math.tau) * (1 + .5 * t) + .006 * math.sin(t * 9 + u * 4)
        x3, z3 = (across, plane + depth) if axis == 'x' else (plane + depth, across)
        v.co = B(x3, y, z3)
    uv = bm.loops.layers.uv.verify()
    for f in bm.faces:
        for l in f.loops:
            l[uv].uv = (l.vert.index % (nu + 1) / nu, l.vert.index // (nu + 1) / nv)
    me = bpy.data.meshes.new(name)
    bm.to_mesh(me)
    bm.free()
    return link(name, me, MAT['Curtain'])

cur = []
for cx in (-1.55, 1.55):
    cur.append(curtain('c1', cx - .52, cx - .26, 1.87, 1.02, 1.72, 'x', 5, .05))
    cur.append(curtain('c2', cx + .26, cx + .52, 1.87, 1.02, 1.72, 'x', 5, -.05))
cur.append(curtain('c3', .58, .84, 1.84, 1.07, -2.43, 'z', 4, .04))
cur.append(curtain('c4', 1.36, 1.62, 1.84, 1.07, -2.43, 'z', 4, -.04))
bpy.ops.object.select_all(action='DESELECT')
for c in cur:
    c.select_set(True)
bpy.context.view_layer.objects.active = cur[0]
bpy.ops.object.join()
curtains = bpy.context.view_layer.objects.active
curtains.name = 'Curtains'
keep.append(curtains)

# ---------------- export ----------------
bpy.ops.object.select_all(action='DESELECT')
for o in keep:
    o.hide_set(False)
    o.select_set(True)
    print('export', o.name, len(o.data.polygons), [m.name for m in o.data.materials])
kw = dict(filepath=out, export_format='GLB', use_selection=True, export_apply=True)
try:
    bpy.ops.export_scene.gltf(**kw, export_materials='EXPORT')
except TypeError:
    bpy.ops.export_scene.gltf(**kw)
print('wrote', out)
