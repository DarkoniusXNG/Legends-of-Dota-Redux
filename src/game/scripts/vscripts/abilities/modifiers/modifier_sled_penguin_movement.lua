
modifier_sled_penguin_movement = class({})

----------------------------------------------------------------------------------

function modifier_sled_penguin_movement:IsHidden()
	return true
end

----------------------------------------------------------------------------------

function modifier_sled_penguin_movement:IsPurgable()
	return false
end

--------------------------------------------------------------------------------


function modifier_sled_penguin_movement:GetModifierDisableTurning( params )
	return 1
end

-----------------------------------------------------------------------

function modifier_sled_penguin_movement:GetOverrideAnimation( params )
	if self:GetParent() ~= self:GetCaster() then
		return ACT_DOTA_FLAIL
	end

	return ACT_DOTA_SLIDE_LOOP
end

----------------------------------------------------------------------------------

function modifier_sled_penguin_movement:OnCreated( kv )
	if IsServer() then
		self.max_sled_speed = self:GetAbility():GetSpecialValueFor( "max_sled_speed" )
		self.speed_step = self:GetAbility():GetSpecialValueFor( "speed_step" )
		self.crash_impaired_duration = self:GetAbility():GetSpecialValueFor( "crash_impaired_duration" )
		self.tree_destroy_radius = self:GetAbility():GetSpecialValueFor( "tree_destroy_radius" )
		self.pinata_burst_radius = self:GetAbility():GetSpecialValueFor( "pinata_burst_radius" )

		self.nCurSpeed = 20
		self.flDesiredYaw = self:GetCaster():GetAnglesAsVector().y

		self.bPlayedVroomSinceLastCrash = false

		if kv.just_crashed ~= nil then
			self.speed_step = self.speed_step / 2.0
			self.nCurSpeed = 0

			local impaired_duration = self:GetAbility():GetSpecialValueFor( "impaired_duration" )
			self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_sled_penguin_impairment", { duration = impaired_duration } )

			self:GetParent():StartGesture( ACT_DOTA_DIE )

			if self:IsParentPenguin() then
				FindClearSpaceForUnit( self:GetParent(), self:GetParent():GetAbsOrigin(), true )
			end
		end

		--[[
		if self:IsParentPenguin() then
			EmitSoundOn( "SledPenguin.RidingLoop", self:GetParent() )
		end
		]]

		--[[
		if self:IsParentPenguin() == false then
			print( "self:GetParent():GetUnitName() == " .. self:GetParent():GetUnitName() )
			EmitSoundOnClient( "SledPenguin.RidingLoop", self:GetParent():GetPlayerOwner() )
		end
		]]

		if self:ApplyHorizontalMotionController() == false then 
			self:Destroy()
			return
		end

		self:StartIntervalThink( 0.1 )
	end
end

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:OnIntervalThink()
	if IsServer() then
		if self:GetParent():HasModifier( "modifier_sled_penguin_movement" ) and self:GetParent():HasModifier( "modifier_sled_penguin_crash" ) == false then
			if self:IsParentPenguin() then
				-- Search for any pinatas in my burst radius and explode them
				local nTargetFlags =  0--DOTA_UNIT_TARGET_FLAG_OUT_OF_WORLD + DOTA_UNIT_TARGET_FLAG_INVULNERABLE + DOTA_UNIT_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES
				local hEnemies = FindUnitsInRadius( self:GetParent():GetTeamNumber(), self:GetParent():GetOrigin(), self:GetParent(), 200, DOTA_UNIT_TARGET_TEAM_ENEMY, DOTA_UNIT_TARGET_HERO + DOTA_UNIT_TARGET_BASIC, nTargetFlags, 0, false )
				local talent = self:GetParent().hero:FindAbilityByName("special_bonus_unique_sled_penguin_0")
				local talentValue = 0
				if talent then
					talentValue = talent:GetSpecialValueFor("value")
				end
				for _, hEnemy in pairs( hEnemies ) do
					if not hEnemy:HasModifier("modifier_knockback") then
						if hEnemy:IsRealHero() and talentValue ~= 1 then
							self.nCurSpeed = self.nCurSpeed * 0.5
						else
							self.nCurSpeed = self.nCurSpeed * 0.9
						end
						local damageTable = {
							attacker = self:GetParent().hero,
							victim = hEnemy,
							ability = self:GetAbility(),
							damage = self:GetAbility():GetSpecialValueFor("damage"),
							damage_type = DAMAGE_TYPE_MAGICAL,
						}
						ApplyDamage(damageTable)
						local vLocation = self:GetParent():GetOrigin()
						local kv =
						{
							center_x = vLocation.x,
							center_y = vLocation.y,
							center_z = vLocation.z,
							should_stun = false, 
							duration = 1,
							knockback_duration = 0.3,
							knockback_distance = 250,
							knockback_height = 75,
						}

						hEnemy:AddNewModifier( self:GetParent().hero, self:GetAbility(), "modifier_knockback", kv )
					end
				end
			end
		end
	end
