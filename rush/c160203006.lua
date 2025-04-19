--大恐竜駕ダイナーミクス
--Dynamic Dino Dynamix
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	--Destroy 2 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(s.descost)
	e1:SetCondition(s.descon)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=3400
function s.filter1(c)
	return c:IsCode(160203005)
end
function s.filter2(c)
	return c:IsCode(160203007)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.descost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.descon(e)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsLevelAbove,9),e:GetHandler():GetControler(),0,LOCATION_MZONE,nil)
	return e:GetHandler():IsMaximumMode() and #g==0
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,LOCATION_MZONE)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local c=e:GetHandler()
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)~=0 then
		local g=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			local sg=g:Select(tp,1,2,nil)
			Duel.HintSelection(sg)
			sg=sg:AddMaximumCheck()
			Duel.Destroy(sg,REASON_EFFECT)
		end
	end
end