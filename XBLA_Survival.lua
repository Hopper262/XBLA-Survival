-- XBLA Survival 2.1
-- design by Freeverse
-- coding by Hopper

-- load all survival monsters
CollectionsUsed = { 2, 5, 8, 9, 10, 11, 12, 14, 15, 16, 31 }

-- round timings
first_round_start = 15*30
later_round_start = 60*30
last_round = 10

-- cancel initial monster drops
Game.monsters_replenish = false

-- cancel initial health drops
for _, name in ipairs({ "single health", "double health", "triple health" }) do
  local it = ItemTypes[name]
  it.initial_count = 0
  it.total_available = 0
end

Triggers = {}

function Triggers.init(restoring_game)
  if #Players > 1 then
    Triggers = {}
    return
  end
  if restoring_game then
    Players.print("XBLA Survival does not work with saved games")
    Triggers = {}
    return
  end
    
  current_ticks = 0
  current_round = 0
  current_score = 0
  game_finished = false
  AdjustItemPhysics()
  AdjustMonsterPhysics()
--   Game.monsters_replenish = true
end

function Triggers.monster_damaged(monster, aggressor_monster, damage_type, damage_amount, projectile)
  if monster.player then return end
  if aggressor_monster == nil then return end
  if not aggressor_monster.player then return end
  
  local amt = damage_amount
  if monster.vitality < 0 then amt = amt + monster.vitality end
  current_score = current_score + amt
end

function Triggers.monster_killed(monster, aggressor_player, projectile)
  if game_finished then return end
  if monster.player then return end
  ReplaceMonster(monster.type)
end

first_idle = true
function Triggers.idle()
  if first_idle then
    first_idle = false
    
    local df = maintitle(Game.difficulty.mnemonic)
    for p in Players() do
      p.overlays[0].text = df
    end
  end
  
  if Players[0].dead then game_finished = true end
  if not game_finished then
    current_ticks = Game.ticks
    if current_ticks < first_round_start then
      -- do nothing
    elseif current_ticks == first_round_start then
      LaunchRound(1)
    elseif (current_ticks % later_round_start) == 0 then
      LaunchRound(1 + math.floor(current_ticks / later_round_start))
    end
    
    -- replenish monsters ourselves, since XBLA changed the placement logic
    -- (monsters teleport in, and will do so in visible locations)
    if (Game.ticks % (15*30)) == 1 then
      ReplaceMonsters()
    end
  end
  
  -- format overlays
  if current_round > 0 then
    local tm = string.format("Time: %s", format_time(current_ticks))
    local sc = string.format("Score: %d", current_score)
    local rd = string.format("Round %d", current_round)
  
    for p in Players() do
      p.overlays[1].text = rd
      p.overlays[2].text = tm
      p.overlays[3].text = sc
    end
  else
    local tm = string.format("Starting in: %s", format_time(first_round_start - current_ticks))
    
    for p in Players() do
      p.overlays[1].text = tm
    end
  end
end

function maintitle(str)
  local title = "Survival " .. string.upper(string.sub(str, 1, 1))
  local st, fn = string.find(str, " ")
  if st ~= nil then
    title = title .. string.upper(string.sub(str, fn + 1, fn + 1))
  end
  return title
end

function format_time(ticks)
   local secs = math.ceil(ticks / 30)
   return string.format("%d:%02d", math.floor(secs / 60), secs % 60)
end

function AdjustItemPhysics()
  for _, name in ipairs({ "single health", "double health", "triple health" }) do
    local it = ItemTypes[name]
    it.initial_count = 0
    it.minimum_count = 0
    it.maximum_count = -1
    it.random_chance = 0
    it.random_location = false
    it.total_available = -1
  end
end

