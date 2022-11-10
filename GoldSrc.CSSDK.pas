(*============ (C) Copyright 2020, Alexander B. All rights reserved. ============*)
(*                                                                               *)
(*  Module:                                                                      *)
(*    GoldSrc.CSSDK                                                              *)
(*                                                                               *)
(*  License:                                                                     *)
(*    You may freely use this code provided you retain this copyright message.   *)
(*                                                                               *)
(*  Description:                                                                 *)
(*    Provides relatively full SDK for Counter-Strike 1.6 Mod.                   *)
(*===============================================================================*)

unit GoldSrc.CSSDK;

{$MinEnumSize 4}

interface

uses
  System.Math.Vectors,

  GoldSrc.SDK,

  GoldSrc.BaseInterface,
  GoldSrc.VGUI;

const
  CSSDK_VERSION = 20200831;

const
  FBEAM_STARTENTITY = $00000001;
  FBEAM_ENDENTITY = $00000002;
  FBEAM_FADEIN = $00000004;
  FBEAM_FADEOUT = $00000008;
  FBEAM_SINENOISE = $00000010;
  FBEAM_SOLID = $00000020;
  FBEAM_SHADEIN = $00000040;
  FBEAM_SHADEOUT = $00000080;
  FBEAM_STARTVISIBLE = $10000000;		// Has this client actually seen this beam's start entity yet?
  FBEAM_ENDVISIBLE = $20000000;		// Has this client actually seen this beam's end entity yet?
  FBEAM_ISACTIVE = $40000000;
  FBEAM_FOREVER = $80000000;

  HISTORY_MAX = 64;  // Must be power of 2
  HISTORY_MASK = HISTORY_MAX - 1;

  STUDIO_RENDER = 1;
  STUDIO_EVENTS = 2;

  PLANE_ANYZ = 5;

  ALIAS_Z_CLIP_PLANE = 5;

  // flags in finalvert_t.flags
  ALIAS_LEFT_CLIP = $0001;
  ALIAS_TOP_CLIP = $0002;
  ALIAS_RIGHT_CLIP = $0004;
  ALIAS_BOTTOM_CLIP = $0008;
  ALIAS_Z_CLIP = $0010;
  ALIAS_ONSEAM = $0020;
  ALIAS_XY_CLIP_MASK = $000F;

  ZISCALE	= Single($8000); // TODO: Check (float)0x8000

  CACHE_SIZE = 32; // used to align key data structures

  // Max # of clients allowed in a server.
  MAX_CLIENTS = 32;

  // How many bits to use to encode an edict.
  MAX_EDICT_BITS = 11;			// # of bits needed to represent max edicts
  // Max # of edicts in a level (2048)
  MAX_EDICTS = 1 shl MAX_EDICT_BITS;

  // How many data slots to use when in multiplayer (must be power of 2)
  MULTIPLAYER_BACKUP = 64;
  // Same for single player
  SINGLEPLAYER_BACKUP = 8;

  //
  // Constants shared by the engine and dlls
  // This header file included by engine files and DLL files.
  // Most came from server.h
  // edict->flags
  FL_FLY = 1 shl 0;	// Changes the SV_Movestep() behavior to not need to be on ground
  FL_SWIM = 1 shl 1;	// Changes the SV_Movestep() behavior to not need to be on ground (but stay in water)
  FL_CONVEYOR = 1 shl 2;
  FL_CLIENT	= 1 shl 3;
  FL_INWATER = 1 shl 4;
  FL_MONSTER = 1 shl 5;
  FL_GODMODE = 1 shl 6;
  FL_NOTARGET = 1 shl 7;
  FL_SKIPLOCALHOST = 1 shl 8;	// Don't send entity to local host, it's predicting this entity itself
  FL_ONGROUND = 1 shl 9;	// At rest / on the ground
  FL_PARTIALGROUND = 1 shl 10;	// not all corners are valid
  FL_WATERJUMP = 1 shl 11;	// player jumping out of water
  FL_FROZEN = 1 shl 12; // Player is frozen for 3rd person camera
  FL_FAKECLIENT = 1 shl 13;	// JAC: fake client, simulated server side; don't send network messages to them
  FL_DUCKING = 1 shl 14;	// Player flag -- Player is fully crouched
  FL_FLOAT = 1 shl 15;	// Apply floating force to this entity when in water
  FL_GRAPHED = 1 shl 16; // worldgraph has this ent listed as something that blocks a connection

  // UNDONE: Do we need these?
  FL_IMMUNE_WATER = 1 shl 17;
  FL_IMMUNE_SLIME = 1 shl 18;
  FL_IMMUNE_LAVA = 1 shl 19;

  FL_PROXY = 1 shl 20;	// This is a spectator proxy
  FL_ALWAYSTHINK = 1 shl 21;	// Brush model flag -- call think every frame regardless of nextthink - ltime (for constantly changing velocity/path)
  FL_BASEVELOCITY = 1 shl 22;	// Base velocity has been applied this frame (used to convert base velocity into momentum)
  FL_MONSTERCLIP = 1 shl 23;	// Only collide in with monsters who have FL_MONSTERCLIP set
  FL_ONTRAIN = 1 shl 24; // Player is _controlling_ a train, so movement commands should be ignored on client during prediction.
  FL_WORLDBRUSH = 1 shl 25;	// Not moveable/removeable brush entity (really part of the world, but represented as an entity for transparency or something)
  FL_SPECTATOR = 1 shl 26; // This client is a spectator, don't run touch functions, etc.
  FL_CUSTOMENTITY = 1 shl 29;	// This is a custom entity
  FL_KILLME = 1 shl 30;	// This entity is marked for death -- This allows the engine to kill ents at the appropriate time
  FL_DORMANT = 1 shl 31;	// Entity is dormant, no updates to client

  // SV_EmitSound2 flags
  SND_EMIT2_NOPAS	= 1 shl 0;	// never to do check PAS
  SND_EMIT2_INVOKER	= 1 shl 1;	// do not send to the client invoker

  // Engine edict->spawnflags
  SF_NOTINDEATHMATCH = $0800;	// Do not spawn when deathmatch and loading entities from a file


  // Goes into globalvars_t.trace_flags
  FTRACE_SIMPLEBOX = 1 shl 0;	// Traceline with a simple box

  // walkmove modes
  WALKMOVE_NORMAL = 0; // normal walkmove
  WALKMOVE_WORLDONLY = 1; // doesn't hit ANY entities, no matter what the solid type
  WALKMOVE_CHECKONLY = 2; // move, but don't touch triggers

  // edict->movetype values
  MOVETYPE_NONE = 0;		// never moves
  //MOVETYPE_ANGLENOCLIP	1;
  //MOVETYPE_ANGLECLIP		2;
  MOVETYPE_WALK = 3;		// Player only - moving on the ground
  MOVETYPE_STEP = 4;		// gravity, special edge handling -- monsters use this
  MOVETYPE_FLY = 5;		// No gravity, but still collides with stuff
  MOVETYPE_TOSS = 6;		// gravity/collisions
  MOVETYPE_PUSH = 7;		// no clip to world, push and crush
  MOVETYPE_NOCLIP = 8;		// No gravity, no collisions, still do velocity/avelocity
  MOVETYPE_FLYMISSILE = 9;		// extra size to monsters
  MOVETYPE_BOUNCE = 10;		// Just like Toss, but reflect velocity when contacting surfaces
  MOVETYPE_BOUNCEMISSILE = 11;		// bounce w/o gravity
  MOVETYPE_FOLLOW = 12;		// track movement of aiment
  MOVETYPE_PUSHSTEP = 13;		// BSP model that needs physics/world collisions (uses nearest hull for world collision)

  // edict->solid values
  // NOTE: Some movetypes will cause collisions independent of SOLID_NOT/SOLID_TRIGGER when the entity moves
  // SOLID only effects OTHER entities colliding with this one when they move - UGH!
  SOLID_NOT	= 0;		// no interaction with other objects
  SOLID_TRIGGER	= 1;		// touch on edge, but not blocking
  SOLID_BBOX	= 2;		// touch on edge, block
  SOLID_SLIDEBOX	= 3;		// touch on edge, but not an onground
  SOLID_BSP	= 4;		// bsp clip, touch on edge, block

  // edict->deadflag values
  DEAD_NO	= 0; // alive
  DEAD_DYING = 1; // playing death animation or still falling off of a ledge waiting to hit ground
  DEAD_DEAD	= 2; // dead. lying still.
  DEAD_RESPAWNABLE = 3;
  DEAD_DISCARDBODY = 4;

  DAMAGE_NO	= 0;
  DAMAGE_YES = 1;
  DAMAGE_AIM = 2;

  // entity effects
  EF_BRIGHTFIELD = 1;	// swirling cloud of particles
  EF_MUZZLEFLASH = 2;	// single frame ELIGHT on entity attachment 0
  EF_BRIGHTLIGHT = 4;	// DLIGHT centered at entity origin
  EF_DIMLIGHT = 8;	// player flashlight
  EF_INVLIGHT = 16;	// get lighting from ceiling
  EF_NOINTERP = 32;	// don't interpolate the next frame
  EF_LIGHT = 64;	// rocket flare glow sprite
  EF_NODRAW = 128;	// don't draw entity
  EF_NIGHTVISION = 256; // player nightvision
  EF_SNIPERLASER = 512; // sniper laser effect
  EF_FIBERCAMERA = 1024;// fiber camera

  // entity flags
  EFLAG_SLERP = 1;	// do studio interpolation of this entity

  //
  // temp entity events
  //
  TE_BEAMPOINTS = 0;		// beam effect between two points
  // coord coord coord (start position)
  // coord coord coord (end position)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_BEAMENTPOINT = 1;		// beam effect between point and entity
  // short (start entity)
  // coord coord coord (end position)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_GUNSHOT = 2;		// particle effect plus ricochet sound
  // coord coord coord (position)

  TE_EXPLOSION = 3;		// additive sprite, 2 dynamic lights, flickering particles, explosion sound, move vertically 8 pps
  // coord coord coord (position)
  // short (sprite index)
  // byte (scale in 0.1's)
  // byte (framerate)
  // byte (flags)
  //
  // The Explosion effect has some flags to control performance/aesthetic features:
  TE_EXPLFLAG_NONE = 0;	// all flags clear makes default Half-Life explosion
  TE_EXPLFLAG_NOADDITIVE = 1;	// sprite will be drawn opaque (ensure that the sprite you send is a non-additive sprite)
  TE_EXPLFLAG_NODLIGHTS = 2;	// do not render dynamic lights
  TE_EXPLFLAG_NOSOUND = 4;	// do not play client explosion sound
  TE_EXPLFLAG_NOPARTICLES = 8;	// do not draw particles


  TE_TAREXPLOSION = 4;		// Quake1 "tarbaby" explosion with sound
  // coord coord coord (position)

  TE_SMOKE = 5;		// alphablend sprite, move vertically 30 pps
  // coord coord coord (position)
  // short (sprite index)
  // byte (scale in 0.1's)
  // byte (framerate)

  TE_TRACER = 6;		// tracer effect from point to point
  // coord, coord, coord (start)
  // coord, coord, coord (end)

  TE_LIGHTNING = 7;		// TE_BEAMPOINTS with simplified parameters
  // coord, coord, coord (start)
  // coord, coord, coord (end)
  // byte (life in 0.1's)
  // byte (width in 0.1's)
  // byte (amplitude in 0.01's)
  // short (sprite model index)

  TE_BEAMENTS = 8;
  // short (start entity)
  // short (end entity)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_SPARKS = 9;		// 8 random tracers with gravity, ricochet sprite
  // coord coord coord (position)

  TE_LAVASPLASH = 10;		// Quake1 lava splash
  // coord coord coord (position)

  TE_TELEPORT = 11;		// Quake1 teleport splash
  // coord coord coord (position)

  TE_EXPLOSION2 = 12;		// Quake1 colormaped (base palette) particle explosion with sound
  // coord coord coord (position)
  // byte (starting color)
  // byte (num colors)

  TE_BSPDECAL = 13;		// Decal from the .BSP file
  // coord, coord, coord (x,y,z), decal position (center of texture in world)
  // short (texture index of precached decal texture name)
  // short (entity index)
  // [optional - only included if previous short is non-zero (not the world)] short (index of model of above entity)

  TE_IMPLOSION = 14;		// tracers moving toward a point
  // coord, coord, coord (position)
  // byte (radius)
  // byte (count)
  // byte (life in 0.1's)

  TE_SPRITETRAIL = 15;		// line of moving glow sprites with gravity, fadeout, and collisions
  // coord, coord, coord (start)
  // coord, coord, coord (end)
  // short (sprite index)
  // byte (count)
  // byte (life in 0.1's)
  // byte (scale in 0.1's)
  // byte (velocity along vector in 10's)
  // byte (randomness of velocity in 10's)

  TE_BEAM = 16;		// obsolete

  TE_SPRITE = 17;		// additive sprite, plays 1 cycle
  // coord, coord, coord (position)
  // short (sprite index)
  // byte (scale in 0.1's)
  // byte (brightness)

  TE_BEAMSPRITE = 18;		// A beam with a sprite at the end
  // coord, coord, coord (start position)
  // coord, coord, coord (end position)
  // short (beam sprite index)
  // short (end sprite index)

  TE_BEAMTORUS = 19;		// screen aligned beam ring, expands to max radius over lifetime
  // coord coord coord (center position)
  // coord coord coord (axis and radius)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_BEAMDISK = 20;		// disk that expands to max radius over lifetime
  // coord coord coord (center position)
  // coord coord coord (axis and radius)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_BEAMCYLINDER = 21;		// cylinder that expands to max radius over lifetime
  // coord coord coord (center position)
  // coord coord coord (axis and radius)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_BEAMFOLLOW = 22;		// create a line of decaying beam segments until entity stops moving
  // short (entity:attachment to follow)
  // short (sprite index)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte,byte,byte (color)
  // byte (brightness)

  TE_GLOWSPRITE = 23;
  // coord, coord, coord (pos) short (model index) byte (scale / 10)

  TE_BEAMRING = 24;		// connect a beam ring to two entities
  // short (start entity)
  // short (end entity)
  // short (sprite index)
  // byte (starting frame)
  // byte (frame rate in 0.1's)
  // byte (life in 0.1's)
  // byte (line width in 0.1's)
  // byte (noise amplitude in 0.01's)
  // byte,byte,byte (color)
  // byte (brightness)
  // byte (scroll speed in 0.1's)

  TE_STREAK_SPLASH = 25;		// oriented shower of tracers
  // coord coord coord (start position)
  // coord coord coord (direction vector)
  // byte (color)
  // short (count)
  // short (base speed)
  // short (ramdon velocity)

  TE_BEAMHOSE = 26;		// obsolete

  TE_DLIGHT = 27;		// dynamic light, effect world, minor entity effect
  // coord, coord, coord (pos)
  // byte (radius in 10's)
  // byte byte byte (color)
  // byte (brightness)
  // byte (life in 10's)
  // byte (decay rate in 10's)

  TE_ELIGHT = 28;		// point entity light, no world effect
  // short (entity:attachment to follow)
  // coord coord coord (initial position)
  // coord (radius)
  // byte byte byte (color)
  // byte (life in 0.1's)
  // coord (decay rate)

  TE_TEXTMESSAGE = 29;
  // short 1.2.13 x (-1 = center)
  // short 1.2.13 y (-1 = center)
  // byte Effect 0 = fade in/fade out
        // 1 is flickery credits
        // 2 is write out (training room)

  // 4 bytes r,g,b,a color1	(text color)
  // 4 bytes r,g,b,a color2	(effect color)
  // ushort 8.8 fadein time
  // ushort 8.8  fadeout time
  // ushort 8.8 hold time
  // optional ushort 8.8 fxtime	(time the highlight lags behing the leading text in effect 2)
  // string text message		(512 chars max sz string)
  TE_LINE = 30;
  // coord, coord, coord		startpos
  // coord, coord, coord		endpos
  // short life in 0.1 s
  // 3 bytes r, g, b

  TE_BOX = 31;
  // coord, coord, coord		boxmins
  // coord, coord, coord		boxmaxs
  // short life in 0.1 s
  // 3 bytes r, g, b

  TE_KILLBEAM = 99;		// kill all beams attached to entity
  // short (entity)

  TE_LARGEFUNNEL = 100;
  // coord coord coord (funnel position)
  // short (sprite index)
  // short (flags)

  TE_BLOODSTREAM = 101;		// particle spray
  // coord coord coord (start position)
  // coord coord coord (spray vector)
  // byte (color)
  // byte (speed)

  TE_SHOWLINE = 102;		// line of particles every 5 units, dies in 30 seconds
  // coord coord coord (start position)
  // coord coord coord (end position)

  TE_BLOOD = 103;		// particle spray
  // coord coord coord (start position)
  // coord coord coord (spray vector)
  // byte (color)
  // byte (speed)

  TE_DECAL = 104;		// Decal applied to a brush entity (not the world)
  // coord, coord, coord (x,y,z), decal position (center of texture in world)
  // byte (texture index of precached decal texture name)
  // short (entity index)

  TE_FIZZ = 105;		// create alpha sprites inside of entity, float upwards
  // short (entity)
  // short (sprite index)
  // byte (density)

  TE_MODEL = 106;		// create a moving model that bounces and makes a sound when it hits
  // coord, coord, coord (position)
  // coord, coord, coord (velocity)
  // angle (initial yaw)
  // short (model index)
  // byte (bounce sound type)
  // byte (life in 0.1's)

  TE_EXPLODEMODEL = 107;		// spherical shower of models, picks from set
  // coord, coord, coord (origin)
  // coord (velocity)
  // short (model index)
  // short (count)
  // byte (life in 0.1's)

  TE_BREAKMODEL = 108;		// box of models or sprites
  // coord, coord, coord (position)
  // coord, coord, coord (size)
  // coord, coord, coord (velocity)
  // byte (random velocity in 10's)
  // short (sprite or model index)
  // byte (count)
  // byte (life in 0.1 secs)
  // byte (flags)

  TE_GUNSHOTDECAL = 109;		// decal and ricochet sound
  // coord, coord, coord (position)
  // short (entity index???)
  // byte (decal???)

  TE_SPRITE_SPRAY = 110;		// spay of alpha sprites
  // coord, coord, coord (position)
  // coord, coord, coord (velocity)
  // short (sprite index)
  // byte (count)
  // byte (speed)
  // byte (noise)

  TE_ARMOR_RICOCHET = 111;		// quick spark sprite, client ricochet sound.
  // coord, coord, coord (position)
  // byte (scale in 0.1's)

  TE_PLAYERDECAL = 112;		// ???
  // byte (playerindex)
  // coord, coord, coord (position)
  // short (entity???)
  // byte (decal number???)
  // [optional] short (model index???)

  TE_BUBBLES = 113;		// create alpha sprites inside of box, float upwards
  // coord, coord, coord (min start position)
  // coord, coord, coord (max start position)
  // coord (float height)
  // short (model index)
  // byte (count)
  // coord (speed)

  TE_BUBBLETRAIL = 114;		// create alpha sprites along a line, float upwards
  // coord, coord, coord (min start position)
  // coord, coord, coord (max start position)
  // coord (float height)
  // short (model index)
  // byte (count)
  // coord (speed)

  TE_BLOODSPRITE = 115;		// spray of opaque sprite1's that fall, single sprite2 for 1..2 secs (this is a high-priority tent)
  // coord, coord, coord (position)
  // short (sprite1 index)
  // short (sprite2 index)
  // byte (color)
  // byte (scale)

  TE_WORLDDECAL = 116;		// Decal applied to the world brush
  // coord, coord, coord (x,y,z), decal position (center of texture in world)
  // byte (texture index of precached decal texture name)

  TE_WORLDDECALHIGH = 117;		// Decal (with texture index > 256) applied to world brush
  // coord, coord, coord (x,y,z), decal position (center of texture in world)
  // byte (texture index of precached decal texture name - 256)

  TE_DECALHIGH = 118;		// Same as TE_DECAL, but the texture index was greater than 256
  // coord, coord, coord (x,y,z), decal position (center of texture in world)
  // byte (texture index of precached decal texture name - 256)
  // short (entity index)

  TE_PROJECTILE = 119;		// Makes a projectile (like a nail) (this is a high-priority tent)
  // coord, coord, coord (position)
  // coord, coord, coord (velocity)
  // short (modelindex)
  // byte (life)
  // byte (owner)  projectile won't collide with owner (if owner == 0, projectile will hit any client).

  TE_SPRAY = 120;		// Throws a shower of sprites or models
  // coord, coord, coord (position)
  // coord, coord, coord (direction)
  // short (modelindex)
  // byte (count)
  // byte (speed)
  // byte (noise)
  // byte (rendermode)

  TE_PLAYERSPRITES = 121;		// sprites emit from a player's bounding box (ONLY use for players!)
  // byte (playernum)
  // short (sprite modelindex)
  // byte (count)
  // byte (variance) (0 = no variance in size) (10 = 10% variance in size)

  TE_PARTICLEBURST = 122;		// very similar to lavasplash.
  // coord (origin)
  // short (radius)
  // byte (particle color)
  // byte (duration * 10) (will be randomized a bit)

  TE_FIREFIELD = 123;		// makes a field of fire.
  // coord (origin)
  // short (radius) (fire is made in a square around origin. -radius, -radius to radius, radius)
  // short (modelindex)
  // byte (count)
  // byte (flags)
  // byte (duration (in seconds) * 10) (will be randomized a bit)
  //
  // to keep network traffic low, this message has associated flags that fit into a byte:
  TEFIRE_FLAG_ALLFLOAT = 1; // all sprites will drift upwards as they animate
  TEFIRE_FLAG_SOMEFLOAT = 2; // some of the sprites will drift upwards. (50% chance)
  TEFIRE_FLAG_LOOP = 4; // if set, sprite plays at 15 fps, otherwise plays at whatever rate stretches the animation over the sprite's duration.
  TEFIRE_FLAG_ALPHA = 8; // if set, sprite is rendered alpha blended at 50% else, opaque
  TEFIRE_FLAG_PLANAR = 16; // if set, all fire sprites have same initial Z instead of randomly filling a cube.
  TEFIRE_FLAG_ADDITIVE = 32; // if set, sprite is rendered non-opaque with additive

  TE_PLAYERATTACHMENT = 124; // attaches a TENT to a player (this is a high-priority tent)
  // byte (entity index of player)
  // coord (vertical offset) ( attachment origin.z = player origin.z + vertical offset )
  // short (model index)
  // short (life * 10 );

  TE_KILLPLAYERATTACHMENTS = 125; // will expire all TENTS attached to a player.
  // byte (entity index of player)

  TE_MULTIGUNSHOT = 126; // much more compact shotgun message
  // This message is used to make a client approximate a 'spray' of gunfire.
  // Any weapon that fires more than one bullet per frame and fires in a bit of a spread is
  // a good candidate for MULTIGUNSHOT use. (shotguns)
  //
  // NOTE: This effect makes the client do traces for each bullet, these client traces ignore
  //		 entities that have studio models.Traces are 4096 long.
  //
  // coord (origin)
  // coord (origin)
  // coord (origin)
  // coord (direction)
  // coord (direction)
  // coord (direction)
  // coord (x noise * 100)
  // coord (y noise * 100)
  // byte (count)
  // byte (bullethole decal texture index)

  TE_USERTRACER = 127; // larger message than the standard tracer, but allows some customization.
  // coord (origin)
  // coord (origin)
  // coord (origin)
  // coord (velocity)
  // coord (velocity)
  // coord (velocity)
  // byte ( life * 10 )
  // byte ( color ) this is an index into an array of color vectors in the engine. (0 - )
  // byte ( length * 10 )

  // contents of a spot in the world
  CONTENTS_EMPTY = -1;
  CONTENTS_SOLID = -2;
  CONTENTS_WATER = -3;
  CONTENTS_SLIME = -4;
  CONTENTS_LAVA = -5;
  CONTENTS_SKY = -6;

  CONTENTS_LADDER = -16;

  CONTENT_FLYFIELD = -17;
  CONTENT_GRAVITY_FLYFIELD = -18;
  CONTENT_FOG = -19;

  CONTENT_EMPTY = -1;
  CONTENT_SOLID = -2;
  CONTENT_WATER = -3;
  CONTENT_SLIME = -4;
  CONTENT_LAVA = -5;
  CONTENT_SKY= -6;

  // channels
  CHAN_AUTO = 0;
  CHAN_WEAPON = 1;
  CHAN_VOICE = 2;
  CHAN_ITEM = 3;
  CHAN_BODY = 4;
  CHAN_STREAM = 5;			// allocate stream channel from the static or dynamic area
  CHAN_STATIC = 6;			// allocate channel from the static area
  CHAN_NETWORKVOICE_BASE  = 7;		// voice data coming across the network
  CHAN_NETWORKVOICE_END = 500;		// network voice data reserves slots (CHAN_NETWORKVOICE_BASE through CHAN_NETWORKVOICE_END).
  CHAN_BOT = 501;			// channel used for bot chatter.

  // attenuation values
  ATTN_NONE = 0;
  ATTN_NORM: Single = 0.8;
  ATTN_IDLE: Single = 2.0;
  ATTN_STATIC: Single = 1.25;

  // pitch values
  PITCH_NORM = 100;			// non-pitch shifted
  PITCH_LOW = 95;			// other values are possible - 0-255, where 255 is very high
  PITCH_HIGH = 120;

  // volume values
  VOL_NORM = 1.0;

  BREAK_TYPEMASK = $4F;
  BREAK_GLASS = $01;
  BREAK_METAL = $02;
  BREAK_FLESH = $04;
  BREAK_WOOD = $08;

  BREAK_SMOKE = $10;
  BREAK_TRANS = $20;
  BREAK_CONCRETE = $40;
  BREAK_2 = $80;

  // Colliding temp entity sounds

  BOUNCE_GLASS = BREAK_GLASS;
  BOUNCE_METAL = BREAK_METAL;
  BOUNCE_FLESH = BREAK_FLESH;
  BOUNCE_WOOD = BREAK_WOOD;
  BOUNCE_SHRAP = $10;
  BOUNCE_SHELL = $20;
  BOUNCE_CONCRETE = BREAK_CONCRETE;
  BOUNCE_SHOTSHELL = $80;

  // Temp entity bounce sound types
  TE_BOUNCE_NULL = 0;
  TE_BOUNCE_SHELL = 1;
  TE_BOUNCE_SHOTSHELL = 2;

  // Rendering constants
  kRenderNormal = 0;			// src
  kRenderTransColor = 1;		// c*a+dest*(1-a)
  kRenderTransTexture = 2;	// src*a+dest*(1-a)
  kRenderGlow = 3;			// src*a+dest -- No Z buffer checks
  kRenderTransAlpha = 4;		// src*srca+dest*(1-srca)
  kRenderTransAdd = 5;		// src*a+dest

  kRenderFxNone = 0;
  kRenderFxPulseSlow = 1;
  kRenderFxPulseFast = 2;
  kRenderFxPulseSlowWide = 3;
  kRenderFxPulseFastWide = 4;
  kRenderFxFadeSlow = 5;
  kRenderFxFadeFast = 6;
  kRenderFxSolidSlow = 7;
  kRenderFxSolidFast = 8;
  kRenderFxStrobeSlow = 9;
  kRenderFxStrobeFast = 10;
  kRenderFxStrobeFaster = 11;
  kRenderFxFlickerSlow = 12;
  kRenderFxFlickerFast = 13;
  kRenderFxNoDissipation = 14;
  kRenderFxDistort = 15;			// Distort/scale/translate flicker
  kRenderFxHologram = 16;			// kRenderFxDistort + distance fade
  kRenderFxDeadPlayer = 17;		// kRenderAmt is the player index
  kRenderFxExplode = 18;			// Scale up really big!
  kRenderFxGlowShell = 19;			// Glowing Shell
  kRenderFxClampMinScale = 20;		// Keep this sprite from getting very small (SPRITES only!)
  kRenderFxLightMultiplier = 21;	//CTM !!!CZERO added to tell the studiorender that the value in iuser2 is a lightmultiplier

  FCVAR_ARCHIVE = 1 shl 0;	// set to cause it to be saved to vars.rc
  FCVAR_USERINFO = 1 shl 1;	// changes the client's info string
  FCVAR_SERVER = 1 shl 2;	// notifies players when changed
  FCVAR_EXTDLL = 1 shl 3;	// defined by external DLL
  FCVAR_CLIENTDLL = 1 shl 4;  // defined by the client dll
  FCVAR_PROTECTED = 1 shl 5;  // It's a server cvar, but we don't send the data since it's a password, etc.  Sends 1 if it's not bland/zero, 0 otherwise as value
  FCVAR_SPONLY = 1 shl 6;  // This cvar cannot be changed by clients connected to a multiplayer server.
  FCVAR_PRINTABLEONLY = 1 shl 7;  // This cvar's string cannot contain unprintable characters ( e.g., used for player name etc ).
  FCVAR_UNLOGGED = 1 shl 8;  // If this is a FCVAR_SERVER, don't log changes to the log file / console if we are creating a log
  FCVAR_NOEXTRAWHITEPACE = 1 shl 9;  // strip trailing/leading white space from this cvar

  // director_cmds.h
  // sub commands for svc_director

  DRC_ACTIVE = 0;	// tells client that he's an spectator and will get director command
  DRC_STATUS = 1;	// send status infos about proxy
  DRC_CAMERA = 2;	// set the actual director camera position
  DRC_EVENT = 3;	// informs the dircetor about ann important game event

  // commands of the director API function CallDirectorProc(...)

  DRCAPI_NOP = 0;	// no operation
  DRCAPI_ACTIVE = 1;	// de/acivates director mode in engine
  DRCAPI_STATUS = 2;   // request proxy information
  DRCAPI_SETCAM = 3;	// set camera n to given position and angle
  DRCAPI_GETCAM = 4;	// request camera n position and angle
  DRCAPI_DIRPLAY = 5;	// set director time and play with normal speed
  DRCAPI_DIRFREEZE = 6;	// freeze directo at this time
  DRCAPI_SETVIEWMODE = 7;	// overview or 4 cameras
  DRCAPI_SETOVERVIEWPARAMS = 8;	// sets parameter for overview mode
  DRCAPI_SETFOCUS = 9;	// set the camera which has the input focus
  DRCAPI_GETTARGETS = 10;	// queries engine for player list
  DRCAPI_SETVIEWPOINTS = 11;	// gives engine all waypoints

  //DLL State Flags

  DLL_INACTIVE = 0;		// no dll
  DLL_ACTIVE = 1;		// dll is running
  DLL_PAUSED = 2;		// dll is paused
  DLL_CLOSE = 3;		// closing down dll
  DLL_TRANS = 4; 		// Level Transition

  // DLL Pause reasons

  DLL_NORMAL = 0;   // User hit Esc or something.
  DLL_QUIT = 4;   // Quit now
  DLL_RESTART = 5;   // Switch to launcher for linux, does a quit but returns 1

  // DLL Substate info ( not relevant )
  NG_NORMAL = 1 shl 0;

  // For entityType below
  ENTITY_NORMAL = 1 shl 0;
  ENTITY_BEAM = 1 shl 1;

  ET_NORMAL = 0;
  ET_PLAYER = 1;
  ET_TEMPENTITY = 2;
  ET_BEAM = 3;
  // BMODEL or SPRITE that was split across BSP nodes
  ET_FRAGMENTED	= 4;

