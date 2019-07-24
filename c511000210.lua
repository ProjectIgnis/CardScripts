--Obligatory Summon
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c,race)
	return c:IsFaceup() and c:IsRace(race)
end
function s.spfilter(c,e,tp)
	return c:IsCanBeSpecialSummoned(e,0,1-tp,false,false,POS_FACEUP) 
		and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0 and Duel.IsPlayerCanSpecialSummon(1-tp) 
		and Duel.IsExistingMatchingCard(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
		and Duel.IsExistingMatchingCard(Card.IsCanBeSpecialSummoned,tp,0,LOCATION_DECK,1,nil,e,0,1-tp,false,false,POS_FACEUP) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,1-tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	if ft<=0 then return end
	if Duel.IsPlayerAffectedByEffect(1-tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	local sg=Duel.SelectMatchingCard(1-tp,s.spfilter,1-tp,LOCATION_DECK,0,ft,ft,nil,e,tp)
	if #sg>0 and Duel.SpecialSummon(sg,0,1-tp,1-tp,false,false,POS_FACEUP)>0 then
		local tc=sg:GetFirst()
		while tc do
			tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			tc=sg:GetNext()
		end
		sg:KeepAlive()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAINING)
		e1:SetLabelObject(sg)
		e1:SetCondition(s.discon)
		e1:SetOperation(s.disop)
		Duel.RegisterEffect(e1,tp)
	end
end
function s.disfilter(c)
	return c:GetFlagEffect(id)>0
end
function s.discon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.disfilter,1,nil) then
		g:DeleteGroup()
		e:Reset()
		return false
	end
	return g:IsContains(re:GetHandler()) and re:GetCode()==EVENT_SPSUMMON_SUCCESS and Duel.IsChainDisablable(ev)
end
function s.disop(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
