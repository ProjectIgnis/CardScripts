-- プロパ・ガンダケ
-- Propa Gandake
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Change race
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.chtg)
	e1:SetOperation(s.chop)
	c:RegisterEffect(e1)
end
function s.getraces(g)
	local rs=0
	for c in g:Iter() do
		rs=rs|c:GetRace()
	end
	return rs&(RACE_BEAST|RACE_INSECT|RACE_PLANT|RACE_ROCK)
end
function s.chtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local rs=s.getraces(Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,e:GetHandler()))
	if chk==0 then return rs>0 end
	e:SetLabel(Duel.AnnounceRace(tp,1,rs))
end
function s.chop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local race=e:GetLabel()
	if race<=0 or not c:IsRelateToEffect(e) then return end
	-- Change this card's race
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_RACE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(race)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
	if not c:IsImmuneToEffect(e) and c:IsRace(race) then
		-- Change other monsters' race
		local e2=e1:Clone()
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
		e2:SetTarget(function(e,c) return c~=e:GetHandler() end)
		e2:SetValue(function(e) return e:GetHandler():GetRace() end)
		c:RegisterEffect(e2)
		-- Cannot target monsters with the same race as this card
		local e3=e2:Clone()
		e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetTarget(function(e,c) return c:IsRace(e:GetHandler():GetRace()) end)
		e3:SetValue(s.value)
		c:RegisterEffect(e3)
	end
end
function s.value(e,re,rp)
	local rc=e:GetHandler():GetRace()
	local trig_rc,eff=Duel.GetChainInfo(0,CHAININFO_TRIGGERING_RACE,CHAININFO_TRIGGERING_EFFECT)
	return re:IsActiveType(TYPE_MONSTER) and re:GetActivateLocation()==LOCATION_MZONE
		and (re:GetHandler():IsRace(rc) or (eff==re and trig_rc==rc)) and aux.tgoval(e,re,rp)
end