type
  netsrc_s =
  (
    NS_CLIENT,
    NS_SERVER,
    NS_MULTICAST	// xxxMO
  );
  netsrc_t = netsrc_s;

  TNetSrc = netsrc_t;
  PNetSrc = ^TNetSrc;

const
  // Event was invoked with stated origin
  FEVENT_ORIGIN	= 1 shl 0;

  // Event was invoked with stated angles
  FEVENT_ANGLES = 1 shl 1;

  // Skip local host for event send.
  FEV_NOTHOST = 1 shl 0;

  // Send the event reliably.  You must specify the origin and angles and use
  // PLAYBACK_EVENT_FULL for this to work correctly on the server for anything
  // that depends on the event origin/angles.  I.e., the origin/angles are not
  // taken from the invoking edict for reliable events.
  FEV_RELIABLE = 1 shl 1;

  // Don't restrict to PAS/PVS, send this event to _everybody_ on the server ( useful for stopping CHAN_STATIC
  //  sounds started by client event when client is not in PVS anymore ( hwguy in TFC e.g. ).
  FEV_GLOBAL = 1 shl 2;

  // If this client already has one of these events in its queue, just update the event instead of sending it as a duplicate
  //
  FEV_UPDATE = 1 shl 3;

  // Only send to entity specified as the invoker
  FEV_HOSTONLY = 1 shl 4;

  // Only send if the event was created on the server.
  FEV_SERVER = 1 shl 5;

  // Only issue event client side ( from shared code )
  FEV_CLIENT = 1 shl 6;

  // all shared consts between server, clients and proxy
  TYPE_CLIENT = 0;	// client is a normal HL client (default)
  TYPE_PROXY = 1;	// client is another proxy
  TYPE_COMMENTATOR = 3;	// client is a commentator
  TYPE_DEMO = 4;	// client is a demo file

  // sub commands of svc_hltv:
  HLTV_ACTIVE	= 0;	// tells client that he's an spectator and will get director commands
  HLTV_STATUS	= 1;	// send status infos about proxy
  HLTV_LISTEN	= 2;	// tell client to listen to a multicast stream

  // director command types:
  DRC_CMD_NONE = 0;	// NULL director command
  DRC_CMD_START = 1;	// start director mode
  DRC_CMD_EVENT = 2;	// informs about director command
  DRC_CMD_MODE = 3;	// switches camera modes
  DRC_CMD_CAMERA = 4;	// set fixed camera
  DRC_CMD_TIMESCALE = 5;	// sets time scale
  DRC_CMD_MESSAGE = 6;	// send HUD centerprint
  DRC_CMD_SOUND = 7;	// plays a particular sound
  DRC_CMD_STATUS = 8;	// HLTV broadcast status
  DRC_CMD_BANNER = 9;	// set GUI banner
  DRC_CMD_STUFFTEXT = 10;	// like the normal svc_stufftext but as director command
  DRC_CMD_CHASE = 11;	// chase a certain player
  DRC_CMD_INEYE = 12;	// view player through own eyes
  DRC_CMD_MAP = 13;	// show overview map
  DRC_CMD_CAMPATH = 14;	// define camera waypoint
  DRC_CMD_WAYPOINTS = 15;	// start moving camera, inetranl message

  DRC_CMD_LAST = 15;


  // DRC_CMD_EVENT event flags
  DRC_FLAG_PRIO_MASK = $0F;	// priorities between 0 and 15 (15 most important)
  DRC_FLAG_SIDE = 1 shl 4;	//
  DRC_FLAG_DRAMATIC = 1 shl 5;	// is a dramatic scene
  DRC_FLAG_SLOWMOTION = 1 shl 6;  // would look good in SloMo
  DRC_FLAG_FACEPLAYER = 1 shl 7;  // player is doning something (reload/defuse bomb etc)
  DRC_FLAG_INTRO = 1 shl 8;	// is a introduction scene
  DRC_FLAG_FINAL = 1 shl 9;	// is a final scene
  DRC_FLAG_NO_RANDOM = 1 shl 10;	// don't randomize event data


  // DRC_CMD_WAYPOINT flags
  DRC_FLAG_STARTPATH = 1;	// end with speed 0.0
  DRC_FLAG_SLOWSTART = 2;	// start with speed 0.0
  DRC_FLAG_SLOWEND = 4;	// end with speed 0.0

  IN_ATTACK = 1 shl 0;
  IN_JUMP = 1 shl 1;
  IN_DUCK = 1 shl 2;
  IN_FORWARD = 1 shl 3;
  IN_BACK = 1 shl 4;
  IN_USE = 1 shl 5;
  IN_CANCEL	 = 1 shl 6;
  IN_LEFT = 1 shl 7;
  IN_RIGHT = 1 shl 8;
  IN_MOVELEFT = 1 shl 9;
  IN_MOVERIGHT = 1 shl 10;
  IN_ATTACK2 = 1 shl 11;
  IN_RUN = 1 shl 12;
  IN_RELOAD = 1 shl 13;
  IN_ALT1 = 1 shl 14;
  IN_SCORE = 1 shl 15;   // Used by client.dll for when scoreboard is held down

type
  VoiceTweakControl =
  (
    MicrophoneVolume = 0, // values 0-1.
    OtherSpeakerScale,    // values 0-1. Scales how loud other players are.
    MicBoost              // 20 db gain to voice input
  );
  TVoiceTweakControl = VoiceTweakControl;

const
  NETAPI_REQUEST_SERVERLIST = 0;  // Doesn't need a remote address
  NETAPI_REQUEST_PING = 1;
  NETAPI_REQUEST_RULES = 2;
  NETAPI_REQUEST_PLAYERS = 3;
  NETAPI_REQUEST_DETAILS = 4;

  // Set this flag for things like broadcast requests, etc. where the engine should not
  //  kill the request hook after receiving the first response
  FNETAPI_MULTIPLE_RESPONSE = 1 shl 0;

  NET_SUCCESS = 0;
  NET_ERROR_TIMEOUT = 1 shl 0;
  NET_ERROR_PROTO_UNSUPPORTED = 1 shl 1;
  NET_ERROR_UNDEFINED = 1 shl 2;

type
  netadrtype_t =
  (
    NA_UNUSED,
    NA_LOOPBACK,
    NA_BROADCAST,
    NA_IP,
    NA_IPX,
    NA_BROADCAST_IPX
  );
  TNetAdrType = netadrtype_t;

  ptype_t =
  (
    pt_static,
    pt_grav,
    pt_slowgrav,
    pt_fire,
    pt_explode,
    pt_explode2,
    pt_blob,
    pt_blob2,
    pt_vox_slowgrav,
    pt_vox_grav,
    pt_clientcustom   // Must have callback function specified
  );
  TPType = ptype_t;

const
  NUM_GLYPHS = 256;

  // DATA STRUCTURE INFO

  MAX_NUM_ARGVS = 50;

  // SYSTEM INFO
  MAX_QPATH = 64;		// max length of a game pathname
  MAX_OSPATH = 260;		// max length of a filesystem pathname

  ON_EPSILON = 0.1;		// point on plane side epsilon

  MAX_LIGHTSTYLE_INDEX_BITS = 6;
  MAX_LIGHTSTYLES = 1 shl MAX_LIGHTSTYLE_INDEX_BITS;

  // Resource counts;
  MAX_MODEL_INDEX_BITS = 9;	// sent as a short
  MAX_MODELS = 1 shl MAX_MODEL_INDEX_BITS;
  MAX_SOUND_INDEX_BITS = 9;
  MAX_SOUNDS = 1 shl MAX_SOUND_INDEX_BITS;

  MAX_GENERIC_INDEX_BITS = 9;
  MAX_GENERIC = 1 shl MAX_GENERIC_INDEX_BITS;
  MAX_DECAL_INDEX_BITS = 9;
  MAX_BASE_DECALS = 1 shl MAX_DECAL_INDEX_BITS;

  MAX_USER_MSG_DATA = 192;

  // Temporary entity array
  TENTPRIORITY_LOW = 0;
  TENTPRIORITY_HIGH = 1;

  // TEMPENTITY flags
  FTENT_NONE = $00000000;
  FTENT_SINEWAVE = $00000001;
  FTENT_GRAVITY = $00000002;
  FTENT_ROTATE = $00000004;
  FTENT_SLOWGRAVITY = $00000008;
  FTENT_SMOKETRAIL = $00000010;
  FTENT_COLLIDEWORLD = $00000020;
  FTENT_FLICKER = $00000040;
  FTENT_FADEOUT = $00000080;
  FTENT_SPRANIMATE = $00000100;
  FTENT_HITSOUND = $00000200;
  FTENT_SPIRAL = $00000400;
  FTENT_SPRCYCLE = $00000800;
  FTENT_COLLIDEALL = $00001000; // will collide with world and slideboxes
  FTENT_PERSIST = $00002000; // tent is not removed when unable to draw
  FTENT_COLLIDEKILL = $00004000; // tent is removed upon collision with anything
  FTENT_PLYRATTACHMENT = $00008000; // tent is attached to a player (owner)
  FTENT_SPRANIMATELOOP = $00010000; // animating sprite doesn't die when last frame is displayed
  FTENT_SPARKSHOWER = $00020000;
  FTENT_NOMODEL = $00040000; // Doesn't have a model, never try to draw ( it just triggers other things )
  FTENT_CLIENTCUSTOM = $00080000; // Must specify callback.  Callback function is responsible for killing tempent and updating fields ( unless other flags specify how to do things )

type
  //--------------------------------------------------------------------------
  // sequenceDefaultBits_e
  //
  // Enumerated list of possible modifiers for a command.  This enumeration
  // is used in a bitarray controlling what modifiers are specified for a command.
  //---------------------------------------------------------------------------
  sequenceModifierBits =
  (
    SEQUENCE_MODIFIER_EFFECT_BIT = 1 shl 1,
    SEQUENCE_MODIFIER_POSITION_BIT = 1 shl 2,
    SEQUENCE_MODIFIER_COLOR_BIT = 1 shl 3,
    SEQUENCE_MODIFIER_COLOR2_BIT = 1 shl 4,
    SEQUENCE_MODIFIER_FADEIN_BIT = 1 shl 5,
    SEQUENCE_MODIFIER_FADEOUT_BIT = 1 shl 6,
    SEQUENCE_MODIFIER_HOLDTIME_BIT = 1 shl 7,
    SEQUENCE_MODIFIER_FXTIME_BIT = 1 shl 8,
    SEQUENCE_MODIFIER_SPEAKER_BIT = 1 shl 9,
    SEQUENCE_MODIFIER_LISTENER_BIT = 1 shl 10,
    SEQUENCE_MODIFIER_TEXTCHANNEL_BIT	= 1 shl 11
  );
  sequenceModifierBits_e = sequenceModifierBits;
  TSequenceModifierBits = sequenceModifierBits;

  //---------------------------------------------------------------------------
  // sequenceCommandEnum_e
  //
  // Enumerated sequence command types.
  //---------------------------------------------------------------------------
  sequenceCommandEnum_ =
  (
    SEQUENCE_COMMAND_ERROR = -1,
    SEQUENCE_COMMAND_PAUSE = 0,
    SEQUENCE_COMMAND_FIRETARGETS,
    SEQUENCE_COMMAND_KILLTARGETS,
    SEQUENCE_COMMAND_TEXT,
    SEQUENCE_COMMAND_SOUND,
    SEQUENCE_COMMAND_GOSUB,
    SEQUENCE_COMMAND_SENTENCE,
    SEQUENCE_COMMAND_REPEAT,
    SEQUENCE_COMMAND_SETDEFAULTS,
    SEQUENCE_COMMAND_MODIFIER,
    SEQUENCE_COMMAND_POSTMODIFIER,
    SEQUENCE_COMMAND_NOOP,

    SEQUENCE_MODIFIER_EFFECT,
    SEQUENCE_MODIFIER_POSITION,
    SEQUENCE_MODIFIER_COLOR,
    SEQUENCE_MODIFIER_COLOR2,
    SEQUENCE_MODIFIER_FADEIN,
    SEQUENCE_MODIFIER_FADEOUT,
    SEQUENCE_MODIFIER_HOLDTIME,
    SEQUENCE_MODIFIER_FXTIME,
    SEQUENCE_MODIFIER_SPEAKER,
    SEQUENCE_MODIFIER_LISTENER,
    SEQUENCE_MODIFIER_TEXTCHANNEL
  );
  sequenceCommandEnum_e = sequenceCommandEnum_;
  TSequenceCommandEnum = sequenceCommandEnum_e;

  //---------------------------------------------------------------------------
  // sequenceCommandType_e
  //
  // Typeerated sequence command types.
  //---------------------------------------------------------------------------
  sequenceCommandType_ =
  (
    SEQUENCE_TYPE_COMMAND,
    SEQUENCE_TYPE_MODIFIER
  );
  sequenceCommandType_e = sequenceCommandType_;
  TSequenceCommandType = sequenceCommandType_e;

  TRICULLSTYLE =
  (
    TRI_FRONT = 0,
    TRI_NONE = 1
  );
  TTriCullStyle = TRICULLSTYLE;

const
  TRI_TRIANGLES = 0;
  TRI_TRIANGLE_FAN = 1;
  TRI_QUADS = 2;
  TRI_POLYGON = 3;
  TRI_LINES = 4;
  TRI_TRIANGLE_STRIP = 5;
  TRI_QUAD_STRIP = 6;

  // header
  Q1BSP_VERSION = 29;		// quake1 regular version (beta is 28)
  HLBSP_VERSION = 30;		// half-life regular version

  MAX_MAP_HULLS = 4;

  CONTENTS_ORIGIN = -7;		// removed at csg time
  CONTENTS_CLIP = -8;		// changed to contents_solid
  CONTENTS_CURRENT_0 = -9;
  CONTENTS_CURRENT_90 = -10;
  CONTENTS_CURRENT_180 = -11;
  CONTENTS_CURRENT_270 = -12;
  CONTENTS_CURRENT_UP = -13;
  CONTENTS_CURRENT_DOWN = -14;

  CONTENTS_TRANSLUCENT = -15;

  LUMP_ENTITIES = 0;
  LUMP_PLANES = 1;
  LUMP_TEXTURES = 2;
  LUMP_VERTEXES = 3;
  LUMP_VISIBILITY = 4;
  LUMP_NODES = 5;
  LUMP_TEXINFO = 6;
  LUMP_FACES = 7;
  LUMP_LIGHTING = 8;
  LUMP_CLIPNODES = 9;
  LUMP_LEAFS = 10;
  LUMP_MARKSURFACES = 11;
  LUMP_EDGES = 12;
  LUMP_SURFEDGES = 13;
  LUMP_MODELS = 14;

  HEADER_LUMPS = 15;

  FCMD_HUD_COMMAND = 1 shl 0;
  FCMD_GAME_COMMAND	= 1 shl 1;
  FCMD_WRAPPER_COMMAND = 1 shl 2;

  COM_TOKEN_LEN = 1024;

  // Don't allow overflow
  SIZEBUF_CHECK_OVERFLOW = 0;
  SIZEBUF_ALLOW_OVERFLOW  = 1 shl 0;
  SIZEBUF_OVERFLOWED = 1 shl 1;

  NUM_SAFE_ARGVS = 7;

  COM_COPY_CHUNK_SIZE = 1024;
  COM_MAX_CMD_LINE = 256;

  MAX_RESOURCE_LIST	= 1280;

