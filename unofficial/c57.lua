--Junior Journey Format
--Scripted by threems
local s,id=GetID()

function s.initial_effect(c)
	aux.EnableExtraRules(c,s,s.init)
end
function s.init(c)
	--Tribute Summon Optional
	local limeff=Effect.CreateEffect(c)
	limeff:SetDescription(aux.Stringid(57,0))
	limeff:SetType(EFFECT_TYPE_FIELD)
	limeff:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	limeff:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	limeff:SetCondition(s.ntcon)
	--summon any level
	for _,proc in ipairs({EFFECT_SET_PROC,EFFECT_SUMMON_PROC}) do
		local leff=limeff:Clone()
		leff:SetCode(proc)
		Duel.RegisterEffect(leff,0)
	end
	limeff:Reset()
	--prevent tribute summons except for monsters whose effects explicitly allow/require it
	local notribsum=Effect.CreateEffect(c)
	notribsum:SetType(EFFECT_TYPE_FIELD)
	notribsum:SetCode(EFFECT_CANNOT_SUMMON)
	notribsum:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	notribsum:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	notribsum:SetTarget(s.sumtg)
	Duel.RegisterEffect(notribsum,0)
	--same but for tribute sets
	local notribset=notribsum:Clone()
	notribset:SetCode(EFFECT_CANNOT_MSET)
	notribset:SetTarget(s.settg)
	Duel.RegisterEffect(notribset,0)
	--Limit 1 Spell Activation
	local e1=Effect.GlobalEffect()
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetTargetRange(1,1)
	e1:SetValue(s.aclimit)
	Duel.RegisterEffect(e1,0)
	local e2=Effect.GlobalEffect()
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetOperation(s.aclimit1)
	Duel.RegisterEffect(e2,0)
	--Limit 1 Trap Activation
	local e4=e1:Clone()
	e4:SetValue(s.aclimit3)
	Duel.RegisterEffect(e4,0)
	local e5=e2:Clone()
	e5:SetOperation(s.aclimit4)
	Duel.RegisterEffect(e5,0)
	--Limit 1 Set S/T per turn
	local e7=Effect.GlobalEffect()
	e7:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e7:SetCode(EVENT_SSET)
	e7:SetOperation(s.checkop)
	Duel.RegisterEffect(e7,0)	
	local e8=Effect.GlobalEffect()
	e8:SetType(EFFECT_TYPE_FIELD)
	e8:SetCode(EFFECT_CANNOT_SSET)
	e8:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetTargetRange(1,1)
	e8:SetTarget(s.setlimit)
	Duel.RegisterEffect(e8,0)
	--No Hand Size Limit
	local e9=Effect.GlobalEffect()
	e9:SetType(EFFECT_TYPE_FIELD)
	e9:SetCode(EFFECT_HAND_LIMIT)
	e9:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e9:SetTargetRange(1,1)
	e9:SetValue(999)
	Duel.RegisterEffect(e9,0)
	--No First Turn Draw
	local e10=e9:Clone()
	e10:SetCode(EFFECT_DRAW_COUNT)
	e10:SetTargetRange(1,1)
	e10:SetCondition(s.nodraw)
	e10:SetValue(0)
	Duel.RegisterEffect(e10,0)
	--Cannot Activate Quick-Play Spells outside of own MP or as Chain Link 2 or Higher
	local e11=Effect.GlobalEffect()
	e11:SetType(EFFECT_TYPE_FIELD)
	e11:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_IGNORE_IMMUNE)
	e11:SetCode(EFFECT_CANNOT_ACTIVATE)
	e11:SetTargetRange(1,1)
	e11:SetValue(s.quicklimit)
	Duel.RegisterEffect(e11,0)
	--Cannot respond with quick-plays (in progress)
	local reseff=Effect.CreateEffect(c)
	reseff:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	reseff:SetOperation(s.sumsuc)
	for _,event in ipairs({EVENT_SUMMON_SUCCESS,EVENT_DAMAGE}) do
		local reff=reseff:Clone()
		reseff:SetCode(event)
		Duel.RegisterEffect(reff,0)
	end
	reseff:Reset()
