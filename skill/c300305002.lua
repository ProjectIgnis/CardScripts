--Chemistry in Motion
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,1,false,s.flipcon,s.flipop,1)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_names={22587018,45898858}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--player hint for number of counters
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCode(id+100)
	e3:SetTargetRange(1,0)
	Duel.RegisterEffect(e3,tp)
end
function s.flipcon(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFlagEffect(ep,id)+1
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=ct==1 and Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil,tp)
	local b2=ct==2 and Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) and ft>-1
	local b3=ct==3 and Duel.IsExistingMatchingCard(s.dinofilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.bondfilter,tp,LOCATION_DECK,0,1,nil)
	local b4=ct==4 and Duel.IsExistingMatchingCard(s.mfilter,tp,0,LOCATION_MZONE,1,nil)
	return aux.CanActivateSkill(tp) and (b1 or b2 or b3 or b4)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=Duel.GetFlagEffect(ep,id)+1
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local b1=Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_HAND,0,1,nil,tp)
	local b2=Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND,0,1,nil) and ft>-1
	local b3=Duel.IsExistingMatchingCard(s.dinofilter,tp,LOCATION_MZONE,0,1,nil) and Duel.IsExistingMatchingCard(s.bondfilter,tp,LOCATION_DECK,0,1,nil)
	local b4=Duel.IsExistingMatchingCard(s.mfilter,tp,0,LOCATION_MZONE,1,nil)
	if Duel.GetTurnCount()==1 then Duel.ResetFlagEffect(ep,id) end
	--Discard 1 Dinosaur to add 1 Dinosaur with different Attribute from Deck
	if ct==1 and b1 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local ce=Duel.IsPlayerAffectedByEffect(ep,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(ep,id)))
			Duel.RegisterEffect(nce,ep)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DISCARD)
		local dc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_HAND,0,1,1,nil,tp):GetFirst()
		local att=dc:GetAttribute()
		if Duel.SendtoGrave(dc,REASON_COST+REASON_DISCARD)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local hc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,att)
			if Duel.SendtoHand(hc,tp,REASON_EFFECT)>0 then
				Duel.ConfirmCards(1-tp,hc)
			end
		end
	--Normal Summon 1 WIND or WATER Dinosaur from hand
	elseif ct==2 and b2 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local ce=Duel.IsPlayerAffectedByEffect(ep,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(ep,id)))
			Duel.RegisterEffect(nce,ep)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
		if sc then
			Duel.Summon(tp,sc,true,nil)
		end
	--Change all WATER Dinosaurs to "Hydrogeddon"/Add "Bonding - H20" to hand
	elseif ct==3 and b3 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local ce=Duel.IsPlayerAffectedByEffect(ep,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(ep,id)))
			Duel.RegisterEffect(nce,ep)
		end
		local fg=Duel.GetMatchingGroup(s.dinofilter,tp,LOCATION_MZONE,0,nil)
		for fc in fg:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CHANGE_CODE)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(22587018)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			fc:RegisterEffect(e1)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local ac=Duel.SelectMatchingCard(tp,s.bondfilter,tp,LOCATION_DECK,0,1,1,nil)
		if Duel.SendtoHand(ac,tp,REASON_EFFECT)>0 then
			Duel.ConfirmCards(1-tp,ac)
		end
	--Remove all counters/Change all monsters your opponent controls to FIRE/Pyro monsters
	elseif ct==4 and b4 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.RegisterFlagEffect(ep,id,0,0,0)
		local ce=Duel.IsPlayerAffectedByEffect(ep,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(ep,id)))
			Duel.RegisterEffect(nce,ep)
		end
		Duel.ResetFlagEffect(ep,id)
		local ce=Duel.IsPlayerAffectedByEffect(ep,id+100)
		if ce then
			local nce=ce:Clone()
			ce:Reset()
			nce:SetDescription(aux.Stringid(id,Duel.GetFlagEffect(ep,id)))
			Duel.RegisterEffect(nce,ep)
		end
		local og=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsMonster),tp,0,LOCATION_MZONE,nil)
		for oc in og:Iter() do
			local e1a=Effect.CreateEffect(c)
			e1a:SetType(EFFECT_TYPE_SINGLE)
			e1a:SetCode(EFFECT_CHANGE_RACE)
			e1a:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_IGNORE_IMMUNE)
			e1a:SetRange(LOCATION_MZONE)
			e1a:SetValue(RACE_PYRO)
			e1a:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
			oc:RegisterEffect(e1a)
			local e1b=e1a:Clone()
			e1b:SetCode(EFFECT_CHANGE_ATTRIBUTE)
			e1b:SetValue(ATTRIBUTE_FIRE)
			oc:RegisterEffect(e1b)
		end
	end
end
--Discard functions
function s.disfilter(c,tp)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetAttribute())
end
function s.thfilter(c,att)
	return c:IsRace(RACE_DINOSAUR) and c:IsAbleToHand() and not c:IsAttribute(att)
end
--Summon functions
function s.sumfilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND|ATTRIBUTE_WATER) and c:IsRace(RACE_DINOSAUR) and c:IsSummonable(true,nil)
end
--Name Change/Add Bonding functions
function s.dinofilter(c)
	return c:IsFaceup() and c:IsMonster() and c:IsRace(RACE_DINOSAUR) and c:IsAttribute(ATTRIBUTE_WATER) and not c:IsCode(22587018)
end
function s.bondfilter(c)
	return c:IsCode(45898858) and c:IsAbleToHand()
end
--monsters in opponent's MMZ function
function s.mfilter(c)
	return c:IsMonster() and c:IsFaceup() and not (c:IsRace(RACE_PYRO) or c:IsAttribute(ATTRIBUTE_FIRE))
end