type
  /////////////////
  // Customization
  // passed to pfnPlayerCustomization
  // For automatic downloading.
  resourcetype_t =
  (
    t_sound = 0,
    t_skin,
    t_model,
    t_decal,
    t_generic,
    t_eventscript,
    t_world,		// Fake type for world, is really t_model
    rt_unk,

    rt_max
  );
  TResourceType = resourcetype_t;

const
  RES_FATALIFMISSING = 1 shl 0; // Disconnect if we can't get this file.
  RES_WASMISSING = 1 shl 1; // Do we have the file locally, did we get it ok?
  RES_CUSTOM = 1 shl 2; // Is this resource one that corresponds to another player's customization
                        // or is it a server startup resource.
  RES_REQUESTED = 1 shl 3; // Already requested a download of this one
  RES_PRECACHED = 1 shl 4; // Already precached
  RES_ALWAYS = 1 shl 5;	// download always even if available on client
  RES_UNK_6 = 1 shl 6; // TODO: what is it?
  RES_CHECKFILE = 1 shl 7;// check file on client


  FCUST_FROMHPAK = 1 shl 0;
  FCUST_WIPEDATA = 1 shl 1;
  FCUST_IGNOREINIT = 1 shl 2;

  // Beam types, encoded as a byte
  BEAM_POINTS = 0;
  BEAM_ENTPOINT = 1;
  BEAM_ENTS = 2;
  BEAM_HOSE = 3;

  BEAM_FSINE = $10;
  BEAM_FSOLID = $20;
  BEAM_FSHADEIN = $40;
  BEAM_FSHADEOUT = $80;

  MAX_ENT_LEAFS = 48;

type
  ALERT_TYPE =
  (
    at_notice,
    at_console,		// same as at_notice, but forces a ConPrintf, not a message box
    at_aiconsole,	// same as at_console, but only shown if developer level is 2!
    at_warning,
    at_error,
    at_logged		// Server print to console ( only in multiplayer games ).
  );
  TAlertType = ALERT_TYPE;

  // 4-22-98  JOHN: added for use in pfnClientPrintf
  PRINT_TYPE =
  (
    print_console,
    print_center,
    print_chat
  );
  TPrintType = PRINT_TYPE;

  // For integrity checking of content on clients
  FORCE_TYPE =
  (
    force_exactfile,					// File on client must exactly match server's file
    force_model_samebounds,				// For model files only, the geometry must fit in the same bbox
    force_model_specifybounds,			// For model files only, the geometry must fit in the specified bbox
    force_model_specifybounds_if_avail	// For Steam model files only, the geometry must fit in the specified bbox (if the file is available)
  );
  TForceType = FORCE_TYPE;

const
  //
  // these are the key numbers that should be passed to Key_Event
  //
  K_TAB = 9;
  K_ENTER = 13;
  K_ESCAPE = 27;
  K_SPACE = 32;

  // normal keys should be passed as lowercased ascii

  K_BACKSPACE = 127;
  K_UPARROW = 128;
  K_DOWNARROW = 129;
  K_LEFTARROW = 130;
  K_RIGHTARROW = 131;

  K_ALT = 132;
  K_CTRL = 133;
  K_SHIFT = 134;
  K_F1 = 135;
  K_F2 = 136;
  K_F3 = 137;
  K_F4 = 138;
  K_F5 = 139;
  K_F6 = 140;
  K_F7 = 141;
  K_F8 = 142;
  K_F9 = 143;
  K_F10 = 144;
  K_F11 = 145;
  K_F12 = 146;
  K_INS = 147;
  K_DEL = 148;
  K_PGDN = 149;
  K_PGUP = 150;
  K_HOME = 151;
  K_END = 152;

  K_KP_HOME = 160;
  K_KP_UPARROW = 161;
  K_KP_PGUP = 162;
  K_KP_LEFTARROW = 163;
  K_KP_5 = 164;
  K_KP_RIGHTARROW = 165;
  K_KP_END = 166;
  K_KP_DOWNARROW = 167;
  K_KP_PGDN = 168;
  K_KP_ENTER = 169;
  K_KP_INS = 170;
  K_KP_DEL = 171;
  K_KP_SLASH = 172;
  K_KP_MINUS = 173;
  K_KP_PLUS = 174;
  K_CAPSLOCK = 175;


  //
  // joystick buttons
  //
  K_JOY1 = 203;
  K_JOY2 = 204;
  K_JOY3 = 205;
  K_JOY4 = 206;

  //
  // aux keys are for multi-buttoned joysticks to generate so they can use
  // the normal binding process
  //
  K_AUX1 = 207;
  K_AUX2 = 208;
  K_AUX3 = 209;
  K_AUX4 = 210;
  K_AUX5 = 211;
  K_AUX6 = 212;
  K_AUX7 = 213;
  K_AUX8 = 214;
  K_AUX9 = 215;
  K_AUX10 = 216;
  K_AUX11 = 217;
  K_AUX12 = 218;
  K_AUX13 = 219;
  K_AUX14 = 220;
  K_AUX15 = 221;
  K_AUX16 = 222;
  K_AUX17 = 223;
  K_AUX18 = 224;
  K_AUX19 = 225;
  K_AUX20 = 226;
  K_AUX21 = 227;
  K_AUX22 = 228;
  K_AUX23 = 229;
  K_AUX24 = 230;
  K_AUX25 = 231;
  K_AUX26 = 232;
  K_AUX27 = 233;
  K_AUX28 = 234;
  K_AUX29 = 235;
  K_AUX30 = 236;
  K_AUX31 = 237;
  K_AUX32 = 238;
  K_MWHEELDOWN = 239;
  K_MWHEELUP = 240;

  K_PAUSE = 255;

  //
  // mouse buttons generate virtual keys
  //
 	K_MOUSE1 = 241;
 	K_MOUSE2 = 242;
 	K_MOUSE3 = 243;
  K_MOUSE4 = 244;
  K_MOUSE5 = 245;

  // header
  ALIAS_MODEL_VERSION	= $006;
  IDPOLYHEADER = Ord('I') shl 24 or Ord('D') shl 16 or Ord('P') shl 8 or Ord('O'); // little-endian "IDPO"

  MAX_LBM_HEIGHT = 480;
  MAX_ALIAS_MODEL_VERTS = 2000;

  SURF_PLANEBACK = 2;
  SURF_DRAWSKY = 4;
  SURF_DRAWSPRITE = 8;
  SURF_DRAWTURB = $10;
  SURF_DRAWTILED = $20;
  SURF_DRAWBACKGROUND = $40;

  MAX_MODEL_NAME = 64;
  MIPLEVELS = 4;
  NUM_AMBIENTS = 4;		// automatic ambient sounds
  MAXLIGHTMAPS = 4;
  MAX_KNOWN_MODELS = 1024;

  TEX_SPECIAL = 1; // sky or slime, no lightmap or 256 subdivision

type
  modtype_e =
  (
    mod_bad = -1,
    mod_brush,
    mod_sprite,
    mod_alias,
    mod_studio
  );
  modtype_t = modtype_e;
  TModType = modtype_t;

  synctype_e =
  (
    ST_SYNC = 0,
    ST_RAND = 1
  );
  synctype_t = synctype_e;
  TSyncType = synctype_t;

  aliasframetype_s =
  (
    ALIAS_SINGLE = 0,
    ALIAS_GROUP = 1
  );
  aliasframetype_t = aliasframetype_s;
  TAliasFrameType = aliasframetype_t;

const
  // 16 simultaneous events, max
  MAX_EVENT_QUEUE = 64;

  DEFAULT_EVENT_RESENDS = 1;

  FFADE_IN = $0000;		// Just here so we don't pass 0 into the function
  FFADE_OUT = $0001;		// Fade out (not in)
  FFADE_MODULATE = $0002;		// Modulate (don't blend)
  FFADE_STAYOUT = $0004;		// ignores the duration, stays faded out until new ScreenFade message received
  FFADE_LONGFADE = $0008;		// used to indicate the fade can be longer than 16 seconds (added for czero)

  SPRITE_VERSION = 2; // Half-Life sprites
  IDSPRITEHEADER = Ord('I') shl 24 or Ord('D') shl 16 or Ord('S') shl 8 or Ord('P');	// little-endian "IDSP"

type
  spriteframetype_e =
  (
    SPR_SINGLE = 0,
    SPR_GROUP,
    SPR_ANGLED
  );
  spriteframetype_t = spriteframetype_e;
  TSpriteFrameType = spriteframetype_t;

const
  MAXSTUDIOTRIANGLES = 20000;	// TODO: tune this
  MAXSTUDIOVERTS = 2048;	// TODO: tune this
  MAXSTUDIOSEQUENCES = 2048;	// total animation sequences
  MAXSTUDIOSKINS = 100;		// total textures
  MAXSTUDIOSRCBONES = 512;		// bones allowed at source movement
  MAXSTUDIOBONES = 128;		// total bones actually used
  MAXSTUDIOMODELS = 32;		// sub-models per model
  MAXSTUDIOBODYPARTS = 32;
  MAXSTUDIOGROUPS = 16;
  MAXSTUDIOANIMATIONS = 2048;	// per sequence
  MAXSTUDIOMESHES = 256;
  MAXSTUDIOEVENTS = 1024;
  MAXSTUDIOPIVOTS = 256;
  MAXSTUDIOCONTROLLERS = 8;

  STUDIO_DYNAMIC_LIGHT = $0100;	// dynamically get lighting from floor or ceil (flying monsters)
  STUDIO_TRACE_HITBOX = $0200;	// always use hitbox trace instead of bbox

  // lighting options
  STUDIO_NF_FLATSHADE = $0001;
  STUDIO_NF_CHROME = $0002;
  STUDIO_NF_FULLBRIGHT = $0004;
  STUDIO_NF_NOMIPS = $0008;
  STUDIO_NF_ALPHA = $0010;
  STUDIO_NF_ADDITIVE = $0020;
  STUDIO_NF_MASKED = $0040;

  // motion flags
  STUDIO_X = $0001;
  STUDIO_Y = $0002;
  STUDIO_Z = $0004;
  STUDIO_XR = $0008;
  STUDIO_YR = $0010;
  STUDIO_ZR = $0020;
  STUDIO_LX = $0040;
  STUDIO_LY = $0080;
  STUDIO_LZ = $0100;
  STUDIO_AX = $0200;
  STUDIO_AY = $0400;
  STUDIO_AZ = $0800;
  STUDIO_AXR = $1000;
  STUDIO_AYR = $2000;
  STUDIO_AZR = $4000;
  STUDIO_TYPES = $7FFF;
  STUDIO_RLOOP = $8000;	// controller that wraps shortest distance

  // sequence flags
  STUDIO_LOOPING = $0001;

  // bone flags
  STUDIO_HAS_NORMALS = $0001;
  STUDIO_HAS_VERTICES = $0002;
  STUDIO_HAS_BBOX = $0004;
  STUDIO_HAS_CHROME = $0008;	// if any of the textures have chrome on them

  RAD_TO_STUDIO = 32768.0 / Pi;
  STUDIO_TO_RAD = Pi / 32768.0;

  STUDIO_NUM_HULLS = 128;
  STUDIO_NUM_PLANES = STUDIO_NUM_HULLS * 6;
  STUDIO_CACHE_SIZE = 16;

type
  // Authentication types
  AUTH_IDTYPE =
  (
    AUTH_IDTYPE_UNKNOWN	= 0,
    AUTH_IDTYPE_STEAM	= 1,
    AUTH_IDTYPE_VALVE	= 2,
    AUTH_IDTYPE_LOCAL	= 3
  );
  TAuthIDType = AUTH_IDTYPE;

const
  VOICE_MAX_PLAYERS = MAX_CLIENTS;
  VOICE_MAX_PLAYERS_DW = (VOICE_MAX_PLAYERS div MAX_CLIENTS) + not not (VOICE_MAX_PLAYERS and $1F);

  MAX_PHYSENTS = 600; 		  		// Must have room for all entities in the world.
  MAX_MOVEENTS = 64;
  MAX_CLIP_PLANES = 5;

  PM_NORMAL = $00000000;
  PM_STUDIO_IGNORE = $00000001;	// Skip studio models
  PM_STUDIO_BOX	= $00000002;	// Use boxes for non-complex studio models (even in traceline)
  PM_GLASS_IGNORE = $00000004;	// Ignore entities with non-normal rendermode
  PM_WORLD_ONLY = $00000008;	// Only trace against the world

  PM_TRACELINE_PHYSENTSONLY = 0;
  PM_TRACELINE_ANYVISIBLE = 1;

  MAX_PHYSINFO_STRING = 256;

  CTEXTURESMAX = 1024;	// max number of textures loaded
  CBTEXTURENAMEMAX = 17;	// only load first n chars of name

  CHAR_TEX_CONCRETE = 'C';	// texture types
  CHAR_TEX_METAL = 'M';
  CHAR_TEX_DIRT = 'D';
  CHAR_TEX_VENT = 'V';
  CHAR_TEX_GRATE = 'G';
  CHAR_TEX_TILE = 'T';
  CHAR_TEX_SLOSH = 'S';
  CHAR_TEX_WOOD = 'W';
  CHAR_TEX_COMPUTER = 'P';
  CHAR_TEX_GRASS = 'X';
  CHAR_TEX_GLASS = 'Y';
  CHAR_TEX_FLESH = 'F';
  CHAR_TEX_SNOW = 'N';

  PM_DEAD_VIEWHEIGHT = -8;

  OBS_NONE = 0;
  OBS_CHASE_LOCKED = 1;
  OBS_CHASE_FREE = 2;
  OBS_ROAMING = 3;
  OBS_IN_EYE = 4;
  OBS_MAP_FREE = 5;
  OBS_MAP_CHASE = 6;

  STEP_CONCRETE = 0;
  STEP_METAL = 1;
  STEP_DIRT = 2;
  STEP_VENT = 3;
  STEP_GRATE = 4;
  STEP_TILE = 5;
  STEP_SLOSH = 6;
  STEP_WADE = 7;
  STEP_LADDER = 8;
  STEP_SNOW = 9;

  WJ_HEIGHT = 8;
  STOP_EPSILON = 0.1;
  MAX_CLIMB_SPEED = 200;
  PLAYER_DUCKING_MULTIPLIER = 0.333;
  PM_CHECKSTUCK_MINTIME = 0.05;	// Don't check again too quickly.

  PLAYER_LONGJUMP_SPEED: Single = 350.0;	// how fast we longjump

  // Ducking time
  TIME_TO_DUCK  = 0.4;
  STUCK_MOVEUP = 1;

  PM_VEC_DUCK_HULL_MIN = -18;
  PM_VEC_HULL_MIN = -36;
  PM_VEC_DUCK_VIEW = 12;
  PM_VEC_VIEW = 17;

  PM_PLAYER_MAX_SAFE_FALL_SPEED = 580;	// approx 20 feet
  PM_PLAYER_MIN_BOUNCE_SPEED = 350;
  PM_PLAYER_FALL_PUNCH_THRESHHOLD = 250;	// won't punch player's screen/make scrape noise unless player falling at least this fast.

  // Only allow bunny jumping up to 1.2x server / player maxspeed setting
  BUNNYJUMP_MAX_SPEED_FACTOR: Single = 1.2;

const
  MAX_BUY_WEAPON_PRIMARY   = 13;
  MAX_BUY_WEAPON_SECONDARY = 3;

	BOT_PROGGRESS_DRAW = 0;	// draw status bar progress
	BOT_PROGGRESS_START = 1;	// init status bar progress
	BOT_PROGGRESS_HIDE = 2;		// hide status bar progress

const
  UNDEFINED_COUNT     = $FFFF;
  MAX_PLACES_PER_MAP  = 64;
  UNDEFINED_SUBJECT   = -1;
  COUNT_MANY          = 4; // equal to or greater than this is "many"

type
	BombState =
	(
		MOVING,		// being carried by a Terrorist
		LOOSE,		// loose on the ground somewhere
		PLANTED,	// planted and ticking
		DEFUSED,	// the bomb has been defused
		EXPLODED	// the bomb has exploded
	);
  TBombState = BombState;

const
  NODE_INVALID_EMPTY = -1;

  PATH_TRAVERSABLE_EMPTY = 0;
  PATH_TRAVERSABLE_SLOPE = 1;
  PATH_TRAVERSABLE_STEP = 2;
  PATH_TRAVERSABLE_STEPJUMPABLE = 3;

  MAX_NODES        = 100;
  MAX_HOSTAGES     = 12;
  MAX_HOSTAGES_NAV = 20;

  HOSTAGE_STEPSIZE: Single = 26.0;
  HOSTAGE_STEPSIZE_DEFAULT: Single = 18.0;

  VEC_HOSTAGE_VIEW: TVectorArray = (0, 0, 12);
  VEC_HOSTAGE_HULL_MIN: TVectorArray = (-10, -10, 0);
  VEC_HOSTAGE_HULL_MAX: TVectorArray = (10, 10, 62);

  VEC_HOSTAGE_CROUCH: TVectorArray = (10, 10, 30);
  RESCUE_HOSTAGES_RADIUS: Single = 256.0;				// rescue zones from legacy info_*

type
  HostageChatterType =
  (
    HOSTAGE_CHATTER_START_FOLLOW = 0,
    HOSTAGE_CHATTER_STOP_FOLLOW,
    HOSTAGE_CHATTER_INTIMIDATED,
    HOSTAGE_CHATTER_PAIN,
    HOSTAGE_CHATTER_SCARED_OF_GUNFIRE,
    HOSTAGE_CHATTER_SCARED_OF_MURDER,
    HOSTAGE_CHATTER_LOOK_OUT,
    HOSTAGE_CHATTER_PLEASE_RESCUE_ME,
    HOSTAGE_CHATTER_SEE_RESCUE_ZONE,
    HOSTAGE_CHATTER_IMPATIENT_FOR_RESCUE,
    HOSTAGE_CHATTER_CTS_WIN ,
    HOSTAGE_CHATTER_TERRORISTS_WIN,
    HOSTAGE_CHATTER_RESCUED,
    HOSTAGE_CHATTER_WARN_NEARBY,
    HOSTAGE_CHATTER_WARN_SPOTTED,
    HOSTAGE_CHATTER_CALL_TO_RESCUER,
    HOSTAGE_CHATTER_RETREAT,
    HOSTAGE_CHATTER_COUGH,
    HOSTAGE_CHATTER_BLINDED,
    HOSTAGE_CHATTER_SAW_HE_GRENADE,
    HOSTAGE_CHATTER_DEATH_CRY,
    NUM_HOSTAGE_CHATTER_TYPES
  );
  THostageChatterType = HostageChatterType;

type
  Activity_s =
  (
    ACT_INVALID = -1,

    ACT_RESET = 0,			// Set m_Activity to this invalid value to force a reset to m_IdealActivity
    ACT_IDLE,
    ACT_GUARD,
    ACT_WALK,
    ACT_RUN,
    ACT_FLY,				// Fly (and flap if appropriate)
    ACT_SWIM,
    ACT_HOP,				// vertical jump
    ACT_LEAP,				// long forward jump
    ACT_FALL,
    ACT_LAND,
    ACT_STRAFE_LEFT,
    ACT_STRAFE_RIGHT,
    ACT_ROLL_LEFT,			// tuck and roll, left
    ACT_ROLL_RIGHT,			// tuck and roll, right
    ACT_TURN_LEFT,			// turn quickly left (stationary)
    ACT_TURN_RIGHT,			// turn quickly right (stationary)
    ACT_CROUCH,				// the act of crouching down from a standing position
    ACT_CROUCHIDLE,			// holding body in crouched position (loops)
    ACT_STAND,				// the act of standing from a crouched position
    ACT_USE,
    ACT_SIGNAL1,
    ACT_SIGNAL2,
    ACT_SIGNAL3,
    ACT_TWITCH,
    ACT_COWER,
    ACT_SMALL_FLINCH,
    ACT_BIG_FLINCH,
    ACT_RANGE_ATTACK1,
    ACT_RANGE_ATTACK2,
    ACT_MELEE_ATTACK1,
    ACT_MELEE_ATTACK2,
    ACT_RELOAD,
    ACT_ARM,				// pull out gun, for instance
    ACT_DISARM,				// reholster gun
    ACT_EAT,				// monster chowing on a large food item (loop)
    ACT_DIESIMPLE,
    ACT_DIEBACKWARD,
    ACT_DIEFORWARD,
    ACT_DIEVIOLENT,
    ACT_BARNACLE_HIT,		// barnacle tongue hits a monster
    ACT_BARNACLE_PULL,		// barnacle is lifting the monster ( loop )
    ACT_BARNACLE_CHOMP,		// barnacle latches on to the monster
    ACT_BARNACLE_CHEW,		// barnacle is holding the monster in its mouth ( loop )
    ACT_SLEEP,
    ACT_INSPECT_FLOOR,		// for active idles, look at something on or near the floor
    ACT_INSPECT_WALL,		// for active idles, look at something directly ahead of you ( doesn't HAVE to be a wall or on a wall )
    ACT_IDLE_ANGRY,			// alternate idle animation in which the monster is clearly agitated. (loop)
    ACT_WALK_HURT,			// limp  (loop)
    ACT_RUN_HURT,			// limp  (loop)
    ACT_HOVER,				// Idle while in flight
    ACT_GLIDE,				// Fly (don't flap)
    ACT_FLY_LEFT,			// Turn left in flight
    ACT_FLY_RIGHT,			// Turn right in flight
    ACT_DETECT_SCENT,		// this means the monster smells a scent carried by the air
    ACT_SNIFF,				// this is the act of actually sniffing an item in front of the monster
    ACT_BITE,				// some large monsters can eat small things in one bite. This plays one time, EAT loops.
    ACT_THREAT_DISPLAY,		// without attacking, monster demonstrates that it is angry. (Yell, stick out chest, etc )
    ACT_FEAR_DISPLAY,		// monster just saw something that it is afraid of
    ACT_EXCITED,			// for some reason, monster is excited. Sees something he really likes to eat, or whatever.
    ACT_SPECIAL_ATTACK1,	// very monster specific special attacks.
    ACT_SPECIAL_ATTACK2,
    ACT_COMBAT_IDLE,		// agitated idle.
    ACT_WALK_SCARED,
    ACT_RUN_SCARED,
    ACT_VICTORY_DANCE,		// killed a player, do a victory dance.
    ACT_DIE_HEADSHOT,		// die, hit in head.
    ACT_DIE_CHESTSHOT,		// die, hit in chest
    ACT_DIE_GUTSHOT,		// die, hit in gut
    ACT_DIE_BACKSHOT,		// die, hit in back
    ACT_FLINCH_HEAD,
    ACT_FLINCH_CHEST,
    ACT_FLINCH_STOMACH,
    ACT_FLINCH_LEFTARM,
    ACT_FLINCH_RIGHTARM,
    ACT_FLINCH_LEFTLEG,
    ACT_FLINCH_RIGHTLEG,
    ACT_FLINCH,
    ACT_LARGE_FLINCH,
    ACT_HOLDBOMB,
    ACT_IDLE_FIDGET,
    ACT_IDLE_SCARED,
    ACT_IDLE_SCARED_FIDGET,
    ACT_FOLLOW_IDLE,
    ACT_FOLLOW_IDLE_FIDGET,
    ACT_FOLLOW_IDLE_SCARED,
    ACT_FOLLOW_IDLE_SCARED_FIDGET,
    ACT_CROUCH_IDLE,
    ACT_CROUCH_IDLE_FIDGET,
    ACT_CROUCH_IDLE_SCARED,
    ACT_CROUCH_IDLE_SCARED_FIDGET,
    ACT_CROUCH_WALK,
    ACT_CROUCH_WALK_SCARED,
    ACT_CROUCH_DIE,
    ACT_WALK_BACK,
    ACT_IDLE_SNEAKY,
    ACT_IDLE_SNEAKY_FIDGET,
    ACT_WALK_SNEAKY,
    ACT_WAVE,
    ACT_YES,
    ACT_NO
  );
  Activity = Activity_s;
  TActivity = Activity;

