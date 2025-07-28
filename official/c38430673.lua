--グランドクロス
--Grand Convergence
local s,id=GetID()
function s.initial_effect(c)
	--Inflict 300 damage to your opponent, and if you do, destroy all monsters on the field (if any)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(function(e,tp) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_MACRO_COSMOS),tp,LOCATION_ONFIELD,0,1,nil) end)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMING_BATTLE_START|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_MACRO_COSMOS}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,300)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,tp,LOCATION_MZONE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Damage(1-tp,300,REASON_EFFECT)==0 then return end
	local g=Duel.GetMatchingGroup(nil,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end