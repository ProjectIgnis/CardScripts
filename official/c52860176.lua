--憑依するブラッド・ソウル
--Possessed Dark Soul
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute this face-up card; take control of all face-up Level 3 or lower monsters your opponent currently controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCost(Cost.SelfTribute)
	e1:SetTarget(s.controltg)
	e1:SetOperation(s.controlop)
	c:RegisterEffect(e1)
end
function s.controlfilter(c)
	return c:IsLevelBelow(3) and c:IsFaceup() and c:IsControlerCanBeChanged(true)
end
function s.controltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local ctrl_count=Duel.GetMatchingGroupCount(s.controlfilter,tp,0,LOCATION_MZONE,nil)
		return ctrl_count>0 and Duel.GetMZoneCount(tp,e:GetHandler(),tp,LOCATION_REASON_CONTROL)>=ctrl_count
	end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
end
function s.controlop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.controlfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.GetControl(g,tp)
	end
end