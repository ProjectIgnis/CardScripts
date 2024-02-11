--カリス・マジック－エレガントチェンジ
--Charis Magic - Elegant Change
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.drcost)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.drcostfilter(c)
	return ((c:IsMonster() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_SPELLCASTER)) or c:IsEquipSpell())
		and c:IsAbleToGraveAsCost()
end
function s.drcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.drcostfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,1) end
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tc=Duel.SelectMatchingCard(tp,s.drcostfilter,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if Duel.SendtoGrave(tc,REASON_COST)==1 and Duel.Draw(tp,1,REASON_EFFECT)>0 then
		local g=Duel.GetMatchingGroup(Card.IsMonster,tp,LOCATION_GRAVE,0,nil)
		if #g>=4 then
			Duel.BreakEffect()
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end