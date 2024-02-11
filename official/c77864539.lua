--機皇廠
--Meklord Factory
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 "Meklord Army" monster to the hand and destroy 1 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_DESTROY)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_MEKLORD,SET_MEKLORD_ARMY}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	return d:IsFaceup() and d:IsSetCard(SET_MEKLORD)
end
function s.filter(c)
	return c:IsSetCard(SET_MEKLORD_ARMY) and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.filter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_GRAVE,0,1,1,nil)
	local d=Duel.GetAttackTarget()
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,d,1,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,tc)
		local d=Duel.GetAttackTarget()
		if d:IsRelateToBattle() then
			Duel.Destroy(d,REASON_EFFECT)
		end
	end
end