end

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )
		if self:IsParentPenguin() then
			self:GetCaster():RemoveGesture( ACT_DOTA_SLIDE_LOOP )

			--StopSoundOn( "SledPenguin.RidingLoop", self:GetParent() )

			EmitSoundOn( "Hero_Tusk.IceShards.Penguin", self:GetParent() )
		else
			-- Apply knockback to player hero
			local vLocation = self:GetParent():GetAbsOrigin() + ( self:GetParent():GetForwardVector() * 50 )
			local kv =
			{
				center_x = vLocation.x,
				center_y = vLocation.y,
				center_z = vLocation.z,
				should_stun = true, 
				duration = 0.4,
				knockback_duration = 0.3,
				knockback_distance = 250,
				knockback_height = 75,
			}

			self:GetParent():AddNewModifier( self:GetParent(), self:GetAbility(), "modifier_knockback", kv )
		end
	end
end

--------------------------------------------------------------------------------

--[[
function modifier_sled_penguin_movement:OnDestroy()
	if IsServer() then
		self:GetParent():RemoveHorizontalMotionController( self )

		if self:IsParentPenguin() then
			EmitSoundOn( "Hero_Tusk.IceShards.Penguin", self:GetParent() )
		end
	end
end
]]

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:DeclareFunctions()
	local funcs = 
	{
		MODIFIER_PROPERTY_OVERRIDE_ANIMATION,
		MODIFIER_EVENT_ON_ORDER,
		MODIFIER_PROPERTY_DISABLE_TURNING,
	}

	return funcs
end

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:CheckState()
	local state =
	{
		[ MODIFIER_STATE_STUNNED ] = self:IsParentPenguin(),
		[ MODIFIER_STATE_INVULNERABLE ] = self:IsParentPenguin(),
		[ MODIFIER_STATE_NO_HEALTH_BAR ] = self:IsParentPenguin(),

		[ MODIFIER_STATE_MUTED ] = false,--self:IsParentPenguin() == false,
		[ MODIFIER_STATE_SILENCED ] = false,--self:IsParentPenguin() == false,
		[ MODIFIER_STATE_ROOTED ] = self:IsParentPenguin() == false,
	}

	return state
end

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:UpdateHorizontalMotion( me, dt )
	if IsServer() then

		if not self:GetCaster() then
			return
		end

		if self:IsParentPenguin() then
			self:GetCaster().crashed = false
			if self.bStartedLoop == nil and self:GetElapsedTime() > 0.3 then
				self.bStartedLoop = true
				self:GetCaster():StartGesture( ACT_DOTA_SLIDE_LOOP )
			end

			local flTurnAmount = 0.0
			local curAngles = self:GetCaster():GetAngles()
			
			local flAngleDiff = AngleDiff( self.flDesiredYaw, curAngles.y )
			
			local flTurnRate = self:GetAbility():GetSpecialValueFor("turnrate")
			flTurnAmount = flTurnRate * dt
			flTurnAmount = math.min( flTurnAmount, math.abs( flAngleDiff ) )
		
			if flAngleDiff < 0.0 then
				flTurnAmount = flTurnAmount * -1
			end

			if flAngleDiff ~= 0.0 then
				curAngles.y = curAngles.y + flTurnAmount
				me:SetAbsAngles( curAngles.x, curAngles.y, curAngles.z )
			end

			local vNewPos = self:GetCaster():GetOrigin() + self:GetCaster():GetForwardVector() * ( dt * self.nCurSpeed )
			if GridNav:CanFindPath( me:GetOrigin(), vNewPos ) == false then
				self:GetCaster().crashed = true
				self:CrashAndRecover()
				--self:Crash()
				return
			end
			me:SetOrigin( vNewPos )
			self.nCurSpeed = math.min( self.nCurSpeed + self.speed_step, self.max_sled_speed )

			if ( self.nCurSpeed >= self.max_sled_speed ) and ( self.bPlayedVroomSinceLastCrash == false ) then
				EmitSoundOn( "Frosthaven.Vroom", self:GetParent() )
				self.bPlayedVroomSinceLastCrash = true

				self.nHasteFXIndex = ParticleManager:CreateParticle( "particles/generic_gameplay/rune_haste.vpcf", PATTACH_ABSORIGIN_FOLLOW, self:GetParent() )
			end
		else
			if self:GetCaster().crashed == true then
				self:GetParent():AddNewModifier(self:GetCaster(),self:GetAbility(),"modifier_stunned",{duration =self.crash_impaired_duration})
				self:GetParent():FindAbilityByName("sled_penguin_redux"):ToggleAbility()
			end
			if self:GetCaster():IsAlive() == false or self:GetCaster():FindModifierByName( "modifier_sled_penguin_movement" ) == nil then
				self:Destroy()
				return
			end
			me:SetOrigin( self:GetCaster():GetOrigin() )
			local casterAngles = self:GetCaster():GetAngles() 
			me:SetAbsAngles( casterAngles.x, casterAngles.y, casterAngles.z )
		end
		
	end
