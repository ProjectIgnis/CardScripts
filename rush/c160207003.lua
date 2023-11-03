--超魔軌道マグナム・オーバーロード [R]
--Supreme Fullsteam Magnum Overlord [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--inflict 500 damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
s.MaximumSide="Right"
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(500)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)==0 then return end
	local og=Duel.GetOperatedGroup():GetFirst()
	-- Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
	if e:GetHandler():IsMaximumMode() and og:GetLevel()>0 then
		Duel.Damage(1-tp,og:GetLevel()*100,REASON_EFFECT)
	end
end