--死霊導師デスクレジットメイジ
--Disgraced Mage
local s,id=GetID()
function s.initial_effect(c)
	--to deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_BATTLE_DESTROY_REDIRECT)
	e1:SetValue(LOCATION_DECKSHF)
	c:RegisterEffect(e1)
	--no damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
	e2:SetCondition(s.damcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	--Destroy replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DESTROY_REPLACE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTarget(s.desreptg)
	c:RegisterEffect(e3)
end
function s.damcon(e)
	return e:GetHandler()==Duel.GetAttackTarget()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if chk==0 then return c:IsReason(REASON_BATTLE) and c:IsFaceup() and #g>0 end
	if Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		return true
	else return false end
end