const
	ITBD_PARALLYZE = 0;
	ITBD_NERVE_GAS = 1;
	ITBD_POISON = 2;
	ITBD_RADIATION = 3;
	ITBD_DROWN_RECOVER = 4;
	ITBD_ACID = 5;
	ITBD_SLOW_BURN = 6;
	ITBD_SLOW_FREEZE = 7;
	ITBD_END = 8;

type
  MONSTERSTATE =
  (
    MONSTERSTATE_NONE = 0,
    MONSTERSTATE_IDLE,
    MONSTERSTATE_COMBAT,
    MONSTERSTATE_ALERT,
    MONSTERSTATE_HUNT,
    MONSTERSTATE_PRONE,
    MONSTERSTATE_SCRIPT,
    MONSTERSTATE_PLAYDEAD,
    MONSTERSTATE_DEAD
  );
  TMonsterState = MONSTERSTATE;

const
  SF_WALL_TOOGLE_START_OFF = 1 shl 0;
  SF_WALL_TOOGLE_NOTSOLID = 1 shl 3;

  SF_CONVEYOR_VISUAL = 1 shl 0;
  SF_CONVEYOR_NOTSOLID = 1 shl 1;

  SF_BRUSH_ROTATE_START_ON = 1 shl 0;
  SF_BRUSH_ROTATE_BACKWARDS = 1 shl 1;
  SF_BRUSH_ROTATE_Z_AXIS = 1 shl 2;
  SF_BRUSH_ROTATE_X_AXIS = 1 shl 3;
  SF_BRUSH_ACCDCC = 1 shl 4; // brush should accelerate and decelerate when toggled
  SF_BRUSH_HURT = 1 shl 5; // rotating brush that inflicts pain based on rotation speed
  SF_BRUSH_ROTATE_NOT_SOLID = 1 shl 6; // some special rotating objects are not solid.
  SF_BRUSH_ROTATE_SMALLRADIUS = 1 shl 7;
  SF_BRUSH_ROTATE_MEDIUMRADIUS = 1 shl 8;
  SF_BRUSH_ROTATE_LARGERADIUS = 1 shl 9;

  MAX_FANPITCH: Integer = 100;
  MIN_FANPITCH: Integer = 30;

  SF_PENDULUM_START_ON = 1 shl 0;
  SF_PENDULUM_SWING = 1 shl 1; // spawnflag that makes a pendulum a rope swing
  SF_PENDULUM_PASSABLE = 1 shl 3;
  SF_PENDULUM_AUTO_RETURN = 1 shl 4;

  SF_ROTBUTTON_NOTSOLID = 1 shl 0;
  SF_ROTBUTTON_BACKWARDS = 1 shl 1;

  // Make this button behave like a door (HACKHACK)
  // This will disable use and make the button solid
  // rotating buttons were made SOLID_NOT by default since their were some
  // collision problems with them...
  SF_MOMENTARY_DOOR = 1 shl 0;

  SF_SPARK_TOOGLE = 1 shl 5;
  SF_SPARK_IF_OFF = 1 shl 6;

  SF_BTARGET_USE = 1 shl 0;
  SF_BTARGET_ON = 1 shl 1;

  SF_BUTTON_DONTMOVE = 1 shl 0;
  SF_BUTTON_TOGGLE = 1 shl 5; // button stays pushed until reactivated
  SF_BUTTON_SPARK_IF_OFF = 1 shl 6; // button sparks in OFF state
  SF_BUTTON_TOUCH_ONLY = 1 shl 8; // button only fires as a result of USE key.

  // MultiSouce
  MAX_MS_TARGETS = 32; // maximum number of targets a single multisource entity may be assigned.
  SF_MULTI_INIT = 1 shl 0;

  SF_WORLD_DARK = 1 shl 0; // Fade from black at startup
  SF_WORLD_TITLE = 1 shl 1; // Display game title at startup
  SF_WORLD_FORCETEAM = 1 shl 2; // Force teams

  MAX_WEAPON_SLOTS: Integer = 5;		// hud item selection slots
  MAX_ITEM_TYPES: Integer = 6;		// hud item selection slots
  MAX_AMMO_SLOTS: Integer = 32;	// not really slots
  MAX_ITEMS: Integer = 4;		// hard coded item types

  DEFAULT_FOV: Integer = 90;	// the default field of view

  HIDEHUD_WEAPONS = 1 shl 0;
  HIDEHUD_FLASHLIGHT = 1 shl 1;
  HIDEHUD_ALL = 1 shl 2;
  HIDEHUD_HEALTH = 1 shl 3;
  HIDEHUD_TIMER = 1 shl 4;
  HIDEHUD_MONEY = 1 shl 5;
  HIDEHUD_CROSSHAIR = 1 shl 6;
  HIDEHUD_OBSERVER_CROSSHAIR = 1 shl 7;

  STATUSICON_HIDE  = 0;
  STATUSICON_SHOW  = 1;
  STATUSICON_FLASH = 2;

  HUD_PRINTNOTIFY  = 1;
  HUD_PRINTCONSOLE = 2;
  HUD_PRINTTALK    = 3;
  HUD_PRINTCENTER  = 4;
  HUD_PRINTRADIO   = 5;

  STATUS_NIGHTVISION_ON  = 1;
  STATUS_NIGHTVISION_OFF = 0;

  ITEM_STATUS_NIGHTVISION = 1 shl 0;
  ITEM_STATUS_DEFUSER     = 1 shl 1;

  SCORE_STATUS_DEAD = 1 shl 0;
  SCORE_STATUS_BOMB = 1 shl 1;
  SCORE_STATUS_VIP  = 1 shl 2;

  // player data iuser3
  PLAYER_CAN_SHOOT        = 1 shl 0;
  PLAYER_FREEZE_TIME_OVER = 1 shl 1;
  PLAYER_IN_BOMB_ZONE     = 1 shl 2;
  PLAYER_HOLDING_SHIELD   = 1 shl 3;

  MENU_KEY_1 = 1 shl 0;
  MENU_KEY_2 = 1 shl 1;
  MENU_KEY_3 = 1 shl 2;
  MENU_KEY_4 = 1 shl 3;
  MENU_KEY_5 = 1 shl 4;
  MENU_KEY_6 = 1 shl 5;
  MENU_KEY_7 = 1 shl 6;
  MENU_KEY_8 = 1 shl 7;
  MENU_KEY_9 = 1 shl 8;
  MENU_KEY_0 = 1 shl 9;

  WEAPON_SUIT = 31;
  WEAPON_ALLWEAPONS = not (1 shl WEAPON_SUIT);

type
  // custom enum
  VGUIMenu =
  (
    VGUI_Menu_Team = 2,
    VGUI_Menu_MapBriefing = 4,

    VGUI_Menu_Class_T = 26,
    VGUI_Menu_Class_CT,
    VGUI_Menu_Buy,
    VGUI_Menu_Buy_Pistol,
    VGUI_Menu_Buy_ShotGun,
    VGUI_Menu_Buy_Rifle,
    VGUI_Menu_Buy_SubMachineGun,
    VGUI_Menu_Buy_MachineGun,
    VGUI_Menu_Buy_Item
  );
  TVGUIMenu = VGUIMenu;

  // custom enum
  VGUIMenuSlot =
  (
    VGUI_MenuSlot_Buy_Pistol = 1,
    VGUI_MenuSlot_Buy_ShotGun,
    VGUI_MenuSlot_Buy_SubMachineGun,
    VGUI_MenuSlot_Buy_Rifle,
    VGUI_MenuSlot_Buy_MachineGun,
    VGUI_MenuSlot_Buy_PrimAmmo,
    VGUI_MenuSlot_Buy_SecAmmo,
    VGUI_MenuSlot_Buy_Item
  );
  TVGUIMenuSlot = VGUIMenuSlot;

  // custom enum
  ChooseTeamMenuSlot =
  (
    MENU_SLOT_TEAM_UNDEFINED = -1,

    MENU_SLOT_TEAM_TERRORIST = 1,
    MENU_SLOT_TEAM_CT,
    MENU_SLOT_TEAM_VIP,

    MENU_SLOT_TEAM_RANDOM = 5,
    MENU_SLOT_TEAM_SPECT
  );

  // custom enum
  BuyItemMenuSlot =
  (
    MENU_SLOT_ITEM_VEST = 1,
    MENU_SLOT_ITEM_VESTHELM,
    MENU_SLOT_ITEM_FLASHGREN,
    MENU_SLOT_ITEM_HEGREN,
    MENU_SLOT_ITEM_SMOKEGREN,
    MENU_SLOT_ITEM_NVG,
    MENU_SLOT_ITEM_DEFUSEKIT,
    MENU_SLOT_ITEM_SHIELD
  );

const
  CS_NUM_SKIN				= 4;
  CZ_NUM_SKIN				= 5;

  FIELD_ORIGIN0			= 0;
  FIELD_ORIGIN1			= 1;
  FIELD_ORIGIN2			= 2;

  FIELD_ANGLES0			= 3;
  FIELD_ANGLES1			= 4;
  FIELD_ANGLES2			= 5;

  CUSTOMFIELD_ORIGIN0		= 0;
  CUSTOMFIELD_ORIGIN1		= 1;
  CUSTOMFIELD_ORIGIN2		= 2;

  CUSTOMFIELD_ANGLES0		= 3;
  CUSTOMFIELD_ANGLES1		= 4;
  CUSTOMFIELD_ANGLES2		= 5;

  CUSTOMFIELD_SKIN		  = 6;
  CUSTOMFIELD_SEQUENCE	= 7;
  CUSTOMFIELD_ANIMTIME	= 8;

  MAX_ENTITIES: Integer = 1380;

type
  decal_e =
  (
    DECAL_GUNSHOT1 = 0,
    DECAL_GUNSHOT2,
    DECAL_GUNSHOT3,
    DECAL_GUNSHOT4,
    DECAL_GUNSHOT5,
    DECAL_LAMBDA1,
    DECAL_LAMBDA2,
    DECAL_LAMBDA3,
    DECAL_LAMBDA4,
    DECAL_LAMBDA5,
    DECAL_LAMBDA6,
    DECAL_SCORCH1,
    DECAL_SCORCH2,
    DECAL_BLOOD1,
    DECAL_BLOOD2,
    DECAL_BLOOD3,
    DECAL_BLOOD4,
    DECAL_BLOOD5,
    DECAL_BLOOD6,
    DECAL_YBLOOD1,
    DECAL_YBLOOD2,
    DECAL_YBLOOD3,
    DECAL_YBLOOD4,
    DECAL_YBLOOD5,
    DECAL_YBLOOD6,
    DECAL_GLASSBREAK1,
    DECAL_GLASSBREAK2,
    DECAL_GLASSBREAK3,
    DECAL_BIGSHOT1,
    DECAL_BIGSHOT2,
    DECAL_BIGSHOT3,
    DECAL_BIGSHOT4,
    DECAL_BIGSHOT5,
    DECAL_SPIT1,
    DECAL_SPIT2,
    DECAL_BPROOF1,      // Bulletproof glass decal
    DECAL_GARGSTOMP1,   // Gargantua stomp crack
    DECAL_SMALLSCORCH1, // Small scorch mark
    DECAL_SMALLSCORCH2, // Small scorch mark
    DECAL_SMALLSCORCH3, // Small scorch mark
    DECAL_MOMMABIRTH,   // Big momma birth splatter
    DECAL_MOMMASPLAT,
    DECAL_END
  );
  TDecal = decal_e;

const
  DOOR_SENTENCEWAIT: Single = 6.0;
  DOOR_SOUNDWAIT: Single = 3.0;
  BUTTON_SOUNDWAIT: Single = 0.5;

  SF_DOOR_START_OPEN          = 1 shl 0;
  SF_DOOR_PASSABLE            = 1 shl 3;
  SF_DOOR_NO_AUTO_RETURN      = 1 shl 5;
  SF_DOOR_USE_ONLY            = 1 shl 8;  // door must be opened by player's use button.
  SF_DOOR_TOUCH_ONLY_CLIENTS  = 1 shl 10; // Only clients can touch
  SF_DOOR_ACTUALLY_WATER      = 1 shl 31; // This bit marks that func_door are actually func_water

  SF_SPRITE_STARTON   = 1 shl 0;
  SF_SPRITE_ONCE      = 1 shl 1;
  SF_SPRITE_TEMPORARY = 1 shl 15;

  SF_BEAM_STARTON    = 1 shl 0;
  SF_BEAM_TOGGLE     = 1 shl 1;
  SF_BEAM_RANDOM     = 1 shl 2;
  SF_BEAM_RING       = 1 shl 3;
  SF_BEAM_SPARKSTART = 1 shl 4;
  SF_BEAM_SPARKEND   = 1 shl 5;
  SF_BEAM_DECALS     = 1 shl 6;
  SF_BEAM_SHADEIN    = 1 shl 7;
  SF_BEAM_SHADEOUT   = 1 shl 8;
  SF_BEAM_TEMPORARY  = 1 shl 15;

  SF_BUBBLES_STARTOFF = 1 shl 0;

  SF_GIBSHOOTER_REPEATABLE = 1 shl 0; // Allows a gibshooter to be refired

  SF_BLOOD_RANDOM = 1 shl 0;
  SF_BLOOD_STREAM = 1 shl 1;
  SF_BLOOD_PLAYER = 1 shl 2;
  SF_BLOOD_DECAL = 1 shl 3;

  SF_SHAKE_EVERYONE = 1 shl 0; // Don't check radius
  SF_SHAKE_DISRUPT = 1 shl 1; // Disrupt controls
  SF_SHAKE_INAIR = 1 shl 2; // Shake players in air

  SF_FADE_IN       = 1 shl 0; // Fade in, not out
  SF_FADE_MODULATE = 1 shl 1; // Modulate, don't blend
  SF_FADE_ONLYONE  = 1 shl 2;

  SF_MESSAGE_ONCE = 1 shl 0; // Fade in, not out
  SF_MESSAGE_ALL  = 1 shl 1; // Send to all clients

  SF_FUNNEL_REVERSE = 1 shl 0; // Funnel effect repels particles instead of attracting them

  SF_ENVEXPLOSION_NODAMAGE   = 1 shl 0; // when set, ENV_EXPLOSION will not actually inflict damage
  SF_ENVEXPLOSION_REPEATABLE = 1 shl 1; // can this entity be refired?
  SF_ENVEXPLOSION_NOFIREBALL = 1 shl 2; // don't draw the fireball
  SF_ENVEXPLOSION_NOSMOKE    = 1 shl 3; // don't draw the smoke
  SF_ENVEXPLOSION_NODECAL    = 1 shl 4; // don't make a scorch mark
  SF_ENVEXPLOSION_NOSPARKS   = 1 shl 5; // don't make a scorch mark

type
  hash_types_e =
  (
    CLASSNAME
  );
  THashTypes = hash_types_e;

  // Things that toggle (buttons/triggers/doors) need this
  TOGGLE_STATE =
  (
    TS_AT_TOP,
    TS_AT_BOTTOM,
    TS_GOING_UP,
    TS_GOING_DOWN
  );
  TToggleState = TOGGLE_STATE;

  USE_TYPE =
  (
    USE_OFF,
    USE_ON,
    USE_SET,
    USE_TOGGLE
  );
  TUseType = USE_TYPE;

  IGNORE_MONSTERS =
  (
    ignore_monsters_ = 1,
    dont_ignore_monsters = 0,
    missile = 2
  );
  TIgnoreMonsters = IGNORE_MONSTERS;

  IGNORE_GLASS =
  (
    ignore_glass_ = 1,
    dont_ignore_glass = 0
  );

const
  point_hull = 0;
  human_hull = 1;
  large_hull = 2;
  head_hull = 3;

type
  Explosions =
  (
    expRandom = 0,
    expDirected
  );
  TExplosions = Explosions;

  Materials =
  (
    matGlass = 0,
    matWood,
    matMetal,
    matFlesh,
    matCinderBlock,
    matCeilingTile,
    matComputer,
    matUnbreakableGlass,
    matRocks,
    matNone,
    matLastMaterial
  );
  TMaterials = Materials;

const
  // this many shards spawned when breakable objects break
  NUM_SHARDS = 6;      // this many shards spawned when breakable objects break

  // func breakable
  SF_BREAK_TRIGGER_ONLY = 1 shl 0; // may only be broken by trigger
  SF_BREAK_TOUCH        = 1 shl 1; // can be 'crashed through' by running player (plate glass)
  SF_BREAK_PRESSURE     = 1 shl 2; // can be broken by a player standing on it
  SF_BREAK_CROWBAR      = 1 shl 8; // instant break if hit with crowbar

  SF_PUSH_BREAKABLE = 1 shl 7; // func_pushable (it's also func_breakable, so don't collide with those flags)

type
  TANKBULLET =
  (
    TANK_BULLET_NONE = 0,	// Custom damage
    TANK_BULLET_9MM,		// env_laser (duration is 0.5 rate of fire)
    TANK_BULLET_MP5,		// rockets
    TANK_BULLET_12MM		// explosion?
  );

const
  SF_TANK_ACTIVE      = 1 shl 0;
  SF_TANK_PLAYER      = 1 shl 1;
  SF_TANK_HUMANS      = 1 shl 2;
  SF_TANK_ALIENS      = 1 shl 3;
  SF_TANK_LINEOFSIGHT = 1 shl 4;
  SF_TANK_CANCONTROL  = 1 shl 5;

  SF_TANK_SOUNDON = 1 shl 15;

  MAX_RULE_BUFFER  = 1024;
  MAX_VOTE_MAPS = 100;
  MAX_VIP_QUEUES = 5;

  MAX_MOTD_CHUNK = 60;
  MAX_MOTD_LENGTH = 1536; // (MAX_MOTD_CHUNK * 4)

  ITEM_RESPAWN_TIME = 30;
  WEAPON_RESPAWN_TIME = 20;
  AMMO_RESPAWN_TIME = 20;
  ROUND_RESPAWN_TIME = 20;
  ROUND_BEGIN_DELAY = 5; // delay before beginning new round

  // longest the intermission can last, in seconds
  MAX_INTERMISSION_TIME = 120;

  // when we are within this close to running out of entities, items
  // marked with the ITEM_FLAG_LIMITINWORLD will delay their respawn
  ENTITY_INTOLERANCE = 100;

  // custom enum
  WINNER_NONE = 0;
  WINNER_DRAW = 1;

	WINSTATUS_CTS = 1;
	WINSTATUS_TERRORISTS = 2;
	WINSTATUS_DRAW = 3;

type
  // custom enum
  // used for EndRoundMessage() logged messages
  ScenarioEventEndRound =
  (
    ROUND_NONE,
    ROUND_TARGET_BOMB,
    ROUND_VIP_ESCAPED,
    ROUND_VIP_ASSASSINATED,
    ROUND_TERRORISTS_ESCAPED,
    ROUND_CTS_PREVENT_ESCAPE,
    ROUND_ESCAPING_TERRORISTS_NEUTRALIZED,
    ROUND_BOMB_DEFUSED,
    ROUND_CTS_WIN,
    ROUND_TERRORISTS_WIN,
    ROUND_END_DRAW,
    ROUND_ALL_HOSTAGES_RESCUED,
    ROUND_TARGET_SAVED,
    ROUND_HOSTAGE_NOT_RESCUED,
    ROUND_TERRORISTS_NOT_ESCAPED,
    ROUND_VIP_NOT_ESCAPED,
    ROUND_GAME_COMMENCE,
    ROUND_GAME_RESTART,
    ROUND_GAME_OVER
  );
  TScenarioEventEndRound = ScenarioEventEndRound;

  RewardRules =
  (
    RR_CTS_WIN,
    RR_TERRORISTS_WIN,
    RR_TARGET_BOMB,
    RR_VIP_ESCAPED,
    RR_VIP_ASSASSINATED,
    RR_TERRORISTS_ESCAPED,
    RR_CTS_PREVENT_ESCAPE,
    RR_ESCAPING_TERRORISTS_NEUTRALIZED,
    RR_BOMB_DEFUSED,
    RR_BOMB_PLANTED,
    RR_BOMB_EXPLODED,
    RR_ALL_HOSTAGES_RESCUED,
    RR_TARGET_BOMB_SAVED,
    RR_HOSTAGE_NOT_RESCUED,
    RR_VIP_NOT_ESCAPED,
    RR_LOSER_BONUS_DEFAULT,
    RR_LOSER_BONUS_MIN,
    RR_LOSER_BONUS_MAX,
    RR_LOSER_BONUS_ADD,
    RR_RESCUED_HOSTAGE,
    RR_TOOK_HOSTAGE_ACC,
    RR_TOOK_HOSTAGE,
    RR_END
  );
  TRewardRules = RewardRules;

  // custom enum
  RewardAccount =
  (
    REWARD_TARGET_BOMB              = 3500,
    REWARD_VIP_ESCAPED              = 3500,
    REWARD_VIP_ASSASSINATED         = 3250,
    REWARD_TERRORISTS_ESCAPED       = 3150,
    REWARD_CTS_PREVENT_ESCAPE       = 3500,
    REWARD_ESCAPING_TERRORISTS_NEUTRALIZED = 3250,
    REWARD_BOMB_DEFUSED             = 3250,
    REWARD_BOMB_PLANTED             = 800,
    REWARD_BOMB_EXPLODED            = 3250,
    REWARD_CTS_WIN                  = 3000,
    REWARD_TERRORISTS_WIN           = 3000,
    REWARD_ALL_HOSTAGES_RESCUED     = 2500,

    // the end round was by the expiration time
    REWARD_TARGET_BOMB_SAVED        = 3250,
    REWARD_HOSTAGE_NOT_RESCUED      = 3250,
    REWARD_VIP_NOT_ESCAPED          = 3250,

    // loser bonus
    REWARD_LOSER_BONUS_DEFAULT      = 1400,
    REWARD_LOSER_BONUS_MIN          = 1500,
    REWARD_LOSER_BONUS_MAX          = 3000,
    REWARD_LOSER_BONUS_ADD          = 500,

    REWARD_RESCUED_HOSTAGE          = 750,
    REWARD_KILLED_ENEMY             = 300,
    REWARD_KILLED_VIP               = 2500,
    REWARD_VIP_HAVE_SELF_RESCUED    = 2500,

    REWARD_TAKEN_HOSTAGE            = 1000,
    REWARD_TOOK_HOSTAGE_ACC         = 100,
    REWARD_TOOK_HOSTAGE             = 150
  );
  TRewardAccount = RewardAccount;

  // custom enum
  PaybackForBadThing =
  (
    PAYBACK_FOR_KILLED_TEAMMATES    = -3300
  );
  TPaybackForBadThing = PaybackForBadThing;

  // custom enum
  InfoMapBuyParam =
  (
    BUYING_EVERYONE = 0,
    BUYING_ONLY_CTS,
    BUYING_ONLY_TERRORISTS,
    BUYING_NO_ONE
  );
  TInfoMapBuyParam = InfoMapBuyParam;

