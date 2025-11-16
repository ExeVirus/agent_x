function ax_core.lava_particles(pos)
    core.add_particlespawner({texture="bubble_red.png",amount = 10,time = 0.5,glow=13,pos=pos,exptime=1,minvel=vector.new(-3,-3,-3),maxvel=vector.new(3,3,3),drag=vector.new(1,0.5,1)})
    core.add_particlespawner({texture="bubble_orange.png",amount = 10,time = 0.5,glow=13,pos=pos,exptime=1,minvel=vector.new(-3,-3,-3),maxvel=vector.new(3,3,3),drag=vector.new(1,0.5,1)})
    core.add_particlespawner({texture="bubble_yellow.png",amount = 10,time = 0.5,glow=13,pos=pos,exptime=1,minvel=vector.new(-3,-3,-3),maxvel=vector.new(3,3,3),drag=vector.new(1,0.5,1)})
end

local rand = PcgRandom(core.get_us_time())
function ax_core.beam(player_pos, target_pos)
    local distance = vector.distance(player_pos, target_pos)
    if (distance > 5) then
        local direction = vector.direction(player_pos, target_pos)
        for i=1,5 do
            core.add_particle({
                -- pos=vector.add(player_pos,vector.multiply(direction, 1-(20/i)),
                pos=vector.add(player_pos,vector.multiply(direction, distance/rand:next(10, 100)*10)),
                -- pos=player_pos,
                velocity=direction,
                expirationtime=0.1,
                size=0.5,
                texture="bubble_yellow.png",
                glow=13,
            })
        end
    end
end