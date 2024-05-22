--インフェルニティ・クイーン
--Infernity Queen
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Make 1 DARK monster you control able to attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function(e,tp) return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)==0 and Duel.IsAbleToEnterBP() end)
	e1:SetCost(s.diratkcost)
	e1:SetTarget(s.diratktg)
	e1:SetOperation(s.diratkop)
	c:RegisterEffect(e1)
end
function s.diratkcostfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.diratkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.diratkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,s.diratkcostfilter,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.diratktgfilter(c)
	return c:IsAttribute(ATTRIBUTE_DARK) and c:IsFaceup() and not c:IsHasEffect(EFFECT_DIRECT_ATTACK)
end
function s.diratktg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_MZONE) and s.diratktgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.diratktgfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	Duel.SelectTarget(tp,s.diratktgfilter,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.diratkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		--It can attack directly this turn
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3205)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_DIRECT_ATTACK)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
end