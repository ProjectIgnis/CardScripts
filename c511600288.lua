--クロス・リンケージ・ハック
--Cross Linkage Hack
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.lfilter(c)
	return c:IsFaceup() and c:IsLinkMonster()
end
function s.cfilter(c,lg)
	return (c:IsFacedown() or not c:IsLinkMonster()) and lg:IsContains(c)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local lg=Group.CreateGroup()
	Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil):ForEach(function(lc) lg=lg+lc:GetLinkedGroup() end)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,lg)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,2)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end