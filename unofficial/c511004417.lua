--Acrobat Tower
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,Card.IsSetCard,1,false,nil,nil,0x9f) end
	local g=Duel.SelectReleaseGroupCost(tp,Card.IsSetCard,1,1,false,nil,nil,0x9f)
	Duel.Release(g,REASON_COST)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) and Duel.IsPlayerCanDraw(1-tp,2) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,0,0,PLAYER_ALL,2)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.IsPlayerCanDraw(tp,2) or not Duel.IsPlayerCanDraw(1-tp,2) then return end
	local g1=Group.CreateGroup()
	local g2=Group.CreateGroup()
	local lose1=false
	local lose2=false
	while not (g1:IsExists(Card.IsType,1,nil,TYPE_MONSTER) or lose1) 
		or not (g2:IsExists(Card.IsType,1,nil,TYPE_MONSTER) or lose2) do
		local s1=Duel.GetDecktopGroup(tp,2)
		local s2=Duel.GetDecktopGroup(1-tp,2)
		if not (g1:IsExists(Card.IsType,1,nil,TYPE_MONSTER) or lose1) then
			g1:Merge(s1)
			if #s1<=1 then lose1=true end
			Duel.Draw(tp,2,REASON_EFFECT)
		end
		if not (g2:IsExists(Card.IsType,1,nil,TYPE_MONSTER) or lose2) then
			g2:Merge(s2)
			if #s2<=1 then lose2=true end
			Duel.Draw(1-tp,2,REASON_EFFECT)
		end
	end
	Duel.ConfirmCards(1-tp,g1)
	Duel.ConfirmCards(tp,g2)
	if lose1 or lose2 then return end
	Duel.SendtoGrave(g1,REASON_EFFECT)
	Duel.SendtoGrave(g2,REASON_EFFECT)
	local lv1=0
	local lv2=0
	local dam=Duel.GetMatchingGroupCount(Card.IsType,tp,LOCATION_MZONE+LOCATION_GRAVE,LOCATION_MZONE+LOCATION_GRAVE,nil,TYPE_MONSTER)*200
	local tc1=g1:GetFirst()
	while tc1 do
		if tc1:IsType(TYPE_MONSTER) then
			lv1=lv1+tc1:GetLevel()
		end
		tc1=g1:GetNext()
	end
	local tc2=g2:GetFirst()
	while tc2 do
		if tc2:IsType(TYPE_MONSTER) then
			lv2=lv2+tc2:GetLevel()
		end
		tc2=g2:GetNext()
	end
	if lv1>=lv2 then
		Duel.Damage(tp,dam,REASON_EFFECT)
	else
		Duel.Damage(1-tp,dam,REASON_EFFECT)
	end
end
