--陽炎殿の君主
--Queen of the Blazing Domain
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Cannot be destroyed by effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	--Destroy up to 2 cards you control, including a face-up Spell/Trap card, and if you, Special Summon this card from hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_HAND)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
end
function s.rescon(sg,e,tp,mg)
	return sg:IsExists(aux.FaceupFilter(Card.IsSpellTrap),1,nil) and Duel.GetMZoneCount(tp,sg)>0
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsCanBeEffectTarget,tp,LOCATION_ONFIELD,0,nil,e)
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false)
		and aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,0,tp) end
	local tg=aux.SelectUnselectGroup(g,e,tp,1,2,s.rescon,1,tp,HINTMSG_DESTROY,s.rescon)
	Duel.SetTargetCard(tg)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tg,#tg,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetTargetCards(e)
	if #tg==0 then return end
	local ct=Duel.Destroy(tg,REASON_EFFECT)
	if ct==0 then return end
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and Duel.SpecialSummonStep(c,0,tp,tp,false,false,POS_FACEUP) then
		if ct==1 then
			--Return this card to the hand during the End Phase of the next turn
			local turn_ct=Duel.GetTurnCount()
			aux.DelayedOperation(c,PHASE_END,id,e,tp,
				function(tc) Duel.SendtoHand(tc,nil,REASON_EFFECT) end,
				function(tc) return Duel.GetTurnCount()==turn_ct+1 end,
			nil,2,aux.Stringid(id,1))
		elseif ct==2 then
			--Any monster sent from the field to the opponent's GY is banished instead
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,2))
			e1:SetType(EFFECT_TYPE_FIELD)
			e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
			e1:SetCode(EFFECT_TO_GRAVE_REDIRECT)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
			e1:SetTarget(function(e,c) local tp=e:GetHandlerPlayer() return not c:IsOwner(tp) and Duel.IsPlayerCanRemove(tp,c) end)
			e1:SetValue(LOCATION_REMOVED)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD)
			c:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end