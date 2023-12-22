--シンクロ・クリード
--Synchro Creed
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Draw 1 card then draw 1 more if 3+ Synchro monsters are on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),0,LOCATION_MZONE,LOCATION_MZONE,1,nil) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p,ct=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	if Duel.Draw(p,ct,REASON_EFFECT)>0
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsType,TYPE_SYNCHRO),tp,LOCATION_MZONE,LOCATION_MZONE,3,nil) 
		and Duel.IsPlayerCanDraw(p,1) and Duel.SelectYesNo(p,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		Duel.Draw(p,1,REASON_EFFECT)
	end
end