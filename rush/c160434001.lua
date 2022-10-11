--トランザム・ライナック－ウォー・トゥ・ゼン！
--Transamu Rainac - War To Zen!
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 face-up monster your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttackBelow(1400) and c:IsAttribute(ATTRIBUTE_LIGHT)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,e:GetHandler())
end
function s.filter(c)
	return c:IsMonster() and c:IsFaceup() and c:IsAttackBelow(1500) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local dg=Duel.GetMatchingGroup(s.filter,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		sg=sg:AddMaximumCheck()
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end
