--ＳＲウィング・シンクロン
--Speedroid Wing Synchron
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Pendulum procedure
	Pendulum.AddProcedure(c)
	--Destroy both this card and 1 Level 2 WIND Pendulum Monster Card in your Pendulum Zone, and if you do, Special Summon 1 "Clear Wing Synchro Dragon"
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_PZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Send 1 "Speedroid" Spell/Trap from your Deck to the GY
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_DECK)
	e2:SetCountLimit(1,id)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetOperation(s.tgop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_SPEEDROID}
s.listed_names={82044279} --"Clear Wing Synchro Dragon"
function s.desfilter(c)
	return c:IsLevel(2) and c:IsAttribute(ATTRIBUTE_WIND)
end
function s.spfilter(c,e,tp)
	return c:IsCode(82044279) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_SYNCHRO,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_PZONE,0,1,e:GetHandler())
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp) end
	local g=Duel.GetFieldGroup(tp,LOCATION_PZONE,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,2,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local pc=Duel.GetMatchingGroup(nil,tp,LOCATION_PZONE,0,c):GetFirst()
	if c:IsRelateToEffect(e) and pc and s.desfilter(pc) and Duel.Destroy(Group.FromCards(c,pc),REASON_EFFECT)==2 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sc=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
		if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_SYNCHRO,tp,tp,false,false,POS_FACEUP)>0 then
			sc:CompleteProcedure()
		end
	end
	--Cards in your Pendulum Zone cannot be destroyed by card effects for the rest of this turn
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_PZONE,0)
	e1:SetValue(1)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,2))
	--You cannot Special Summon, except WIND monsters, for the rest of this turn
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetDescription(aux.Stringid(id,3))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(function(e,c) return not c:IsAttribute(ATTRIBUTE_WIND) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.tgcon(e)
	local c=e:GetHandler()
	return c:IsLocation(LOCATION_EXTRA) and c:IsFaceup()
end
function s.windsynchrofilter(c)
	return c:IsAttribute(ATTRIBUTE_WIND) and c:IsType(TYPE_SYNCHRO) and c:IsFaceup()
end
function s.tgfilter(c)
	return c:IsSetCard(SET_SPEEDROID) and c:IsSpellTrap() and c:IsAbleToGrave()
end
function s.tgtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local g=Duel.GetMatchingGroup(s.windsynchrofilter,tp,LOCATION_MZONE,0,nil)
		return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_DECK,0,1,nil)
			and g:GetBinClassCount(Card.GetRace)>=2
	end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.tgfilter,tp,LOCATION_DECK,0,1,1,nil)
	if #g>0 then
		Duel.SendtoGrave(g,REASON_EFFECT)
	end
end