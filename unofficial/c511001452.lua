--メダリオン・カタストロフィー
--Heraldry Catastrophe
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(1-tp) and chkc:IsFaceup() and chkc:IsOwner(tp) end
	if chk==0 then return Duel.IsExistingTarget(aux.FaceupFilter(Card.IsOwner,tp),tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,aux.FaceupFilter(Card.IsOwner,tp),tp,0,LOCATION_MZONE,1,1,nil,tp)
	local dg=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,g:GetFirst():GetAttack()),tp,0,LOCATION_MZONE,nil)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,dg,#dg,tp,LOCATION_MZONE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
		e1:SetCode(EVENT_TURN_END)
		e1:SetCountLimit(1)
		e1:SetOperation(s.desop)
		e1:SetLabelObject(tc)
		Duel.RegisterEffect(e1,tp)
		tc:CreateEffectRelation(e1)
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsAttackBelow,tc:GetAttack()),tp,0,LOCATION_MZONE,nil)
	if tc:IsRelateToEffect(e) and tc:IsControler(1-tp) and tc:IsOnField() and #g>0 then
		if Duel.Destroy(g,REASON_EFFECT)>0 then
			Duel.BreakEffect()
			local dg=Duel.GetOperatedGroup()
			local dam=dg:GetSum(Card.GetPreviousAttackOnField)
			Duel.Damage(1-tp,dam,REASON_EFFECT)
		end
	end
end
