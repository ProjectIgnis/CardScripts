-- 荒廃の蟠竜
-- Coiled Dragon of Destruction
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Inflict damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.damcost)
	e1:SetTarget(s.damtg)
	e1:SetOperation(s.damop)
	c:RegisterEffect(e1)
end
function s.damcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_FZONE,0,1,nil) end
end
function s.damtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(600)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,600)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	-- Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local cg=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsAbleToDeckOrExtraAsCost),tp,LOCATION_FZONE,0,1,1,nil)
	if #cg<1 then return end
	Duel.HintSelection(cg,true)
	if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_COST)>0 then
		-- Effect
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
