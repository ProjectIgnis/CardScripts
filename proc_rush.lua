EFFECT_IS_LEGEND=160212041
-- List of Legend cards, to be used with Card.IsLegend
local LEGEND_LIST={160001000,160205001,160418001,160002000,160421015,160404001,160421016,160432004,160003000,
160006000,160417001,160429001,160318004,160417002,160310002,160417003,160011000,160012000,160008000,160005000,
160009000,160007000,160004000,160010000,160318001,160432002,160310001,160318002,160318003,160201009,160202048,
160203018,160203023,160204048,160204049,160205069,160205070,160206025,160310003,160318006,160408003,160411003,
160417004,160417006,160421017,160428099,160428100,160432003,160202019,160318005,160417005,160418003,160434005,
160436005,160437001,160206019,160206002,160206008,160206022,160206028,160013020,160440001,160440002,160440003,
160429002,160208063,160208064,160208065,160014065,160446002,160015056,160210001,160207060,160210032,160210029,
160210058,160440010,160016033,160016034,160440011,160211080,160402039,160017033,160402040,160429003,160320014,
160320038,160018036,160212004,160212003,160402044,160212075,160212001,160402045,160019063,160019064,160019065,
160213078,160213082,160402047,160213084,160020059,160213076,160020001,160020040,160020000,160214052,160323029,
160214020}
-- Returns if a card is a Legend. Can be updated if a GetOT function is added to the core
function Card.IsLegend(c)
	return c:IsHasEffect(EFFECT_IS_LEGEND) or c:IsOriginalCode(table.unpack(LEGEND_LIST))
end

if Duel.IsDuelType(DUEL_INVERTED_QUICK_PRIORITY) then
	--Traps cannot be chained to each other
	local traprush1=Effect.GlobalEffect()
	traprush1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	traprush1:SetCode(EVENT_CHAINING)
	traprush1:SetOperation(function(e,tp,eg,ep,ev,re,r,rp)
							local rc=re:GetHandler()
							if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsTrapEffect() then
								Duel.SetChainLimit(aux.FALSE)
							end
						end)
	Duel.RegisterEffect(traprush1,0)
	--Traps cannot miss timing and can be activated in the Damage Step
	Card.RegisterEffect=(function()
		local oldfunc=Card.RegisterEffect
		return function(card,eff,...)
			if card:IsTrap() and eff:IsHasType(EFFECT_TYPE_ACTIVATE) then
				local prop1,prop2=eff:GetProperty()
				eff:SetProperty(prop1|EFFECT_FLAG_DELAY|EFFECT_FLAG_DAMAGE_STEP,prop2)
			end
			--Detect if "eff" is a Continuous Effect
            local eff_type=eff:GetType()
            if not eff:IsActivated() and eff:GetRange()&LOCATION_MZONE>0 and eff:GetReset()==0
                and not eff:IsHasProperty(EFFECT_FLAG_CANNOT_DISABLE) then
                --Mark "card" as a card with a Continuous Effect
                card:RegisterFlagEffect(FLAG_HAS_CONTINUOUS_EFFECT,0,0,0)
                --Change the effect's condition to return false if it has the "negation" flag
                local prev_cond=eff:GetCondition()
                eff:SetCondition(function(e,...)
                                    return (prev_cond==nil or prev_cond(e,...)) and not e:GetHandler():HasFlagEffect(FLAG_NEGATE_CONTINUOUS_EFFECT)
                                end)
            end
            return oldfunc(card,eff,...)
		end
	end)()
end
function Card.IsCanChangePositionRush(c)
	return c:IsCanChangePosition() and not c:IsMaximumMode()
end
function Card.CanChangeIntoTypeRush(c,type,turnvalue)
	if not c:IsRace(type) then return true end
	if c:IsOriginalRace(type) then return false end
	if not c:IsHasEffect(EFFECT_CHANGE_RACE) then return true end
	if nil==turnvalue then turnvalue=1 end
	local eff={c:GetCardEffect(EFFECT_CHANGE_RACE)}
	for _,te in ipairs(eff) do
		local effType=te:GetType()
		if effType~=EFFECT_TYPE_FIELD and eff_type~=EFFECT_TYPE_EQUIP then
			local _,effectvalue=te:GetReset()
			if effectvalue>=turnvalue then return false end
		end
	end
	return true
