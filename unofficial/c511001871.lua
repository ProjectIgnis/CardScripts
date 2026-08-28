--アマゾネスの魅了
--Amazoness Charm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(aux.AND(Card.IsDefensePos,Card.IsCanChangePosition),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	for tc in g:Iter() do
		if Duel.ChangePosition(tc,POS_FACEUP_ATTACK)>0 then
			tc:UpdateAttack(200,RESET_EVENT|RESETS_STANDARD,c)
		end
	end
end