const
  // weapon respawning return codes
  GR_NONE = 0;

  GR_WEAPON_RESPAWN_YES = 1;
  GR_WEAPON_RESPAWN_NO = 2;

  GR_AMMO_RESPAWN_YES = 3;
  GR_AMMO_RESPAWN_NO = 4;

  GR_ITEM_RESPAWN_YES = 5;
  GR_ITEM_RESPAWN_NO = 6;

  GR_PLR_DROP_GUN_ALL = 7;
  GR_PLR_DROP_GUN_ACTIVE = 8;
  GR_PLR_DROP_GUN_NO = 9;

  GR_PLR_DROP_AMMO_ALL = 10;
  GR_PLR_DROP_AMMO_ACTIVE = 11;
  GR_PLR_DROP_AMMO_NO = 12;

  // custom enum
  SCENARIO_BLOCK_TIME_EXPRIRED      = 1 shl 0; // flag "a"
  SCENARIO_BLOCK_NEED_PLAYERS       = 1 shl 1; // flag "b"
  SCENARIO_BLOCK_VIP_ESCAPE         = 1 shl 2; // flag "c"
  SCENARIO_BLOCK_PRISON_ESCAPE      = 1 shl 3; // flag "d"
  SCENARIO_BLOCK_BOMB               = 1 shl 4; // flag "e"
  SCENARIO_BLOCK_TEAM_EXTERMINATION = 1 shl 5; // flag "f"
  SCENARIO_BLOCK_HOSTAGE_RESCUE     = 1 shl 6; // flag "g"

  // Player relationship return codes
  GR_NOTTEAMMATE = 0;
  GR_TEAMMATE = 1;
  GR_ENEMY = 2;
  GR_ALLY = 3;
  GR_NEUTRAL = 4;

  DHF_ROUND_STARTED     = 1 shl 1;
  DHF_HOSTAGE_SEEN_FAR  = 1 shl 2;
  DHF_HOSTAGE_SEEN_NEAR = 1 shl 3;
  DHF_HOSTAGE_USED      = 1 shl 4;
  DHF_HOSTAGE_INJURED   = 1 shl 5;
  DHF_HOSTAGE_KILLED    = 1 shl 6;
  DHF_FRIEND_SEEN       = 1 shl 7;
  DHF_ENEMY_SEEN        = 1 shl 8;
  DHF_FRIEND_INJURED    = 1 shl 9;
  DHF_FRIEND_KILLED     = 1 shl 10;
  DHF_ENEMY_KILLED      = 1 shl 11;
  DHF_BOMB_RETRIEVED    = 1 shl 12;
  DHF_AMMO_EXHAUSTED    = 1 shl 15;
  DHF_IN_TARGET_ZONE    = 1 shl 16;
  DHF_IN_RESCUE_ZONE    = 1 shl 17;
  DHF_IN_ESCAPE_ZONE    = 1 shl 18;
  DHF_IN_VIPSAFETY_ZONE = 1 shl 19;
  DHF_NIGHTVISION       = 1 shl 20;
  DHF_HOSTAGE_CTMOVE    = 1 shl 21;
  DHF_SPEC_DUCK         = 1 shl 22;

  DHM_ROUND_CLEAR       = DHF_ROUND_STARTED or DHF_HOSTAGE_KILLED or
  DHF_FRIEND_KILLED or DHF_BOMB_RETRIEVED;

  DHM_CONNECT_CLEAR     = DHF_HOSTAGE_SEEN_FAR or DHF_HOSTAGE_SEEN_NEAR or
    DHF_HOSTAGE_USED or DHF_HOSTAGE_INJURED or DHF_FRIEND_SEEN or
    DHF_ENEMY_SEEN or DHF_FRIEND_INJURED or DHF_ENEMY_KILLED or
    DHF_AMMO_EXHAUSTED or DHF_IN_TARGET_ZONE or DHF_IN_RESCUE_ZONE or
    DHF_IN_ESCAPE_ZONE or DHF_IN_VIPSAFETY_ZONE or DHF_HOSTAGE_CTMOVE or
    DHF_SPEC_DUCK;

type
  ItemRestType =
  (
    ITEM_TYPE_BUYING,  // when a player buying items
    ITEM_TYPE_TOUCHED, // when the player touches with a weaponbox or armoury_entity
    ITEM_TYPE_EQUIPPED // when an entity game_player_equip gives item to player or default item's on player spawn
  );
  TItemRestType = ItemRestType;

const
  // constant items
  ITEM_ID_ANTIDOTE = 2;
  ITEM_ID_SECURITY = 3;

type
  ItemID =
  (
    ITEM_NONE = -1,
    ITEM_SHIELDGUN,
    ITEM_P228,
    ITEM_GLOCK,
    ITEM_SCOUT,
    ITEM_HEGRENADE,
    ITEM_XM1014,
    ITEM_C4,
    ITEM_MAC10,
    ITEM_AUG,
    ITEM_SMOKEGRENADE,
    ITEM_ELITE,
    ITEM_FIVESEVEN,
    ITEM_UMP45,
    ITEM_SG550,
    ITEM_GALIL,
    ITEM_FAMAS,
    ITEM_USP,
    ITEM_GLOCK18,
    ITEM_AWP,
    ITEM_MP5N,
    ITEM_M249,
    ITEM_M3,
    ITEM_M4A1,
    ITEM_TMP,
    ITEM_G3SG1,
    ITEM_FLASHBANG,
    ITEM_DEAGLE,
    ITEM_SG552,
    ITEM_AK47,
    ITEM_KNIFE,
    ITEM_P90,
    ITEM_NVG,
    ITEM_DEFUSEKIT,
    ITEM_KEVLAR,
    ITEM_ASSAULT,
    ITEM_LONGJUMP,
    ITEM_SODACAN,
    ITEM_HEALTHKIT,
    ITEM_ANTIDOTE,
    ITEM_BATTERY
  );
  TItemID = ItemID;

const
  SF_LIGHT_START_OFF = 1 shl 0;

  MAX_BOMB_RADIUS: Single = 2048.0;

  SF_SCORE_NEGATIVE = 1 shl 0; // Allow negative scores
  SF_SCORE_TEAM = 1 shl 1; // Award points to team in teamplay

  SF_ENVTEXT_ALLPLAYERS = 1 shl 0; // Message will be displayed to all players instead of just the activator.

  SF_TEAMMASTER_FIREONCE = 1 shl 0; // Remove on Fire
  SF_TEAMMASTER_ANYTEAM = 1 shl 1; // Any team until set? -- Any team can use this until the team is set (otherwise no teams can use it)

  SF_TEAMSET_FIREONCE = 1 shl 0; // Remove entity after firing.
  SF_TEAMSET_CLEARTEAM = 1 shl 1; // Clear team -- Sets the team to "NONE" instead of activator

  SF_PKILL_FIREONCE = 1 shl 0; // Remove entity after firing.

  SF_GAMECOUNT_FIREONCE   = 1 shl 0; // Remove entity after firing.
  SF_GAMECOUNT_RESET      = 1 shl 1; // Reset entity Initial value after fired.
  SF_GAMECOUNT_OVER_LIMIT = 1 shl 2; // Fire a target when initial value is higher than limit value.

  SF_GAMECOUNTSET_FIREONCE = 1 shl 0; // Remove entity after firing.

  MAX_EQUIP = 32;
  SF_PLAYEREQUIP_USEONLY = 1 shl 0;   // If set, the game_player_equip entity will not equip respawning players,
                                      // but only react to direct triggering, equipping its activator. This makes its master obsolete.
  SF_PTEAM_FIREONCE = 1 shl 0; // Remove entity after firing.
  SF_PTEAM_KILL     = 1 shl 1; // Kill Player.
  SF_PTEAM_GIB      = 1 shl 2; // Gib Player.

  EVENT_SPECIFIC = 0;
  EVENT_SCRIPTED = 1000;
  EVENT_SHARED   = 2000;
  EVENT_CLIENT   = 5000;

  MONSTER_EVENT_BODYDROP_LIGHT = 2001;
  MONSTER_EVENT_BODYDROP_HEAVY = 2002;
  MONSTER_EVENT_SWISHSOUND     = 2010;

  R_AL = -2; // (ALLY) pals. Good alternative to R_NO when applicable.
  R_FR = -1; // (FEAR) will run
  R_NO = 0;  // (NO RELATIONSHIP) disregard
  R_DL = 1;  // (DISLIKE) will attack
  R_HT = 2;  // (HATE) will attack this character instead of any visible DISLIKEd characters
  R_NM = 3;  // (NEMESIS) A monster Will ALWAYS attack its nemsis, no matter what

  SF_MONSTER_WAIT_TILL_SEEN  = 1 shl 0; // spawnflag that makes monsters wait until player can see them before attacking.
  SF_MONSTER_GAG             = 1 shl 1; // no idle noises from this monster
  SF_MONSTER_HITMONSTERCLIP  = 1 shl 2;
  SF_MONSTER_PRISONER        = 1 shl 4; // monster won't attack anyone, no one will attacks him.

  SF_MONSTER_WAIT_FOR_SCRIPT = 1 shl 7; //spawnflag that makes monsters wait to check for attacking until the script is done or they've been attacked
  SF_MONSTER_PREDISASTER     = 1 shl 8; //this is a predisaster scientist or barney. Influences how they speak.
  SF_MONSTER_FADECORPSE      = 1 shl 9; // Fade out corpse after death
  SF_MONSTER_FALL_TO_GROUND  = 1 shl 31;

  // These bits represent the monster's memory
  MEMORY_CLEAR               = 0;
  bits_MEMORY_PROVOKED       = 1 shl 0;  // right now only used for houndeyes.
  bits_MEMORY_INCOVER        = 1 shl 1;  // monster knows it is in a covered position.
  bits_MEMORY_SUSPICIOUS     = 1 shl 2;  // Ally is suspicious of the player, and will move to provoked more easily
  bits_MEMORY_PATH_FINISHED  = 1 shl 3;  // Finished monster path (just used by big momma for now)
  bits_MEMORY_ON_PATH        = 1 shl 4;  // Moving on a path
  bits_MEMORY_MOVE_FAILED    = 1 shl 5;  // Movement has already failed
  bits_MEMORY_FLINCHED       = 1 shl 6;  // Has already flinched
  bits_MEMORY_KILLED         = 1 shl 7;  // HACKHACK -- remember that I've already called my Killed()
  bits_MEMORY_CUSTOM4        = 1 shl 28; // Monster-specific memory
  bits_MEMORY_CUSTOM3        = 1 shl 29; // Monster-specific memory
  bits_MEMORY_CUSTOM2        = 1 shl 30; // Monster-specific memory
  bits_MEMORY_CUSTOM1        = 1 shl 31; // Monster-specific memory

  // MoveToOrigin stuff
  MOVE_START_TURN_DIST = 64; // when this far away from moveGoal, start turning to face next goal
  MOVE_STUCK_DIST      = 32; // if a monster can't step this far, it is stuck.

  MOVE_NORMAL = 0; // normal move in the direction monster is facing
  MOVE_STRAFE = 1; // moves in direction specified, no matter which way monster is facing

type
  HitBoxGroup =
  (
    HITGROUP_GENERIC = 0,
    HITGROUP_HEAD,
    HITGROUP_CHEST,
    HITGROUP_STOMACH,
    HITGROUP_LEFTARM,
    HITGROUP_RIGHTARM,
    HITGROUP_LEFTLEG,
    HITGROUP_RIGHTLEG,
    HITGROUP_SHIELD,

    NUM_HITGROUPS
  );
  THitBoxGroup = HitBoxGroup;

const
  CAMERA_MODE_SPEC_ANYONE            = 0;
  CAMERA_MODE_SPEC_ONLY_TEAM         = 1;
  CAMERA_MODE_SPEC_ONLY_FRIST_PERSON = 2;

  SF_CORNER_WAITFORTRIG = 1 shl 0;
  SF_CORNER_TELEPORT    = 1 shl 1;
  SF_CORNER_FIREONCE    = 1 shl 2;

  SF_PLAT_TOGGLE = 1 shl 0; // The lift is no more automatically called from top and activated by stepping on it.
                                // It required trigger to do so.
  SF_TRAIN_WAIT_RETRIGGER = 1 shl 0;
  SF_TRAIN_START_ON       = 1 shl 2; // Train is initially moving
  SF_TRAIN_PASSABLE       = 1 shl 3; // Train is not solid -- used to make water trains

  SF_TRACK_ACTIVATETRAIN = 1 shl 0;
  SF_TRACK_RELINK        = 1 shl 1;
  SF_TRACK_ROTMOVE       = 1 shl 2;
  SF_TRACK_STARTBOTTOM   = 1 shl 3;
  SF_TRACK_DONT_MOVE     = 1 shl 4;

type
  TRAIN_CODE =
  (
    TRAIN_SAFE,
    TRAIN_BLOCKING,
    TRAIN_FOLLOWING
  );
  TTrainCode = TRAIN_CODE;

  // pev->speed is the travel speed
  // pev->health is current health
  // pev->max_health is the amount to reset to each time it starts

const
  SF_GUNTARGET_START_ON = 1 shl 0;

  SOUND_FLASHLIGHT_ON = 'items/flashlight1.wav';
  SOUND_FLASHLIGHT_OFF = 'items/flashlight1.wav';

  MAX_PLAYER_NAME_LENGTH: Integer    = 32;
  MAX_AUTOBUY_LENGTH: Integer        = 256;
  MAX_REBUY_LENGTH: Integer          = 256;

  MAX_RECENT_PATH: Integer           = 20;
  MAX_HOSTAGE_ICON: Integer          = 4;	// the maximum number of icons of the hostages in the HUD

  MAX_SUIT_NOREPEAT: Integer         = 32;
  MAX_SUIT_PLAYLIST: Integer         = 4;	// max of 4 suit sentences queued up at any time

  MAX_BUFFER_MENU: Integer           = 175;
  MAX_BUFFER_MENU_BRIEFING: Integer  = 50;

  SUIT_UPDATE_TIME: Single        = 3.5;
  SUIT_FIRST_UPDATE_TIME: Single  = 0.1;

  MAX_PLAYER_FATAL_FALL_SPEED: Single = 1100.0;
  MAX_PLAYER_SAFE_FALL_SPEED: Single  = 500.0;
  MAX_PLAYER_USE_RADIUS: Single       = 64.0;

  ARMOR_RATIO: Single = 0.5;			// Armor Takes 50% of the damage
  ARMOR_BONUS: Single = 0.5;			// Each Point of Armor is work 1/x points of health

  FLASH_DRAIN_TIME: Single = 1.2;	// 100 units/3 minutes
  FLASH_CHARGE_TIME: Single = 0.2;	// 100 units/20 seconds (seconds per unit)

  // damage per unit per second.
  DAMAGE_FOR_FALL_SPEED: Single   = 100.0 / 600.0; // (MAX_PLAYER_FATAL_FALL_SPEED - MAX_PLAYER_SAFE_FALL_SPEED);
  PLAYER_MIN_BOUNCE_SPEED: Single = 350.0;

  // won't punch player's screen/make scrape noise unless player falling at least this fast.
  PLAYER_FALL_PUNCH_THRESHHOLD: Single = 250.0;

  // Money blinks few of times on the freeze period
  // NOTE: It works for CZ
  MONEY_BLINK_AMOUNT: Integer = 30;

  // Player time based damage
  AIRTIME                 = 12;		// lung full of air lasts this many seconds
  PARALYZE_DURATION       = 2;		// number of 2 second intervals to take damage
  PARALYZE_DAMAGE: Single = 1.0;	// damage to take each 2 second interval

  NERVEGAS_DURATION = 2;
  NERVEGAS_DAMAGE: Single = 5.0;

  POISON_DURATION = 5;
  POISON_DAMAGE: Single = 2.0;

  RADIATION_DURATION = 2;
  RADIATION_DAMAGE: Single = 1.0;

  ACID_DURATION = 2;
  ACID_DAMAGE: Single = 5.0;

  SLOWBURN_DURATION = 2;
  SLOWBURN_DAMAGE: Single = 1.0;

  SLOWFREEZE_DURATION = 2;
  SLOWFREEZE_DAMAGE: Single = 1.0;

  // Player physics flags bits
  // CBasePlayer::m_afPhysicsFlags
  PFLAG_ONLADDER          = 1 shl 0;
  PFLAG_ONSWING           = 1 shl 0;
  PFLAG_ONTRAIN           = 1 shl 1;
  PFLAG_ONBARNACLE        = 1 shl 2;
  PFLAG_DUCKING           = 1 shl 3; // In the process of ducking, but totally squatted yet
  PFLAG_USING             = 1 shl 4; // Using a continuous entity
  PFLAG_OBSERVER          = 1 shl 5; // player is locked in stationary cam mode. Spectators can move, observers can't.

  TRAIN_OFF               = $00;
  TRAIN_NEUTRAL           = $01;
  TRAIN_SLOW              = $02;
  TRAIN_MEDIUM            = $03;
  TRAIN_FAST              = $04;
  TRAIN_BACK              = $05;

  TRAIN_ACTIVE            = $80;
  TRAIN_NEW               = $C0;

  SUIT_GROUP: Boolean           = True;
  SUIT_SENTENCE: Boolean        = False;

  SUIT_REPEAT_OK: Integer       = 0;
  SUIT_NEXT_IN_30SEC: Integer	= 30;
  SUIT_NEXT_IN_1MIN: Integer    = 60;
  SUIT_NEXT_IN_5MIN: Integer    = 300;
  SUIT_NEXT_IN_10MIN: Integer   = 600;
  SUIT_NEXT_IN_30MIN: Integer   = 1800;
  SUIT_NEXT_IN_1HOUR: Integer   = 3600;

  MAX_TEAM_NAME_LENGTH: Integer  = 16;

  AUTOAIM_2DEGREES: Double     = 0.0348994967025;
  AUTOAIM_5DEGREES: Double     = 0.08715574274766;
  AUTOAIM_8DEGREES: Double     = 0.1391731009601;
  AUTOAIM_10DEGREES: Double    = 0.1736481776669;

type
   // custom enum
  RewardType =
  (
    RT_NONE,
    RT_ROUND_BONUS,
    RT_PLAYER_RESET,
    RT_PLAYER_JOIN,
    RT_PLAYER_SPEC_JOIN,
    RT_PLAYER_BOUGHT_SOMETHING,
    RT_HOSTAGE_TOOK,
    RT_HOSTAGE_RESCUED,
    RT_HOSTAGE_DAMAGED,
    RT_HOSTAGE_KILLED,
    RT_TEAMMATES_KILLED,
    RT_ENEMY_KILLED,
    RT_INTO_GAME,
    RT_VIP_KILLED,
    RT_VIP_RESCUED_MYSELF
  );
  TRewardType = RewardType;

  PLAYER_ANIM =
  (
    PLAYER_IDLE,
    PLAYER_WALK,
    PLAYER_JUMP,
    PLAYER_SUPERJUMP,
    PLAYER_DIE,
    PLAYER_ATTACK1,
    PLAYER_ATTACK2,
    PLAYER_FLINCH,
    PLAYER_LARGE_FLINCH,
    PLAYER_RELOAD,
    PLAYER_HOLDBOMB
  );
  TPlayerAnim = PLAYER_ANIM;

  _Menu =
  (
    Menu_OFF,
    Menu_ChooseTeam,
    Menu_IGChooseTeam,
    Menu_ChooseAppearance,
    Menu_Buy,
    Menu_BuyPistol,
    Menu_BuyRifle,
    Menu_BuyMachineGun,
    Menu_BuyShotgun,
    Menu_BuySubMachineGun,
    Menu_BuyItem,
    Menu_Radio1,
    Menu_Radio2,
    Menu_Radio3,
    Menu_ClientBuy
  );
  TMenu = _Menu;

  TeamName =
  (
    UNASSIGNED,
    TERRORIST,
    CT,
    SPECTATOR
  );
  TTeamName = TeamName;

  ModelName =
  (
    MODEL_UNASSIGNED,
    MODEL_URBAN,
    MODEL_TERROR,
    MODEL_LEET,
    MODEL_ARCTIC,
    MODEL_GSG9,
    MODEL_GIGN,
    MODEL_SAS,
    MODEL_GUERILLA,
    MODEL_VIP,
    MODEL_MILITIA,
    MODEL_SPETSNAZ,
    MODEL_AUTO
  );
  TModelName = ModelName;

  JoinState =
  (
    JOINED,
    SHOWLTEXT,
    READINGLTEXT,
    SHOWTEAMSELECT,
    PICKINGTEAM,
    GETINTOGAME
  );
  TJoinState = JoinState;

  TrackCommands =
  (
    CMD_SAY = 0,
    CMD_SAYTEAM,
    CMD_FULLUPDATE,
    CMD_VOTE,
    CMD_VOTEMAP,
    CMD_LISTMAPS,
    CMD_LISTPLAYERS,
    CMD_NIGHTVISION,
    COMMANDS_TO_TRACK
  );
  TTrackCommands = TrackCommands;

  IgnoreChatMsg =
  (
    IGNOREMSG_NONE,
    IGNOREMSG_ENEMY,
    IGNOREMSG_TEAM
  );
  TIgnoreChatMsg = IgnoreChatMsg;

  ThrowDirection =
  (
    THROW_NONE,
    THROW_FORWARD,
    THROW_BACKWARD,
    THROW_HITVEL,
    THROW_BOMB,
    THROW_GRENADE,
    THROW_HITVEL_MINUS_AIRVEL
  );

const
  MAX_ID_RANGE: Single            = 2048.0;
  MAX_SPEC_ID_RANGE: Single       = 8192.0;
  MAX_SBAR_STRING: Integer        = 128;

  SBAR_TARGETTYPE_TEAMMATE: Integer   = 1;
  SBAR_TARGETTYPE_ENEMY: Integer      = 2;
  SBAR_TARGETTYPE_HOSTAGE: Integer    = 3;

type
  sbar_data =
  (
    SBAR_ID_TARGETTYPE = 1,
    SBAR_ID_TARGETNAME,
    SBAR_ID_TARGETHEALTH,
    SBAR_END
  );
  TSBarData = sbar_data;

  MusicState =
  (
    SILENT,
    CALM,
    INTENSE
  );