end
function Card.CanChangeIntoAttributeRush(c,attribute,turnvalue)
	if not c:IsAttribute(attribute) then return true end
	if c:IsOriginalAttribute(attribute) then return false end
	if not c:IsHasEffect(EFFECT_CHANGE_ATTRIBUTE) then return true end
	if nil==turnvalue then turnvalue=1 end
	local eff={c:GetCardEffect(EFFECT_CHANGE_ATTRIBUTE)}
	for _,te in ipairs(eff) do
		local effType=te:GetType()
		if effType~=EFFECT_TYPE_FIELD and eff_type~=EFFECT_TYPE_EQUIP then
			local _,effectvalue=te:GetReset()
			if effectvalue>=turnvalue then return false end
		end
	end
	return true
end

--Add function to simplify some effect
--c: the card gaining effect
--reset: when the effect should disappear
--rc: the card giving effect
--condition: condition for the effect to be "active"
--properties: properties beside EFFECT_FLAG_CLIENT_HINT
function Card.AddPiercing(c,reset,rc,condition,properties)
	local e1=nil
	if rc then
		e1=Effect.CreateEffect(rc)
	else
		e1=Effect.CreateEffect(c)
	end
	e1:SetDescription(3208)
	if not properties then properties=0 end
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+properties)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	if condition then e1:SetCondition(condition) end
	if reset then e1:SetReset(reset) end
	c:RegisterEffect(e1)
end

--Double/Triple tribute handler
FLAG_HAS_DOUBLE_TRIBUTE=160015004
FLAG_TRIPLE_TRIBUTE=160012000
FLAG_NO_TRIBUTE=160001029
FLAG_DOUBLE_TRIB=160009052 --Executie up
FLAG_DOUBLE_TRIB_DRAGON=160402002 --righteous dragon
FLAG_DOUBLE_TRIB_FIRE=160007025 --dododo second
FLAG_DOUBLE_TRIB_WINGEDBEAST=160005033 --blasting bird
FLAG_DOUBLE_TRIB_LIGHT=160414001 --ultimate flag beast surge bicorn
FLAG_DOUBLE_TRIB_MACHINE=160414101
FLAG_DOUBLE_TRIB_DARK=160317015 --Voidvelgr Globule
FLAG_DOUBLE_TRIB_GALAXY=160317115
FLAG_DOUBLE_TRIB_WIND=160011022 -- Bluegrass Stealer
FLAG_DOUBLE_TRIB_PSYCHIC=160011122
FLAG_DOUBLE_TRIB_LEVEL7=160205051 -- Double Twin Dragon
FLAG_DOUBLE_TRIB_GREYSTORM=160414002 -- Cosmo Predictor
FLAG_DOUBLE_TRIB_200_DEF=160012015 -- Green-Eyes Star Cat
FLAG_DOUBLE_TRIB_NORMAL=160319014 -- Light Effigy
FLAG_DOUBLE_TRIB_LEVEL8=160015035 -- Darkness Doom Giant
FLAG_DOUBLE_TRIB_WYRM=160015011 -- Demolition Soldier Ashiba Bikke
FLAG_DOUBLE_TRIB_FIEND=160210078 -- Royal Rebel's Guardian
FLAG_DOUBLE_TRIB_SPELLCASTER=160017008 -- Releaslayer
FLAG_DOUBLE_TRIB_0_ATK=160017041 -- Multiply Skull
FLAG_DOUBLE_TRIB_0_DEF=160017141 
FLAG_DOUBLE_TRIB_EFFECT=160017241
FLAG_DOUBLE_TRIB_LEGEND=160212047 -- Legend Scout
FLAG_DOUBLE_TRIB_FAIRY=160019009 -- Dice Key Lilith
FLAG_DOUBLE_TRIB_OBLIVION=160020004 -- Chaos Coolstars
FLAG_DOUBLE_TRIB_REQUIEM=160020104
function Card.AddDoubleTribute(c,id,otfilter,eftg,reset,...)
	for i,flag in ipairs{...} do
		c:RegisterFlagEffect(flag,reset,0,1)
	end
	c:RegisterFlagEffect(FLAG_HAS_DOUBLE_TRIBUTE,reset,0,1)
	local e1=aux.summonproc(c,true,true,1,1,SUMMON_TYPE_TRIBUTE+100,aux.Stringid(id,0),otfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetTarget(eftg)
	e2:SetLabelObject(e1)
	if reset~=0 then e2:SetReset(reset) end
	c:RegisterEffect(e2)
	local e3=aux.summonproc3trib(c,aux.Stringid(id,1),otfilter)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_GRANT)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e4:SetTarget(aux.ThreeTribGrantTarget(eftg))
	e4:SetLabelObject(e3)
	if reset~=0 then e4:SetReset(reset) end
	c:RegisterEffect(e4)
