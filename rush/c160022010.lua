--号令のナリキング・レックス
--Commanding Ritzy King Rex
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "Ritzy King Rex" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160203010)
	c:RegisterEffect(e0)
	--Destroy 1 face up monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DRAW)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_UPSTART_GOBLIN}
function s.filter(c)
	return c:IsMonster() and not c:IsRace(RACE_DINOSAUR)
end
function s.cfilter(c)
	return (c:IsMonster() and c:IsLegend()) or c:IsCode(CARD_UPSTART_GOBLIN)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,1,nil)
		and not Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_MZONE,nil)
	if #dg>0 then
		local sg=dg:Select(tp,1,1,nil)
		local sg2=sg:AddMaximumCheck()
		Duel.HintSelection(sg2)
		if Duel.Destroy(sg,REASON_EFFECT)>0 
			and Duel.IsPlayerCanDraw(tp,1) 
			and Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_GRAVE,0,1,nil,CARD_UPSTART_GOBLIN) 
			and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end