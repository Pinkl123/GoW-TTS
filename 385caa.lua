--Script create by Pinkl
--vk.com/jhramone

function onload()

self.createButton({
        label="Test", click_function="spawnitem", function_owner=self,
        position={0,0.1,-2},rotation={0,180,0}, height=400, width=1200, font_size=240,
		 color={0,0,0}, font_color={1,1,1}
  })

end

function spawnitem()
  self.lock()
  position = self.getPosition()
  rotation = self.getRotation()

  seting_effect = {}
  seting_effect.assetbundle = 'https://drive.google.com/uc?export=download&id=0BxvLXJFgtJJ8cV9UV003eGk5T1E'

  seting_effect2 = {}
  seting_effect2.assetbundle = 'https://drive.google.com/uc?export=download&id=0BxvLXJFgtJJ8N0d6cnl0bkQ5SUU'

  seting = {}
  seting.image = 'http://i.imgur.com/SRbrDP1.png'

  seting_dice = {}
  seting_dice.type = 5
  seting_dice.image = 'https://gateway.ipfs.io/ipfs/QmQ2FaDgiVw6faxPxEMVEMFy1g5scneVDkkD9qxk1W5kFc'


  effect_parameters = {}
  effect_parameters.type ='Custom_AssetBundle'
  effect_parameters.scale = {x=0.01, y=0.01, z=0.01}
  effect_parameters.position = {position.x, position.y, position.z}

  effect_parameters2 = {}
  effect_parameters2.type ='Custom_AssetBundle'
  effect_parameters2.scale = {x=0.01, y=0.01, z=0.01}
  effect_parameters2.position = {position.x, position.y+1.5, position.z}

  dice_parameters = {}
  dice_parameters.type = 'Custom_Dice'
  dice_parameters.position = {position.x, position.y+5, position.z}

  token_parameters = {}
  token_parameters.type = 'Custom_Token'
  token_parameters.scale = {x=0.01, y=1, z=0.01}

  token_parameters.position = {position.x, position.y, position.z}
  token_parameters.rotation = {rotation.x+90, rotation.y, rotation.z}

  effect = spawnObject(effect_parameters)
  effect.setCustomObject(seting_effect)
  effect.lock()
  effect.AssetBundle.playLoopingEffect(8)

  effect2 = spawnObject(effect_parameters2)
  effect2.setCustomObject(seting_effect2)
  effect2.lock()

  --dice = spawnObject(dice_parameters)
  --dice.setCustomObject(seting_dice)
  --dice.lock()

  token = spawnObject(token_parameters)
  token.setCustomObject(seting)

  token.lock()

  Wait.frames(function() item() end, 1)
  function item()
    item = token.getGUID()
  end
    --[[Wait.time(function() dice.unlock()
      dice.roll()
    end, 1)]]

  Wait.time(function() Start() end, 1)
  Wait.time(function() effect2.AssetBundle.playTriggerEffect(1) end, 3)
end

--[[function onCollisionEnter(collision_info)
  dice.lock()
end]]

spinning = false
spinTime = 5
function Start()

  rouletteWheelGUID = item
  rouletteWheel = nil
  rouletteWheel = getObjectFromGUID(item)
    if spinning == false then
        startTime = os.clock()
        startLuaCoroutine(self, 'SpinCoroutine')
    end
end

function SpinCoroutine ()

    spinning = true
    b = 480
    a = 0
    alpha = 0

    while a < b do

        currentRot = token.getRotation()
        currentSca = token.getScale()
        currentPos = token.getPosition()

        currentRot['y'] = currentRot['y'] + 3
        currentSca['z'] = currentSca['z'] + 0.001
        currentSca['x'] = currentSca['x'] + 0.001
        currentPos['y'] = currentPos['y'] + 0.0083

        token.setPosition(currentPos)
        token.setScale(currentSca)
        token.setRotation(currentRot)
        token.setColorTint({1,1,1,0 + alpha})
        effect.setPosition(currentPos)

        coroutine.yield(0) --wait one frame
        log(a)
        a = a + 1
        alpha = alpha + 0.0030
    end

    spinning = false

    Wait.time(function () effect.destruct() effect2.destruct() rouletteWheel.unlock() self.unlock() end, 3)
    --[[ Always return 1 at the end of a coroutine. --]]
    return 1
end