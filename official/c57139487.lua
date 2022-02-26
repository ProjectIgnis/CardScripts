--連鎖除外
--Chain Disappearance
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e2)
	local e3=e1:Clone()
	e3:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3)
end
function s.filter(c)
	return c:IsLocation(LOCATION_MZONE) and c:IsFaceup() and c:GetAttack()<=1000 and c:IsAbleToRemove()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return eg:IsExists(s.filter,1,nil) end
	local g=eg:Filter(s.filter,nil)
	Duel.SetTargetCard(g)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function s.efilter(c,e)
	return c:IsFaceup() and c:IsAttackBelow(1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetTargetCards(e):Filter(s.efilter,nil)
	if #sg==0 or Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)==0 then return end
	local rg=Group.CreateGroup()
	for tc in sg:Iter() do
		if tc:IsLocation(LOCATION_REMOVED) then
			local tpe=tc:GetType()
			if (tpe&TYPE_TOKEN)==0 then
				rg:Merge(Duel.GetMatchingGroup(Card.IsCode,tp,0,LOCATION_DECK+LOCATION_HAND,nil,tc:GetCode()))
			end
		end
	end
	if #rg>0 then
		Duel.BreakEffect()
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end