--ネクメイド・キャリッジ
--Necromaid Carriage
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send the top card of your Deck to the GY and special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeck(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(Duel.GetDeckbottomGroup(tp,1),REASON_EFFECT)
	local ct=Duel.GetOperatedGroup():GetFirst()
	if ct and ct:IsRace(RACE_ZOMBIE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and ct:IsCanBeSpecialSummoned(e,0,tp,false,false) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		if Duel.SpecialSummon(ct,0,tp,tp,false,false,POS_FACEUP) then
			--Cannot activate the effect of "Necromaid Carriage"
			local e2=Effect.CreateEffect(e:GetHandler())
			e2:SetDescription(aux.Stringid(id,2))
			e2:SetType(EFFECT_TYPE_FIELD)
			e2:SetCode(EFFECT_CANNOT_ACTIVATE)
			e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
			e2:SetTargetRange(1,0)
			e2:SetValue(s.aclimit)
			e2:SetReset(RESET_PHASE|PHASE_END)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsCode(id)
end