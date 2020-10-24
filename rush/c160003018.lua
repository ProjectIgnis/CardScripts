--獣翼剛王セイス
--Seis the Mighty King of Bestial Wings
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- atk/def change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(aux.TRUE,tp,LOCATION_SZONE,0,nil)==Duel.GetMatchingGroupCount(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_SZONE,0,1,nil) end
end
function s.tgfilter(c)
	return c:GetAttack()>0 or c:GetDefense()>0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(s.tgfilter),tp,0,LOCATION_MZONE,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--requirement
	local tg=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_SZONE,0,1,3,nil)
	local sent=Duel.SendtoGrave(tg,nil,REASON_COST)
	if sent>0 then
		--effect
		if c:IsRelateToEffect(e) and c:IsFaceup() then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local g=Duel.SelectMatchingCard(tp,aux.FilterFaceupFunction(s.tgfilter),tp,0,LOCATION_MZONE,1,1,nil)
			if #g>0 then
				Duel.HintSelection(g)
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_ATTACK)
				e1:SetValue(-1000*sent)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				g:GetFirst():RegisterEffect(e1)
				local e2=e1:Clone()
				e2:SetCode(EFFECT_UPDATE_DEFENSE)
				g:GetFirst():RegisterEffect(e2)
			end
		end
	end
end
