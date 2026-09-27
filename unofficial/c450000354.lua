--磁石の虹色獣
--Magnet Chameleon
local s,id=GetID()
function s.initial_effect(c)
	--If there is another face-up Attack Position monster on the field with the same name as this card: You can negate the effects of 1 face-up monster your opponent controls.
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c,code)
	return c:IsAttackPos() and c:IsCode(code)
end
function s.condition(e,tp,eg,ev,ep,re,r,rp)
	local code=e:GetHandler():GetCode()
	return Duel.IsExistMatchingCard(s.cfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil,1,code) 
end
function s.target(e,tp,eg,ev,ep,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,0)
end
function s.operation(e,tp,eg,ev,ep,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(Card.IsNegatableMonster,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local tc=Duel.SelectMatchingCard(tp,Card.IsNegatableMonster,tp,0,LOCATION_MZONE,1,1,nil):GetFirst()
	if tc and tc:IsFaceup() then
		tc:NegateEffects(c)
	end
end
