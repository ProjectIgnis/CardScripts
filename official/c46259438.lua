--契約洗浄
--Contract Laundering
local s,id=GetID()
function s.initial_effect(c)
	--Destroy as many "Dark Contract" cards in your Spell & Trap Zone as possible, and if you do, draw the same number of cards you destroyed, then gain 1000 LP for each card you drew with this effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARK_CONTRACT}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_DARK_CONTRACT),tp,LOCATION_STZONE,0,1,nil)
		and Duel.IsPlayerCanDraw(tp,1) end
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DARK_CONTRACT),tp,LOCATION_STZONE,0,nil)
	local dark_contract_count=#g
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,dark_contract_count,tp,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,dark_contract_count)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,dark_contract_count*1000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsSetCard,SET_DARK_CONTRACT),tp,LOCATION_STZONE,0,nil)
	if #g==0 then return end
	local destroy_count=Duel.Destroy(g,REASON_EFFECT)
	if destroy_count>0 then
		local draw_count=Duel.Draw(tp,destroy_count,REASON_EFFECT)
		if draw_count>0 then
			Duel.BreakEffect()
			Duel.Recover(tp,draw_count*1000,REASON_EFFECT)
		end
	end
end