function AdjustMonsterPhysics()
  -- get those S'pht'Kr moving
  MonsterTypes["minor defender"].attacks_immediately = true
  MonsterTypes["minor defender"].waits_with_clear_shot = false
  MonsterTypes["major defender"].attacks_immediately = true
  MonsterTypes["major defender"].waits_with_clear_shot = false
  
  -- prevent promotion/demotion: variety is the spice of life
  -- also turn off default random spawns
  for mt in MonsterTypes() do
    mt.major = false
    mt.minor = false
    mt.minimum_count = 0
    mt.maximum_count = 0
    mt.total_available = 0
  end
  
  -- rebuild monster enemy lists to focus their hate
  for _, name in ipairs({
      "minor defender", "major defender", "explodabob",
      "sewage yeti", "water yeti", "lava yeti",
      "mother of all hunters",
      "minor fighter", "major fighter",
      "minor projectile fighter", "major projectile fighter",
      "minor compiler", "major compiler",
      "minor drone", "major drone",
      "minor cyborg", "major cyborg",
      "minor flame cyborg", "major flame cyborg",
      "minor hunter", "major hunter",
      "minor trooper", "major trooper" }) do
    mt = MonsterTypes[name]
    for mc in MonsterClasses() do
      mt.enemies[mc] = false
    end
    mt.enemies["player"] = true
  end
  for _, name in ipairs({
      "sewage yeti", "water yeti", "lava yeti",
      "mother of all hunters",
      "minor fighter", "major fighter",
      "minor projectile fighter", "major projectile fighter",
      "minor compiler", "major compiler",
      "minor drone", "major drone",
      "minor cyborg", "major cyborg",
      "minor flame cyborg", "major flame cyborg",
      "minor hunter", "major hunter",
      "minor trooper", "major trooper" }) do
    mt = MonsterTypes[name]
    for eidx, ename in ipairs({
        "bob", "madd", "possessed drone" }) do
      mt.enemies[ename] = true
    end
  end
  for _, name in ipairs({
      "sewage yeti", "water yeti", "lava yeti" }) do
    mt = MonsterTypes[name]
    for _, ename in ipairs({
        "fighter", "trooper", "hunter", "enforcer", "juggernaut" }) do
      mt.enemies[ename] = true
    end
  end
  for _, name in ipairs({
      "minor fighter", "major fighter",
      "minor projectile fighter", "major projectile fighter",
      "minor compiler", "major compiler",
      "minor drone", "major drone",
      "minor cyborg", "major cyborg",
      "minor flame cyborg", "major flame cyborg",
      "minor hunter", "major hunter",
      "minor trooper", "major trooper" }) do
    mt = MonsterTypes[name]
    for _, ename in ipairs({
        "tick", "yeti" }) do
      mt.enemies[ename] = true
    end
  end
end

function DeployMonster(mtype, min, max)
  local mt = MonsterTypes[mtype]
  mt.minimum_count = min
  mt.maximum_count = max
  mt.random_chance = -1
  mt.total_available = -1
  mt.random_location = true
end

function RemoveMonster(mtype)
  local mt = MonsterTypes[mtype]
  mt.minimum_count = 0
  mt.total_available = 1
end

function DeployPowerup(itype)
  local poly = choose_invisible_random_point()
  if poly then
    Items.new(poly.x, poly.y, 0, poly, ItemTypes[itype])
  end
end

function LaunchRound(round)
  if round == 1 then
    DeployMonster("minor fighter", 4, 8)
    DeployMonster("major fighter", 4, 8)
    DeployMonster("minor projectile fighter", 4, 8)
    DeployMonster("major projectile fighter", 4, 8)
  elseif round == 2 then
    DeployPowerup("double health")
    RemoveMonster("minor fighter")
    RemoveMonster("major fighter")
    DeployMonster("minor drone", 2, 4)
    DeployMonster("major drone", 2, 4)
  elseif round == 3 then
    DeployPowerup("triple health")
    RemoveMonster("minor projectile fighter")
    RemoveMonster("major projectile fighter")
    DeployMonster("explodabob", 4, 8)
    DeployMonster("sewage yeti", 4, 8)
  elseif round == 4 then
    RemoveMonster("minor drone")
    RemoveMonster("major drone")
    DeployMonster("minor defender", 1, 2)
    DeployMonster("minor compiler", 1, 2)
    DeployMonster("major compiler", 1, 2)
    DeployMonster("water yeti", 2, 4)
    DeployMonster("lava yeti", 2, 4)
  elseif round == 5 then
    RemoveMonster("explodabob")
    RemoveMonster("sewage yeti")
    DeployMonster("minor cyborg", 1, 2)
    DeployMonster("major cyborg", 1, 2)
    DeployMonster("minor flame cyborg", 1, 2)
    DeployMonster("major flame cyborg", 1, 2)
  elseif round == 6 then
    DeployPowerup("triple health")
    RemoveMonster("minor compiler")
    RemoveMonster("major compiler")
    RemoveMonster("minor defender")
    RemoveMonster("water yeti")
    RemoveMonster("lava yeti")
    RemoveMonster("minor cyborg")
    RemoveMonster("minor flame cyborg")
    DeployMonster("major cyborg", 2, 3)
    DeployMonster("major flame cyborg", 2, 3)
    DeployMonster("minor enforcer", 2, 4)
    DeployMonster("major enforcer", 2, 4)
    DeployMonster("minor hunter", 1, 2)
    DeployMonster("major hunter", 1, 2)
    DeployMonster("minor trooper", 1, 2)
    DeployMonster("major trooper", 1, 2)
  elseif round == 7 then
    RemoveMonster("major cyborg")
    RemoveMonster("major flame cyborg")
    DeployMonster("mother of all cyborgs", 1, 2)
    DeployMonster("mother of all hunters", 1, 2)
  elseif round == 8 then
    RemoveMonster("minor enforcer")
    RemoveMonster("major enforcer")
    RemoveMonster("minor hunter")
    DeployMonster("major hunter", 2, 4)
    DeployMonster("major drone", 4, 8)
    DeployMonster("minor juggernaut", 1, 1)
  elseif round == 9 then
    DeployPowerup("triple health")
    RemoveMonster("mother of all cyborgs")
    DeployMonster("minor juggernaut", 1, 2)
    DeployMonster("major hunter", 4, 8)
    DeployMonster("mother of all hunters", 2, 4)
    DeployMonster("major drone", 12, 16)
    RemoveMonster("minor trooper")
    DeployMonster("major trooper", 2, 4)
  elseif round == 10 then
    RemoveMonster("major trooper")
    RemoveMonster("major drone")
    DeployMonster("major enforcer", 4, 8)
    DeployMonster("minor defender", 1, 2)
    DeployMonster("major defender", 1, 2)
    RemoveMonster("minor juggernaut")
    DeployMonster("major juggernaut", 1, 2)
  else
    return
  end
  current_round = round
