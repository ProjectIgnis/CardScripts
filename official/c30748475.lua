--魔砲戦機ダルマ・カルマ
--Destructive Daruma Karma Cannon
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_POSITION,g,#g,0,0)
	local tg=Duel.GetMatchingGroup(aux.NOT(Card.IsCanTurnSet),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #tg>0 then
		Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,tg,#tg,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsCanTurnSet,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 and Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE)>0 then
		local turn_p=Duel.GetTurnPlayer()
		local g1=Duel.GetMatchingGroup(Card.IsFaceup,turn_p,LOCATION_MZONE,0,nil)
		local g2=Duel.GetMatchingGroup(Card.IsFaceup,turn_p,0,LOCATION_MZONE,nil)
		if #g1==0 and #g2==0 then return end
		Duel.BreakEffect()
		if #g1>0 then
			Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,turn_p)
		end
		if #g2>0 then
			Duel.SendtoGrave(g2,REASON_RULE,PLAYER_NONE,1-turn_p)
		end
	end
end