--ピュアリィ・ハッピーメモリー
--Purery Happy Memory
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Targeted card cannot be destroyed by effects, discard 1 card and Special Summon 1 "Purery" monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetHintTiming(TIMING_MAIN_END)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Grants extra attacks to "Purery" Xyz monster with this card as material
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_XMATERIAL)
	e2:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e2:SetCondition(function(e) return e:GetHandler():IsSetCard(0x289) end)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
s.listed_names={id}
s.listed_series={0x289}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,e:GetHandler()) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x289) and c:IsLevel(1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELECT)
	local tc=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,e:GetHandler()):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	--Cannot be destroyed by effects once
	local extraproperty=tc:IsPosition(POS_FACEDOWN) and EFFECT_FLAG_SET_AVAILABLE or 0
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(3001)
	e1:SetProperty(EFFECT_FLAG_CLIENT_HINT+EFFECT_FLAG_NO_TURN_RESET+extraproperty)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_COUNT)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,2)
	e1:SetCountLimit(1)
	e1:SetValue(function(e,re,r,rp) return r&REASON_EFFECT>0 end)
	tc:RegisterEffect(e1)
	--Discard 1 card and Special Summon 1 "Purery" monster from the Deck
	if Duel.IsExistingMatchingCard(Card.IsDiscardable,tp,LOCATION_HAND,0,1,nil) 
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		if Duel.DiscardHand(tp,Card.IsDiscardable,1,1,REASON_EFFECT+REASON_DISCARD,nil)>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
			if #g>0 then
				Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
			end
		end
	end
end
function s.value(e)
	return e:GetHandler():GetOverlayGroup():FilterCount(Card.IsCode,nil,id)
end