--ネクメイド・ルーカー
--Necromaid Lurker
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--Name becomes "Necromaid Nana" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160406003)
	c:RegisterEffect(e0)
	--Destroy 1 card on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY|CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsMonster() and (c:IsRitualMonster() or c:IsRace(RACE_ZOMBIE)) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(cg,e,tp,1,3,s.rescon,0) end
end
function s.rescon(sg,e,tp,mg)
	return (#sg==1 and sg:IsExists(Card.IsRitualMonster,1,nil,id)) or sg:IsExists(Card.IsRace,3,nil,RACE_ZOMBIE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
	if chk==0 then return #dg>0 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local cg=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_GRAVE,0,nil)
	local g=aux.SelectUnselectGroup(cg,e,tp,1,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(g)
	if Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	local dg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,0,LOCATION_ONFIELD,nil)
	if #dg>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local sg=dg:Select(tp,1,1,nil)
		local sg2=sg:AddMaximumCheck()
		Duel.HintSelection(sg2)
		if Duel.Destroy(sg,REASON_EFFECT)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.BreakEffect()
			Duel.Damage(1-tp,700,REASON_EFFECT)
		end
	end
end