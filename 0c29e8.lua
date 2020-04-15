function onCollisionEnter(x)
  local guid = x.collision_object.getGUID()
  self.setVar("collisionWith", guid)
end