const
  // These are caps bits to indicate what an object's capabilities (currently used for save/restore and level transitions)
  FCAP_CUSTOMSAVE         = $00000001;
  FCAP_ACROSS_TRANSITION  = $00000002; // should transfer between transitions
  FCAP_MUST_SPAWN         = $00000004; // Spawn after restore
  FCAP_DONT_SAVE          = $80000000; // Don't save this
  FCAP_IMPULSE_USE        = $00000008; // can be used by the player
  FCAP_CONTINUOUS_USE     = $00000010; // can be used by the player
  FCAP_ONOFF_USE          = $00000020; // can be used by the player
  FCAP_DIRECTIONAL_USE    = $00000040; // Player sends +/- 1 when using (currently only tracktrains)
  FCAP_MASTER             = $00000080; // Can be used to "master" other entities (like multisource)
  FCAP_MUST_RESET         = $00000100; // should reset on the new round
  FCAP_MUST_RELEASE       = $00000200; // should release on the new round

  // UNDONE: This will ignore transition volumes (trigger_transition), but not the PVS!!!
  FCAP_FORCE_TRANSITION   = $00000080; // ALWAYS goes across transitions

  // for Classify
  CLASS_NONE              = 0;
  CLASS_MACHINE           = 1;
  CLASS_PLAYER            = 2;
  CLASS_HUMAN_PASSIVE     = 3;
  CLASS_HUMAN_MILITARY    = 4;
  CLASS_ALIEN_MILITARY    = 5;
  CLASS_ALIEN_PASSIVE     = 6;
  CLASS_ALIEN_MONSTER     = 7;
  CLASS_ALIEN_PREY        = 8;
  CLASS_ALIEN_PREDATOR    = 9;
  CLASS_INSECT            = 10;
  CLASS_PLAYER_ALLY       = 11;
  CLASS_PLAYER_BIOWEAPON  = 12; // hornets and snarks.launched by players
  CLASS_ALIEN_BIOWEAPON   = 13; // hornets and snarks.launched by the alien menace
  CLASS_VEHICLE           = 14;
  CLASS_BARNACLE          = 99; // special because no one pays attention to it, and it eats a wide cross-section of creatures.

  SF_NORESPAWN            = 1 shl 30; // set this bit on guns and stuff that should never respawn.

  DMG_GENERIC             = 0;       // generic damage was done
  DMG_CRUSH               = 1 shl 0;  // crushed by falling or moving object
  DMG_BULLET              = 1 shl 1;  // shot
  DMG_SLASH               = 1 shl 2;  // cut, clawed, stabbed
  DMG_BURN                = 1 shl 3;  // heat burned
  DMG_FREEZE              = 1 shl 4;  // frozen
  DMG_FALL                = 1 shl 5;  // fell too far
  DMG_BLAST               = 1 shl 6;  // explosive blast damage
  DMG_CLUB                = 1 shl 7;  // crowbar, punch, headbutt
  DMG_SHOCK               = 1 shl 8;  // electric shock
  DMG_SONIC               = 1 shl 9;  // sound pulse shockwave
  DMG_ENERGYBEAM          = 1 shl 10; // laser or other high energy beam
  DMG_NEVERGIB            = 1 shl 12; // with this bit OR'd in, no damage type will be able to gib victims upon death
  DMG_ALWAYSGIB           = 1 shl 13; // with this bit OR'd in, any damage type can be made to gib victims upon death
  DMG_DROWN               = 1 shl 14; // Drowning

  // time-based damage
  DMG_TIMEBASED           = not $3FFF; // mask for time-based damage

  DMG_PARALYZE            = 1 shl 15; // slows affected creature down
  DMG_NERVEGAS            = 1 shl 16; // nerve toxins, very bad
  DMG_POISON              = 1 shl 17; // blood poisioning
  DMG_RADIATION           = 1 shl 18; // radiation exposure
  DMG_DROWNRECOVER        = 1 shl 19; // drowning recovery
  DMG_ACID                = 1 shl 20; // toxic chemicals or acid burns
  DMG_SLOWBURN            = 1 shl 21; // in an oven
  DMG_SLOWFREEZE          = 1 shl 22; // in a subzero freezer
  DMG_MORTAR              = 1 shl 23; // Hit by air raid (done to distinguish grenade from mortar)
  DMG_EXPLOSION           = 1 shl 24;

  // these are the damage types that are allowed to gib corpses
  DMG_GIB_CORPSE          = DMG_CRUSH or DMG_FALL or DMG_BLAST or DMG_SONIC or DMG_CLUB;

  // these are the damage types that have client hud art
  DMG_SHOWNHUD            = DMG_POISON or DMG_ACID or DMG_FREEZE or DMG_SLOWFREEZE or DMG_DROWN or DMG_BURN or DMG_SLOWBURN or DMG_NERVEGAS or DMG_RADIATION or DMG_SHOCK;

  // when calling KILLED(), a value that governs gib behavior is expected to be
  // one of these three values
  GIB_NORMAL             = 0; // gib if entity was overkilled
  GIB_NEVER              = 1; // never gib, no matter how much death damage is done ( freezing, etc )
  GIB_ALWAYS             = 2; // always gib ( Houndeye Shock, Barnacle Bite )
  GIB_HEALTH_VALUE       = -30;

  // these MoveFlag values are assigned to a WayPoint's TYPE in order to demonstrate the
  // type of movement the monster should use to get there.
  bits_MF_TO_TARGETENT        = 1 shl 0; // local move to targetent.
  bits_MF_TO_ENEMY            = 1 shl 1; // local move to enemy
  bits_MF_TO_COVER            = 1 shl 2; // local move to a hiding place
  bits_MF_TO_DETOUR           = 1 shl 3; // local move to detour point.
  bits_MF_TO_PATHCORNER       = 1 shl 4; // local move to a path corner
  bits_MF_TO_NODE             = 1 shl 5; // local move to a node
  bits_MF_TO_LOCATION         = 1 shl 6; // local move to an arbitrary point
  bits_MF_IS_GOAL             = 1 shl 7; // this waypoint is the goal of the whole move.
  bits_MF_DONT_SIMPLIFY       = 1 shl 8; // Don't let the route code simplify this waypoint

  // If you define any flags that aren't _TO_ flags, add them here so we can mask
  // them off when doing compares.
  bits_MF_NOT_TO_MASK         = bits_MF_IS_GOAL or bits_MF_DONT_SIMPLIFY;

  MOVEGOAL_NONE               = 0;
  MOVEGOAL_TARGETENT          = bits_MF_TO_TARGETENT;
  MOVEGOAL_ENEMY              = bits_MF_TO_ENEMY;
  MOVEGOAL_PATHCORNER         = bits_MF_TO_PATHCORNER;
  MOVEGOAL_LOCATION           = bits_MF_TO_LOCATION;
  MOVEGOAL_NODE               = bits_MF_TO_NODE;

  // these bits represent conditions that may befall the monster, of which some are allowed
  // to interrupt certain schedules.
  bits_COND_NO_AMMO_LOADED    = 1 shl 0;  // weapon needs to be reloaded!
  bits_COND_SEE_HATE          = 1 shl 1;  // see something that you hate
  bits_COND_SEE_FEAR          = 1 shl 2;  // see something that you are afraid of
  bits_COND_SEE_DISLIKE       = 1 shl 3;  // see something that you dislike
  bits_COND_SEE_ENEMY         = 1 shl 4;  // target entity is in full view.
  bits_COND_ENEMY_OCCLUDED    = 1 shl 5;  // target entity occluded by the world
  bits_COND_SMELL_FOOD        = 1 shl 6;
  bits_COND_ENEMY_TOOFAR      = 1 shl 7;
  bits_COND_LIGHT_DAMAGE      = 1 shl 8;  // hurt a little
  bits_COND_HEAVY_DAMAGE      = 1 shl 9;  // hurt a lot
  bits_COND_CAN_RANGE_ATTACK1 = 1 shl 10;
  bits_COND_CAN_MELEE_ATTACK1 = 1 shl 11;
  bits_COND_CAN_RANGE_ATTACK2 = 1 shl 12;
  bits_COND_CAN_MELEE_ATTACK2 = 1 shl 13;
  //bits_COND_CAN_RANGE_ATTACK3 (1 shl 14)

  bits_COND_PROVOKED          = 1 shl 15;
  bits_COND_NEW_ENEMY         = 1 shl 16;
  bits_COND_HEAR_SOUND        = 1 shl 17; // there is an interesting sound
  bits_COND_SMELL             = 1 shl 18; // there is an interesting scent
  bits_COND_ENEMY_FACING_ME   = 1 shl 19; // enemy is facing me
  bits_COND_ENEMY_DEAD        = 1 shl 20; // enemy was killed. If you get this in combat, try to find another enemy. If you get it in alert, victory dance.
  bits_COND_SEE_CLIENT        = 1 shl 21; // see a client
  bits_COND_SEE_NEMESIS       = 1 shl 22; // see my nemesis

  bits_COND_SPECIAL1          = 1 shl 28; // Defined by individual monster
  bits_COND_SPECIAL2          = 1 shl 29; // Defined by individual monster

  bits_COND_TASK_FAILED       = 1 shl 30;
  bits_COND_SCHEDULE_DONE     = 1 shl 31;

  bits_COND_ALL_SPECIAL       = bits_COND_SPECIAL1 or bits_COND_SPECIAL2;
  bits_COND_CAN_ATTACK        = bits_COND_CAN_RANGE_ATTACK1 or bits_COND_CAN_MELEE_ATTACK1 or bits_COND_CAN_RANGE_ATTACK2 or bits_COND_CAN_MELEE_ATTACK2;

  TASKSTATUS_NEW              = 0; // Just started
  TASKSTATUS_RUNNING          = 1; // Running task & movement
  TASKSTATUS_RUNNING_MOVEMENT = 2; // Just running movement
  TASKSTATUS_RUNNING_TASK     = 3; // Just running task
  TASKSTATUS_COMPLETE         = 4; // Completed, get next task

type
  // These are the schedule types
  SCHEDULE_TYPE =
  (
    SCHED_NONE = 0,
    SCHED_IDLE_STAND,
    SCHED_IDLE_WALK,
    SCHED_WAKE_ANGRY,
    SCHED_WAKE_CALLED,
    SCHED_ALERT_FACE,
    SCHED_ALERT_SMALL_FLINCH,
    SCHED_ALERT_BIG_FLINCH,
    SCHED_ALERT_STAND,
    SCHED_INVESTIGATE_SOUND,
    SCHED_COMBAT_FACE,
    SCHED_COMBAT_STAND,
    SCHED_CHASE_ENEMY,
    SCHED_CHASE_ENEMY_FAILED,
    SCHED_VICTORY_DANCE,
    SCHED_TARGET_FACE,
    SCHED_TARGET_CHASE,
    SCHED_SMALL_FLINCH,
    SCHED_TAKE_COVER_FROM_ENEMY,
    SCHED_TAKE_COVER_FROM_BEST_SOUND,
    SCHED_TAKE_COVER_FROM_ORIGIN,
    SCHED_COWER,					// usually a last resort!
    SCHED_MELEE_ATTACK1,
    SCHED_MELEE_ATTACK2,
    SCHED_RANGE_ATTACK1,
    SCHED_RANGE_ATTACK2,
    SCHED_SPECIAL_ATTACK1,
    SCHED_SPECIAL_ATTACK2,
    SCHED_STANDOFF,
    SCHED_ARM_WEAPON,
    SCHED_RELOAD,
    SCHED_GUARD,
    SCHED_AMBUSH,
    SCHED_DIE,
    SCHED_WAIT_TRIGGER,
    SCHED_FOLLOW,
    SCHED_SLEEP,
    SCHED_WAKE,
    SCHED_BARNACLE_VICTIM_GRAB,
    SCHED_BARNACLE_VICTIM_CHOMP,
    SCHED_AISCRIPT,
    SCHED_FAIL,

    LAST_COMMON_SCHEDULE			// Leave this at the bottom
  );
  TScheduleType = SCHEDULE_TYPE;

  // These are the shared tasks
  SHARED_TASKS =
  (
    TASK_INVALID = 0,
    TASK_WAIT,
    TASK_WAIT_FACE_ENEMY,
    TASK_WAIT_PVS,
    TASK_SUGGEST_STATE,
    TASK_WALK_TO_TARGET,
    TASK_RUN_TO_TARGET,
    TASK_MOVE_TO_TARGET_RANGE,
    TASK_GET_PATH_TO_ENEMY,
    TASK_GET_PATH_TO_ENEMY_LKP,
    TASK_GET_PATH_TO_ENEMY_CORPSE,
    TASK_GET_PATH_TO_LEADER,
    TASK_GET_PATH_TO_SPOT,
    TASK_GET_PATH_TO_TARGET,
    TASK_GET_PATH_TO_HINTNODE,
    TASK_GET_PATH_TO_LASTPOSITION,
    TASK_GET_PATH_TO_BESTSOUND,
    TASK_GET_PATH_TO_BESTSCENT,
    TASK_RUN_PATH,
    TASK_WALK_PATH,
    TASK_STRAFE_PATH,
    TASK_CLEAR_MOVE_WAIT,
    TASK_STORE_LASTPOSITION,
    TASK_CLEAR_LASTPOSITION,
    TASK_PLAY_ACTIVE_IDLE,
    TASK_FIND_HINTNODE,
    TASK_CLEAR_HINTNODE,
    TASK_SMALL_FLINCH,
    TASK_FACE_IDEAL,
    TASK_FACE_ROUTE,
    TASK_FACE_ENEMY,
    TASK_FACE_HINTNODE,
    TASK_FACE_TARGET,
    TASK_FACE_LASTPOSITION,
    TASK_RANGE_ATTACK1,
    TASK_RANGE_ATTACK2,
    TASK_MELEE_ATTACK1,
    TASK_MELEE_ATTACK2,
    TASK_RELOAD,
    TASK_RANGE_ATTACK1_NOTURN,
    TASK_RANGE_ATTACK2_NOTURN,
    TASK_MELEE_ATTACK1_NOTURN,
    TASK_MELEE_ATTACK2_NOTURN,
    TASK_RELOAD_NOTURN,
    TASK_SPECIAL_ATTACK1,
    TASK_SPECIAL_ATTACK2,
    TASK_CROUCH,
    TASK_STAND,
    TASK_GUARD,
    TASK_STEP_LEFT,
    TASK_STEP_RIGHT,
    TASK_STEP_FORWARD,
    TASK_STEP_BACK,
    TASK_DODGE_LEFT,
    TASK_DODGE_RIGHT,
    TASK_SOUND_ANGRY,
    TASK_SOUND_DEATH,
    TASK_SET_ACTIVITY,
    TASK_SET_SCHEDULE,
    TASK_SET_FAIL_SCHEDULE,
    TASK_CLEAR_FAIL_SCHEDULE,
    TASK_PLAY_SEQUENCE,
    TASK_PLAY_SEQUENCE_FACE_ENEMY,
    TASK_PLAY_SEQUENCE_FACE_TARGET,
    TASK_SOUND_IDLE,
    TASK_SOUND_WAKE,
    TASK_SOUND_PAIN,
    TASK_SOUND_DIE,
    TASK_FIND_COVER_FROM_BEST_SOUND,		// tries lateral cover first, then node cover
    TASK_FIND_COVER_FROM_ENEMY,				// tries lateral cover first, then node cover
    TASK_FIND_LATERAL_COVER_FROM_ENEMY,
    TASK_FIND_NODE_COVER_FROM_ENEMY,
    TASK_FIND_NEAR_NODE_COVER_FROM_ENEMY,	// data for this one is the MAXIMUM acceptable distance to the cover.
    TASK_FIND_FAR_NODE_COVER_FROM_ENEMY,	// data for this one is there MINIMUM aceptable distance to the cover.
    TASK_FIND_COVER_FROM_ORIGIN,
    TASK_EAT,
    TASK_DIE,
    TASK_WAIT_FOR_SCRIPT,
    TASK_PLAY_SCRIPT,
    TASK_ENABLE_SCRIPT,
    TASK_PLANT_ON_SCRIPT,
    TASK_FACE_SCRIPT,
    TASK_WAIT_RANDOM,
    TASK_WAIT_INDEFINITE,
    TASK_STOP_MOVING,
    TASK_TURN_LEFT,
    TASK_TURN_RIGHT,
    TASK_REMEMBER,
    TASK_FORGET,
    TASK_WAIT_FOR_MOVEMENT,		// wait until MovementIsComplete()
    LAST_COMMON_TASK			// LEAVE THIS AT THE BOTTOM (sjb)
  );
  TSharedTasks = SHARED_TASKS;

const
  // These go in the flData member of the TASK_WALK_TO_TARGET, TASK_RUN_TO_TARGET
	TARGET_MOVE_NORMAL = 0;
	TARGET_MOVE_SCRIPTED = 1;

  // A goal should be used for a task that requires several schedules to complete.
  // The goal index should indicate which schedule (ordinally) the monster is running.
  // That way, when tasks fail, the AI can make decisions based on the context of the
  // current goal and sequence rather than just the current schedule.
	GOAL_ATTACK_ENEMY = 0;
	GOAL_MOVE = 1;
	GOAL_TAKE_COVER = 2;
	GOAL_MOVE_TARGET = 3;
	GOAL_EAT = 4;

  SKILL_EASY   = 1;
  SKILL_MEDIUM = 2;
  SKILL_HARD   = 3;

  MAX_SENTENCE_NAME: Integer      = 16;
  MAX_SENTENCE_VOXFILE: Integer   = 1536;	// max number of sentences in game. NOTE: this must match CVOXFILESENTENCEMAX in engine\sound.h

  MAX_SENTENCE_GROUPS: Integer    = 200;		// max number of sentence groups
  MAX_SENTENCE_LRU: Integer       = 32;		// max number of elements per sentence group
  MAX_SENTENCE_DPV_RESET: Integer = 27;		// max number of dynamic pitch volumes

  MAX_ANNOUNCE_MINS: Single    = 2.25;
  MIN_ANNOUNCE_MINS: Single    = 0.25;

type
  LowFreqOsc =
  (
    LFO_OFF = 0,
    LFO_SQUARE,		// square
    LFO_TRIANGLE,	// triangle
    LFO_RANDOM		// random
  );
  TLowFreqOsc = LowFreqOsc;

const
  SF_AMBIENT_SOUND_STATIC         = 0; // medium radius attenuation
  SF_AMBIENT_SOUND_EVERYWHERE     = $0001;
  SF_AMBIENT_SOUND_SMALLRADIUS    = $0002;
  SF_AMBIENT_SOUND_MEDIUMRADIUS   = $0004;
  SF_AMBIENT_SOUND_LARGERADIUS    = $0008;
  SF_AMBIENT_SOUND_START_SILENT   = $0016;
  SF_AMBIENT_SOUND_NOT_LOOPING    = $0032;

  SF_SPEAKER_START_SILENT	= $0001; // wait for trigger 'on' to start announcements

type
  GrenCatchType =
  (
    GRENADETYPE_NONE  = 0,
    GRENADETYPE_SMOKE,
    GRENADETYPE_FLASH
  );
  TGrenCatchType = GrenCatchType;

const
  MAX_ITEM_COUNTS: Integer = 32;

  SF_PATH_DISABLED      = 1 shl 0;
  SF_PATH_FIREONCE      = 1 shl 1;
  SF_PATH_ALTREVERSE    = 1 shl 2;
  SF_PATH_DISABLE_TRAIN = 1 shl 3;
  SF_PATH_ALTERNATE     = 1 shl 15;

  TRAIN_STARTPITCH: Single = 60.0;
  TRAIN_MAXPITCH: Single   = 200.0;
  TRAIN_MAXSPEED: Single   = 1000.0;

  SF_TRACKTRAIN_NOPITCH     = 1 shl 0;
  SF_TRACKTRAIN_NOCONTROL   = 1 shl 1;
  SF_TRACKTRAIN_FORWARDONLY = 1 shl 2;
  SF_TRACKTRAIN_PASSABLE    = 1 shl 3;

  SF_AUTO_FIREONCE = 1 shl 0;
  SF_AUTO_NORESET  = 1 shl 1;

  SF_RELAY_FIREONCE = 1 shl 0;

  MAX_MM_TARGETS: Integer = 16; // maximum number of targets a single multi_manager entity may be assigned.

  SF_MULTIMAN_THREAD = 1 shl 0;
  SF_MULTIMAN_CLONE  = 1 shl 31;

  // Flags to indicate masking off various render parameters that are normally copied to the targets
  SF_RENDER_MASKFX    = 1 shl 0;
  SF_RENDER_MASKAMT   = 1 shl 1;
  SF_RENDER_MASKMODE  = 1 shl 2;
  SF_RENDER_MASKCOLOR = 1 shl 3;

  SF_TRIGGER_ALLOWMONSTERS = 1 shl 0; // monsters allowed to fire this trigger
  SF_TRIGGER_NOCLIENTS     = 1 shl 1; // players not allowed to fire this trigger
  SF_TRIGGER_PUSHABLES     = 1 shl 2; // only pushables can fire this trigger
  SF_TRIGGER_NORESET       = 1 shl 6; // it is not allowed to be resetting on a new round

  SF_TRIGGER_HURT_TARGETONCE      = 1 shl 0; // Only fire hurt target once
  SF_TRIGGER_HURT_START_OFF       = 1 shl 1; // spawnflag that makes trigger_push spawn turned OFF
  SF_TRIGGER_HURT_NO_CLIENTS      = 1 shl 3; // spawnflag that makes trigger_push spawn turned OFF
  SF_TRIGGER_HURT_CLIENTONLYFIRE  = 1 shl 4; // trigger hurt will only fire its target if it is hurting a client
  SF_TRIGGER_HURT_CLIENTONLYTOUCH = 1 shl 5; // only clients may touch this trigger.

  SF_CHANGELEVEL_USEONLY = 1 shl 1;

  SF_TRIGGER_PUSH_ONCE      = 1 shl 0;
  SF_TRIGGER_PUSH_START_OFF = 1 shl 1; // spawnflag that makes trigger_push spawn turned OFF

  SF_ENDSECTION_USEONLY = 1 shl 0;

  SF_CAMERA_PLAYER_POSITION    = 1 shl 0;
  SF_CAMERA_PLAYER_TARGET      = 1 shl 1;
  SF_CAMERA_PLAYER_TAKECONTROL = 1 shl 2;

  SIGNAL_BUY       = 1 shl 0;
  SIGNAL_BOMB      = 1 shl 1;
  SIGNAL_RESCUE    = 1 shl 2;
  SIGNAL_ESCAPE    = 1 shl 3;
  SIGNAL_VIPSAFETY = 1 shl 4;

  GROUP_OP_AND	= 0;
  GROUP_OP_NAND	= 1;

  // Dot products for view cone checking
  VIEW_FIELD_FULL			= -1.0;	// +-180 degrees
  VIEW_FIELD_WIDE			= -0.7;	// +-135 degrees 0.1 // +-85 degrees, used for full FOV checks
  VIEW_FIELD_NARROW		= 0.7;		// +-45 degrees, more narrow check used to set up ranged attacks
  VIEW_FIELD_ULTRA_NARROW	= 0.9;		// +-25 degrees, more narrow check used to set up ranged attacks

  SND_STOP				= 1 shl 5;	// duplicated in protocol.h stop sound
  SND_CHANGE_VOL			= 1 shl 6;	// duplicated in protocol.h change sound vol
  SND_CHANGE_PITCH		= 1 shl 7;	// duplicated in protocol.h change sound pitch
  SND_SPAWNING			= 1 shl 8;	// duplicated in protocol.h we're spawing, used in some cases for ambients

  // All monsters need this data
  DONT_BLEED			= -1;
  BLOOD_COLOR_DARKRED: Byte = 223;
  BLOOD_COLOR_RED: Byte = 247;
  BLOOD_COLOR_YELLOW: Byte = 195;
  BLOOD_COLOR_GREEN: Byte	= 195; //BLOOD_COLOR_YELLOW;

  GERMAN_GIB_COUNT	= 4;
  HUMAN_GIB_COUNT		= 6;
  ALIEN_GIB_COUNT		= 4;

  LANGUAGE_ENGLISH	= 0;
  LANGUAGE_GERMAN		= 1;
  LANGUAGE_FRENCH		= 2;
  LANGUAGE_BRITISH	= 3;

