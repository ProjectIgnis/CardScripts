--融合失敗
--Mispolymerization
local s,id=GetID()
function s.initial_effect(c)
	--When a Fusion Monster is Special Summoned: Return all Fusion Monsters on the field to the Extra Deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOEXTRA)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(aux.FaceupFilter(Card.IsFusionMonster),1,nil)
end
function s.rtexfilter(c)
	return c:IsFusionMonster() and c:IsFaceup() and c:IsAbleToExtra()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.rtexfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.rtexfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TODECK,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.rtexfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.SendtoDeck(g,nil,SEQ_DECKTOP,REASON_EFFECT)
	end
end