end
function s.ntcon(e,c,minc)
	if c==nil then return true end
	local _,max=c:GetTributeRequirement()
	return max>0 and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.sumtg(e,c,tp,sumtp)
	for _,exceps in ipairs({75285069,22996376,36354007,95701283,51192573}) do --listing card ids for cards like Moisture Creature
		if c:IsCode(exceps) then return false end
	end
	
	if c:IsHasEffect(EFFECT_LIMIT_SUMMON_PROC) then return false end
	
	return (sumtp&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
end
function s.settg(e,c,tp,sumtp)
	for _,exceps in ipairs({22996376}) do --listing card ids for cards like Moisture Creature, but for sets
		if c:IsCode(exceps) then return false end
	end
	
	if c:IsHasEffect(EFFECT_LIMIT_SET_PROC) then return false end
	
	return (sumtp&SUMMON_TYPE_TRIBUTE)==SUMMON_TYPE_TRIBUTE
end
function s.acfilter(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_SPELL)>0
end
function s.aclimit(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_SPELL) then --and re:GetHandler():IsLocation(LOCATION_HAND)
		return Duel.IsExistingMatchingCard(s.acfilter,tp,0xff,0,1,nil)
	end
	return false
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_SPELL,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():ResetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_SPELL)
	end
end
function s.acfilter2(c)
	return c:GetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP)>0
end
function s.aclimit3(e,re,tp)
	if not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	if re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsLocation(LOCATION_HAND)
		return Duel.IsExistingMatchingCard(s.acfilter2,tp,0xff,0,1,nil)
	end
	return false
end
function s.aclimit4(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():RegisterFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.aclimit5(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_TRAP) then --and re:GetHandler():IsPreviousLocation(LOCATION_HAND)
		re:GetHandler():ResetFlagEffect(EFFECT_TYPE_ACTIVATE+TYPE_TRAP)
	end
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re~=nil then
		if re:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	end
	local hg=eg:Filter(Card.IsPreviousLocation,nil,LOCATION_HAND)
	if #hg>0 then
		if hg:IsExists(Card.IsType,1,nil,TYPE_SPELL) then
			Duel.RegisterFlagEffect(rp,TYPE_SPELL,RESET_PHASE+PHASE_END,0,1)
		end
		if hg:IsExists(Card.IsType,1,nil,TYPE_TRAP) then
			Duel.RegisterFlagEffect(rp,TYPE_TRAP,RESET_PHASE+PHASE_END,0,1)
		end
	end
end
function s.setlimit(e,c,tp)
	--If it's not a main phase no need to restrict sets
	if Duel.GetCurrentPhase()~=PHASE_MAIN1 and Duel.GetCurrentPhase()~=PHASE_MAIN2 then return false end
	
	--similarly, if the current chain is above 0 no need to restrict sets
	if Duel.GetCurrentChain()>0 then return false end
	
	return c:IsLocation(LOCATION_HAND) and (Duel.GetFlagEffect(tp,TYPE_SPELL)>0
		or Duel.GetFlagEffect(tp,TYPE_TRAP)>0)
end
function s.nodraw(e,c,tp)
	return Duel.GetTurnCount()==1
end
function s.quicklimit(e,re,tp)
	if re:GetHandler():GetOriginalType()==TYPE_SPELL+TYPE_QUICKPLAY and re:IsHasType(EFFECT_TYPE_ACTIVATE) then
		
		--if the current chain is above 0 no quick-play can activate
		if Duel.GetCurrentChain()>0 then return true end
	
		--If it's not a main phase no quick-play can activate
		if Duel.GetCurrentPhase()~=PHASE_MAIN1 and Duel.GetCurrentPhase()~=PHASE_MAIN2 then return true end
	
		--only turn player can activate
		return Duel.GetTurnPlayer()~=tp
	end
	return false
end
function s.resplimit(e,re,tp)
	if e:GetHandler():GetOriginalType()==TYPE_SPELL+TYPE_QUICKPLAY and e:IsHasType(EFFECT_TYPE_ACTIVATE) then return false end
	return true
end
function s.sumsuc(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetChainLimitTillChainEnd(s.resplimit)
end