const
  VEC_HULL_MIN_Z: TVectorArray = (0, 0, -36);
  VEC_DUCK_HULL_MIN_Z: TVectorArray = (0, 0, -18);

  VEC_HULL_MIN: TVectorArray = (-16, -16, -36);
  VEC_HULL_MAX: TVectorArray = (16, 16, 36);

  VEC_VIEW: TVectorArray = (0, 0, 17);

  VEC_DUCK_HULL_MIN: TVectorArray = (-16, -16, -18);
  VEC_DUCK_HULL_MAX: TVectorArray = (16, 16, 32);
  VEC_DUCK_VIEW: TVectorArray = (0, 0, 12);

  VEHICLE_SPEED0_ACCELERATION: Double = 0.005000000000000000;
  VEHICLE_SPEED1_ACCELERATION: Double = 0.002142857142857143;
  VEHICLE_SPEED2_ACCELERATION: Double = 0.003333333333333334;
  VEHICLE_SPEED3_ACCELERATION: Double = 0.004166666666666667;
  VEHICLE_SPEED4_ACCELERATION: Double = 0.004000000000000000;
  VEHICLE_SPEED5_ACCELERATION: Double = 0.003800000000000000;
  VEHICLE_SPEED6_ACCELERATION: Double = 0.004500000000000000;
  VEHICLE_SPEED7_ACCELERATION: Double = 0.004250000000000000;
  VEHICLE_SPEED8_ACCELERATION: Double = 0.002666666666666667;
  VEHICLE_SPEED9_ACCELERATION: Double = 0.002285714285714286;
  VEHICLE_SPEED10_ACCELERATION: Double = 0.001875000000000000;
  VEHICLE_SPEED11_ACCELERATION: Double = 0.001444444444444444;
  VEHICLE_SPEED12_ACCELERATION: Double = 0.001200000000000000;
  VEHICLE_SPEED13_ACCELERATION: Double = 0.000916666666666666;

  VEHICLE_STARTPITCH = 60;
  VEHICLE_MAXPITCH   = 200;
  VEHICLE_MAXSPEED   = 1500;

type
  WeaponIdType =
  (
    WEAPON_NONE = 0,
    WEAPON_P228,
    WEAPON_GLOCK,
    WEAPON_SCOUT,
    WEAPON_HEGRENADE,
    WEAPON_XM1014,
    WEAPON_C4,
    WEAPON_MAC10,
    WEAPON_AUG,
    WEAPON_SMOKEGRENADE,
    WEAPON_ELITE,
    WEAPON_FIVESEVEN,
    WEAPON_UMP45,
    WEAPON_SG550,
    WEAPON_GALIL,
    WEAPON_FAMAS,
    WEAPON_USP,
    WEAPON_GLOCK18,
    WEAPON_AWP,
    WEAPON_MP5N,
    WEAPON_M249,
    WEAPON_M3,
    WEAPON_M4A1,
    WEAPON_TMP,
    WEAPON_G3SG1,
    WEAPON_FLASHBANG,
    WEAPON_DEAGLE,
    WEAPON_SG552,
    WEAPON_AK47,
    WEAPON_KNIFE,
    WEAPON_P90,
    WEAPON_SHIELDGUN = 99
  );
  TWeaponIdType = WeaponIdType;

  AutoBuyClassType =
  (
    AUTOBUYCLASS_NONE           = 0,
    AUTOBUYCLASS_PRIMARY        = 1 shl 0,
    AUTOBUYCLASS_SECONDARY      = 1 shl 1,
    AUTOBUYCLASS_AMMO           = 1 shl 2,
    AUTOBUYCLASS_ARMOR          = 1 shl 3,
    AUTOBUYCLASS_DEFUSER        = 1 shl 4,
    AUTOBUYCLASS_PISTOL         = 1 shl 5,
    AUTOBUYCLASS_SMG            = 1 shl 6,
    AUTOBUYCLASS_RIFLE          = 1 shl 7,
    AUTOBUYCLASS_SNIPERRIFLE    = 1 shl 8,
    AUTOBUYCLASS_SHOTGUN        = 1 shl 9,
    AUTOBUYCLASS_MACHINEGUN     = 1 shl 10,
    AUTOBUYCLASS_GRENADE        = 1 shl 11,
    AUTOBUYCLASS_NIGHTVISION    = 1 shl 12,
    AUTOBUYCLASS_SHIELD         = 1 shl 13
  );
  TAutoBuyClassType = AutoBuyClassType;

  AmmoCostType =
  (
    AMMO_338MAG_PRICE   = 125,
    AMMO_357SIG_PRICE   = 50,
    AMMO_45ACP_PRICE    = 25,
    AMMO_50AE_PRICE     = 40,
    AMMO_556MM_PRICE    = 60,
    AMMO_57MM_PRICE     = 50,
    AMMO_762MM_PRICE    = 80,
    AMMO_9MM_PRICE      = 20,
    AMMO_BUCKSHOT_PRICE = 65
  );
  TAmmoCostType = AmmoCostType;

  WeaponCostType =
  (
    AK47_PRICE      = 2500,
    AWP_PRICE       = 4750,
    DEAGLE_PRICE    = 650,
    G3SG1_PRICE     = 5000,
    SG550_PRICE     = 4200,
    GLOCK18_PRICE   = 400,
    M249_PRICE      = 5750,
    M3_PRICE        = 1700,
    M4A1_PRICE      = 3100,
    AUG_PRICE       = 3500,
    MP5NAVY_PRICE   = 1500,
    P228_PRICE      = 600,
    P90_PRICE       = 2350,
    UMP45_PRICE     = 1700,
    MAC10_PRICE     = 1400,
    SCOUT_PRICE     = 2750,
    SG552_PRICE     = 3500,
    TMP_PRICE       = 1250,
    USP_PRICE       = 500,
    ELITE_PRICE     = 800,
    FIVESEVEN_PRICE = 750,
    XM1014_PRICE    = 3000,
    GALIL_PRICE     = 2000,
    FAMAS_PRICE     = 2250,
    SHIELDGUN_PRICE = 2200
  );
  TWeaponCostType = WeaponCostType;

  WeaponState =
  (
    WPNSTATE_USP_SILENCED       = 1 shl 0,
    WPNSTATE_GLOCK18_BURST_MODE = 1 shl 1,
    WPNSTATE_M4A1_SILENCED      = 1 shl 2,
    WPNSTATE_ELITE_LEFT         = 1 shl 3,
    WPNSTATE_FAMAS_BURST_MODE   = 1 shl 4,
    WPNSTATE_SHIELD_DRAWN       = 1 shl 5
  );
  TWeaponState = WeaponState;

  // custom enum
  // the default amount of ammo that comes with each gun when it spawns
  ClipGiveDefault =
  (
    P228_DEFAULT_GIVE           = 13,
    GLOCK18_DEFAULT_GIVE        = 20,
    SCOUT_DEFAULT_GIVE          = 10,
    HEGRENADE_DEFAULT_GIVE      = 1,
    XM1014_DEFAULT_GIVE         = 7,
    C4_DEFAULT_GIVE             = 1,
    MAC10_DEFAULT_GIVE          = 30,
    AUG_DEFAULT_GIVE            = 30,
    SMOKEGRENADE_DEFAULT_GIVE   = 1,
    ELITE_DEFAULT_GIVE          = 30,
    FIVESEVEN_DEFAULT_GIVE      = 20,
    UMP45_DEFAULT_GIVE          = 25,
    SG550_DEFAULT_GIVE          = 30,
    GALIL_DEFAULT_GIVE          = 35,
    FAMAS_DEFAULT_GIVE          = 25,
    USP_DEFAULT_GIVE            = 12,
    AWP_DEFAULT_GIVE            = 10,
    MP5NAVY_DEFAULT_GIVE        = 30,
    M249_DEFAULT_GIVE           = 100,
    M3_DEFAULT_GIVE             = 8,
    M4A1_DEFAULT_GIVE           = 30,
    TMP_DEFAULT_GIVE            = 30,
    G3SG1_DEFAULT_GIVE          = 20,
    FLASHBANG_DEFAULT_GIVE      = 1,
    DEAGLE_DEFAULT_GIVE         = 7,
    SG552_DEFAULT_GIVE          = 30,
    AK47_DEFAULT_GIVE           = 30,
    //KNIFE_DEFAULT_GIVE        = 1,
    P90_DEFAULT_GIVE            = 50
  );
  TClipGiveDefault = ClipGiveDefault;

  ClipSizeType =
  (
    P228_MAX_CLIP       = 13,
    GLOCK18_MAX_CLIP    = 20,
    SCOUT_MAX_CLIP      = 10,
    XM1014_MAX_CLIP     = 7,
    MAC10_MAX_CLIP      = 30,
    AUG_MAX_CLIP        = 30,
    ELITE_MAX_CLIP      = 30,
    FIVESEVEN_MAX_CLIP  = 20,
    UMP45_MAX_CLIP      = 25,
    SG550_MAX_CLIP      = 30,
    GALIL_MAX_CLIP      = 35,
    FAMAS_MAX_CLIP      = 25,
    USP_MAX_CLIP        = 12,
    AWP_MAX_CLIP        = 10,
    MP5N_MAX_CLIP       = 30,
    M249_MAX_CLIP       = 100,
    M3_MAX_CLIP         = 8,
    M4A1_MAX_CLIP       = 30,
    TMP_MAX_CLIP        = 30,
    G3SG1_MAX_CLIP      = 20,
    DEAGLE_MAX_CLIP     = 7,
    SG552_MAX_CLIP      = 30,
    AK47_MAX_CLIP       = 30,
    P90_MAX_CLIP        = 50
  );
  TClipSizeType = ClipSizeType;

  WeightWeapon =
  (
    P228_WEIGHT         = 5,
    GLOCK18_WEIGHT      = 5,
    SCOUT_WEIGHT        = 30,
    HEGRENADE_WEIGHT    = 2,
    XM1014_WEIGHT       = 20,
    C4_WEIGHT           = 3,
    MAC10_WEIGHT        = 25,
    AUG_WEIGHT          = 25,
    SMOKEGRENADE_WEIGHT = 1,
    ELITE_WEIGHT        = 5,
    FIVESEVEN_WEIGHT    = 5,
    UMP45_WEIGHT        = 25,
    SG550_WEIGHT        = 20,
    GALIL_WEIGHT        = 25,
    FAMAS_WEIGHT        = 75,
    USP_WEIGHT          = 5,
    AWP_WEIGHT          = 30,
    MP5NAVY_WEIGHT      = 25,
    M249_WEIGHT         = 25,
    M3_WEIGHT           = 20,
    M4A1_WEIGHT         = 25,
    TMP_WEIGHT          = 25,
    G3SG1_WEIGHT        = 20,
    FLASHBANG_WEIGHT    = 1,
    DEAGLE_WEIGHT       = 7,
    SG552_WEIGHT        = 25,
    AK47_WEIGHT         = 25,
    P90_WEIGHT          = 26,
    KNIFE_WEIGHT        = 0
  );
  TWeightWeapon = WeightWeapon;

  MaxAmmoType =
  (
    MAX_AMMO_BUCKSHOT   = 32,
    MAX_AMMO_9MM        = 120,
    MAX_AMMO_556NATO    = 90,
    MAX_AMMO_556NATOBOX = 200,
    MAX_AMMO_762NATO    = 90,
    MAX_AMMO_45ACP      = 100,
    MAX_AMMO_50AE       = 35,
    MAX_AMMO_338MAGNUM  = 30,
    MAX_AMMO_57MM       = 100,
    MAX_AMMO_357SIG     = 52,

    // custom
    MAX_AMMO_SMOKEGRENADE = 1,
    MAX_AMMO_HEGRENADE    = 1,
    MAX_AMMO_FLASHBANG    = 2
  );
  TMaxAmmoType = MaxAmmoType;

  AmmoType =
  (
    AMMO_NONE,
    AMMO_338MAGNUM,
    AMMO_762NATO,
    AMMO_556NATOBOX,
    AMMO_556NATO,
    AMMO_BUCKSHOT,
    AMMO_45ACP,
    AMMO_57MM,
    AMMO_50AE,
    AMMO_357SIG,
    AMMO_9MM,
    AMMO_FLASHBANG,
    AMMO_HEGRENADE,
    AMMO_SMOKEGRENADE,
    AMMO_C4,

    AMMO_MAX_TYPES
  );
  TAmmoType = AmmoType;

  WeaponClassType =
  (
    WEAPONCLASS_NONE,
    WEAPONCLASS_KNIFE,
    WEAPONCLASS_PISTOL,
    WEAPONCLASS_GRENADE,
    WEAPONCLASS_SUBMACHINEGUN,
    WEAPONCLASS_SHOTGUN,
    WEAPONCLASS_MACHINEGUN,
    WEAPONCLASS_RIFLE,
    WEAPONCLASS_SNIPERRIFLE,

    WEAPONCLASS_MAX
  );
  TWeaponClassType = WeaponClassType;

  AmmoBuyAmount =
  (
    AMMO_338MAG_BUY     = 10,
    AMMO_357SIG_BUY     = 13,
    AMMO_45ACP_BUY      = 12,
    AMMO_50AE_BUY       = 7,
    AMMO_556NATO_BUY    = 30,
    AMMO_556NATOBOX_BUY = 30,
    AMMO_57MM_BUY       = 50,
    AMMO_762NATO_BUY    = 30,
    AMMO_9MM_BUY        = 30,
    AMMO_BUCKSHOT_BUY   = 8
  );
  TAmmoBuyAmount = AmmoBuyAmount;

  ItemCostType =
  (
    ASSAULTSUIT_PRICE   = 1000,
    FLASHBANG_PRICE     = 200,
    HEGRENADE_PRICE     = 300,
    SMOKEGRENADE_PRICE  = 300,
    KEVLAR_PRICE        = 650,
    HELMET_PRICE        = 350,
    NVG_PRICE           = 1250,
    DEFUSEKIT_PRICE     = 200
  );
  TItemCostType = ItemCostType;

  shieldgun_e =
  (
    SHIELDGUN_IDLE,
    SHIELDGUN_SHOOT1,
    SHIELDGUN_SHOOT2,
    SHIELDGUN_SHOOT_EMPTY,
    SHIELDGUN_RELOAD,
    SHIELDGUN_DRAW,
    SHIELDGUN_DRAWN_IDLE,
    SHIELDGUN_UP,
    SHIELDGUN_DOWN
  );
  TShieldGun = shieldgun_e;

  // custom
  shieldgren_e =
  (
    SHIELDREN_IDLE = 4,
    SHIELDREN_UP,
    SHIELDREN_DOWN
  );
  TShieldRen = shieldgren_e;

  InventorySlotType =
  (
    NONE_SLOT,
    PRIMARY_WEAPON_SLOT,
    PISTOL_SLOT,
    KNIFE_SLOT,
    GRENADE_SLOT,
    C4_SLOT
  );
  TInventorySlotType = InventorySlotType;

  Bullet =
  (
    BULLET_NONE,
    BULLET_PLAYER_9MM,
    BULLET_PLAYER_MP5,
    BULLET_PLAYER_357,
    BULLET_PLAYER_BUCKSHOT,
    BULLET_PLAYER_CROWBAR,
    BULLET_MONSTER_9MM,
    BULLET_MONSTER_MP5,
    BULLET_MONSTER_12MM,
    BULLET_PLAYER_45ACP,
    BULLET_PLAYER_338MAG,
    BULLET_PLAYER_762MM,
    BULLET_PLAYER_556MM,
    BULLET_PLAYER_50AE,
    BULLET_PLAYER_57MM,
    BULLET_PLAYER_357SIG
  );
  TBullet = Bullet;