end

function choose_invisible_random_point()
  for i = 1,10 do
    local poly = Polygons[Game.global_random(#Polygons)]
    if polygon_is_valid_for_item_drop(poly) then
      return poly
    end
  end
  return nil
end

function polygon_is_valid_for_item_drop(poly)
  local ptype = poly.type.mnemonic
  if ptype == "item impassable" or
     ptype == "monster impassable" or
     ptype == "platform" or
     ptype == "teleporter" then
    return false
  end
  for item in Items() do
    if item.polygon == poly then return false end
  end
  if point_is_player_visible(poly) then return false end
  return true
end

function polygon_is_valid_for_monster_drop(poly, mtype)
  local ptype = poly.type.mnemonic
  if ptype == "monster impassable" or
     ptype == "platform" or
     ptype == "teleporter" then
    return false
  end
  -- disallow too-small polygons
  if poly.area < (mtype.radius * mtype.radius * 4) then return false end
  if mtype.height > (poly.ceiling.z - poly.floor.z) then return false end
  
  for item in poly:monsters() do
    return false
  end
  for item in Projectiles() do
    if item.polygon == poly then return false end
  end
  for item in Effects() do
    if item.polygon == poly then return false end
  end
--   if point_is_player_visible(poly) then return false end
  return true
end

function point_is_player_visible(poly)
  for p in Players() do
    if not line_is_obstructed(p, poly, poly) then return true end
  end
  return false
end

function line_is_obstructed(start, dest_point, dest_poly)
  local poly = start.polygon
  while true do
    if poly == dest_poly then return false end
    local line = poly:find_line_crossed_leaving(start.x, start.y, dest_point.x, dest_point.y)
    if line == nil then return true end
    if line.solid then return true end
    poly = find_adjacent_polygon(poly, line)
  end
end

function find_adjacent_polygon(poly, line)
  if poly == line.cw_polygon then return line.ccw_polygon end
  return line.cw_polygon
end

function PlaceMonster(mtype)
  for i = 1,10 do
    local poly = Polygons[Game.global_random(#Polygons)]
    if polygon_is_valid_for_monster_drop(poly, mtype) then
      local mon = Monsters.new(poly.x, poly.y, 0, poly, mtype)
      mon.visible = false
      mon.active = true
      return
    end
  end
end

function ReplaceMonster(mtype)
  local min = mtype.minimum_count
  if min > 0 then
    local cur = 0
    for m in Monsters() do
      if m.type == mtype then cur = cur + 1 end
      if cur >= min then return end
    end
    PlaceMonster(mtype)
  end
end

function ReplaceMonsters()
  local mcounts = {}
  for mt in MonsterTypes() do
    if mt.minimum_count > 0 then
      if mcounts[mt] == nil then mcounts[mt] = 0 end
    end
  end
  for m in Monsters() do
    if mcounts[m.type] ~= nil then
      mcounts[m.type] = mcounts[m.type] + 1
    end
  end
  
  for mt in MonsterTypes() do
    local cur = mcounts[mt]
    if cur ~= nil then
      local add = 0
      local min = mt.minimum_count
      if mt.total_available == -1 then min = mt.maximum_count end
      if cur < min then add = min - cur end
      for i = 1,add do
        PlaceMonster(mt)
      end
    end
  end
end
