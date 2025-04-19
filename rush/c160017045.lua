--リリースレイヤー
--Sevens Road Ultima Witch
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Procedure
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,160401001,1,s.ffilter,1)
	--Shuffle to Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TODECK+CATEGORY_TOHAND)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	Duel.AddCustomActivityCounter(id,ACTIVITY_CHAIN,s.chainfilter)
end
s.named_material={160401001}
function s.chainfilter(re,tp,cid)
	if Duel.GetFlagEffect(tp,id)==0 then return true end
	return not re:GetHandler():IsNormalSpell()
end
function s.ffilter(c,fc,sumtype,tp)
	return c:IsType(TYPE_FUSION,scard,sumtype,tp) and c:IsRace(RACE_SPELLCASTER|RACE_MAGICALKNIGHT,scard,sumtype,tp)
end
function s.tdfilter(c)
	return c:IsSpell() and c:IsAbleToDeck()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tdfilter,tp,0,LOCATION_GRAVE,1,nil) end
end
function s.thfilter(c)
	return c:IsSpell() and c:IsAbleToHand()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.tdfilter,tp,0,LOCATION_GRAVE,1,1,nil)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 then
		if Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,e:GetHandler()) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,e:GetHandler())
			if #g>0 then
				Duel.SendtoHand(g,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,g)
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(aux.Stringid(id,2))
				e1:SetType(EFFECT_TYPE_FIELD)
				e1:SetCode(EFFECT_CANNOT_ACTIVATE)
				e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
				e1:SetTargetRange(1,0)
				e1:SetCondition(s.accon)
				e1:SetValue(s.aclimit)
				e1:SetReset(RESET_PHASE|PHASE_END)
				Duel.RegisterEffect(e1,tp)
				Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,2)
			end
		end
	end
end
function s.accon(e)
	return Duel.GetCustomActivityCount(id,e:GetHandlerPlayer(),ACTIVITY_CHAIN)>0
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsNormalSpell()
end
