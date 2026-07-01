--封魔一閃
--Flash of the Forbidden Spell
local s,id=GetID()
function s.initial_effect(c)
	--If your opponent controls monsters in all of their Main Monster Zones: Destroy all monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
local TOTAL_MMZ_COUNT=Duel.IsDuelType(DUEL_3_COLUMNS_FIELD) and 3 or 5
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCount(nil,tp,0,LOCATION_MMZONE,nil)==TOTAL_MMZ_COUNT
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	if #g>0 then
		Duel.Destroy(g,REASON_EFFECT)
	end
end