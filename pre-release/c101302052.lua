--瘴煙の死霊術師
--Miasma Necromancer
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure: 2 monsters, including a DARK Spellcaster monster
	Link.AddProcedure(c,nil,2,2,s.matcheck)
	--Add 1 Level 5 or higher DARK Spellcaster monster from your GY to your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e) return e:GetHandler():IsLinkSummoned() end)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Normal Summon 1 Spellcaster monster
	local e2a=Effect.CreateEffect(c)
	e2a:SetDescription(aux.Stringid(id,1))
	e2a:SetCategory(CATEGORY_SUMMON)
	e2a:SetType(EFFECT_TYPE_IGNITION)
	e2a:SetRange(LOCATION_MZONE)
	e2a:SetCountLimit(1,{id,1})
	e2a:SetCost(s.sumcost)
	e2a:SetTarget(s.sumtg)
	e2a:SetOperation(s.sumop)
	c:RegisterEffect(e2a)
	--Workaround so that the card to be sent as cost for "e2a" isn't considered for the potential Tributes (same as "Ancient Gear Commander" [27483935])
	--"e2a" currently won't work when trying to summon a monster without Tributes while all the player's MMZs are full
	local e2b=Effect.CreateEffect(c)
	e2b:SetType(EFFECT_TYPE_FIELD)
	e2b:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e2b:SetCode(EFFECT_UNRELEASABLE_SUM)
	e2b:SetRange(LOCATION_MZONE)
	e2b:SetTargetRange(LOCATION_MZONE,0)
	e2b:SetTarget(function(e,c) return c==e:GetLabelObject() end)
	e2b:SetValue(1)
	c:RegisterEffect(e2b)
	e2a:SetLabelObject(e2b)
end
function s.matfilter(c,lc,sumtype,tp)
	return c:IsAttribute(ATTRIBUTE_DARK,lc,sumtype,tp) and c:IsRace(RACE_SPELLCASTER,lc,sumtype,tp)
end
function s.matcheck(g,lc,sumtype,tp)
	return g:IsExists(s.matfilter,1,nil,lc,sumtype,tp) 
end
function s.thfilter(c)
	return c:IsLevelAbove(5) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsRace(RACE_SPELLCASTER) and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)>0 and sc:IsLocation(LOCATION_HAND) then
		local code=sc:GetCode()
		--But you cannot activate cards, or the effects of cards, with its name for the rest of this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(aux.Stringid(id,2))
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_ACTIVATE)
		e1:SetTargetRange(1,0)
		e1:SetValue(function(e,re,tp) return re:GetHandler():IsCode(code) end)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.sumcostfilter(c,tp,eff)
	if not (c:IsSpellTrap() and c:IsAbleToGraveAsCost()) then return false end
	eff:SetLabelObject(c)
	local res=Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,c)
	eff:SetLabelObject(nil)
	return res
end
function s.sumcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local eff=e:GetLabelObject()
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,nil,tp,eff) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.sumcostfilter,tp,LOCATION_HAND|LOCATION_ONFIELD,0,1,1,nil,tp,eff)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.sumfilter(c)
	return c:IsRace(RACE_SPELLCASTER) and c:IsSummonable(true,nil)
end
function s.sumtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.sumfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil):GetFirst()
	if sc then
		Duel.Summon(tp,sc,true,nil)
	end
end