end
function aux.DoubleTributeCon(e,tp,eg,ep,ev,re,r,rp)
	return not Duel.IsPlayerAffectedByEffect(tp,FLAG_NO_TRIBUTE)
end
--function to check if the monster have the flag for double tribute (used in otfilter)
function Card.CanBeDoubleTribute(c,...)
	if c:GetFlagEffect(FLAG_DOUBLE_TRIB)~=0 then return false end
	local totalFlags=0
	for i,flag in ipairs{...} do
		totalFlags=totalFlags+flag
		if c:GetFlagEffect(flag)~=0 then return false end
	end
	if c:GetFlagEffect(totalFlags)~=0 then return false end
	return true
end
--function to check if the monster can get the corresponding double tribute flags
--explanation: you can use Executie up on a monster like Rightous dragon that used its own effect to become a double tribute for dragon, it then become usable as 2 tribute for any monsters not just dragon
--but the opposite scenario don't work, if you used executie up on a Righteous dragon making it a double tribute for any monster, you can't activate righteous dragon effect
function Card.IsDoubleTribute(c,...)
	--check for each individual flag
	for i,flag in ipairs{...} do
		if c:GetFlagEffect(flag)==0 then return false end
	end
	return true
end
function Card.AddNoTributeCheck(c,id,stringid,rangeP1,rangeP2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(FLAG_NO_TRIBUTE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetDescription(aux.Stringid(id,stringid))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	e1:SetTargetRange(rangeP1,rangeP2)
	c:RegisterEffect(e1)
end
function Duel.AddNoTributeCheck(c,tp,id,stringid,rangeP1,rangeP2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(FLAG_NO_TRIBUTE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetDescription(aux.Stringid(id,stringid))
	e1:SetTargetRange(rangeP1,rangeP2)
	e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	Duel.RegisterEffect(e1,tp)
end
function aux.summonproc(c,ns,opt,min,max,val,desc,f,sumop)
	val = val or SUMMON_TYPE_TRIBUTE
	local e1=Effect.CreateEffect(c)
	if desc then e1:SetDescription(desc) end
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if ns and opt then
		e1:SetCode(EFFECT_SUMMON_PROC)
	else
		e1:SetCode(EFFECT_LIMIT_SUMMON_PROC)
	end
	if ns then
		e1:SetCondition(Auxiliary.NormalSummonCondition1(min,max,f))
		e1:SetTarget(Auxiliary.NormalSummonTarget(min,max,f))
		e1:SetOperation(Auxiliary.NormalSummonOperation(min,max,sumop))
	else
		e1:SetCondition(Auxiliary.NormalSummonCondition2())
	end
	e1:SetValue(val)
	return e1
end
function aux.ThreeTribGrantTarget(eftg)
	return function(e,c)
		return eftg(e,c) and c:GetFlagEffect(FLAG_TRIPLE_TRIBUTE)~=0
	end
end
function aux.summonproc3trib(c,desc,otfilter)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	if desc then e1:SetDescription(desc) end
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(aux.ThreeTributeCondition(otfilter))
	e1:SetTarget(aux.ThreeTributeTarget(otfilter))
	e1:SetOperation(aux.ThreeTributeOperation())
	e1:SetValue(SUMMON_TYPE_TRIBUTE+1)
	c:RegisterEffect(e1)
	return e1
end
function aux.ThreeTributeCondition(otfilter)
	return function (e,c)
		if c==nil then return true end
		if not c:IsLevelAbove(7) then return false end
		local tp=e:GetHandlerPlayer()
		local rg1=Duel.GetTributeGroup(c)
		local rg2=Duel.GetMatchingGroup(otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
		return aux.SelectUnselectGroup(rg1,e,tp,2,2,aux.ChkfMMZ(1),0)
			and aux.SelectUnselectGroup(rg2,e,tp,1,1,aux.ChkfMMZ(1),0)
	end
end
function aux.ThreeTributeTarget(otfilter)
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local rg1=Duel.GetMatchingGroup(otfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,tp)
		local mg1=aux.SelectUnselectGroup(rg1,e,tp,1,1,aux.ChkfMMZ(1),1,tp,HINTMSG_RELEASE,nil,nil,true)
		if #mg1>0 then
			local sg=mg1:GetFirst()
			local rg2=Duel.GetTributeGroup(e:GetHandler())
			rg2:RemoveCard(sg)
			local mg2=aux.SelectUnselectGroup(rg2,e,tp,1,1,nil,1,tp,HINTMSG_RELEASE,nil,nil,true)
			mg1:Merge(mg2)
		end
		if #mg1==2 then
			mg1:KeepAlive()
			e:SetLabelObject(mg1)
			return true
		end
		return false
	end
end
function aux.ThreeTributeOperation()
	return function (e,tp,eg,ep,ev,re,r,rp,c)
		local g=e:GetLabelObject()
		if not g then return end
		c:SetMaterial(g)
		Duel.Release(g,REASON_COST)
		g:DeleteGroup()
	end
end

--Utility functions for Rush
--Returns true if a monster can get a piercing effect as per Rush rules
function Card.CanGetPiercingRush(c)
	if c:IsHasEffect(EFFECT_CANNOT_ATTACK) then return false end
	local e=c:IsHasEffect(EFFECT_PIERCE)
	if e==nil then return true end
    return e:GetReset()==0
end
-- Checks if the monster would be a valid target for the equip card
-- Needed because Rush cards typically don't need this check after they are equipped
function Card.CheckEquipTargetRush(equip,monster)
	local effect=equip:GetActivateEffect()
	if nil~=effect then
		local filter=effect:GetTarget()
		if nil~=filter then
			return filter(effect,effect:GetHandlerPlayer(),nil,nil,nil,nil,nil,nil,nil,monster)
		end
	end
	return false
end
function Card.GetMaterialCountRush(c)
	if c:GetSummonType()==SUMMON_TYPE_TRIBUTE+100 then return c:GetMaterialCount()+1 end
	return c:GetMaterialCount()
end

FLAG_HAS_CONTINUOUS_EFFECT=160015036
FLAG_NEGATE_CONTINUOUS_EFFECT=160015136
function Card.HasContinuousRushEffect(card)
    if card:HasFlagEffect(FLAG_HAS_CONTINUOUS_EFFECT) then return true end
    --If it doesn't have the flag mark then check if it's in Maximum Mode and any of the other pieces has the flag
    if card:IsMaximumMode() then
        local maximum_pieces=Duel.GetMatchingGroup(Card.IsMaximumMode,card:GetControler(),LOCATION_MZONE,0,nil)
        return maximum_pieces:IsExists(Card.HasFlagEffect,1,nil,FLAG_HAS_CONTINUOUS_EFFECT)
    end
    return false
end
function Card.NegateContinuousRushEffects(card,resets)
    if card:IsMaximumMode() then
        local maximum_pieces=Duel.GetMatchingGroup(Card.IsMaximumMode,card:GetControler(),LOCATION_MZONE,0,nil)
        for tc in maximum_pieces:Iter() do
            tc:RegisterFlagEffect(FLAG_NEGATE_CONTINUOUS_EFFECT,resets,0,1)
        end
    else
        card:RegisterFlagEffect(FLAG_NEGATE_CONTINUOUS_EFFECT,resets,0,1)
    end
end
function Duel.ChangeToFaceupAttackOrFacedownDefense(card,tp)
	if not card:IsCanChangePosition() then return end
	if card:IsAttackPos() then
		Duel.ChangePosition(card,POS_FACEDOWN_DEFENSE)
	elseif card:IsFacedown() then
		Duel.ChangePosition(card,POS_FACEUP_ATTACK)
	else
		local op=Duel.SelectOption(tp,aux.Stringid(160018023,2),aux.Stringid(160018023,3))
		if op==0 then
			Duel.ChangePosition(card,0,0,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK)
		else
			Duel.ChangePosition(card,POS_FACEDOWN_DEFENSE)
		end
	end
end
