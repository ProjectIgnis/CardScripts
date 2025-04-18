--CNo.106 溶岩掌ジャイアント・ハンド・レッド
--Number C106: Giant Red Hand
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon Procedure
	Xyz.AddProcedure(c,nil,5,3)
	--Negate the effects of all face-up cards on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_NEGATE)
	e1:SetType(EFFECT_TYPE_QUICK_F)
	e1:SetCode(EVENT_CHAINING)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.negcon)
	e1:SetOperation(s.negop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NUMBER}
s.xyz_number=106
function s.negcon(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc&LOCATION_ONFIELD)~=0 and not e:GetHandler():IsStatus(STATUS_CHAINING)
		and e:GetHandler():GetOverlayGroup():IsExists(Card.IsSetCard,1,nil,SET_NUMBER)
end
function s.negop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or Duel.GetCurrentChain()~=ev+1 or c:RemoveOverlayCard(tp,1,1,REASON_EFFECT)<1 then return end
	local g=Duel.GetMatchingGroup(Card.IsNegatable,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,c)
	g:ForEach(function(tc) tc:NegateEffects(c,RESET_PHASE|PHASE_END,true) end)
end