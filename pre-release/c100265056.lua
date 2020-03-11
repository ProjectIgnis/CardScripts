--[JP name]
--Mayakashi Mayhem
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	c:RegisterEffect(e1)
	--Apply 1 of the 4 different options
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_DRAW+CATEGORY_TOGRAVE+CATEGORY_DAMAGE)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e2:SetCost(s.cost)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,2))
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e3)
end
s.listed_names={}
	--Lists "Mayakashi" archetype
s.listed_series={0x121}
	--Zombie synchro monster special summoned anywhere but extra deck
function s.cfilter(c)
	return c:IsRace(RACE_ZOMBIE) and c:IsType(TYPE_SYNCHRO) 
		and c:GetSummonLocation()~=LOCATION_EXTRA
end
	--Not really a cost, make the effect once per chain
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFlagEffect(tp,id+4)==0 end
	Duel.RegisterFlagEffect(tp,id+4,RESET_CHAIN,0,1)
end
	--If it ever happened
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil) and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
	--Check for "Mayakashi" spell/trap, except itself
function s.setfilter(c)
	return c:IsSetCard(0x121) and c:IsType(TYPE_TRAP+TYPE_SPELL) and c:IsSSetable() and not c:IsCode(id)
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0
	or Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0
	or Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFlagEffect(tp,id+2)==0 end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(800)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,800)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,0,LOCATION_MZONE)
end
	--Apply 1 of the following effects
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local off=1
	local ops={}
	local opval={}
	if Duel.IsPlayerCanDraw(tp,1) and Duel.GetFlagEffect(tp,id)==0 then
		ops[off]=aux.Stringid(id,3)
		opval[off-1]=1
		off=off+1
	end
	if Duel.IsExistingMatchingCard(s.setfilter,tp,LOCATION_DECK,0,1,nil) and Duel.GetFlagEffect(tp,id+1)==0 then
		ops[off]=aux.Stringid(id,4)
		opval[off-1]=2
		off=off+1
	end
	if Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) and Duel.GetFlagEffect(tp,id+2)==0 then
		ops[off]=aux.Stringid(id,5)
		opval[off-1]=3
		off=off+1
	end
	if Duel.GetFlagEffect(tp,id+3)==0 then
		ops[off]=aux.Stringid(id,6)
		opval[off-1]=4
		off=off+1
	end
	if off==1 then return end
	local op=Duel.SelectOption(tp,table.unpack(ops))
	if opval[op]==1 then --Draw 1 card
		Duel.Draw(tp,1,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
	elseif opval[op]==2 then --Set 1 "Mayakashi" spell/trap from deck
		local g=Duel.GetMatchingGroup(s.setfilter,tp,LOCATION_DECK,0,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SET)
			local sg=g:Select(tp,1,1,nil)
			Duel.SSet(tp,sg)
			Duel.ConfirmCards(1-tp,sg)
			Duel.RegisterFlagEffect(tp,id+1,RESET_PHASE+PHASE_END,0,1)
		end
	elseif opval[op]==3 then --Send opponent's monster with lowest ATK to GY
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			local tg=g:GetMinGroup(Card.GetAttack)
			if #tg>1 then
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
				local sg=tg:Select(tp,1,1,nil)
				Duel.HintSelection(sg)
				Duel.SendtoGrave(sg,REASON_EFFECT)
			else Duel.SendtoGrave(tg,REASON_EFFECT) end
		Duel.RegisterFlagEffect(tp,id+2,RESET_PHASE+PHASE_END,0,1)
		end
	elseif opval[op]==4 then --Inflict 800 damage
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
			Duel.Damage(p,d,REASON_EFFECT)
		Duel.RegisterFlagEffect(tp,id+3,RESET_PHASE+PHASE_END,0,1)
	end
end
