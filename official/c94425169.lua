--エレメントの泉
--Spring of Rebirth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Gain 500 LP everytime a monster on the field returns to the hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.condition)
	e2:SetTarget(s.target)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsPreviousLocation(LOCATION_MZONE) and c:IsMonster()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.filter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Recover(tp,500,REASON_EFFECT)
end