type
  MonsterEvent_s = record
    event: Integer;
    options: PAnsiChar;
  end;
  MonsterEvent_t = MonsterEvent_s;

  TMonsterEvent = MonsterEvent_s;
  PMonsterEvent = ^MonsterEvent_s;

  CSaveRestoreBuffer = object
  public
    m_pdata: ^SAVERESTOREDATA;
  end;

  CSave = object(CSaveRestoreBuffer)
  public
  end;

  CRestore = object(CSaveRestoreBuffer)
  public
    m_global: Integer;
    m_precache: Integer;
  end;

  VBaseEntity = object
  public
    Spawn: procedure; stdcall;
    Precache: procedure; stdcall;
    Restart: procedure; stdcall;
    KeyValue: procedure(pkvd: PKeyValueData); stdcall;
    Save: function(const save: CSave): Integer; stdcall;
    Restore: function(const restore: CRestore): Integer; stdcall;
    ObjectCaps: function: Integer; stdcall;
    Activate: procedure; stdcall;

	  // Setup the object->object collision box (pev->mins / pev->maxs is the object->world collision box)
	  SetObjectCollisionBox: procedure; stdcall;

    // Classify - returns the type of group (i.e, "houndeye", or "human military" so that monsters with different classnames
    // still realize that they are teammates. (overridden for monsters that form groups)
    Classify: function: Integer; stdcall;

    DeathNotice: procedure(const pevChild: entvars_t); stdcall;
    TraceAttack: procedure(const pevAttacker: entvars_t; flDamage: Single; vecDir: Vector; const ptr: TraceResult; bitsDamageType: Integer); stdcall;

    TakeDamage: function(pevInflictor, pevAttacker: PEntVars; flDamage: Single; bitsDamageType: Integer): BOOL; stdcall;
    TakeHealth: function(flHealth: Single; bitsDamageType: Integer): BOOL; stdcall;
    Killed: procedure(const pevAttacker: entvars_t; iGib: Integer); stdcall;
    BloodColor: function: Integer; stdcall;
    TraceBleed: procedure(flDamage: Single; vecDir: Vector; const ptr: TraceResult; bitsDamageType: Integer); stdcall;
    IsTriggered: function(pActivator: Pointer {CBaseEntity}): BOOL; stdcall;
    MyMonsterPointer: function: Pointer {CBaseMonster}; stdcall;
    MySquadMonsterPointer: function: Pointer {CSquadMonster}; stdcall;
    GetToggleState: function: Integer; stdcall;
    AddPoints: procedure(score: Integer; bAllowNegativeScore: BOOL);
    AddPointsToTeam: procedure(score: Integer; bAllowNegativeScore: BOOL);
    AddPlayerItem: function(pItem: Pointer {CBasePlayerItem}): BOOL; stdcall;
    RemovePlayerItem: function(pItem: Pointer {CBasePlayerItem}): BOOL; stdcall;
    GiveAmmo: function(iAmount: Integer; szName: PAnsiChar; iMax: Integer = -1): Integer; stdcall;
    GetDelay: function: Single; stdcall;
    IsMoving: function: Integer; stdcall;
    OverrideReset: procedure; stdcall;
    DamageDecal: function(bitsDamageType: Integer): Integer; stdcall;

    // This is ONLY used by the node graph to test movement through a door
    SetToggleState: procedure(state: Integer); stdcall;

    StartSneaking: procedure; stdcall;
    StopSneaking: procedure; stdcall;

    OnControls: function(const onpev: entvars_t): BOOL; stdcall;
    IsSneaking: function: BOOL; stdcall;
    IsAlive: function: BOOL; stdcall;
    IsBSPModel: function: BOOL; stdcall;
    ReflectGauss: function: BOOL; stdcall;
    HasTarget: function(targetname: string_t): BOOL; stdcall;
    IsInWorld: function: BOOL; stdcall;
    IsPlayer: function: BOOL; stdcall;
    IsNetClient: function: BOOL; stdcall;
    TeamID: function: PAnsiChar; stdcall;
    GetNextTarget: function: Pointer {CBaseEntity}; stdcall;
    Think: procedure; stdcall;
    Touch: procedure(pOther: Pointer {CBaseEntity}); stdcall;
    Use: procedure(pActivator, pCaller: Pointer {CBaseEntity}; useType: USE_TYPE = USE_OFF; value: Single = 0.0); stdcall;
    Blocked: procedure(pOther: Pointer {CBaseEntity}); stdcall;
    Respawn: function: Pointer {CBaseEntity}; stdcall;

    // used by monsters that are created by the MonsterMaker
    UpdateOwner: procedure; stdcall;
    FBecomeProne: function: BOOL; stdcall;

    Center: function: Vector; stdcall; // center point of entity
    EyePosition: function: Vector; stdcall; { return (pev->origin + pev->view_ofs); }		// position of eyes
    EarPosition: function: Vector; stdcall; { return (pev->origin + pev->view_ofs); }		// position of ears
    BodyTarget: function(const posSrc: Vector): Vector;	// position to shoot at

    Illumination: function: Integer; stdcall;

    FVisibleByEnt: function(pEntity: Pointer {CBaseEntity}): BOOL; stdcall;
    FVisibleByVec: function(const vecOrigin: Vector): BOOL; stdcall;
  end;

  PVBaseEntity = ^VBaseEntity;
  CBaseEntity = ^PVBaseEntity;

  VBaseDelay = object(VBaseEntity)
  public

  end;

  PVBaseDelay = ^VBaseDelay;
  CBaseDelay = ^PVBaseDelay;

  VBaseAnimating = object(VBaseDelay)
  public
    HandleAnimEvent: procedure(pEvent: PMonsterEvent); stdcall;
  end;

  PVBaseAnimating = ^VBaseAnimating;
  CBaseAnimating = ^PVBaseAnimating;

  VBaseToggle = object(VBaseAnimating)
  public
    ChangeYaw: function(speed: Integer): Single; stdcall;
    HasHumanGibs: function: BOOL; stdcall;
    HasAlienGibs: function: BOOL; stdcall;
    FadeMonster: procedure; stdcall;
    GibMonster: procedure; stdcall;
    GetDeathActivity: function: Activity; stdcall;
    BecomeDead: procedure; stdcall;
    ShouldFadeOnDeath: function: BOOL; stdcall;
    IRelationship: function(pTarget: Pointer {CBaseEntity}): Integer;
    PainSound: procedure; stdcall;
    ResetMaxSpeed: procedure; stdcall;
    ReportAIState: procedure; stdcall;
    MonsterInitDead: procedure; stdcall;
    Look: procedure(iDistance: Integer); stdcall;
    BestVisibleEnemy: function: Pointer {CBaseEntity}; stdcall;
    FInViewConeByEnt: function(pEntity: Pointer {CBaseEntity}): Vector; stdcall;
    FInViewConeByVec: function(const pOrigin: Vector): Vector; stdcall;
  end;

  PVBaseToggle = ^VBaseToggle;
  CBaseToggle = ^PVBaseToggle;

  VBasePlayer = object(VBaseToggle)
  public
    Jump: procedure; stdcall;
    Duck: procedure; stdcall;
    PreThink: procedure; stdcall;
    PostThink: procedure; stdcall;
    GetGunPosition: function: Vector; stdcall;
    IsBot: function: BOOL; stdcall;
    UpdateClientData: procedure; stdcall;
    ImpulseCommands: procedure; stdcall;
    RoundRespawn: procedure; stdcall;
    GetAutoaimVector: function(flDelta: Single): Vector; stdcall;
    Blind: procedure(flUntilTime, flHoldTime, flFadeTime: Single; iAlpha: Integer); stdcall;
    OnTouchingWeapon: procedure(pWeapon: Pointer {CWeaponBox}); stdcall;
  end;

  PVBasePlayer = ^VBasePlayer;
  CBasePlayer = ^PVBasePlayer;

  VGuiLibraryPlayer_t = record
    name: PAnsiChar;
    ping: Integer;
    packetloss: Integer;
    thisplayer: Boolean;
    teamname: PAnsiChar;
    teamnumber: Integer;
    frags: Integer;
    deaths: Integer;
    playerclass: Integer;
    health: Integer;
    dead: Boolean;
    m_nSteamID: UInt64;
  end;

  TVGuiLibraryPlayer = VGuiLibraryPlayer_t;
  PVGuiLibraryPlayer = ^VGuiLibraryPlayer_t;
  {$IF SizeOf(TVGuiLibraryPlayer) <> 56} {$MESSAGE WARN 'Type size mismatch @ TVGuiLibraryPlayer.'} {$DEFINE MSME} {$IFEND}

  ININTERMISSION = function: Integer; cdecl;
  SPECTATOR_FINDNEXTPLAYER = procedure(reverse: Boolean); cdecl;
  SPECTATOR_FINDPLAYER = procedure(name: PAnsiChar); cdecl;
  SPECTATOR_PIPINSETOFF = function: Integer; cdecl;
  SPECTATOR_INSETVALUES = procedure(out x, y, wide, tall: Integer); cdecl;
  SPECTATOR_CHECKSETTINGS = procedure; cdecl;
  SPECTATOR_NUMBER = function: Integer; cdecl;
  SPECTATOR_ISSPECTATEONLY = function: Boolean; cdecl;
  HUDTIME = function: Single; cdecl;
  MESSAGE_ADD = procedure; cdecl;
  MESSAGE_HUD = procedure(c: PAnsiChar; iSize: Integer; pbuf: Pointer); cdecl;
  TEAMPLAY = function: Integer; cdecl;
  CLIENTCMD = procedure(cmd: PAnsiChar); cdecl;
  TEAMNUMBER = function: Integer; cdecl;
  GETLEVELNAME = function: PAnsiChar; cdecl;
  COMPARSEFILE = function(data, token: PAnsiChar): PAnsiChar; cdecl;
  COMLOADFILE = function(path: PAnsiChar; usehunk: Integer; var pLength: Integer): PByte; cdecl;
  COMFREEFILE = procedure; cdecl;
  COMFILEBASE = procedure(&in, &out: PAnsiChar); cdecl;
  CONDPRINTF = procedure(fmt: PAnsiChar); cdecl varargs;
  //GETPLAYERINFO = function(index: Integer): VGuiLibraryPlayer_t; cdecl;
  GETPLAYERINFO = procedure(var ply: VGuiLibraryPlayer_t; index: Integer); cdecl;
  GETMAXPLAYERS = function: Integer; cdecl;
  SPECTATOR_ISSPECTATING = function: Boolean; cdecl;
  SPECTATOR_SPECTATORMODE = function: Integer; cdecl;
  SPECTATOR_SPECTATORTARGET = function: Integer; cdecl;
  GETLOCALPLAYERINDEX = function: Integer; cdecl;
  VOICESTOPSQUELCH = procedure; cdecl;
  DEMOPLAYBACK = function: Boolean; cdecl;
  CVARGETFLOAT = function(cvar: PAnsiChar): Single; cdecl;

  VGuiLibraryInterface_t = record
    InIntermission: ININTERMISSION;
    FindNextPlayer: SPECTATOR_FINDNEXTPLAYER;
    FindPlayer: SPECTATOR_FINDPLAYER;
    PipInsetOff: SPECTATOR_PIPINSETOFF;
    InsetValues: SPECTATOR_INSETVALUES;
    CheckSettings: SPECTATOR_CHECKSETTINGS;
    SpectatorNumber: SPECTATOR_NUMBER;
    IsSpectator: SPECTATOR_ISSPECTATING;
    SpectatorMode: SPECTATOR_SPECTATORMODE;
    SpectatorTarget: SPECTATOR_SPECTATORTARGET;
    IsSpectateOnly: SPECTATOR_ISSPECTATEONLY;
    HudTime: HUDTIME;
    MessageAdd: MESSAGE_ADD;
    MessageHud: MESSAGE_HUD;
    TeamPlay: TEAMPLAY;
    CallEnghudClientCmd: CLIENTCMD;
    TeamNumber: TEAMNUMBER;
    GetLevelName: GETLEVELNAME;
    GetLocalPlayerIndex: GETLOCALPLAYERINDEX;
    COM_ParseFile: COMPARSEFILE;
    COM_LoadFile: COMLOADFILE;
    COM_FreeFile: COMFREEFILE;
    COM_FileBase: COMFILEBASE;
    Con_DPrintf: CONDPRINTF;
    CallEnghudGetPlayerInfo: GETPLAYERINFO;
    GetMaxPlayers: GETMAXPLAYERS; // always returns 64
    GameVoice_StopSquelchMode: VOICESTOPSQUELCH;
    IsDemoPlayingBack: DEMOPLAYBACK;
    CvarGetFloat: CVARGETFLOAT;
  end;

  TVGuiLibraryInterface = VGuiLibraryInterface_t;
  PVGuiLibraryInterface = ^VGuiLibraryInterface_t;

  // @todo: finish it
  CClientMOTD = record
  private
  {$HINTS OFF}
    dummy: array[0..$10C - 1] of Byte;
  {$HINTS ON}
  public
    m_pMessage: Pointer {vgui2::HTML};
    m_pServerName: Pointer {vgui2::Label};
    m_bFileWritten: Boolean;
    m_szTempFileName: array[0..MAX_PATH - 1] of AnsiChar;
    m_iScoreBoardKey: Integer;
  end;

  CUtlQueue = record
    dummy: array[0..23] of Byte;
  end;

  // @note: must be 'object' to inherit to ScoreBoardTeamInfo
  VGuiLibraryTeamInfo_t = object
  public
    name: PAnsiChar;
    frags: Integer;
    deaths: Integer;
    ping: Integer;
    players: Integer;
    packetloss: Integer;
    teamnumber: Integer;
  end;

  TVGuiLibraryTeamInfo = VGuiLibraryTeamInfo_t;
  PVGuiLibraryTeamInfo = ^VGuiLibraryTeamInfo_t;

  ScoreBoardTeamInfo = object(VGuiLibraryTeamInfo_t)
  public
    already_drawn: Boolean;
    scores_overriden: Boolean;
    ownteam: Boolean;
  end;

  PVTableClientScoreBoardDialog = ^VTableClientScoreBoardDialog;
  VTableClientScoreBoardDialog = object(VTableFrame)
  public
    Reset: procedure; stdcall;
    Update: procedure(servername: PAnsiChar; teamplay, spectator: Boolean); stdcall;
    RebuildTeams: procedure(servername: PAnsiChar; teamplay, spectator: Boolean); stdcall;
    DeathMsg: procedure(killer, victim: Integer); stdcall;
    ActivateEx: procedure(spectatorUIVisible: Boolean); stdcall; // original name is 'Activate'
    SetTeamName: procedure(index: Integer; name: PAnsiChar); stdcall;
    SetTeamDetails: procedure(index, frags, deaths: Integer); stdcall;
    GetTeamName: function(index: Integer): PAnsiChar; stdcall;
    GetPlayerTeamInfo: function(playerIndex: Integer): VGuiLibraryTeamInfo_t; stdcall;
    GetPlayerScoreInfo: function(playerIndex: Integer; kv: Pointer {PKeyValues}): Boolean; stdcall;
    InitScoreboardSections: procedure; stdcall;
    UpdateTeamInfo: procedure; stdcall;
    UpdatePlayerInfo: procedure; stdcall;
    GetTeamColor: function(teamNumber: Integer): Color; stdcall;
    AddHeader: procedure; stdcall;
    AddSection: procedure(teamType: Integer; const team_info: VGuiLibraryTeamInfo_t); stdcall;
  end;

  // @todo: Inherit from DTableFrame
  PDTableClientScoreBoardDialog = ^DTableClientScoreBoardDialog;
  DTableClientScoreBoardDialog = object{DTableFrame}
  private
  {$HINTS OFF}
    Pad: array[0..272 - 1] of Byte;
  {$HINTS ON}
  public
    m_iNumTeams: Integer;
    m_pPlayerList: ^SectionedListPanel;
    m_iSectionId: Integer;
    s_VoiceImage: array[0..4] of Integer;
    TrackerImage: Integer;
    m_TeamInfo: array[0..4] of ScoreBoardTeamInfo;
    m_BlankTeamInfo: ScoreBoardTeamInfo;
    m_iPlayerIndexSymbol: Integer;
    m_iDesiredHeight: Integer;
  end;
  {$IF SizeOf(DTableClientScoreBoardDialog) <> 508} {$MESSAGE WARN 'Structure size mismatch @ DTableClientScoreBoardDialog.'} {$DEFINE MSME} {$IFEND}

  CClientScoreBoardDialog = ^PVTableClientScoreBoardDialog;

  PVTableCSClientScoreBoardDialog = ^VTableCSClientScoreBoardDialog;
  VTableCSClientScoreBoardDialog = object(VTableClientScoreBoardDialog)
  public
    // Adds nothing, just reimplements some parent's methods
  end;

  PDTableCSClientScoreBoardDialog = ^DTableCSClientScoreBoardDialog;
  DTableCSClientScoreBoardDialog = object(DTableClientScoreBoardDialog)
  public
    type
      Avatars = record
        m_iAvatar: Integer;
        m_iImageList: Integer;
      end;
  public
    m_pTopLeftPanel: ^CBitmapImagePanel;
    m_pTopRightPanel: ^CBitmapImagePanel;
    m_pBottomLeftPanel: ^CBitmapImagePanel;
    m_pBottomRightPanel: ^CBitmapImagePanel;
    m_pTopLeftBorderPanel: ^CBitmapImagePanel;
    m_pTopRightBorderPanel: ^CBitmapImagePanel;
    m_pBottomLeftBorderPanel: ^CBitmapImagePanel;
    m_pBottomRightBorderPanel: ^CBitmapImagePanel; // this stair is just right...

    m_careerBgColor: Color;
    m_borderColor: Color;

    m_pTaskLabel: ^VLabel;
    m_pIGA: ^IClientPanel;

    m_pImageList: ^ImageList;
    m_iImageAvatars: array[0..64] of Avatars;

    m_iPlayersToShow: Integer;

    m_pShowHealth: ^cvar_s;
    m_bHealthColumnEnabled: Boolean;
    m_bHealthUpdateReceived: Boolean;

    m_pShowMoney: ^cvar_s;
    m_bMoneyColumnEnabled: Boolean;
    m_bMoneyUpdateReceived: Boolean;

    m_pShortHeaders: ^cvar_s;
    m_bShortHeaders: Boolean;
    m_pShowAvatars: ^cvar_s;

    m_bAvatarColumnEnabled: Boolean;
    m_nAvatarColumnWidth: Integer;
  end;
  {$IF SizeOf(DTableCSClientScoreBoardDialog) <> 1120} {$MESSAGE WARN 'Structure size mismatch @ DTableCSClientScoreBoardDialog.'} {$DEFINE MSME} {$IFEND}

  CCSClientScoreBoardDialog = ^PVTableCSClientScoreBoardDialog;

  PVTableIScoreBoardInterface = ^VTableIScoreBoardInterface;
  VTableIScoreBoardInterface = record
    Reset: procedure; stdcall;
    Update: procedure(servername: PAnsiChar; teamplay, spectator: Boolean); stdcall;
    RebuildTeams: procedure(servername: PAnsiChar; teamplay, spectator: Boolean); stdcall;
    DeathMsg: procedure(killer, victim: Integer); stdcall;
    Activate: procedure(spectatorUIVisible: Boolean); stdcall;
    MoveToFront: procedure; stdcall;
    IsVisible: function: Boolean; stdcall;
    SetVisible: procedure(state: Boolean); stdcall;
    SetParent: procedure(parent: VPANEL); stdcall;
    SetMouseInputEnabled: procedure(state: Boolean); stdcall;
    SetTeamName: procedure(index: Integer; name: PAnsiChar); stdcall;
    SetTeamDetails: procedure(index, frags, deaths: Integer); stdcall;
    GetTeamName: procedure(index: Integer); stdcall;
    GetPlayerTeamInfo: function(playerIndex: Integer): VGuiLibraryTeamInfo_t; stdcall;
  end;

  IScoreBoardInterface = ^PVTableIScoreBoardInterface;

const // for ShowVGUIMenu
  MENU_DEFAULT = 1;
  MENU_TEAM = 2;
  MENU_CLASS = 3;
  MENU_MAPBRIEFING = 4;
  MENU_INTRO = 5;
  MENU_CLASSHELP = 6;
  MENU_CLASSHELP2 = 7;
  MENU_REPEATHELP = 8;
  MENU_SPECHELP = 9;

{$REGION}
type
  PVTeamFortressViewport = ^VTeamFortressViewport;
  VTeamFortressViewport = object
  public
    GetClientDllInterface: function: PVGuiLibraryInterface; stdcall;
    SetClientDllInterface: procedure(const clientInterface: VGuiLibraryInterface_t); stdcall;
    UpdateScoreBoard: procedure; stdcall;
    AllowedToPrintText: function: Boolean; stdcall;
    GetAllPlayersInfo: procedure; stdcall; // does nothing
    DeathMsg: procedure(killer, victim: Integer) stdcall;
    ShowScoreBoard: procedure; stdcall;
    CanShowScoreBoard: function: Boolean; stdcall;
    HideAllVGUIMenu: procedure; stdcall;
    UpdateSpectatorPanel: procedure; stdcall;

    IsScoreBoardVisible: function: Boolean; stdcall;
    HideScoreBoard: procedure; stdcall;

    KeyInput: function(down, keynum: Integer; pszCurrentBinding: PAnsiChar): Integer; stdcall;

    ShowVGUIMenu: procedure(iMenu: Integer); stdcall;
    HideVGUIMenu: procedure(iMenu: Integer); stdcall;

    ShowTutorTextWindow: procedure(szString: PWideChar; id, msgClass, isSpectator: Integer); stdcall;
    ShowTutorLine: procedure(entindex, id: Integer); stdcall;
    ShowTutorState: procedure(szString: PWideChar); stdcall;
    CloseTutorTextWindow: procedure; stdcall;
    IsTutorTextWindowOpen: function: Boolean; stdcall;

    ShowSpectatorGUI: procedure; stdcall;
    ShowSpectatorGUIBar: procedure; stdcall;
    HideSpectatorGUI: procedure; stdcall;
    DeactivateSpectatorGUI: procedure; stdcall;
    IsSpectatorGUIVisible: function: Boolean; stdcall;
    IsSpectatorBarVisible: function: Boolean; stdcall;

    MsgFunc_ResetFade: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;

    SetSpectatorBanner: procedure(image: PAnsiChar); stdcall;
    SpectatorGUIEnableInsetView: procedure(value: Integer); stdcall;

    ShowCommandMenu: procedure; stdcall;
    UpdateCommandMenu: procedure; stdcall;
    HideCommandMenu: procedure; stdcall;
    IsCommandMenuVisible: function: Integer; stdcall;

    GetValidClasses: function(iTeam: Integer): Integer; stdcall;
    GetNumberOfTeams: function: Integer; stdcall;

    GetIsFeigning: function: Boolean; stdcall;
    GetIsSettingDetpack: function: Integer; stdcall;
    GetBuildState: function: Integer; stdcall;

    IsRandomPC: function: Integer; stdcall;

    GetTeamName: function(iTeam: Integer): PAnsiChar; stdcall;
    GetCurrentMenuID: function: Integer; stdcall;
    GetMapName: function: PAnsiChar; stdcall;
    GetServerName: function: PAnsiChar; stdcall;

    InputPlayerSpecial: procedure; stdcall;

    OnTick: procedure; stdcall;

    GetViewPortScheme: function: Integer; stdcall;
    GetViewPortPanel: function: VPANEL; stdcall;
    GetAllowSpectators: function: Integer; stdcall;

    OnLevelChange: procedure; stdcall;

    HideBackGround: procedure; stdcall;

    ChatInputPosition: procedure(var x, y: Integer); stdcall;

    GetSpectatorBottomBarHeight: function: Integer; stdcall;
    GetSpectatorTopBarHeight: function: Integer; stdcall;

    SlotInput: function(iSlot: Integer): Boolean; stdcall;
    GetPlayerTeamInfo: function(playerIndex: Integer): VGuiLibraryTeamInfo_t; stdcall;
    MakeSafeName: procedure(oldName, newName: PAnsiChar; newNameBufSize: Integer); stdcall;

    SetNumberOfTeams: procedure(num: Integer); stdcall;

    IsVGUIMenuActive: function(iMenu: Integer): Boolean; stdcall;
    IsAnyVGUIMenuActive: function: Boolean; stdcall;
    DisplayVGUIMenu: procedure(iMenu: Integer); stdcall;
  end;

  VIViewPortMsgs = object
  public
    MsgFunc_ValClass: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TeamNames: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_Feign: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_Detpack: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_VGUIMenu: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TutorText: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TutorLine: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TutorState: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TutorClose: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_MOTD: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_BuildSt: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_RandomPC: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_ServerName: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_ScoreInfo: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TeamScore: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_TeamInfo: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_Spectator: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_AllowSpec: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_SpecFade: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
  end;

  TeamFortressViewport = ^PVTeamFortressViewport;

  PVIClientVGUI = ^VIClientVGUI;
  VIClientVGUI = object(VIBaseInterface)
  public
    Initialize: procedure(factories: Pointer {CreateInterfaceFn}; count: Integer); stdcall;
    Start: procedure; stdcall;
    Shutdown: procedure; stdcall;

    SetParent: procedure(parent: VPANEL); stdcall;

    UseVGUI1: function: Boolean; stdcall; // always false
    ActivateClientUI: procedure; stdcall; // does nothing
    HideClientUI: procedure; stdcall; // does nothing
  end;

  PVCounterStrikeViewport = ^VCounterStrikeViewport;
  VCounterStrikeViewport = object(VTeamFortressViewport)
  public
    GetForceCamera: function: Integer; stdcall;

    MsgFunc_ForceCam: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;
    MsgFunc_Location: function(pszName: PAnsiChar; iSize: Integer; pbuf: Pointer): Integer; stdcall;

    UpdateBuyPresets: procedure; stdcall;
    UpdateScheme: procedure; stdcall;

    IsProgressBarVisible: function: Boolean; stdcall;
    StartProgressBar: procedure(title: PAnsiChar; numTicks, startTicks: Integer; isTimeBased: Boolean); stdcall;
    UpdateProgressBar: procedure(statusText: PAnsiChar; tick: Integer); stdcall;
    StopProgressBar: procedure; stdcall;
  end;

  CounterStrikeViewport = ^PVCounterStrikeViewport;
{$ENDREGION}

  DTeamFortressViewport = object
  public
    ViewPort: Pointer {IViewPort};
    ClientVGUI: Pointer {IClientVGUI};
    ViewPortMsgs: Pointer {IViewPortMsgs};

    m_sTeamNames: array[0..4] of PAnsiChar;
    m_pMOTD: ^CClientMOTD;
    m_pSpectatorGUI: Pointer {ISpectatorInterface};
    m_pClientScoreBoard: Pointer {IScoreBoardInterface};
    m_pTeamMenu: Pointer {CTeamMenu};
    m_pClassMenu: Pointer {CClassMenu};
    m_pCommandMenu: Pointer {CCommandMenu};
    m_pMapBriefing: Pointer {CVGUITextWindow};
    m_pClassHelp: Pointer {CVGUITextWindow};
    m_pTutorWindowManager: Pointer {TutorWindowManager};
    m_pSpecHelp: Pointer {TeamFortressViewport::CSpecHelpWindow};
    m_pBackGround: Pointer {TeamFortressViewport::CBackGroundPanel};
    m_bInitialized: Boolean; // +72, cf
    m_FactoryList: array[0..4] of Pointer {TCreateInterfaceFn};
    m_pPrivateSpectatorGUI: Pointer {CSpectatorGUI};
    m_pPrivateClientScoreBoard: CClientScoreBoardDialog;
    m_PendingDialogs: CUtlQueue {CUtlQueue<Integer>};
    m_szServerName: array[0..31] of AnsiChar;
    m_szMOTD: array[0..MAX_MOTD_LENGTH - 1] of AnsiChar;
    m_iNumTeams: Integer;
    m_iGotAllMOTD: Integer;
    m_iAllowSpectators: Integer;
    m_sMapName: array[0..63] of AnsiChar;
    m_iValidClasses: array[0..4] of Integer;
    m_bIsFeigning: Boolean;
    m_iIsSettingDetpack: Integer;
    m_iBuildState: Integer;
    m_iRandomPC: Integer;
    m_flScoreBoardLastUpdated: Single;
    m_iCurrentTeamNumber: Integer;
    m_iUser1: Integer;
    m_iUser2: Integer;
    m_pClientDllInterface: ^VGuiLibraryInterface_t;
  end;
  {$IF SizeOf(DTeamFortressViewport) <> 1832} {$MESSAGE WARN 'Structure size mismatch @ DTeamFortressViewport.'} {$DEFINE MSME} {$IFEND}

  DCounterStrikeViewport = object(DTeamFortressViewport)
  public
    CSViewPort: Pointer {ICSViewPort};
    CSViewPortMsgs: Pointer {ICSViewPortMsgs};
    m_pCSBackGround: Pointer {CounterStrikeViewport::CCSBackGroundPanel};
    m_pTeamMenu_CS: Pointer {CCSTeamMenu};
    m_pClassMenu_CS: Pointer {CCSClassMenu};
    m_pBuyMenu: Pointer {CBuyMenu};
    m_pPrivateSpectatorGUI_CS: Pointer {CCSSpectatorGUI};
    m_pPrivateCSClientScoreBoard: CCSClientScoreBoardDialog;
    m_pCareerRoundEndMenu: Pointer {CCSCareerRoundEndMenu};
    m_pCareerMatchEndMenu: Pointer {CCSCareerMatchEndMenu};
    m_pCreditsMenu: Pointer {CCSCreditsMenu};
    m_pBuyPresetMainMenu: Pointer {CBuyPresetEditMainMenu};
    m_pBuyPresetEditMenu: Pointer {CBuyPresetEditMenu};
    m_pProgressBar: Pointer {CCSProgressBar};
    m_iForceCamera: Integer;
    m_iForceChaseCam: Integer;
    m_iFadeToBlack: Integer;
    m_bOldStyleMenus: Boolean;
    m_inClientUI: Boolean;
  end;
  {$IF SizeOf(DCounterStrikeViewport) <> 1904} {$MESSAGE WARN 'Structure size mismatch @ DCounterStrikeViewport.'} {$DEFINE MSME} {$IFEND}

implementation

end.