end

--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:CrashAndRecover()
	GridNav:DestroyTreesAroundPoint( self:GetParent():GetOrigin(), self.tree_destroy_radius, false )

	-- Start a screenshake with the following parameters: vecCenter, flAmplitude, flFrequency, flDuration, flRadius, eCommand( SHAKE_START = 0, SHAKE_STOP = 1 ), bAirShake
	ScreenShake( self:GetParent():GetOrigin(), 10.0, 100.0, 0.5, 1300.0, 0, true )
	self.reset_pos_offset = self:GetAbility():GetSpecialValueFor( "reset_pos_offset" )

	EmitSoundOn( "SledPenguin.Crash.Impact", self:GetParent() )
	EmitSoundOn( "SledPenguin.Crash.Ow", self:GetParent() )

	if self.nHasteFXIndex then
		ParticleManager:DestroyParticle( self.nHasteFXIndex, false )
	end

	local vForward = self:GetParent():GetForwardVector()
	self.vResetPos = self:GetParent():GetAbsOrigin() - ( vForward * self.reset_pos_offset )

	self:GetParent():SetForwardVector( self:GetParent():GetForwardVector() * -1 )
	self:GetParent():SetAbsOrigin( self.vResetPos )

	self.bPlayedVroomSinceLastCrash = false

	
	
end

--------------------------------------------------------------------------------


function modifier_sled_penguin_movement:Crash()
	GridNav:DestroyTreesAroundPoint( self:GetCaster():GetOrigin(), self.tree_destroy_radius, false )

	-- Start a screenshake with the following parameters: vecCenter, flAmplitude, flFrequency, flDuration, flRadius, eCommand( SHAKE_START = 0, SHAKE_STOP = 1 ), bAirShake
	ScreenShake( self:GetParent():GetOrigin(), 10.0, 100.0, 0.5, 1300.0, 0, true )

	self:GetCaster():AddNewModifier( self:GetCaster(), self:GetAbility(), "modifier_sled_penguin_crash", { duration = self.crash_impaired_duration } )
	self:Destroy()
end


--------------------------------------------------------------------------------

function modifier_sled_penguin_movement:OnOrder( params )
	if IsServer() then
		if not self:GetCaster() then
			return 0
		end

		local hOrderedUnit = params.unit 
		local hTargetUnit = params.target
		local nOrderType = params.order_type
		if nOrderType == DOTA_UNIT_ORDER_MOVE_TO_POSITION or nOrderType == DOTA_UNIT_ORDER_ATTACK_MOVE then
			if hOrderedUnit == self:GetParent() and self:IsParentPenguin() == false then
				local vDir = params.new_pos - self:GetCaster():GetOrigin()
				vDir.z = 0
				vDir = vDir:Normalized()
				local angles = VectorAngles( vDir )
				local hBuff = self:GetCaster():FindModifierByName( "modifier_sled_penguin_movement" )
				if hBuff ~= nil then
					hBuff.flDesiredYaw = angles.y
				end	
			end
		end
	end

	return 0
end

-----------------------------------------------------------------------

function modifier_sled_penguin_movement:IsParentPenguin()
	return ( self:GetCaster() == self:GetParent() )
end

--------------------------------------------------------------------------------